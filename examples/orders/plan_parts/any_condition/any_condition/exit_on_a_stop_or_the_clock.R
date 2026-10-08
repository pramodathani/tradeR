#' Build an exit that fires on a fall to a stop level or at ten past three, whichever comes first.
#'
#' A day trade should end either when it goes wrong or when the day ends. The program puts a fall to 990 and a `time_at` condition at 15:10 in an `AnyCondition` group on a protecting market order, and builds it behind an entry as a then join. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/any_condition/any_condition/exit_on_a_stop_or_the_clock.R

library(tradeR)

#' An entry whose exit fires on a stop level or at 15:10.
#'
#' @field stop_level The numeric level in rupees that fires the exit.
#' @field exit_time The character time of day that fires the exit.
StopOrClockExit <- R6::R6Class(
  "StopOrClockExit",
  public = list(
    stop_level = NULL,
    exit_time = NULL,

    #' @description
    #' Sets the level and the time.
    #' @return A new `StopOrClockExit` object.
    initialize = function() {
      self$stop_level <- 990.0
      self$exit_time <- "15:10"
    },

    #' @description
    #' Prints the plan's object.
    #' @return `NULL`, invisibly.
    run = function() {
      plan <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          trigger = AnyCondition$new(
            list(
              PriceCrosses$new(
                level = self$stop_level,
                direction = "at_or_below"
              ),
              TimeAt$new(self$exit_time)
            )
          ),
          pricing = FixedPricing$new(order_type = "MARKET")
        )
      )
      cat(
        jsonlite::toJSON(
          plan$document(),
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
  StopOrClockExit$new()$run()
}
