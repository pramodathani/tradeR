#' One order sent a number of times, spaced by minutes or by trading days
#'
#' @description
#' The `repeat` join of a plan: one order sent again and again, on a timer or once each trading day.
#'
#' The child must be a plain `OrderPart`, not another join, and UBI sends it `times` times, from 1 to 100. Exactly one of `every_minutes` and `every_trading_day_at` must be given. With `every_minutes`, the first copy goes at once and each later copy that many minutes after the one before, counted from when the plan was placed. With `every_trading_day_at`, each copy goes at that time on its own trading day and the plan is kept across days. With `until`, a condition, every copy still waiting is ended once the condition holds; the order then takes no lifetime of its own. UBI also refuses, with the rule `repeat_needs_order`, a child whose presets make it a join, such as a `bracket`, and a child naming a type kept whole, such as a `grid`, because either would place its orders at once rather than wait its turn. A repeat join cannot be a `then` join's child.
#' @examples
#' \dontrun{
#' part <- RepeatPart$new(
#'   child = OrderPart$new(quantity = 10),
#'   times = 6,
#'   every_minutes = 30
#' )
#' document <- part$document()
#' }
#' @export
RepeatPart <- R6::R6Class(
  "RepeatPart",
  inherit = PlanPart,
  public = list(
    #' @field child The `PlanPart` `OrderPart` sent each time.
    child = NULL,
    #' @field times The integer number of copies sent, from 1 to 100.
    times = NULL,
    #' @field every_minutes The numeric minutes between one copy and the next, or `NULL` when `every_trading_day_at` is given.
    every_minutes = NULL,
    #' @field every_trading_day_at The character time of day each copy is sent on its own trading day, such as `09:20`, or `NULL` when `every_minutes` is given.
    every_trading_day_at = NULL,
    #' @field until The `PlanPart` condition that ends every copy still waiting, or `NULL`.
    until = NULL,

    #' @description
    #' Initialises the join with its order and schedule.
    #' @param child The `PlanPart` sent each time, which must be a plain `OrderPart`; UBI refuses a join here, and a preset that stands for a join or a type kept whole, with the rule `repeat_needs_order`.
    #' @param times The integer number of copies, from 1 to 100.
    #' @param every_minutes The numeric minutes above zero between copies, or `NULL` when `every_trading_day_at` is given.
    #' @param every_trading_day_at The character time of day in India, such as `09:20`, at which each copy is sent on its own trading day, or `NULL` when `every_minutes` is given.
    #' @param until A `PlanPart` condition, such as `PriceCrosses` or `TimeAt`, that ends every copy still waiting once it holds, or `NULL` to let every copy run.
    #' @return A new `RepeatPart` object.
    initialize = function(
      child,
      times,
      every_minutes = NULL,
      every_trading_day_at = NULL,
      until = NULL
    ) {
      self$child <- child
      self$times <- times
      self$every_minutes <- every_minutes
      self$every_trading_day_at <- every_trading_day_at
      self$until <- until
    },

    #' @description
    #' Builds the `repeat` node UBI reads.
    #' @return A named list with the single key `repeat`, whose value holds `child`, `times`, and each of `every_minutes`, `every_trading_day_at` and `until` that is not `NULL`.
    #' @examples
    #' \dontrun{
    #' part <- RepeatPart$new(
    #'   child = OrderPart$new(quantity = 10),
    #'   times = 6,
    #'   every_minutes = 30
    #' )
    #' print(part$document())
    #'
    #' part <- RepeatPart$new(
    #'   child = OrderPart$new(
    #'     pricing = MarketablePricing$new(buffer_ticks = 2)
    #'   ),
    #'   times = 5,
    #'   every_trading_day_at = "09:20",
    #'   until = PriceCrosses$new(
    #'     level = 1050.0,
    #'     direction = "at_or_above"
    #'   )
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- list(
        child = self$child$document(),
        times = self$times
      )
      if (!is.null(self$every_minutes)) {
        settings[["every_minutes"]] <- self$every_minutes
      }
      if (!is.null(self$every_trading_day_at)) {
        settings[["every_trading_day_at"]] <- self$every_trading_day_at
      }
      if (!is.null(self$until)) {
        settings[["until"]] <- self$until$document()
      }
      list(
        `repeat` = settings
      )
    }
  )
)
