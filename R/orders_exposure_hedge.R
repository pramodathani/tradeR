ORDERS_EXPOSURE_HEDGE_SYNTHETIC_TYPE <- "exposure_hedge"

#' A standing instruction to trade one hedge instrument whenever the watched instruments' net exposure leaves a band
#'
#' @description
#' The instrument it is built on is the hedge, which is what it trades. UBI works out the side and the quantity of each hedge from the exposure, so the template carries placeholders for them. It answers HTTP 202 with an `outcome` of `armed` and sends nothing until the exposure leaves the band, so keep the `parent_id` from the answer. Each hedge is a whole number of lots of the hedge instrument, rounded down, that brings the total back towards the middle of the band. A hedge already sent counts at once, so it is not sent again while the positions catch up: a resting hedge counts for its whole quantity, and a finished one for what it filled. UBI measures nothing while its positions document is missing, more than a minute old, or marks a broker `stale` or `unreadable`, and prices nothing from a quote marked stale, so the hedge waits rather than trading on old numbers. When a hedge is refused, UBI stops watching and cancels any hedge still resting, and the parent ends `failed` when anything traded, or `rejected` when nothing did. When the hedge instrument is also watched, UBI measures nothing after a hedge fills until the positions document shows that broker's positions observed after the fill, so a slow positions feed delays the next hedge rather than undoing the last one.
#'
#' The order template's attributes are described on `SyntheticOrder`, where `instrument` is the hedge instrument.
#'
#' @examples
#' \dontrun{
#' order <- ExposureHedgeOrder$new(
#'   nifty_future,
#'   watched = list(
#'     ExposureWatch$new(nifty_call, exposure_per_unit = 0.5),
#'     ExposureWatch$new(nifty_put, exposure_per_unit = -0.4)
#'   ),
#'   lower_band = -75.0,
#'   upper_band = 75.0,
#'   product = "nrml",
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
ExposureHedgeOrder <- R6::R6Class(
  "ExposureHedgeOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_EXPOSURE_HEDGE_SYNTHETIC_TYPE,
    #' @field watched The list of `ExposureWatch` whose positions are added up.
    watched = NULL,
    #' @field lower_band The numeric lowest net exposure allowed before a hedge is traded.
    lower_band = NULL,
    #' @field upper_band The numeric highest net exposure allowed before a hedge is traded.
    upper_band = NULL,
    #' @field hedge_exposure_per_unit The numeric exposure one unit of the hedge carries, or `NULL` to let UBI count 1.
    hedge_exposure_per_unit = NULL,

    #' @description
    #' Initialises the hedge.
    #' @param hedge_instrument The `TradeableInstrument` traded to bring the exposure back inside the band.
    #' @param watched The list of `ExposureWatch` whose positions are added up.
    #' @param lower_band The numeric lowest net exposure allowed, below `upper_band`.
    #' @param upper_band The numeric highest net exposure allowed, above `lower_band`.
    #' @param product The character product of the hedge orders, `"cnc"`, `"mis"` or `"nrml"`.
    #' @param hedge_exposure_per_unit The numeric exposure one unit of the hedge carries, which must not be zero, or `NULL` to let UBI count 1.
    #' @param validity The character validity of the hedge orders, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param tag A character label of up to twenty letters and digits to label the request with, or `NULL`.
    #' @param closes_position A logical that is `TRUE` when every hedge closes a position, so it may use the share of a broker's daily order cap kept for exits.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI check the request and return it without recording or sending anything.
    #' @return A new `ExposureHedgeOrder` object.
    initialize = function(
      hedge_instrument,
      watched,
      lower_band,
      upper_band,
      product,
      hedge_exposure_per_unit = NULL,
      validity = NULL,
      tag = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    ) {
      super$initialize(
        hedge_instrument,
        transaction_type = "buy",
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
      self$watched <- as.list(watched)
      self$lower_band <- lower_band
      self$upper_band <- upper_band
      self$hedge_exposure_per_unit <- hedge_exposure_per_unit
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, holding the watched instruments as UBI reads them and the hedge instrument's id, where a value of `NULL` means the field is left out.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' order <- ExposureHedgeOrder$new(
    #'   second_share,
    #'   watched = list(
    #'     ExposureWatch$new(share)
    #'   ),
    #'   lower_band = -5,
    #'   upper_band = 5,
    #'   product = "mis"
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' order <- ExposureHedgeOrder$new(
    #'   second_share,
    #'   watched = list(
    #'     ExposureWatch$new(share, exposure_per_unit = 0.5)
    #'   ),
    #'   lower_band = -10,
    #'   upper_band = 10,
    #'   product = "mis",
    #'   hedge_exposure_per_unit = 2.0
    #' )
    #' fields <- order$synthetic_fields()
    #' print(fields[["hedge_instrument_id"]] == second_share$instrument_id)
    #' print(fields[["watched"]])
    #' }
    synthetic_fields = function() {
      documents <- list()
      for (watch in self$watched) {
        documents[[length(documents) + 1]] <- watch$document()
      }
      list(
        watched = documents,
        lower_band = self$lower_band,
        upper_band = self$upper_band,
        hedge_instrument_id = self$instrument$instrument_id,
        hedge_exposure_per_unit = self$hedge_exposure_per_unit
      )
    }
  )
)
