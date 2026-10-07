ORDERS_ONE_TRIGGERS_OTHER_SYNTHETIC_TYPE <- "oto"

#' An order that places a second, described in advance, once the first one fills
#'
#' @description
#' The second order is sized to what the first actually filled, and grown as more of it fills, so a partial fill never leaves the second order larger than the position it follows. UBI builds the second order by laying the `then_` settings over the whole template, so a template `price` is carried into a `then_order_type` of `market` and refused; give such a template no price, or give the second order its own. UBI checks the second order before sending the first, so a dry run catches that. By default UBI holds a limit first order in its virtual order book until the other side of the book reaches its price, answering HTTP 202 with an `outcome` of `armed`, while the second order rests at the broker; give `hold_limits` `FALSE` to send the first order at once. If the second order has already finished when the first fills further, UBI sends a new second order for the extra quantity. A second order the broker refuses cancels the rest of the first, and the parent ends `failed`, because what the first filled is left without it.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- OneTriggersOtherOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 100,
#'   price = 1000.0,
#'   then_transaction_type = "sell",
#'   then_order_type = "limit",
#'   then_price = 1010.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
OneTriggersOtherOrder <- R6::R6Class(
  "OneTriggersOtherOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_ONE_TRIGGERS_OTHER_SYNTHETIC_TYPE,
    #' @field then_transaction_type The character side of the second order, `"buy"` or `"sell"`.
    then_transaction_type = NULL,
    #' @field then_order_type The character kind of the second order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    then_order_type = NULL,
    #' @field then_price The numeric limit price in rupees of the second order, or `NULL` to use the template's.
    then_price = NULL,
    #' @field then_trigger_price The numeric trigger price in rupees of the second order, or `NULL` to use the template's.
    then_trigger_price = NULL,
    #' @field then_product The character product of the second order, or `NULL` to use the template's.
    then_product = NULL,
    #' @field then_validity The character validity of the second order, or `NULL` to use the template's.
    then_validity = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param then_transaction_type The character side of the second order, `"buy"` or `"sell"`.
    #' @param then_order_type The character kind of the second order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
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
    #' @param then_price The numeric limit price in rupees of the second order, or `NULL` to use the template's.
    #' @param then_trigger_price The numeric trigger price in rupees of the second order, or `NULL` to use the template's.
    #' @param then_product The character product of the second order, or `NULL` to use the template's.
    #' @param then_validity The character validity of the second order, or `NULL` to use the template's.
    #' @return A new `OneTriggersOtherOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      then_transaction_type,
      then_order_type,
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
      then_price = NULL,
      then_trigger_price = NULL,
      then_product = NULL,
      then_validity = NULL
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
      self$then_transaction_type <- then_transaction_type
      self$then_order_type <- then_order_type
      self$then_price <- then_price
      self$then_trigger_price <- then_trigger_price
      self$then_product <- then_product
      self$then_validity <- then_validity
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      then <- list(
        transaction_type = self$then_transaction_type,
        order_type = self$then_order_type
      )
      optional_fields <- list(
        price = self$then_price,
        trigger_price = self$then_trigger_price,
        product = self$then_product,
        validity = self$then_validity
      )
      for (field in names(optional_fields)) {
        if (!is.null(optional_fields[[field]])) {
          then[[field]] <- optional_fields[[field]]
        }
      }
      list(
        then = then
      )
    }
  )
)
