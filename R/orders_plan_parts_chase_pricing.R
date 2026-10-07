#' A pricing rule that steps a limit from its own side of the book towards the other side
#'
#' @description
#' The `chase` pricing rule of a plan: a limit that starts on its own side of the book and walks towards the other until it fills.
#'
#' The order starts at its own touch, and every `step_seconds` it moves `step_ticks` towards the market from where it actually is, never past the other side's touch. With `cross_after_seconds`, once that long has passed the order is moved to the other side's touch, where it fills against what is resting. A cap beside the rule holds every step.
#' @examples
#' \dontrun{
#' pricing <- ChasePricing$new(step_ticks = 1, step_seconds = 5)
#' document <- pricing$document()
#' }
#' @export
ChasePricing <- R6::R6Class(
  "ChasePricing",
  inherit = PlanPart,
  public = list(
    #' @field step_ticks The integer number of ticks each step moves, at least 1, or `NULL` for UBI's default of 1.
    step_ticks = NULL,
    #' @field step_seconds The numeric number of seconds between steps, above zero, or `NULL` for UBI's default of 5.
    step_seconds = NULL,
    #' @field cross_after_seconds The numeric number of seconds after which the order is moved to the other side's touch, or `NULL` to walk until it reaches the touch.
    cross_after_seconds = NULL,

    #' @description
    #' Initialises the rule with its step and timing.
    #' @param step_ticks The integer number of ticks each step moves, at least 1, or `NULL` for UBI's default of 1.
    #' @param step_seconds The numeric number of seconds between steps, above zero, or `NULL` for UBI's default of 5.
    #' @param cross_after_seconds The numeric number of seconds after which the order is moved to the other side's touch, above zero, or `NULL` to keep walking.
    #' @return A new `ChasePricing` object.
    initialize = function(
      step_ticks = NULL,
      step_seconds = NULL,
      cross_after_seconds = NULL
    ) {
      self$step_ticks <- step_ticks
      self$step_seconds <- step_seconds
      self$cross_after_seconds <- cross_after_seconds
    },

    #' @description
    #' Builds the `chase` pricing object UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `chase`, whose value holds `step_ticks`, `step_seconds` and `cross_after_seconds` when each is set.
    #' @examples
    #' \dontrun{
    #' pricing <- ChasePricing$new()
    #' print(pricing$document())
    #'
    #' pricing <- ChasePricing$new(
    #'   step_ticks = 2,
    #'   step_seconds = 10,
    #'   cross_after_seconds = 60
    #' )
    #' print(pricing$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$step_ticks)) {
        settings[["step_ticks"]] <- self$step_ticks
      }
      if (!is.null(self$step_seconds)) {
        settings[["step_seconds"]] <- self$step_seconds
      }
      if (!is.null(self$cross_after_seconds)) {
        settings[["cross_after_seconds"]] <- self$cross_after_seconds
      }
      list(
        chase = settings
      )
    }
  )
)
