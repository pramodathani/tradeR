ORDERS_TWO_SIDED_QUOTE_SYNTHETIC_TYPE <- "two_sided_quote"

#' A bid and an offer kept around the fair price, leaning away from the inventory they build
#'
#' @description
#' This is the Atlas's G16, a market-making pair. Every second, UBI moves the bid to `half_spread_points` below the fair price and the offer the same distance above, the fair price being the midpoint unless `fair_price` says `last`. For each order's worth held, both quotes move `skew_ticks` against the position, a quote is modified only once it would move at least `step_ticks`, and once the net position reaches `most_inventory` the side that would add to it is cancelled until the position comes back. The cap is checked before each re-quote, so a full-size quote can take the position past it by up to one quote less one unit. The template's `quantity` is the size of each quote and must be given, because UBI refuses a `quantity_reference` with HTTP 400. A side whose last order the broker rejected is not quoted again, so a refusal such as a margin shortfall is not repeated every second. Every move of the fair price by a step is two modifications, each counting towards the broker's daily order messages, so keep `step_ticks` as wide as the strategy allows. The order does not finish on its own, so cancel it with `cancel()` when you are done.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- TwoSidedQuoteOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   half_spread_points = 1.0,
#'   most_inventory = 50,
#'   skew_ticks = 2,
#'   step_ticks = 2,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
TwoSidedQuoteOrder <- R6::R6Class(
  "TwoSidedQuoteOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_TWO_SIDED_QUOTE_SYNTHETIC_TYPE,
    #' @field half_spread_points The numeric distance in rupees each quote sits from the fair price. Above zero.
    half_spread_points = NULL,
    #' @field most_inventory The integer largest net position in underlying units the quotes may build, at least 1.
    most_inventory = NULL,
    #' @field skew_ticks The integer number of ticks both quotes move against the position for each order's worth held, at or above zero, or `NULL` to let UBI use 0.
    skew_ticks = NULL,
    #' @field step_ticks The integer smallest move in ticks worth a modification, at least 1, or `NULL` to let UBI use 1.
    step_ticks = NULL,
    #' @field fair_price The character price the quotes are kept around, `mid` or `last`, or `NULL` to let UBI use `mid`.
    fair_price = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer size of each quote in underlying units, not lots; UBI refuses the order with HTTP 400 when it is `NULL`.
    #' @param half_spread_points The numeric distance in rupees each quote sits from the fair price. Above zero.
    #' @param most_inventory The integer largest net position in underlying units the quotes may build, at least 1.
    #' @param price The numeric limit price in rupees, or `NULL` for an order type that takes no price or when a price reference supplies it.
    #' @param trigger_price The numeric trigger price in rupees of the order itself, or `NULL` for an order type that takes no trigger.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param disclosed_quantity The integer quantity to show on the exchange, or `NULL` to disclose the whole order.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param price_reference A named list describing the price for UBI to work out, such as `list(kind = "mid")`, or `NULL`.
    #' @param quantity_reference A named list describing the quantity for UBI to work out, which UBI refuses for this type with HTTP 400, so leave it `NULL`.
    #' @param closes_position A logical that is `TRUE` when every order this type sends closes a position, so it may use the share of a broker's daily order cap kept for exits.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI check the order and answer with the `plan` it would run, without recording or sending anything; the answer's `request` is the template as a broker would receive it, which for a stop is not the stop.
    #' @param skew_ticks The integer number of ticks both quotes move against the position for each order's worth held, at or above zero, or `NULL` to let UBI use 0.
    #' @param step_ticks The integer smallest move in ticks worth a modification, at least 1, or `NULL` to let UBI use 1.
    #' @param fair_price The character price the quotes are kept around, `mid` or `last`, or `NULL` to let UBI use `mid`.
    #' @return A new `TwoSidedQuoteOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      half_spread_points,
      most_inventory,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      price_reference = NULL,
      quantity_reference = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE,
      skew_ticks = NULL,
      step_ticks = NULL,
      fair_price = NULL
    ) {
      super$initialize(
        instrument,
        transaction_type = transaction_type,
        product = product,
        order_type = order_type,
        quantity = quantity,
        price = price,
        trigger_price = trigger_price,
        validity = validity,
        disclosed_quantity = disclosed_quantity,
        after_market = after_market,
        tag = tag,
        price_reference = price_reference,
        quantity_reference = quantity_reference,
        closes_position = closes_position,
        reduce_only = reduce_only,
        hold_limits = hold_limits,
        dry_run = dry_run
      )
      self$half_spread_points <- half_spread_points
      self$most_inventory <- most_inventory
      self$skew_ticks <- skew_ticks
      self$step_ticks <- step_ticks
      self$fair_price <- fair_price
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        half_spread_points = self$half_spread_points,
        most_inventory = self$most_inventory,
        skew_ticks = self$skew_ticks,
        step_ticks = self$step_ticks,
        fair_price = self$fair_price
      )
    }
  )
)
