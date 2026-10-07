ORDERS_LADDER_SYNTHETIC_TYPE <- "ladder"

#' Several limit orders spaced evenly between two prices, sharing the quantity between them
#'
#' @description
#' The quantity is divided among the rungs rather than repeated, in whole lots with the first rungs taking the remainder, so 100 over three steps is 34, 33 and 33, and 225 on a lot of 75 over two steps is 150 and 75. UBI refuses with HTTP 400 a quantity of fewer lots than `steps`. By default UBI holds every rung in its virtual order book and sends each one only when the other side of the book reaches that rung's own price, so a rung the market never reaches costs no order message, and the answer is HTTP 202 with an `outcome` of `armed`. A held rung is the plan part `root.pieces.0`, `root.pieces.1` and so on, which `PlanOrder`'s part methods can change or cancel without a broker message, and it gives up its place in the queue. With `hold_limits` `FALSE` every rung is sent at once and rests at the broker, and the answer carries a `legs` list with one entry per rung. UBI never works out references for a ladder, so give real numbers.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- LadderOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 100,
#'   price = 1000.0,
#'   from_price = 995.0,
#'   to_price = 1000.0,
#'   steps = 3,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
LadderOrder <- R6::R6Class(
  "LadderOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_LADDER_SYNTHETIC_TYPE,
    #' @field from_price The numeric price of the first rung in rupees. Above zero.
    from_price = NULL,
    #' @field to_price The numeric price of the last rung in rupees. Above zero, and different from `from_price`.
    to_price = NULL,
    #' @field steps The integer number of rungs, from 2 to 20. The quantity must be at least this many lots.
    steps = NULL,

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
    #' @return A new `LadderOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      from_price,
      to_price,
      steps,
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
      self$from_price <- from_price
      self$to_price <- to_price
      self$steps <- steps
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- LadderOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 3,
    #'   from_price = 13.0,
    #'   to_price = 12.8,
    #'   steps = 3
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- LadderOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 4,
    #'   from_price = 14.0,
    #'   to_price = 14.3,
    #'   steps = 4
    #' )
    #' fields <- order$synthetic_fields()
    #' price_range <- fields[["to_price"]] - fields[["from_price"]]
    #' gap <- price_range / (fields[["steps"]] - 1)
    #' for (rung in seq_len(fields[["steps"]]) - 1) {
    #'   rung_price <- fields[["from_price"]] + gap * rung
    #'   cat(sprintf("rung %d: %.2f\n", rung + 1, rung_price))
    #' }
    #' }
    synthetic_fields = function() {
      list(
        from_price = self$from_price,
        to_price = self$to_price,
        steps = self$steps
      )
    }
  )
)
