ORDERS_CLOSE_ON_TRIGGER_SYNTHETIC_TYPE <- "close_on_trigger"

#' A level that, when reached, cancels every order on the instrument to free margin and then closes the whole position
#'
#' @description
#' This is the Atlas's G12, a stop whose exit is not refused for margin. When the level is reached, UBI first cancels every order resting on the instrument at every broker, including orders placed outside UBI, because pending orders hold margin, and then closes the whole net position held in the instrument and the template's product with a limit two ticks past the other side's best price. It closes what is held when it fires, so the template's `quantity` is not used, and when nothing is held it completes without sending an order. Set `transaction_type` to the side that opened the position, so a long position is protected by asking for `buy`, which fires when the price falls to the level. `trigger_price` here is that level, not the order's own trigger. With `trigger_on`, the level is compared with the bid, the offer or the midpoint instead of the last trade, or must be reached on two ticks in a row (`double_last`) or for `hold_seconds` (`held`), so a single stray trade does not fire it. It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer. Only orders on the template's product are cancelled, since orders on another product belong to another position, and a change to the order's price or quantity while it waits is refused with HTTP 409.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- CloseOnTriggerOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 995.0,
#'   trigger_price = 995.0,
#'   trigger_on = "held",
#'   hold_seconds = 3.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
CloseOnTriggerOrder <- R6::R6Class(
  "CloseOnTriggerOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_CLOSE_ON_TRIGGER_SYNTHETIC_TYPE,
    #' @field trigger_level The numeric level in rupees that fires the order. Above zero.
    trigger_level = NULL,
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
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let a buy wait for a fall and a sell for a rise.
    #' @param trigger_on The character price compared with the level and how it must confirm, `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let UBI use `last`.
    #' @param hold_seconds The numeric number of seconds the level must stay reached before a `held` trigger fires, which `held` requires, or `NULL`.
    #' @return A new `CloseOnTriggerOrder` object.
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
      self$trigger_direction <- trigger_direction
      self$trigger_on <- trigger_on
      self$hold_seconds <- hold_seconds
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- CloseOnTriggerOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- CloseOnTriggerOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0,
    #'   trigger_on = "held",
    #'   hold_seconds = 10
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        trigger_price = self$trigger_level,
        trigger_direction = self$trigger_direction,
        trigger_on = self$trigger_on,
        hold_seconds = self$hold_seconds
      )
    }
  )
)
