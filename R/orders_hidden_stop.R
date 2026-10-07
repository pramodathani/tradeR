ORDERS_HIDDEN_STOP_SYNTHETIC_TYPE <- "hidden_stop"

#' A stop kept inside UBI that watches the bid or the offer, with an optional real stop behind it
#'
#' @description
#' Set `transaction_type` to the side that opened the position, so a long position is protected by asking for `buy`. The stop watches the bid when protecting a long and the offer when protecting a short, so a single stray trade does not fire it. It protects nothing while UBI is down, which is what the backstop is for: a real stop-loss limit placed at the broker at once. With a backstop the answer is HTTP 200 with an `outcome` of `accepted` and a `legs` list holding the backstop at the path `root.children.1` with its `order_id`; once any of the backstop fills, UBI's own stop stops watching. While the side of the book it watches is empty it does not fire, even if the last trade is past the level, and it sends the template's `quantity` rather than sizing itself from the position. `trigger_price` here is the hidden level, not the order's own trigger. Without a backstop it answers HTTP 202 with an `outcome` of `armed` and sends nothing to a broker until it fires, so keep the `parent_id` from the answer.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- HiddenStopOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 990.0,
#'   trigger_price = 990.0,
#'   backstop_price = 980.0,
#'   backstop_limit_price = 978.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
HiddenStopOrder <- R6::R6Class(
  "HiddenStopOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_HIDDEN_STOP_SYNTHETIC_TYPE,
    #' @field trigger_level The numeric hidden level in rupees.
    trigger_level = NULL,
    #' @field backstop_price The numeric trigger in rupees of a real stop placed at the broker, given together with `backstop_limit_price`, or `NULL`.
    backstop_price = NULL,
    #' @field backstop_limit_price The numeric limit in rupees of that real stop, or `NULL`.
    backstop_limit_price = NULL,
    #' @field buffer_ticks The integer number of ticks past the best price to price the exit, or `NULL` to let UBI use 2.
    buffer_ticks = NULL,
    #' @field trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let UBI work it out from the side.
    trigger_direction = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param trigger_price The numeric hidden level in rupees.
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
    #' @param backstop_price The numeric trigger in rupees of a real stop placed at the broker, given together with `backstop_limit_price`, or `NULL`.
    #' @param backstop_limit_price The numeric limit in rupees of that real stop, or `NULL`.
    #' @param buffer_ticks The integer number of ticks past the best price to price the exit, or `NULL` to let UBI use 2.
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to let UBI work it out from the side.
    #' @return A new `HiddenStopOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      trigger_price,
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
      backstop_price = NULL,
      backstop_limit_price = NULL,
      buffer_ticks = NULL,
      trigger_direction = NULL
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
      self$backstop_price <- backstop_price
      self$backstop_limit_price <- backstop_limit_price
      self$buffer_ticks <- buffer_ticks
      self$trigger_direction <- trigger_direction
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- HiddenStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- HiddenStopOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   trigger_price = 12.0,
    #'   backstop_price = 11.5,
    #'   backstop_limit_price = 11.45,
    #'   buffer_ticks = 5
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        trigger_price = self$trigger_level,
        backstop_price = self$backstop_price,
        backstop_limit_price = self$backstop_limit_price,
        buffer_ticks = self$buffer_ticks,
        trigger_direction = self$trigger_direction
      )
    }
  )
)
