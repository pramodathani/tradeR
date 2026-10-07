ORDERS_TWO_SIDED_BREAKOUT_SYNTHETIC_TYPE <- "two_sided_breakout"

#' A buy stop above a range and a sell stop below it, where the first to fire cancels the other
#'
#' @description
#' Both entries are native stop orders at the exchange, so they fire at exchange speed whether or not UBI is running; UBI only notices which went and cancels the other, rather than reducing it, because the two are opposite trades. A spike through both levels inside one tick fills both. After the break, a stop and a target are armed on the side that filled, each a distance from the entry's average fill rather than a price, because one absolute price cannot suit a break either way: after a break downwards, a target above the range would buy straight back. At least one of `stop_distance` and `target_distance` must be given. UBI never works out references for this type, so give real numbers. If the other side fills before its cancel lands, the two fills offset, and UBI cuts the exits to the net position, which is nothing when both sides filled in full. When the later side filled more, the position has turned over, so UBI cancels the exits resting on the old side and sends them again on the new side, measured from the average fill of the side now held. An exit the broker refuses cancels whatever of the entries is still working, and the parent ends `failed`, because the position is left without that exit.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- TwoSidedBreakoutOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "sl",
#'   quantity = 10,
#'   price = 1012.0,
#'   trigger_price = 1010.0,
#'   buy_trigger = 1010.0,
#'   buy_limit = 1012.0,
#'   sell_trigger = 990.0,
#'   sell_limit = 988.0,
#'   stop_distance = 10.0,
#'   stop_limit_offset = 2.0,
#'   target_distance = 20.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
TwoSidedBreakoutOrder <- R6::R6Class(
  "TwoSidedBreakoutOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_TWO_SIDED_BREAKOUT_SYNTHETIC_TYPE,
    #' @field buy_trigger The numeric trigger of the buy stop in rupees, above `sell_trigger`.
    buy_trigger = NULL,
    #' @field buy_limit The numeric limit of the buy stop in rupees.
    buy_limit = NULL,
    #' @field sell_trigger The numeric trigger of the sell stop in rupees, below `buy_trigger`.
    sell_trigger = NULL,
    #' @field sell_limit The numeric limit of the sell stop in rupees.
    sell_limit = NULL,
    #' @field stop_distance The numeric distance in rupees between the entry's average fill and the trigger of the stop armed after the break, or `NULL` for no stop.
    stop_distance = NULL,
    #' @field stop_limit_offset The numeric distance in rupees by which the stop's limit sits past its trigger, required with `stop_distance`, or `NULL`.
    stop_limit_offset = NULL,
    #' @field target_distance The numeric distance in rupees between the entry's average fill and the target armed after the break, or `NULL` for no target.
    target_distance = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param buy_trigger The numeric trigger of the buy stop in rupees, above `sell_trigger`.
    #' @param buy_limit The numeric limit of the buy stop in rupees.
    #' @param sell_trigger The numeric trigger of the sell stop in rupees, below `buy_trigger`.
    #' @param sell_limit The numeric limit of the sell stop in rupees.
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
    #' @param stop_distance The numeric distance in rupees between the entry's average fill and the trigger of the stop armed after the break, below the fill for a long and above it for a short, or `NULL` for no stop.
    #' @param stop_limit_offset The numeric distance in rupees by which the stop's limit sits past its trigger, required with `stop_distance`, or `NULL`.
    #' @param target_distance The numeric distance in rupees between the entry's average fill and the target armed after the break, above the fill for a long and below it for a short, or `NULL` for no target.
    #' @return A new `TwoSidedBreakoutOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      buy_trigger,
      buy_limit,
      sell_trigger,
      sell_limit,
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
      stop_distance = NULL,
      stop_limit_offset = NULL,
      target_distance = NULL
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
      self$buy_trigger <- buy_trigger
      self$buy_limit <- buy_limit
      self$sell_trigger <- sell_trigger
      self$sell_limit <- sell_limit
      self$stop_distance <- stop_distance
      self$stop_limit_offset <- stop_limit_offset
      self$target_distance <- target_distance
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        buy_trigger = self$buy_trigger,
        buy_limit = self$buy_limit,
        sell_trigger = self$sell_trigger,
        sell_limit = self$sell_limit,
        stop_distance = self$stop_distance,
        stop_limit_offset = self$stop_limit_offset,
        target_distance = self$target_distance
      )
    }
  )
)
