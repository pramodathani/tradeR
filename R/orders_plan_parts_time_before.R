#' A condition that holds until a time of day
#'
#' @description
#' The `time_before` trigger of a plan: until a time of day on the instrument's next trading day.
#'
#' On its own it holds at once, so it is meant for `AllConditions`, where it keeps another condition to the part of the day before the time.
#' @examples
#' \dontrun{
#' condition <- TimeBefore$new("15:00")
#' document <- condition$document()
#' }
#' @export
TimeBefore <- R6::R6Class(
  "TimeBefore",
  inherit = PlanPart,
  public = list(
    #' @field time The character time of day, such as `15:00`.
    time = NULL,

    #' @description
    #' Initialises the condition with its time of day.
    #' @param time The character time of day in India, such as `15:00`.
    #' @return A new `TimeBefore` object.
    initialize = function(time) {
      self$time <- time
    },

    #' @description
    #' Builds the `time_before` condition UBI reads.
    #' @return A named list with the single key `time_before`, whose value is the character time of day.
    #' @examples
    #' \dontrun{
    #' print(TimeBefore$new("15:00")$document())
    #'
    #' condition <- AllConditions$new(
    #'   list(
    #'     TimeAfter$new("10:00"),
    #'     TimeBefore$new("15:00"),
    #'     PriceCrosses$new(level = 995.0)
    #'   )
    #' )
    #' print(condition$document())
    #' }
    document = function() {
      list(
        time_before = self$time
      )
    }
  )
)
