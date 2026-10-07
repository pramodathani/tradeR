ORDERS_PEG_SYNTHETIC_TYPE <- "peg"

#' A limit order kept re-priced to the bid, the offer or the midpoint as the book moves
#'
#' @description
#' Every re-price is a real modification that counts against the broker's order limits, so UBI throttles them and never sends one that changes nothing. A modification that changes the price loses the order's place in the queue. The template's own price is not used: UBI places the order where the reference is, sends a `market` template as a limit there, and with no price for the reference yet answers HTTP 202 with an `outcome` of `armed` and places it on the first tick that has one. `cap_price` must be a whole number of ticks, or UBI refuses the order with HTTP 400.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- PegOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   reference = "mid",
#'   cap_price = 1005.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
PegOrder <- R6::R6Class(
  "PegOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_PEG_SYNTHETIC_TYPE,
    #' @field reference The character price to follow, `own_touch` for your own side's best price, `mid` or `opposite_touch`, or `NULL` to let UBI use `own_touch`.
    reference = NULL,
    #' @field offset_ticks The integer number of ticks away from filling, where a negative number moves towards the market, or `NULL` to let UBI use 0.
    offset_ticks = NULL,
    #' @field cap_price The numeric price in rupees it never goes past, or `NULL`.
    cap_price = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param price The numeric limit price in rupees, or `NULL` for an order type that takes no price or when a price reference supplies it.
    #' @param trigger_price The numeric trigger price in rupees of the order itself, or `NULL` for an order type that takes no trigger.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param disclosed_quantity The integer quantity to show on the exchange, or `NULL` to disclose the whole order.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param price_reference A named list describing the price for UBI to work out, such as `list(kind = "mid")`, or `NULL`.
    #' @param quantity_reference A named list describing the quantity for UBI to work out, such as `list(kind = "liquidate_position")`, or `NULL`.
    #' @param closes_position A logical that is `TRUE` when every order this type sends closes a position, so it may use the share of a broker's daily order cap kept for exits.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI check the order and answer with the `plan` it would run, without recording or sending anything; the answer's `request` is the template as a broker would receive it, which for a stop is not the stop.
    #' @param reference The character price to follow, `own_touch` for your own side's best price, `mid` or `opposite_touch`, or `NULL` to let UBI use `own_touch`.
    #' @param offset_ticks The integer number of ticks away from filling, where a negative number moves towards the market, or `NULL` to let UBI use 0.
    #' @param cap_price The numeric price in rupees it never goes past, or `NULL`.
    #' @return A new `PegOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
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
      reference = NULL,
      offset_ticks = NULL,
      cap_price = NULL
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
      self$reference <- reference
      self$offset_ticks <- offset_ticks
      self$cap_price <- cap_price
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        reference = self$reference,
        offset_ticks = self$offset_ticks,
        cap_price = self$cap_price
      )
    }
  )
)
