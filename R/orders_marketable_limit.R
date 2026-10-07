ORDERS_MARKETABLE_LIMIT_SYNTHETIC_TYPE <- "marketable_limit"

#' A market order sent as a limit that follows the other side of the book until it fills
#'
#' @description
#' A market order with a worst price: a limit a few ticks past the other side's best price, moved after that price until it fills, with whatever is left cancelled after a time. UBI sends it as a `limit` priced `buffer_ticks` past the other side's best price, which for a buy is the best offer, so it trades at once against what rests there but never fills far from the price that was showing. On every later tick UBI moves it to `buffer_ticks` past the other side's best price again, through its repricing throttle, and once `fill_within_seconds` have passed since it was placed it cancels whatever has not filled, so the parent ends `completed` with what filled or `cancelled` when nothing did. UBI refuses the order with HTTP 409, and sends nothing, when it cannot be priced as it arrives: when nobody is offering for a buy, nobody is bidding for a sell, no live quote has arrived, or the quote is marked stale. UBI already runs every plain `market` order that names no `synthetic` type and is not an after-market order as this type with its defaults, while its `UNIFIED_BROKER_INTERFACE_API_ORDER_MARKET_AS_LIMIT` switch is on, which it is by default, so this class is needed only to choose a different buffer or time. A `limit` template that names this type is priced from the book in the same way, and its own price is not used. Each move of the resting limit is a modification that counts against the broker's daily order messages.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- MarketableLimitOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "market",
#'   quantity = 10,
#'   buffer_ticks = 0,
#'   fill_within_seconds = 10,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
MarketableLimitOrder <- R6::R6Class(
  "MarketableLimitOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_MARKETABLE_LIMIT_SYNTHETIC_TYPE,
    #' @field buffer_ticks The integer number of ticks past the other side's best price the limit sits, at least 0, or `NULL` to let UBI use 2.
    buffer_ticks = NULL,
    #' @field fill_within_seconds The numeric number of seconds, above zero, the order may work before whatever is left is cancelled, or `NULL` to let UBI use 30.
    fill_within_seconds = NULL,

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
    #' @param dry_run A logical that is `TRUE` to have UBI check the order and answer with the `plan` it would run, without recording or sending anything; the answer's `request` is the template as written, so a `market` template still shows as a market order there.
    #' @param buffer_ticks The integer number of ticks past the other side's best price the limit sits, at least 0, or `NULL` to let UBI use 2.
    #' @param fill_within_seconds The numeric number of seconds, above zero, the order may work before whatever is left is cancelled, or `NULL` to let UBI use 30.
    #' @return A new `MarketableLimitOrder` object.
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
      buffer_ticks = NULL,
      fill_within_seconds = NULL
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
      self$buffer_ticks <- buffer_ticks
      self$fill_within_seconds <- fill_within_seconds
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        buffer_ticks = self$buffer_ticks,
        fill_within_seconds = self$fill_within_seconds
      )
    }
  )
)
