ORDERS_ONE_CANCELS_OTHER_SYNTHETIC_TYPE <- "oco"

#' A stop and a target resting together on a position already held, each shrinking as the other fills
#'
#' @description
#' Set `transaction_type` to the side that opened the position, so a long position is protected by asking for `buy`, and both exits are sells. When one exit fills in part, the other is reduced by the same amount rather than cancelled, so the position is never left unprotected. Both exits rest at the exchange, so in a fast market both can fill before the reduction lands; no exchange offers an order that prevents that. Give a stop, a target or both, and a stop always needs its limit, because every stop is a stop-limit. Both exits go to the broker that holds the position, whatever the broker selector would choose, and UBI refuses with HTTP 409 a position held at more than one broker or one smaller than the order's `quantity`, since a fill could then open a position the other way.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- OneCancelsOtherOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   stop_price = 990.0,
#'   stop_limit_price = 988.0,
#'   target_price = 1010.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
OneCancelsOtherOrder <- R6::R6Class(
  "OneCancelsOtherOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_ONE_CANCELS_OTHER_SYNTHETIC_TYPE,
    #' @field stop_price The numeric trigger of the stop in rupees, or `NULL` for no stop.
    stop_price = NULL,
    #' @field stop_limit_price The numeric limit of the stop in rupees, required whenever `stop_price` is given, or `NULL`.
    stop_limit_price = NULL,
    #' @field target_price The numeric limit of the target in rupees, or `NULL` for no target.
    target_price = NULL,

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
    #' @param stop_price The numeric trigger of the stop in rupees, or `NULL` for no stop.
    #' @param stop_limit_price The numeric limit of the stop in rupees, required whenever `stop_price` is given, or `NULL`.
    #' @param target_price The numeric limit of the target in rupees, or `NULL` for no target.
    #' @return A new `OneCancelsOtherOrder` object.
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
      stop_price = NULL,
      stop_limit_price = NULL,
      target_price = NULL
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
      self$target_price <- target_price
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        stop_price = self$stop_price,
        stop_limit_price = self$stop_limit_price,
        target_price = self$target_price
      )
    }
  )
)
