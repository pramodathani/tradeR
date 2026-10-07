ORDERS_AVERAGE_TRUE_RANGE_TRAIL_SYNTHETIC_TYPE <- "atr_trail"

#' A trailing stop whose distance is a multiple of the recent average true range
#'
#' @description
#' The distance widens when the market is volatile and narrows when it is quiet. Until enough bars exist to measure the average true range, `trail_points` is used instead.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- AverageTrueRangeTrailOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   trail_points = 5.0,
#'   stop_limit_offset = 2.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
AverageTrueRangeTrailOrder <- R6::R6Class(
  "AverageTrueRangeTrailOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_AVERAGE_TRUE_RANGE_TRAIL_SYNTHETIC_TYPE,
    #' @field trail_points The numeric fixed distance in rupees used until enough bars exist. Above zero.
    trail_points = NULL,
    #' @field stop_limit_offset The numeric distance in rupees past the trigger that the stop's limit sits. Above zero.
    stop_limit_offset = NULL,
    #' @field bar_minutes The numeric length of each bar in minutes, or `NULL` to let UBI use 5.
    bar_minutes = NULL,
    #' @field periods The integer number of bars averaged, from 2 to 49 because UBI keeps the last 50 bars, or `NULL` to let UBI use 14.
    periods = NULL,
    #' @field average_true_range_multiple The numeric multiple of the average true range to trail by, or `NULL` to let UBI use 2.
    average_true_range_multiple = NULL,
    #' @field step_ticks The integer number of ticks the trigger must be able to move before it is moved, or `NULL` to let UBI use 1.
    step_ticks = NULL,
    #' @field activate_at The numeric price in rupees the last traded price must reach before the stop is placed a trail's distance from it, which answers HTTP 202 with an `outcome` of `armed`, or `NULL` to place the stop at once.
    activate_at = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param trail_points The numeric fixed distance in rupees used until enough bars exist. Above zero.
    #' @param stop_limit_offset The numeric distance in rupees past the trigger that the stop's limit sits. Above zero.
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
    #' @param bar_minutes The numeric length of each bar in minutes, or `NULL` to let UBI use 5.
    #' @param periods The integer number of bars averaged, from 2 to 49 because UBI keeps the last 50 bars, or `NULL` to let UBI use 14.
    #' @param average_true_range_multiple The numeric multiple of the average true range to trail by, or `NULL` to let UBI use 2.
    #' @param step_ticks The integer number of ticks the trigger must be able to move before it is moved, or `NULL` to let UBI use 1.
    #' @param activate_at The numeric price in rupees the last traded price must reach before the stop is placed a trail's distance from it, which answers HTTP 202 with an `outcome` of `armed`, or `NULL` to place the stop at once.
    #' @return A new `AverageTrueRangeTrailOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trail_points,
      stop_limit_offset,
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
      bar_minutes = NULL,
      periods = NULL,
      average_true_range_multiple = NULL,
      step_ticks = NULL,
      activate_at = NULL
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
      self$trail_points <- trail_points
      self$stop_limit_offset <- stop_limit_offset
      self$bar_minutes <- bar_minutes
      self$periods <- periods
      self$average_true_range_multiple <- average_true_range_multiple
      self$step_ticks <- step_ticks
      self$activate_at <- activate_at
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- AverageTrueRangeTrailOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "sl",
    #'   quantity = 1,
    #'   trail_points = 1.0,
    #'   stop_limit_offset = 0.05,
    #'   bar_minutes = 1,
    #'   periods = 10,
    #'   average_true_range_multiple = 3.0
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- AverageTrueRangeTrailOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "sl",
    #'   quantity = 1,
    #'   trail_points = 1.0,
    #'   stop_limit_offset = 0.05,
    #'   average_true_range_multiple = 2.5
    #' )
    #' print(order$average_true_range_multiple)
    #' print(order$synthetic[["atr_multiple"]])
    #' }
    synthetic_fields = function() {
      list(
        trail_points = self$trail_points,
        stop_limit_offset = self$stop_limit_offset,
        bar_minutes = self$bar_minutes,
        periods = self$periods,
        atr_multiple = self$average_true_range_multiple,
        step_ticks = self$step_ticks,
        activate_at = self$activate_at
      )
    }
  )
)
