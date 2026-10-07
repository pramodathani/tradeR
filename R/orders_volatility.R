ORDERS_VOLATILITY_SYNTHETIC_TYPE <- "volatility"

#' An option order stated as an implied volatility, priced with the Black-76 model and re-priced as the underlying and time move
#'
#' @description
#' This is the Atlas's G7, an order such as "buy this call at 12.5 volatility". UBI works out the premium from the volatility, the option's strike, expiry and type, the watched instrument's last price as the forward, grown by `interest_rate` to expiry unless it is a future, and the time to 15:30 on the expiry date, in years of 365 days. It follows the watched instrument through the same step and throttle as an `UnderlyingPegOrder`. The template must be a `limit` order, and its `price` is the worst it accepts, the most a buy pays or the least a sell takes; the model's premium is used whenever it is better. Changing the order's price yourself makes it take the volatility your price implies and carry on at that. `lowest_price` and `highest_price` never push the order past that worst price, and an option that has already expired is refused with HTTP 400.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- VolatilityOrder$new(
#'   nifty_call,
#'   transaction_type = "buy",
#'   product = "nrml",
#'   order_type = "limit",
#'   quantity = 75,
#'   price = 180.0,
#'   watch_instrument = nifty_future,
#'   volatility = 12.5,
#'   step_ticks = 4,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
VolatilityOrder <- R6::R6Class(
  "VolatilityOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_VOLATILITY_SYNTHETIC_TYPE,
    #' @field watch_instrument The `Instrument` that gives the forward price: the future of the same expiry for a true Black-76 forward, or the index.
    watch_instrument = NULL,
    #' @field volatility The numeric implied volatility as a percentage, above zero and at most 500, such as 12.5.
    volatility = NULL,
    #' @field interest_rate The numeric interest rate as a percentage, used to grow a watched index to expiry, or `NULL` to let UBI use 0.
    interest_rate = NULL,
    #' @field lowest_price The numeric lowest price in rupees the order is moved to, above zero, or `NULL` for no floor.
    lowest_price = NULL,
    #' @field highest_price The numeric highest price in rupees the order is moved to, above zero and not below `lowest_price`, or `NULL` for no ceiling.
    highest_price = NULL,
    #' @field step_ticks The integer smallest move in ticks worth a modification, at least 1, or `NULL` to let UBI use 1.
    step_ticks = NULL,

    #' @description
    #' Initialises the order template and this type's own settings.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param watch_instrument The `Instrument` that gives the forward price: the future of the same expiry for a true Black-76 forward, or the index.
    #' @param volatility The numeric implied volatility as a percentage, above zero and at most 500, such as 12.5.
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
    #' @param interest_rate The numeric interest rate as a percentage, used to grow a watched index to expiry, or `NULL` to let UBI use 0.
    #' @param lowest_price The numeric lowest price in rupees the order is moved to, above zero, or `NULL` for no floor.
    #' @param highest_price The numeric highest price in rupees the order is moved to, above zero and not below `lowest_price`, or `NULL` for no ceiling.
    #' @param step_ticks The integer smallest move in ticks worth a modification, at least 1, or `NULL` to let UBI use 1.
    #' @return A new `VolatilityOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      watch_instrument,
      volatility,
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
      interest_rate = NULL,
      lowest_price = NULL,
      highest_price = NULL,
      step_ticks = NULL
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
      self$watch_instrument <- watch_instrument
      self$volatility <- volatility
      self$interest_rate <- interest_rate
      self$lowest_price <- lowest_price
      self$highest_price <- highest_price
      self$step_ticks <- step_ticks
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      list(
        watch_instrument_id = self$watch_instrument$instrument_id,
        volatility = self$volatility,
        interest_rate = self$interest_rate,
        lowest_price = self$lowest_price,
        highest_price = self$highest_price,
        step_ticks = self$step_ticks
      )
    }
  )
)
