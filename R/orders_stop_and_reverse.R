ORDERS_STOP_AND_REVERSE_SYNTHETIC_TYPE <- "stop_and_reverse"

#' A level that, when reached, closes the position and opens the same size the other way
#'
#' @description
#' This is the Atlas's G13, which turns a long of 75 into a short of 75 or the other way. Like a `CloseOnTriggerOrder`, it first cancels every order resting on the instrument to free margin, acts on the net position held when it fires, and completes without an order when nothing is held. With `method` set to `sequential`, UBI sends a closing order and, once it has filled completely, a second order of the same size and side that opens the reverse; with `double`, it sends one order for twice the position, which is faster but needs the broker to accept margin for the new side before the old one closes. Both are limits two ticks past the other side's best price. Set `transaction_type` to the side that opened the position. `trigger_price` here is the level, not the order's own trigger. With `trigger_on`, the level is compared with the bid, the offer or the midpoint instead of the last trade, or must be reached on two ticks in a row (`double_last`) or for `hold_seconds` (`held`), so a single stray trade does not fire it. It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer. With `sequential`, the reverse is sent on the side the close traded and waits until every broker's close is done, then opens the whole reverse at the broker of the first close, sized to what the close filled.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- StopAndReverseOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 75,
#'   price = 995.0,
#'   trigger_price = 995.0,
#'   method = "sequential",
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
StopAndReverseOrder <- R6::R6Class(
  "StopAndReverseOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_STOP_AND_REVERSE_SYNTHETIC_TYPE,
    #' @field trigger_level The numeric level in rupees that fires the order. Above zero.
    trigger_level = NULL,
    #' @field method The character way the flip is sent, `sequential` or `double`, or `NULL` to let UBI use `sequential`.
    method = NULL,
    #' @field trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let a buy wait for a fall and a sell for a rise.
    trigger_direction = NULL,
    #' @field trigger_on The character price compared with the level and how it must confirm, `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let UBI use `last`.
    trigger_on = NULL,
    #' @field hold_seconds The numeric number of seconds the level must stay reached before a `held` trigger fires, which `held` requires, or `NULL`.
    hold_seconds = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param trigger_price The numeric level in rupees that fires the order. Above zero.
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
    #' @param method The character way the flip is sent, `sequential` or `double`, or `NULL` to let UBI use `sequential`.
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let a buy wait for a fall and a sell for a rise.
    #' @param trigger_on The character price compared with the level and how it must confirm, `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let UBI use `last`.
    #' @param hold_seconds The numeric number of seconds the level must stay reached before a `held` trigger fires, which `held` requires, or `NULL`.
    #' @return A new `StopAndReverseOrder` object.
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
      method = NULL,
      trigger_direction = NULL,
      trigger_on = NULL,
      hold_seconds = NULL
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
      self$method <- method
      self$trigger_direction <- trigger_direction
      self$trigger_on <- trigger_on
      self$hold_seconds <- hold_seconds
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        trigger_price = self$trigger_level,
        method = self$method,
        trigger_direction = self$trigger_direction,
        trigger_on = self$trigger_on,
        hold_seconds = self$hold_seconds
      )
    }
  )
)
