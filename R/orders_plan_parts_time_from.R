#' A condition that holds from a time of day onwards, and at once when that time has already passed today
#'
#' @description
#' The `time_from` trigger of a plan: from a time of day onwards, starting at once when that time has already passed today.
#'
#' It differs from `time_at` and `time_after` only in what happens to a time already passed on a trading day. Those two refuse such a time when the plan is placed, while `time_from` holds at once, so an order placed inside its window starts straight away rather than being refused. A time not yet reached today, or any time on a weekend or holiday, waits for that time on the instrument's next trading day, as `time_at` does.
#' @examples
#' \dontrun{
#' condition <- TimeFrom$new("15:00")
#' document <- condition$document()
#' }
#' @export
TimeFrom <- R6::R6Class(
  "TimeFrom",
  inherit = PlanPart,
  public = list(
    #' @field time The character time of day, such as `15:00`.
    time = NULL,

    #' @description
    #' Initialises the condition with its time of day.
    #' @param time The character time of day in India, such as `15:00` or `09:20:30`.
    #' @return A new `TimeFrom` object.
    initialize = function(time) {
      self$time <- time
    },

    #' @description
    #' Builds the `time_from` condition UBI reads.
    #' @return A named list with the single key `time_from`, whose value is the character time of day.
    #' @examples
    #' \dontrun{
    #' print(TimeFrom$new("15:00")$document())
    #'
    #' part <- OrderPart$new(
    #'   trigger = TimeFrom$new("09:20"),
    #'   pricing = MarketablePricing$new()
    #' )
    #' print(part$document())
    #' }
    document = function() {
      list(
        time_from = self$time
      )
    }
  )
)
