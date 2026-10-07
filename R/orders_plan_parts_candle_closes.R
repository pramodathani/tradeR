#' A condition that holds when a bar UBI builds from its own ticks closes past a level
#'
#' @description
#' The `candle_closes` trigger of a plan: a whole bar closing past a level, rather than any tick touching it.
#'
#' UBI builds the bars itself from the last traded price it sees, aligned to the clock and `bar_minutes` long, 5 minutes by default. The condition answers once per bar, at its close, so a wick through the level does not count, and nothing is known until the first bar after the order rests has closed. With no direction, a position opened with a buy waits for a close at or below the level and one opened with a sell for a close at or above it, which is a stop's meaning.
#' @examples
#' \dontrun{
#' condition <- CandleCloses$new(level = 995.0, bar_minutes = 15)
#' document <- condition$document()
#' }
#' @export
CandleCloses <- R6::R6Class(
  "CandleCloses",
  inherit = PlanPart,
  public = list(
    #' @field level The numeric level in rupees that a close must reach.
    level = NULL,
    #' @field direction The character direction, `at_or_above` or `at_or_below`, or `NULL` to take it from the side that opened the position.
    direction = NULL,
    #' @field bar_minutes The numeric length of one bar in minutes, or `NULL` for UBI's default of 5.
    bar_minutes = NULL,

    #' @description
    #' Initialises the condition with its level and settings.
    #' @param level The numeric level in rupees, above zero.
    #' @param direction The character direction, `at_or_above` or `at_or_below`, or `NULL` for a long to wait for a close at or below the level and a short for one at or above it.
    #' @param bar_minutes The numeric length of one bar in minutes, above zero, or `NULL` for UBI's default of 5.
    #' @return A new `CandleCloses` object.
    initialize = function(
      level,
      direction = NULL,
      bar_minutes = NULL
    ) {
      self$level <- level
      self$direction <- direction
      self$bar_minutes <- bar_minutes
    },

    #' @description
    #' Builds the `candle_closes` condition UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `candle_closes`, whose value holds `level` and each other setting that is set.
    #' @examples
    #' \dontrun{
    #' condition <- CandleCloses$new(level = 995.0)
    #' print(condition$document())
    #'
    #' condition <- CandleCloses$new(
    #'   level = 1010.0,
    #'   direction = "at_or_above",
    #'   bar_minutes = 15
    #' )
    #' print(condition$document())
    #'
    #' part <- OrderPart$new(
    #'   side = "protect",
    #'   trigger = CandleCloses$new(level = 990.0),
    #'   pricing = MarketablePricing$new()
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- list(
        level = self$level
      )
      if (!is.null(self$direction)) {
        settings[["direction"]] <- self$direction
      }
      if (!is.null(self$bar_minutes)) {
        settings[["bar_minutes"]] <- self$bar_minutes
      }
      list(
        candle_closes = settings
      )
    }
  )
)
