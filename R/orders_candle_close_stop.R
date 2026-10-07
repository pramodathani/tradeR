ORDERS_CANDLE_CLOSE_STOP_SYNTHETIC_TYPE <- "candle_close_stop"

#' A hidden stop that fires only when a whole bar closes past the level
#'
#' @description
#' A brief wick through the level does not stop the position out. The bars are built from the last traded price on UBI's own ticks from the moment the order is placed, and are aligned to the clock, so one-minute bars end on the minute and the first decision can come seconds after placing. The exit is a limit `buffer_ticks` past the other side's best price when the bar closes, and is not moved afterwards. Everything else is as for a `HiddenStopOrder`, including the optional backstop, which makes the answer HTTP 200 with a `legs` list. Without a backstop it answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- CandleCloseStopOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 990.0,
#'   trigger_price = 990.0,
#'   bar_minutes = 15.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
CandleCloseStopOrder <- R6::R6Class(
  "CandleCloseStopOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_CANDLE_CLOSE_STOP_SYNTHETIC_TYPE,
    #' @field trigger_level The numeric hidden level in rupees.
    trigger_level = NULL,
    #' @field bar_minutes The numeric length of each bar in minutes, or `NULL` to let UBI use 5.
    bar_minutes = NULL,
    #' @field backstop_price The numeric trigger in rupees of a real stop placed at the broker, given together with `backstop_limit_price`, or `NULL`.
    backstop_price = NULL,
    #' @field backstop_limit_price The numeric limit in rupees of that real stop, or `NULL`.
    backstop_limit_price = NULL,
    #' @field buffer_ticks The integer number of ticks past the best price to price the exit, or `NULL` to let UBI use 2.
    buffer_ticks = NULL,
    #' @field trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let UBI work it out from the side.
    trigger_direction = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param trigger_price The numeric hidden level in rupees.
    #' @param price The numeric limit price in rupees, or `NULL` for an order type that takes no price or when a price reference supplies it.
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
    #' @param bar_minutes The numeric length of each bar in minutes, or `NULL` to let UBI use 5.
    #' @param backstop_price The numeric trigger in rupees of a real stop placed at the broker, given together with `backstop_limit_price`, or `NULL`.
    #' @param backstop_limit_price The numeric limit in rupees of that real stop, or `NULL`.
    #' @param buffer_ticks The integer number of ticks past the best price to price the exit, or `NULL` to let UBI use 2.
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let UBI work it out from the side.
    #' @return A new `CandleCloseStopOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trigger_price,
      price = NULL,
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
      bar_minutes = NULL,
      backstop_price = NULL,
      backstop_limit_price = NULL,
      buffer_ticks = NULL,
      trigger_direction = NULL
    ) {
      super$initialize(
        instrument,
        transaction_type = transaction_type,
        product = product,
        order_type = order_type,
        quantity = quantity,
        price = price,
        trigger_price = NULL,
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
      self$trigger_level <- trigger_price
      self$bar_minutes <- bar_minutes
      self$backstop_price <- backstop_price
      self$backstop_limit_price <- backstop_limit_price
      self$buffer_ticks <- buffer_ticks
      self$trigger_direction <- trigger_direction
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- CandleCloseStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0,
    #'   bar_minutes = 15
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- CandleCloseStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0,
    #'   backstop_price = 11.5,
    #'   backstop_limit_price = 11.45
    #' )
    #' print(order$trigger_level)
    #' print(order$trigger_price)
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        trigger_price = self$trigger_level,
        bar_minutes = self$bar_minutes,
        backstop_price = self$backstop_price,
        backstop_limit_price = self$backstop_limit_price,
        buffer_ticks = self$buffer_ticks,
        trigger_direction = self$trigger_direction
      )
    }
  )
)
