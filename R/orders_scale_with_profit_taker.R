ORDERS_SCALE_WITH_PROFIT_TAKER_SYNTHETIC_TYPE <- "scale_with_profit_taker"

#' A ladder whose every filled rung gets its own profit-taker, and is placed again once that profit is taken
#'
#' @description
#' This is the Atlas's G15, what Interactive Brokers sells as ScaleTrader. The rungs are placed as a `LadderOrder` places them, shared out in whole lots. Once a rung has filled completely, a limit for what it filled goes out `profit_points` better, a sell above a filled buy or a buy below a filled sell, and once that fills the rung is placed again at its own price, until each rung has been placed again `most_cycles` times, so each rung trades `most_cycles + 1` times. A rung that only partly fills waits for the rest before its profit-taker goes out, and if it is cancelled instead, the part that filled gets no profit-taker. A rung is placed again only after its profit-taker has closed it, so the position never grows past the ladder's own quantity. A profit-taker the broker refuses leaves the other rungs working, and the parent stays `working`. Without `most_cycles` the order does not finish on its own, so cancel it with `cancel()` when you are done; with it, the parent completes once every rung has used its cycles. By default UBI holds each rung in its virtual order book until the other side of the book reaches its price, and holds it again once its profit has been taken, answering HTTP 202 with nothing placed, while every profit-taker rests at the broker as soon as its rung fills; give `hold_limits` `FALSE` to rest the rungs at the broker.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- ScaleWithProfitTakerOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 30,
#'   price = 1000.0,
#'   from_price = 1000.0,
#'   to_price = 990.0,
#'   steps = 3,
#'   profit_points = 4.0,
#'   most_cycles = 5,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
ScaleWithProfitTakerOrder <- R6::R6Class(
  "ScaleWithProfitTakerOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_SCALE_WITH_PROFIT_TAKER_SYNTHETIC_TYPE,
    #' @field from_price The numeric price of the first rung in rupees. Above zero.
    from_price = NULL,
    #' @field to_price The numeric price of the last rung in rupees. Above zero, and different from `from_price`.
    to_price = NULL,
    #' @field steps The integer number of rungs, from 2 to 20. The quantity must be at least this many lots.
    steps = NULL,
    #' @field profit_points The numeric distance in rupees past a filled rung's price at which its profit-taker is placed. Above zero.
    profit_points = NULL,
    #' @field most_cycles The integer number of times each rung is placed again after its profit is taken, at least 1, so each rung trades one time more than this, or `NULL` to let a rung cycle until the order is cancelled.
    most_cycles = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param from_price The numeric price of the first rung in rupees. Above zero.
    #' @param to_price The numeric price of the last rung in rupees. Above zero, and different from `from_price`.
    #' @param steps The integer number of rungs, from 2 to 20. The quantity must be at least this many lots.
    #' @param profit_points The numeric distance in rupees past a filled rung's price at which its profit-taker is placed. Above zero.
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
    #' @param most_cycles The integer number of times each rung is placed again after its profit is taken, at least 1, so each rung trades one time more than this, or `NULL` to let a rung cycle until the order is cancelled.
    #' @return A new `ScaleWithProfitTakerOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      from_price,
      to_price,
      steps,
      profit_points,
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
      most_cycles = NULL
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
      self$from_price <- from_price
      self$to_price <- to_price
      self$steps <- steps
      self$profit_points <- profit_points
      self$most_cycles <- most_cycles
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        from_price = self$from_price,
        to_price = self$to_price,
        steps = self$steps,
        profit_points = self$profit_points,
        most_cycles = self$most_cycles
      )
    }
  )
)
