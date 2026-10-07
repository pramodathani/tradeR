ORDERS_OPENING_AUCTION_SYNTHETIC_TYPE <- "opening_auction"

#' An order placed during the pre-open session, so it fills at the price the opening call auction discovers
#'
#' @description
#' This is market-on-open or limit-on-open, the Atlas's G1. UBI places it at `at_time` while the pre-open is collecting orders, answering HTTP 202 with an `outcome` of `armed`, or at once, with the broker's answer, when collection is already open. Only NSE and BSE equities and exchange traded funds, until 09:10 for a limit and 09:05 for a market order, and NSE stock and index futures, until 09:07 and 09:05, have a pre-open; UBI refuses anything else with HTTP 400 rather than send it into continuous trading, and refuses stop orders and `ioc` too. It does not check that a future is the current month's, the only one with a pre-open. Times follow the instrument's exchange trading calendar, so on a weekend or an exchange holiday the order waits for the next trading day's pre-open. Keep the `parent_id` from the answer, since nothing reaches a broker until then.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- OpeningAuctionOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
OpeningAuctionOrder <- R6::R6Class(
  "OpeningAuctionOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_OPENING_AUCTION_SYNTHETIC_TYPE,
    #' @field at_time The character time to place the order, as `HH:MM` or `HH:MM:SS` India time, from 09:00 and before the pre-open stops collecting this order, or `NULL` to let UBI use `09:00:30`.
    at_time = NULL,

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
    #' @param at_time The character time to place the order, as `HH:MM` or `HH:MM:SS` India time, from 09:00 and before the pre-open stops collecting this order, or `NULL` to let UBI use `09:00:30`.
    #' @return A new `OpeningAuctionOrder` object.
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
      at_time = NULL
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
      self$at_time <- at_time
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        at_time = self$at_time
      )
    }
  )
)
