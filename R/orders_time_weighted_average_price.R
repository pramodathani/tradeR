ORDERS_TIME_WEIGHTED_AVERAGE_PRICE_SYNTHETIC_TYPE <- "twap"

#' A large order sent as equal slices at even intervals over a period
#'
#' @description
#' Spreading the order over time brings the average price paid closer to the period's average than to the price at the moment of asking. By default UBI holds each slice in its virtual order book from its turn until the other side of the book reaches its price, unless `hold_limits` is `FALSE`, but only when the template is a `limit` order with a price that is neither `ioc` nor after-market; any other order, such as a market TWAP, is sent unheld, slice by slice. Slices are shared out in whole lots, and a slice that comes to nothing, as it does when the order has fewer lots than slices, is skipped and the schedule moves on. At most one slice goes per tick, so slices that fell due while UBI was busy follow one a tick, and the schedule does not stop at the market's close.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- TimeWeightedAveragePriceOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 600,
#'   price_reference = list(
#'     kind = "marketable"
#'   ),
#'   slices = 6,
#'   over_minutes = 30.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
TimeWeightedAveragePriceOrder <- R6::R6Class(
  "TimeWeightedAveragePriceOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_TIME_WEIGHTED_AVERAGE_PRICE_SYNTHETIC_TYPE,
    #' @field slices The integer number of slices, from 2 to 60. A quantity of fewer lots than this is accepted, and the empty slices are skipped.
    slices = NULL,
    #' @field over_minutes The numeric number of minutes to spread the slices over. Above zero.
    over_minutes = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param slices The integer number of slices, from 2 to 60. A quantity of fewer lots than this is accepted, and the empty slices are skipped.
    #' @param over_minutes The numeric number of minutes to spread the slices over. Above zero.
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
    #' @return A new `TimeWeightedAveragePriceOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      slices,
      over_minutes,
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
      dry_run = FALSE
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
      self$slices <- slices
      self$over_minutes <- over_minutes
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        slices = self$slices,
        over_minutes = self$over_minutes
      )
    }
  )
)
