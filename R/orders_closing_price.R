ORDERS_CLOSING_PRICE_SYNTHETIC_TYPE <- "closing_price"

#' An order sliced by volume through the half hour the day's closing price is computed from
#'
#' @description
#' This is market-on-close or limit-on-close, the Atlas's G2. NSE and BSE compute an equity's closing price as the volume weighted average of the trades from 15:00 to 15:30, so this is a volume weighted order spread across that window, which is the nearest there is for futures, options and intraday orders; only the cash segment's post-closing session fills at the closing price exactly, and it takes only delivery orders. The length is worked out from the window, so there is no `over_minutes`. An order sent before the window answers HTTP 202 with an `outcome` of `armed` and sends its first slice when the window opens, one sent inside the window sends its first slice at once and spreads the rest over what is left, and one sent after 15:30 is refused with HTTP 400. The window follows the instrument's exchange trading calendar. Slices are shared out in whole lots, and a slice that comes to nothing, as it does when the order has fewer lots than slices, is skipped and the schedule moves on.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- ClosingPriceOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 600,
#'   price = 1000.0,
#'   slices = 6,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
ClosingPriceOrder <- R6::R6Class(
  "ClosingPriceOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_CLOSING_PRICE_SYNTHETIC_TYPE,
    #' @field slices The integer number of slices, from 2 to 60, or `NULL` to let UBI use 6, one every five minutes across the default window. A quantity of fewer lots than this is accepted, and the empty slices are skipped.
    slices = NULL,
    #' @field window_start The character time the window opens, as `HH:MM` or `HH:MM:SS` India time, from 09:15 and before 15:30, or `NULL` to let UBI use `15:00`.
    window_start = NULL,
    #' @field volume_profile The list of numeric relative weights, kept as a list so it is sent as a JSON array even when it holds one weight, one per half hour from the open, none negative and adding up to more than zero, or `NULL` to let UBI use its own.
    volume_profile = NULL,

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
    #' @param slices The integer number of slices, from 2 to 60, or `NULL` to let UBI use 6, one every five minutes across the default window. A quantity of fewer lots than this is accepted, and the empty slices are skipped.
    #' @param window_start The character time the window opens, as `HH:MM` or `HH:MM:SS` India time, from 09:15 and before 15:30, or `NULL` to let UBI use `15:00`.
    #' @param volume_profile A numeric vector or list of relative weights, one per half hour from the open, none negative and adding up to more than zero, or `NULL` to let UBI use its own.
    #' @return A new `ClosingPriceOrder` object.
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
      slices = NULL,
      window_start = NULL,
      volume_profile = NULL
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
      self$slices <- slices
      self$window_start <- window_start
      self$volume_profile <- NULL
      if (!is.null(volume_profile)) {
        self$volume_profile <- as.list(volume_profile)
      }
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- ClosingPriceOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "cnc",
    #'   order_type = "limit",
    #'   quantity = 10,
    #'   price = 13.0,
    #'   slices = 10
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- ClosingPriceOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "cnc",
    #'   order_type = "limit",
    #'   quantity = 12,
    #'   price = 13.0,
    #'   slices = 6,
    #'   window_start = "14:45",
    #'   volume_profile = list(
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     1.0,
    #'     3.0
    #'   )
    #' )
    #' print(order$synthetic)
    #' }
    synthetic_fields = function() {
      list(
        slices = self$slices,
        window_start = self$window_start,
        volume_profile = self$volume_profile
      )
    }
  )
)
