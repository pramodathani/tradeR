ORDERS_GOOD_TILL_TIME_SYNTHETIC_TYPE <- "good_till_time"

#' An order placed now whose unfilled part is cancelled at a time of day
#'
#' @description
#' Indian exchanges offer only `day` and `ioc` validity, with nothing in between, so this fills that gap: whatever has filled by `until_time` is kept, and the rest is cancelled. With `at_expiry` set to `market`, the rest is instead made marketable at `until_time`, as a limit two ticks past the other side's best price, and the order carries on until it fills. Times follow the instrument's exchange trading calendar: on a weekend or an exchange holiday a time means that time on the next trading day. By default UBI holds a limit order in its virtual order book until the other side of the book reaches its price, and one still held at `until_time` is never sent; it is not held when `hold_limits` is `FALSE` or `at_expiry` is `market`.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- GoodTillTimeOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 100,
#'   price = 995.0,
#'   until_time = "14:30",
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
GoodTillTimeOrder <- R6::R6Class(
  "GoodTillTimeOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_GOOD_TILL_TIME_SYNTHETIC_TYPE,
    #' @field until_time The character time of day to cancel what has not filled, as `HH:MM` or `HH:MM:SS` India time, later on the trading day.
    until_time = NULL,
    #' @field at_expiry The character action at `until_time`, `cancel` to cancel whatever has not filled or `market` to modify it to a limit two ticks past the other side's best price so it takes what is there, or `NULL` to let UBI use `cancel`.
    at_expiry = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param until_time The character time of day to cancel what has not filled, as `HH:MM` or `HH:MM:SS` India time, later on the trading day.
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
    #' @param at_expiry The character action at `until_time`, `cancel` to cancel whatever has not filled or `market` to modify it to a limit two ticks past the other side's best price so it takes what is there, or `NULL` to let UBI use `cancel`.
    #' @return A new `GoodTillTimeOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      until_time,
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
      at_expiry = NULL
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
      self$until_time <- until_time
      self$at_expiry <- at_expiry
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- GoodTillTimeOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   until_time = "14:00"
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- GoodTillTimeOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 14.0,
    #'   until_time = "15:10",
    #'   at_expiry = "market"
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        until_time = self$until_time,
        at_expiry = self$at_expiry
      )
    }
  )
)
