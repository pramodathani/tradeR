#' An execution that sends slices on a clock, each a fixed share smaller than the one before
#'
#' @description
#' The `front_loaded` execution of a plan: slices that shrink as they go, so most of the order trades early, an implementation shortfall order.
#'
#' It sends `slices`, from 2 to 60, on the same clock as `TwapExecution`, one every `over_minutes` times 60 divided by `slices` seconds, the first at once. Each slice is `1 - urgency × 0.5` of the one before, so an urgency of 0 is an even split and an urgency of 1 halves every slice; UBI's default urgency is 0.5, each slice three quarters of the last. Slices are whole lots, and a slice that comes to nothing is skipped.
#'
#' It can be the outer or the inner execution of a nested pair, and cannot carry a resting stop.
#' @examples
#' \dontrun{
#' execution <- FrontLoadedExecution$new(
#'   slices = 5,
#'   over_minutes = 30
#' )
#' part <- OrderPart$new(execution = execution)
#' document <- part$document()
#' }
#' @export
FrontLoadedExecution <- R6::R6Class(
  "FrontLoadedExecution",
  inherit = PlanPart,
  public = list(
    #' @field slices The integer number of slices, from 2 to 60.
    slices = NULL,
    #' @field over_minutes The numeric number of minutes the slices are spread across, above zero.
    over_minutes = NULL,
    #' @field urgency The numeric from 0 to 1 saying how front-loaded the schedule is, or `NULL` for UBI's default of 0.5.
    urgency = NULL,

    #' @description
    #' Initialises the execution with its slices, its span and its urgency.
    #' @param slices The integer number of slices, from 2 to 60.
    #' @param over_minutes The numeric number of minutes the slices are spread across, above zero.
    #' @param urgency The numeric from 0, an even split, to 1, each slice half the one before, or `NULL` for UBI's default of 0.5.
    #' @return A new `FrontLoadedExecution` object.
    initialize = function(
      slices,
      over_minutes,
      urgency = NULL
    ) {
      self$slices <- slices
      self$over_minutes <- over_minutes
      self$urgency <- urgency
    },

    #' @description
    #' Builds the `front_loaded` execution object UBI reads.
    #' @return A named list with the single key `front_loaded`, whose value holds `slices`, `over_minutes` and, when it is set, `urgency`.
    #' @examples
    #' \dontrun{
    #' execution <- FrontLoadedExecution$new(
    #'   slices = 5,
    #'   over_minutes = 30
    #' )
    #' print(execution$document())
    #'
    #' execution <- FrontLoadedExecution$new(
    #'   slices = 4,
    #'   over_minutes = 20,
    #'   urgency = 1.0
    #' )
    #' print(execution$document())
    #'
    #' part <- OrderPart$new(
    #'   execution = FrontLoadedExecution$new(
    #'     slices = 6,
    #'     over_minutes = 60,
    #'     urgency = 0.8
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 50
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      settings[["slices"]] <- self$slices
      settings[["over_minutes"]] <- self$over_minutes
      if (!is.null(self$urgency)) {
        settings[["urgency"]] <- self$urgency
      }
      list(
        front_loaded = settings
      )
    }
  )
)
