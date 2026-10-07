#' A condition that holds from a time of day onwards
#'
#' @description
#' The `time_at` trigger of a plan: a time of day reached on the instrument's next trading day.
#'
#' UBI works the moment out once, when the plan is placed, so a time already passed on a trading day is refused, and a weekend or holiday rolls to the next trading day. It holds from that moment on, exactly as `time_after` does; the two names exist so a plan reads naturally.
#' @examples
#' \dontrun{
#' condition <- TimeAt$new("10:00")
#' document <- condition$document()
#' }
#' @export
TimeAt <- R6::R6Class(
  "TimeAt",
  inherit = PlanPart,
  public = list(
    #' @field time The character time of day, such as `10:00`.
    time = NULL,

    #' @description
    #' Initialises the condition with its time of day.
    #' @param time The character time of day in India, such as `10:00` or `14:45`.
    #' @return A new `TimeAt` object.
    initialize = function(time) {
      self$time <- time
    },

    #' @description
    #' Builds the `time_at` condition UBI reads.
    #' @return A named list with the single key `time_at`, whose value is the character time of day.
    #' @examples
    #' \dontrun{
    #' print(TimeAt$new("10:00")$document())
    #'
    #' part <- OrderPart$new(trigger = TimeAt$new("14:45"))
    #' print(part$document())
    #' }
    document = function() {
      list(
        time_at = self$time
      )
    }
  )
)
