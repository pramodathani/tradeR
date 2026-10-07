ORDERS_STEPPED_STOP_SYNTHETIC_TYPE <- "stepped_stop"

#' A native stop moved to set levels at set profits, and switched to trailing at the last
#'
#' @description
#' This is an adjustable stop, the Atlas's G8. The stop-limit is placed at `stop_price`, and each rule names a `gain`, the profit in points from `entry_price` that sets it off, and either a `stop_at_gain`, where to move the stop measured from `entry_price`, or a `trail_points`, which starts the stop trailing as a `TrailingStopOrder` does. A market that jumps past several gains applies them all in one modification, a stop is only ever moved in the position's favour, and a trailing rule must be the last. Set `transaction_type` to the side that opened the position, so a long position is protected by asking for `buy`.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- SteppedStopOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   entry_price = 1000.0,
#'   stop_price = 990.0,
#'   stop_limit_offset = 2.0,
#'   rules = list(
#'     list(
#'       gain = 20,
#'       stop_at_gain = 0
#'     ),
#'     list(
#'       gain = 60,
#'       trail_points = 25
#'     )
#'   ),
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
SteppedStopOrder <- R6::R6Class(
  "SteppedStopOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_STEPPED_STOP_SYNTHETIC_TYPE,
    #' @field entry_price The numeric price in rupees the position was opened at, which every gain is measured from. Above zero.
    entry_price = NULL,
    #' @field stop_price The numeric trigger price in rupees the stop starts at. Above zero.
    stop_price = NULL,
    #' @field stop_limit_offset The numeric distance in rupees past the trigger that the stop's limit sits. Above zero.
    stop_limit_offset = NULL,
    #' @field rules The list of 1 to 20 named list rules, each with a `gain` above zero and larger than the one before and exactly one of `stop_at_gain`, a number that may be negative to keep some risk, or `trail_points`, above zero, which only the last rule may have.
    rules = NULL,
    #' @field step_ticks The integer number of ticks the trigger must be able to move before it is moved once trailing, or `NULL` to let UBI use 1.
    step_ticks = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param entry_price The numeric price in rupees the position was opened at, which every gain is measured from. Above zero.
    #' @param stop_price The numeric trigger price in rupees the stop starts at. Above zero.
    #' @param stop_limit_offset The numeric distance in rupees past the trigger that the stop's limit sits. Above zero.
    #' @param rules The list of 1 to 20 named list rules, each with a `gain` above zero and larger than the one before and exactly one of `stop_at_gain`, a number that may be negative to keep some risk, or `trail_points`, above zero, which only the last rule may have.
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
    #' @param step_ticks The integer number of ticks the trigger must be able to move before it is moved once trailing, or `NULL` to let UBI use 1.
    #' @return A new `SteppedStopOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      entry_price,
      stop_price,
      stop_limit_offset,
      rules,
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
      step_ticks = NULL
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
      self$entry_price <- entry_price
      self$stop_price <- stop_price
      self$stop_limit_offset <- stop_limit_offset
      self$rules <- rules
      self$step_ticks <- step_ticks
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        entry_price = self$entry_price,
        stop_price = self$stop_price,
        stop_limit_offset = self$stop_limit_offset,
        rules = self$rules,
        step_ticks = self$step_ticks
      )
    }
  )
)
