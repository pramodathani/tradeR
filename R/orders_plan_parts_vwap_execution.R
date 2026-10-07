#' An execution that sends slices on a clock, each sized by the volume profile of the half hour it falls in
#'
#' @description
#' The `vwap` execution of a plan: slices sized by how busy the market usually is, a volume-weighted average price order.
#'
#' It sends `slices`, from 2 to 60, on the same clock as `TwapExecution`, but each slice takes the weight of the half hour it falls in, so slices near the busy open and close are bigger. The half hours are counted from the segment's own open, 09:15 for equity and 09:00 for currency and MCX, on the day the order starts working, and a slice after the last half hour takes the last weight. `volume_profile` gives the weights, one per half hour from the open; without it, an equity order takes UBI's NSE equity shape and a currency or commodity order gets even slices. Slices are whole lots, and a slice that comes to nothing is skipped.
#'
#' The span is given in one of two ways: `over_minutes`, or `until`, a time of day such as `"15:00"`, which spreads the slices from when the order starts until that time and is refused if the order starts after it. Giving both is refused. A VWAP can be the outer or the inner execution of a nested pair, and cannot carry a resting stop.
#' @examples
#' \dontrun{
#' execution <- VwapExecution$new(slices = 10, until = "15:00")
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
VwapExecution <- R6::R6Class(
  "VwapExecution",
  inherit = PlanPart,
  public = list(
    #' @field slices The integer number of slices, from 2 to 60.
    slices = NULL,
    #' @field over_minutes The numeric number of minutes the slices are spread across, or `NULL` when `until` is given.
    over_minutes = NULL,
    #' @field until The character time of day, such as `15:00`, the slices end by, or `NULL` when `over_minutes` is given.
    until = NULL,
    #' @field volume_profile The numeric vector of relative weights, one per half hour from the segment's open, or `NULL` for UBI's default.
    volume_profile = NULL,

    #' @description
    #' Initialises the execution with its slices, its span and its profile.
    #' @param slices The integer number of slices, from 2 to 60.
    #' @param over_minutes The numeric number of minutes the slices are spread across, or `NULL` when `until` is given.
    #' @param until The character time of day in India, `HH:MM`, the slices end by, or `NULL` when `over_minutes` is given.
    #' @param volume_profile A numeric vector of relative weights at or above zero, one per half hour from the segment's open, or `NULL` for UBI's NSE equity shape on equity and even slices elsewhere.
    #' @return A new `VwapExecution` object.
    initialize = function(
      slices,
      over_minutes = NULL,
      until = NULL,
      volume_profile = NULL
    ) {
      self$slices <- slices
      self$over_minutes <- over_minutes
      self$until <- until
      self$volume_profile <- volume_profile
    },

    #' @description
    #' Builds the `vwap` execution object UBI reads.
    #' @return A named list with the single key `vwap`, whose value holds `slices`, whichever of `over_minutes` and `until` is set, and `volume_profile` when it is set.
    #' @examples
    #' \dontrun{
    #' execution <- VwapExecution$new(slices = 10, over_minutes = 90)
    #' print(execution$document())
    #'
    #' execution <- VwapExecution$new(slices = 12, until = "15:00")
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   execution = VwapExecution$new(
    #'     slices = 8,
    #'     over_minutes = 120,
    #'     volume_profile = list(
    #'       3.0,
    #'       2.0,
    #'       1.5,
    #'       1.0
    #'     )
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 20
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      settings[["slices"]] <- self$slices
      if (!is.null(self$over_minutes)) {
        settings[["over_minutes"]] <- self$over_minutes
      }
      if (!is.null(self$until)) {
        settings[["until"]] <- self$until
      }
      if (!is.null(self$volume_profile)) {
        settings[["volume_profile"]] <- as.list(self$volume_profile)
      }
      list(
        vwap = settings
      )
    }
  )
)
