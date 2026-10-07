ORDERS_ACCOUNT_CONDITIONAL_SYNTHETIC_TYPE <- "account_conditional"

#' An order sent, or cancelled, when the account's free margin, day's profit or open position count reaches a level
#'
#' @description
#' This is the Atlas's G17, which waits on the account rather than on a price. About once a second, UBI compares `account_field` with `account_level` in `trigger_direction`: `available_balance` is the free margin across every broker, `day_pnl` is realized plus unrealized profit across every broker as the daily loss lockout reads it, and `open_positions` is how many net positions are open. With `action` set to `place`, nothing is sent until the condition holds, and the answer is HTTP 202 with an `outcome` of `armed`, so keep the `parent_id` from the answer. With `cancel`, the order is sent at once and cancelled when the condition holds, such as pulling a resting bid when the day's loss reaches a limit. `trigger_direction` is required, because the side of the order says nothing about which way the account has to move. With `place`, a limit order is held in UBI's virtual order book from the moment the condition holds until the other side of the book reaches its price, even if the account figure moves back, unless `hold_limits` is `FALSE`.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- AccountConditionalOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 995.0,
#'   account_field = "day_pnl",
#'   account_level = -5000.0,
#'   trigger_direction = "at_or_below",
#'   action = "cancel",
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
AccountConditionalOrder <- R6::R6Class(
  "AccountConditionalOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_ACCOUNT_CONDITIONAL_SYNTHETIC_TYPE,
    #' @field account_field The character figure watched, `available_balance`, `day_pnl` or `open_positions`.
    account_field = NULL,
    #' @field account_level The numeric level the figure is compared with, in rupees or in positions, which may be negative for a loss.
    account_level = NULL,
    #' @field trigger_direction The character direction, `at_or_above` or `at_or_below`.
    trigger_direction = NULL,
    #' @field action The character action when the condition holds, `place` to send the order then or `cancel` to send it at once and cancel it then, or `NULL` to let UBI use `place`.
    action = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param account_field The character figure watched, `available_balance`, `day_pnl` or `open_positions`.
    #' @param account_level The numeric level the figure is compared with, in rupees or in positions, which may be negative for a loss.
    #' @param trigger_direction The character direction, `at_or_above` or `at_or_below`.
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
    #' @param action The character action when the condition holds, `place` to send the order then or `cancel` to send it at once and cancel it then, or `NULL` to let UBI use `place`.
    #' @return A new `AccountConditionalOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      account_field,
      account_level,
      trigger_direction,
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
      action = NULL
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
      self$account_field <- account_field
      self$account_level <- account_level
      self$trigger_direction <- trigger_direction
      self$action <- action
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- AccountConditionalOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   account_field = "open_positions",
    #'   account_level = 5,
    #'   trigger_direction = "at_or_above"
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- AccountConditionalOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   account_field = "day_pnl",
    #'   account_level = -2000.0,
    #'   trigger_direction = "at_or_below",
    #'   action = "cancel"
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        account_field = self$account_field,
        account_level = self$account_level,
        trigger_direction = self$trigger_direction,
        action = self$action
      )
    }
  )
)
