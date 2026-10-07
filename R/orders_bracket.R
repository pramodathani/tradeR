ORDERS_BRACKET_SYNTHETIC_TYPE <- "bracket"

#' An entry that arms a stop and a target behind itself on its first fill, even a partial one
#'
#' @description
#' The exits are sized to what has filled and grown as more fills arrive, and once an exit fills the rest of the entry is cancelled and the other exit reduced. Give a stop, a target or both, and a stop always needs its limit, because every stop is a stop-limit. An entry that must never go out without a stop is a `CoverOrder` instead. By default UBI holds a limit entry in its virtual order book until the other side of the book reaches its price, answering HTTP 202 with an `outcome` of `armed`, while the exits rest at the broker as the entry fills; give `hold_limits` `FALSE` to send the entry at once. An entry fill that arrives after both exits have finished sends the exits again for what it added, and a stop or target off the tick is refused with HTTP 400 before anything is sent, by a dry run as well. A stop or target you cancel by its `order_id` stays cancelled, and its unfilled quantity comes off its part, so a later entry fill is protected for the new quantity only; an exit the exchange cancels is likewise sent again only once a later entry fill grows it. An exit the broker refuses cancels the rest of the entry, and the parent ends `failed`, because the position is left without that exit.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- BracketOrder$new(
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
BracketOrder <- R6::R6Class(
  "BracketOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_BRACKET_SYNTHETIC_TYPE,
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
    #' @return A new `BracketOrder` object.
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
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- BracketOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   stop_price = 12.5,
    #'   stop_limit_price = 12.45,
    #'   target_price = 13.6
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- BracketOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   stop_price = 12.5,
    #'   stop_limit_price = 12.45
    #' )
    #' print(order$synthetic_fields())
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        stop_price = self$stop_price,
        stop_limit_price = self$stop_limit_price,
        target_price = self$target_price
      )
    }
  )
)
