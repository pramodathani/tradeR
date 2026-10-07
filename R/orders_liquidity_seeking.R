ORDERS_LIQUIDITY_SEEKING_SYNTHETIC_TYPE <- "liquidity_seeking"

#' An order that shows nothing and strikes only when enough size appears at an acceptable price
#'
#' @description
#' It is the closest thing to a minimum-quantity order that anyone can build: it waits until the visible book covers `minimum_quantity` at `limit_price` or better, and then sends an order for it. It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer. The strike is rounded down to whole lots and uses the template's validity, so with the default `day` an unfilled strike rests at `limit_price`. A book UBI marks stale is never acted on.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- LiquiditySeekingOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 500,
#'   price = 1000.0,
#'   limit_price = 1001.0,
#'   minimum_quantity = 200,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
LiquiditySeekingOrder <- R6::R6Class(
  "LiquiditySeekingOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_LIQUIDITY_SEEKING_SYNTHETIC_TYPE,
    #' @field limit_price The numeric worst price in rupees it will trade at. Above zero.
    limit_price = NULL,
    #' @field minimum_quantity The integer smallest size worth striking for, at least 1.
    minimum_quantity = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param limit_price The numeric worst price in rupees it will trade at. Above zero.
    #' @param minimum_quantity The integer smallest size worth striking for, at least 1.
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
    #' @return A new `LiquiditySeekingOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      limit_price,
      minimum_quantity,
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
      self$limit_price <- limit_price
      self$minimum_quantity <- minimum_quantity
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- LiquiditySeekingOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   limit_price = 13.0,
    #'   minimum_quantity = 5000
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- LiquiditySeekingOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   limit_price = 14.0,
    #'   minimum_quantity = 1000
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        limit_price = self$limit_price,
        minimum_quantity = self$minimum_quantity
      )
    }
  )
)
