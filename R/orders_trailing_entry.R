ORDERS_TRAILING_ENTRY_SYNTHETIC_TYPE <- "trailing_entry"

#' A stop entry that follows a falling market down, so the first bounce of the trailing distance fills it
#'
#' @description
#' It is the mirror of a trailing stop for entering: as the price falls, the buy stop's trigger is lowered to stay the trailing distance above the low. Give `trail_points` or `trail_percent`, not both.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- TrailingEntryOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "sl",
#'   quantity = 10,
#'   price = 1002.0,
#'   trigger_price = 1000.0,
#'   trail_points = 5.0,
#'   stop_limit_offset = 2.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
TrailingEntryOrder <- R6::R6Class(
  "TrailingEntryOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_TRAILING_ENTRY_SYNTHETIC_TYPE,
    #' @field stop_limit_offset The numeric distance in rupees past the trigger that the stop's limit sits. Above zero.
    stop_limit_offset = NULL,
    #' @field trail_points The numeric fixed trailing distance in rupees, or `NULL`.
    trail_points = NULL,
    #' @field trail_percent The numeric trailing distance as a percentage of the best price seen, or `NULL`.
    trail_percent = NULL,
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
    #' @param trail_points The numeric fixed trailing distance in rupees, or `NULL`.
    #' @param trail_percent The numeric trailing distance as a percentage of the best price seen, or `NULL`.
    #' @param step_ticks The integer number of ticks the trigger must be able to move before it is moved, or `NULL` to let UBI use 1.
    #' @param activate_at The numeric price in rupees the last traded price must reach before the stop is placed a trail's distance from it, which answers HTTP 202 with an `outcome` of `armed`, or `NULL` to place the stop at once.
    #' @return A new `TrailingEntryOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
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
      trail_points = NULL,
      trail_percent = NULL,
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
      self$stop_limit_offset <- stop_limit_offset
      self$trail_points <- trail_points
      self$trail_percent <- trail_percent
      self$step_ticks <- step_ticks
      self$activate_at <- activate_at
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        stop_limit_offset = self$stop_limit_offset,
        trail_points = self$trail_points,
        trail_percent = self$trail_percent,
        step_ticks = self$step_ticks,
        activate_at = self$activate_at
      )
    }
  )
)
