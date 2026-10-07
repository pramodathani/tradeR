#' A condition that holds from a time of day onwards
#'
#' @description
#' The `time_after` trigger of a plan: from a time of day onwards on the instrument's next trading day.
#'
#' It holds exactly as `time_at` does, and reads better inside `AllConditions`, where it keeps another condition to the part of the day after the time.
#' @examples
#' \dontrun{
#' condition <- TimeAfter$new("09:30")
#' document <- condition$document()
#' }
#' @export
TimeAfter <- R6::R6Class(
  "TimeAfter",
  inherit = PlanPart,
  public = list(
    #' @field time The character time of day, such as `09:30`.
    time = NULL,

    #' @description
    #' Initialises the condition with its time of day.
    #' @param time The character time of day in India, such as `09:30`.
    #' @return A new `TimeAfter` object.
    initialize = function(time) {
      self$time <- time
    },

    #' @description
    #' Builds the `time_after` condition UBI reads.
    #' @return A named list with the single key `time_after`, whose value is the character time of day.
    #' @examples
    #' \dontrun{
    #' print(TimeAfter$new("09:30")$document())
    #'
    #' condition <- AllConditions$new(
    #'   list(
    #'     TimeAfter$new("09:30"),
    #'     PriceCrosses$new(level = 995.0)
    #'   )
    #' )
    #' print(condition$document())
    #' }
    document = function() {
      list(
        time_after = self$time
      )
    }
  )
)
