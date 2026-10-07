#' One watched instrument and how much exposure each unit of its position carries
#'
#' @description
#' One instrument whose position counts towards the exposure an `ExposureHedgeOrder` keeps inside a band.
#'
#' @examples
#' \dontrun{
#' watch <- ExposureWatch$new(nifty_call, exposure_per_unit = 0.5)
#' document <- watch$document()
#' }
#' @export
ExposureWatch <- R6::R6Class(
  "ExposureWatch",
  public = list(
    #' @field instrument The `Instrument` whose net position is counted.
    instrument = NULL,
    #' @field exposure_per_unit The numeric exposure one unit of the position carries, or `NULL` to let UBI count 1.
    exposure_per_unit = NULL,

    #' @description
    #' Initialises the watch.
    #' @param instrument The `Instrument` whose net position is counted.
    #' @param exposure_per_unit The numeric exposure one unit carries, such as an option's delta, or `NULL` to let UBI count 1.
    #' @return A new `ExposureWatch` object.
    initialize = function(instrument, exposure_per_unit = NULL) {
      self$instrument <- instrument
      self$exposure_per_unit <- exposure_per_unit
    },

    #' @description
    #' Builds the watched object UBI reads.
    #' @return A named list with `instrument_id`, and `exposure_per_unit` when it is set.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' watch <- ExposureWatch$new(share)
    #' print(watch$document())
    #'
    #' first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' watches <- list(
    #'   ExposureWatch$new(first_share, exposure_per_unit = 1.2),
    #'   ExposureWatch$new(second_share, exposure_per_unit = 0.8)
    #' )
    #' for (watch in watches) {
    #'   print(watch$document())
    #' }
    #' }
    document = function() {
      watched <- list(
        instrument_id = self$instrument$instrument_id
      )
      if (!is.null(self$exposure_per_unit)) {
        watched[["exposure_per_unit"]] <- self$exposure_per_unit
      }
      watched
    }
  )
)
