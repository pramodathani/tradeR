ORDERS_SQUARE_OFF_SYNTHETIC_TYPE <- "square_off"

#' The day's positions on one product, closed with limit orders at a time of day after their resting orders are cancelled
#'
#' @description
#' UBI decides the side, the order type and the quantity of every closing order from the positions, so the template carries placeholders for them. The instrument only anchors the request; it does not limit what is closed. It answers HTTP 202 with an `outcome` of `armed` and sends nothing until `at_time`, so keep the `parent_id` from the answer. At that time UBI cancels every open order on each instrument it closes, including stops still waiting for their trigger, and sends each closing order on the product of the position it closes. Times follow the instrument's exchange trading calendar: on a weekend or an exchange holiday a time means that time on the next trading day.
#'
#' The order template's attributes are described on `SyntheticOrder`.
#'
#' @examples
#' \dontrun{
#' order <- SquareOffOrder$new(
#'   share,
#'   at_time = "15:05",
#'   product = "mis",
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
SquareOffOrder <- R6::R6Class(
  "SquareOffOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_SQUARE_OFF_SYNTHETIC_TYPE,
    #' @field at_time The character time of day to square off, as `HH:MM` or `HH:MM:SS` India time.
    at_time = NULL,
    #' @field only_instruments The list of `TradeableInstrument` to limit the square-off to, or `NULL` for every position on the product.
    only_instruments = NULL,

    #' @description
    #' Initialises the square-off.
    #' @param instrument The `TradeableInstrument` that anchors the request, which does not limit what is closed.
    #' @param at_time The character time of day to square off, as `HH:MM` or `HH:MM:SS` India time, later today and well before the broker's own square-off.
    #' @param product The character order product of the positions to close and of the closing orders, `"cnc"`, `"mis"` or `"nrml"`.
    #' @param only_instruments The list of `TradeableInstrument` to limit the square-off to, or `NULL` for every position on the product.
    #' @param validity The character validity of the closing orders, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param tag A character label of up to twenty letters and digits to label the request with, or `NULL`.
    #' @param closes_position A logical that is `TRUE` to let the closing orders use the share of a broker's daily order cap kept for exits, which is what a square-off is.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI check the request and return it without recording or sending anything.
    #' @return A new `SquareOffOrder` object.
    initialize = function(
      instrument,
      at_time,
      product = "mis",
      only_instruments = NULL,
      validity = NULL,
      tag = NULL,
      closes_position = TRUE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    ) {
      super$initialize(
        instrument,
        transaction_type = "sell",
        product = product,
        order_type = "market",
        quantity = 1,
        validity = validity,
        tag = tag,
        closes_position = closes_position,
        reduce_only = reduce_only,
        hold_limits = hold_limits,
        dry_run = dry_run
      )
      self$at_time <- at_time
      self$only_instruments <- only_instruments
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #'
    #' UBI filters positions by their product as the positions route spells it, so the order product is translated: `mis` becomes `intraday`, `cnc` becomes `delivery` and `nrml` becomes `carry`. A product with no translation is sent as given.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      position_product <- self$product
      lowered_product <- tolower(self$product)
      known_products <- names(INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT)
      if (lowered_product %in% known_products) {
        position_product <-
          INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT[[lowered_product]]
      }
      instrument_ids <- NULL
      if (length(self$only_instruments) > 0) {
        instrument_ids <- list()
        for (chosen_instrument in self$only_instruments) {
          instrument_ids[[length(instrument_ids) + 1]] <-
            chosen_instrument$instrument_id
        }
      }
      list(
        at_time = self$at_time,
        product = position_product,
        instrument_ids = instrument_ids
      )
    }
  )
)
