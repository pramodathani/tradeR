#' Build trigger groups for three trading windows of the day, each a start time and an end time.
#'
#' A `time_before` condition on its own holds at once, so it is paired with a `time_after` condition to make a window. The program builds the morning, midday and afternoon windows and prints each group's object, ready to be joined with a price condition. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_before/time_before/trading_windows.R

library(tradeR)

#' Three windows of the trading day.
#'
#' @field windows The named list of a window name to a character vector of two times of day, the start and the end.
TradingWindows <- R6::R6Class(
  "TradingWindows",
  public = list(
    windows = NULL,

    #' @description
    #' Sets the windows.
    #' @return A new `TradingWindows` object.
    initialize = function() {
      self$windows <- list(
        morning = c(
          "09:30",
          "11:00"
        ),
        midday = c(
          "11:00",
          "13:30"
        ),
        afternoon = c(
          "13:30",
          "15:00"
        )
      )
    },

    #' @description
    #' Builds the group that holds between two times.
    #' @param start The character time of day the window opens.
    #' @param end The character time of day the window closes.
    #' @return The `AllConditions` group.
    window = function(start, end) {
      AllConditions$new(
        list(
          TimeAfter$new(start),
          TimeBefore$new(end)
        )
      )
    },

    #' @description
    #' Prints each window's object.
    #' @return `NULL`, invisibly.
    run = function() {
      for (name in names(self$windows)) {
        times <- self$windows[[name]]
        start <- times[[1]]
        end <- times[[2]]
        document <- jsonlite::toJSON(
          self$window(start, end)$document(),
          auto_unbox = TRUE,
          null = "null",
          digits = NA
        )
        cat(sprintf("%s: %s\n", name, document))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TradingWindows$new()$run()
}
