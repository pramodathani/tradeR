ORDERS_CHASER_SYNTHETIC_TYPE <- "chaser"

#' A limit order that starts on its own side of the book and steps towards the other until it fills
#'
#' @description
#' It saves the spread when the market is patient and still fills when it is not. After `cross_after_seconds` it crosses the spread outright, and it never goes past `cap_price`. It is never moved backwards, even when the book lags behind it, and `cross_after_seconds` is counted from the first tick after it rests.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- ChaserOrder$new(
#'   share,
#'   transaction_type = "sell",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 75,
#'   price = 120.0,
#'   cap_price = 115.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
ChaserOrder <- R6::R6Class(
  "ChaserOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_CHASER_SYNTHETIC_TYPE,
    #' @field step_ticks The integer number of ticks per step, or `NULL` to let UBI use 1.
    step_ticks = NULL,
    #' @field step_seconds The numeric number of seconds between steps, or `NULL` to let UBI use 5.
    step_seconds = NULL,
    #' @field cap_price The numeric worst price in rupees it will take, or `NULL`.
    cap_price = NULL,
    #' @field cross_after_seconds The numeric number of seconds after which it crosses the spread, or `NULL` never to cross.
    cross_after_seconds = NULL,

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
    #' @param step_ticks The integer number of ticks per step, or `NULL` to let UBI use 1.
    #' @param step_seconds The numeric number of seconds between steps, or `NULL` to let UBI use 5.
    #' @param cap_price The numeric worst price in rupees it will take, or `NULL`.
    #' @param cross_after_seconds The numeric number of seconds after which it crosses the spread, or `NULL` never to cross.
    #' @return A new `ChaserOrder` object.
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
      step_ticks = NULL,
      step_seconds = NULL,
      cap_price = NULL,
      cross_after_seconds = NULL
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
      self$step_ticks <- step_ticks
      self$step_seconds <- step_seconds
      self$cap_price <- cap_price
      self$cross_after_seconds <- cross_after_seconds
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- ChaserOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   step_ticks = 2,
    #'   step_seconds = 3,
    #'   cap_price = 13.2
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- ChaserOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 14.0
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        step_ticks = self$step_ticks,
        step_seconds = self$step_seconds,
        cap_price = self$cap_price,
        cross_after_seconds = self$cross_after_seconds
      )
    }
  )
)
