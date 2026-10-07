ORDERS_DAILY_STOP_SYNTHETIC_TYPE <- "daily_stop"

#' A native stop placed afresh every morning for a position held overnight
#'
#' @description
#' Native Indian stops expire at the end of the day. This re-places one each trading morning at `arm_at`, after the opening auction has settled, never on a weekend or an exchange holiday, and an order sent after that day's `arm_at` first arms on the next trading day. It answers HTTP 202 with an `outcome` of `armed`, and a stop price off the tick is refused with HTTP 400 when it is placed. A change made to the day's stop lasts that day only, since the next morning's stop is placed at `stop_price` again. When the market has already opened past the stop, it closes the position with a limit instead of placing a stop that would fire at whatever the gap left. UBI never works out references for this type, so give real numbers. `valid_days` counts 24-hour periods from when the order was placed. It ends as soon as any stop has traded, so a stop that fills only partly leaves the rest unprotected from the next morning. Nothing is sent to a broker until the first morning, so keep the `parent_id` from the answer.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- DailyStopOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "sl",
#'   quantity = 10,
#'   price = 948.0,
#'   trigger_price = 950.0,
#'   stop_price = 950.0,
#'   stop_limit_price = 948.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
DailyStopOrder <- R6::R6Class(
  "DailyStopOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_DAILY_STOP_SYNTHETIC_TYPE,
    #' @field stop_price The numeric trigger of the stop in rupees. Above zero.
    stop_price = NULL,
    #' @field stop_limit_price The numeric limit of the stop in rupees. Above zero.
    stop_limit_price = NULL,
    #' @field arm_at The character time of day to place the stop, as `HH:MM` India time, which UBI refuses with seconds, or `NULL` to let UBI use `09:20`.
    arm_at = NULL,
    #' @field valid_days The integer number of days to keep re-placing it, from 1 to 365, or `NULL` to let UBI use 30.
    valid_days = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param stop_price The numeric trigger of the stop in rupees. Above zero.
    #' @param stop_limit_price The numeric limit of the stop in rupees. Above zero.
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
    #' @param arm_at The character time of day to place the stop, as `HH:MM` India time, which UBI refuses with seconds, or `NULL` to let UBI use `09:20`.
    #' @param valid_days The integer number of days to keep re-placing it, from 1 to 365, or `NULL` to let UBI use 30.
    #' @return A new `DailyStopOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      stop_price,
      stop_limit_price,
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
      arm_at = NULL,
      valid_days = NULL
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
      self$stop_price <- stop_price
      self$stop_limit_price <- stop_limit_price
      self$arm_at <- arm_at
      self$valid_days <- valid_days
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- DailyStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "cnc",
    #'   order_type = "sl",
    #'   quantity = 1,
    #'   stop_price = 12.0,
    #'   stop_limit_price = 11.95,
    #'   arm_at = "09:30",
    #'   valid_days = 10
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- DailyStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "cnc",
    #'   order_type = "sl",
    #'   quantity = 1,
    #'   stop_price = 12.0,
    #'   stop_limit_price = 11.95
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        stop_price = self$stop_price,
        stop_limit_price = self$stop_limit_price,
        arm_at = self$arm_at,
        valid_days = self$valid_days
      )
    }
  )
)
