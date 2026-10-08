#' Build an intraday trade that closes itself at ten past three, before the broker squares it off.
#'
#' Brokers close intraday positions themselves shortly before the market shuts, often at a poor price. The program builds a then join whose child protects each fill of the entry with a market order held by a `time_at` condition until 15:10, so the position is closed on the trader's own terms. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_at/time_at/exit_before_the_intraday_square_off.R

library(tradeR)

#' An entry whose every fill is closed at market at 15:10.
#'
#' @field exit_time The character time of day the exit is sent at.
TimedIntradayExit <- R6::R6Class(
  "TimedIntradayExit",
  public = list(
    exit_time = NULL,

    #' @description
    #' Sets the exit time.
    #' @return A new `TimedIntradayExit` object.
    initialize = function() {
      self$exit_time <- "15:10"
    },

    #' @description
    #' Builds the entry and its timed exit.
    #' @return The `ThenPart`.
    build_plan = function() {
      ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          trigger = TimeAt$new(self$exit_time),
          pricing = FixedPricing$new(order_type = "MARKET")
        )
      )
    },

    #' @description
    #' Prints the plan's object.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(
        jsonlite::toJSON(
          self$build_plan()$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TimedIntradayExit$new()$run()
}
