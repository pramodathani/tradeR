ORDERS_GOOD_TILL_TRIGGERED_SYNTHETIC_TYPE <- "gtt"

#' A limit-if-touched order that keeps waiting across days until it fires or expires
#'
#' @description
#' Native Indian stops expire at the end of the day, and this is what brokers sell as GTT for multi-day holdings. A gap through the level fires it at the open, and nothing that watches prices can act on a price that never traded. `trigger_price` here is the level, not the order's own trigger. With `trigger_on`, the level is compared with the bid, the offer or the midpoint instead of the last trade, or must be reached on two ticks in a row (`double_last`) or for `hold_seconds` (`held`), so a single stray trade does not fire it. It answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer. Once touched, its limit is held in UBI's virtual order book, across days until `valid_days` runs out, until the other side of the book reaches it, unless `hold_limits` is `FALSE`; a held one therefore does not die at the close as a `day` limit sent at the touch would.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- GoodTillTriggeredOrder$new(
#'   share,
#'   transaction_type = "sell",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 951.0,
#'   trigger_price = 950.0,
#'   limit_price = 951.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
GoodTillTriggeredOrder <- R6::R6Class(
  "GoodTillTriggeredOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_GOOD_TILL_TRIGGERED_SYNTHETIC_TYPE,
    #' @field trigger_level The numeric level in rupees that fires the order. Above zero.
    trigger_level = NULL,
    #' @field limit_price The numeric limit price in rupees of the order sent. Above zero.
    limit_price = NULL,
    #' @field valid_days The integer number of days to keep waiting, from 1 to 365, or `NULL` to let UBI use 30.
    valid_days = NULL,
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
    #' @param limit_price The numeric limit price in rupees of the order sent. Above zero.
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
    #' @param valid_days The integer number of days to keep waiting, from 1 to 365, or `NULL` to let UBI use 30.
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let a buy wait for a fall and a sell for a rise.
    #' @param trigger_on The character price compared with the level and how it must confirm, `last`, `bid`, `ask`, `mid`, `double_last` or `held`, or `NULL` to let UBI use `last`.
    #' @param hold_seconds The numeric number of seconds the level must stay reached before a `held` trigger fires, which `held` requires, or `NULL`.
    #' @return A new `GoodTillTriggeredOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trigger_price,
      limit_price,
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
      valid_days = NULL,
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
      self$limit_price <- limit_price
      self$valid_days <- valid_days
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
    #' order <- GoodTillTriggeredOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "cnc",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0,
    #'   limit_price = 12.05,
    #'   valid_days = 90
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- GoodTillTriggeredOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "cnc",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 16.0,
    #'   limit_price = 15.95,
    #'   trigger_on = "double_last"
    #' )
    #' print(order$trigger_level)
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        trigger_price = self$trigger_level,
        limit_price = self$limit_price,
        valid_days = self$valid_days,
        trigger_direction = self$trigger_direction,
        trigger_on = self$trigger_on,
        hold_seconds = self$hold_seconds
      )
    }
  )
)
