ORDERS_ATTACHED_HEDGE_SYNTHETIC_TYPE <- "attached_hedge"

#' An entry whose fills are hedged in another instrument as they happen, by a ratio or by an option's delta
#'
#' @description
#' This is the Atlas's G14. After each fill, UBI works out the hedge as minus the ratio times everything filled so far, in units of the hedge instrument, rounded to its nearest whole lot, and sends a new hedge order for the whole lots still missing, so no resting order is resized, and the hedge keeps growing after earlier hedge orders have filled. A positive ratio hedges on the opposite side, so a bought stock is hedged by a sold future, and a negative one hedges on the same side. Give exactly one of `ratio`, a fixed number of hedge units per filled unit such as a beta, or `delta_volatility`, which sizes the hedge by the option's Black-76 delta at that volatility and needs the entry to be an option. Each hedge goes to the entry's broker as a limit two ticks past the hedge instrument's other side, rounded to that instrument's own tick. A hedge quote marked stale prices nothing, and neither does a delta whose forward has no price, so the hedge waits and tries again on every tick. A hedge order cancelled at the exchange, such as an `ioc` order that found nothing, is not sent again at once, and the next entry fill sends what is missing, while a hedge order whose quantity you change keeps your change. When the entry finishes having filled less than one lot of the hedge, no hedge is sent and the parent completes. When a hedge is refused, UBI cancels the rest of the entry and the parent ends `failed`, because what filled is left unhedged.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- AttachedHedgeOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "nrml",
#'   order_type = "limit",
#'   quantity = 1000,
#'   price = 1000.0,
#'   hedge_instrument = share_future,
#'   ratio = 1.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
AttachedHedgeOrder <- R6::R6Class(
  "AttachedHedgeOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_ATTACHED_HEDGE_SYNTHETIC_TYPE,
    #' @field hedge_instrument The `Instrument` to hedge in, which is not the entry's own, since UBI refuses that with HTTP 400.
    hedge_instrument = NULL,
    #' @field ratio The numeric number of hedge units per filled unit, not zero, or `NULL` when `delta_volatility` sizes the hedge.
    ratio = NULL,
    #' @field delta_volatility The numeric volatility as a percentage above zero at which the option's delta is worked out, or `NULL` when `ratio` sizes the hedge.
    delta_volatility = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param hedge_instrument The `Instrument` to hedge in, which is not the entry's own, since UBI refuses that with HTTP 400.
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
    #' @param ratio The numeric number of hedge units per filled unit, not zero, or `NULL` when `delta_volatility` sizes the hedge.
    #' @param delta_volatility The numeric volatility as a percentage above zero at which the option's delta is worked out, or `NULL` when `ratio` sizes the hedge.
    #' @return A new `AttachedHedgeOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      hedge_instrument,
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
      ratio = NULL,
      delta_volatility = NULL
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
      self$hedge_instrument <- hedge_instrument
      self$ratio <- ratio
      self$delta_volatility <- delta_volatility
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' order <- AttachedHedgeOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   hedge_instrument = second_share,
    #'   ratio = 1.0
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' order <- AttachedHedgeOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   hedge_instrument = second_share,
    #'   ratio = -0.5
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        hedge_instrument_id = self$hedge_instrument$instrument_id,
        ratio = self$ratio,
        delta_volatility = self$delta_volatility
      )
    }
  )
)
