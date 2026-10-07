ORDERS_VIRTUAL_LIMIT_SYNTHETIC_TYPE <- "virtual_limit"

#' A limit order held inside UBI and sent only when the other side of the book reaches its price
#'
#' @description
#' Nothing rests at the exchange, so the order is invisible until it is sent, and UBI estimates where it would have stood in the queue. The template must be a `limit` order with a price. With `paper` set, nothing is ever sent and the order is filled on paper from that estimate. UBI now runs every plain `limit` order with a price, `day` validity and no `synthetic` object as this type by default, so this class is needed only for `paper`. While it is held, its price and quantity are changed with `TradeableInstrument$modify_order(parent_id = ...)` and it is cancelled with `TradeableInstrument$cancel_parent()` or `cancel()`; once sent, it is changed by its broker order id like any other order. It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, a price that is not a whole number of ticks is refused with HTTP 400 when it is placed, and a limit the market never reaches costs no order message at all, so keep the `parent_id` from the answer.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- VirtualLimitOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 999.0,
#'   paper = TRUE,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
VirtualLimitOrder <- R6::R6Class(
  "VirtualLimitOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_VIRTUAL_LIMIT_SYNTHETIC_TYPE,
    #' @field paper A logical that is `TRUE` to fill the order on paper and never send anything.
    paper = NULL,

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
    #' @param paper A logical that is `TRUE` to fill the order on paper and never send anything.
    #' @return A new `VirtualLimitOrder` object.
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
      paper = FALSE
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
      self$paper <- paper
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      fields <- list()
      if (isTRUE(self$paper)) {
        fields[["paper"]] <- TRUE
      }
      fields
    }
  )
)
