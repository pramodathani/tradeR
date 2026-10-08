#' Build a trailing exit kept inside UBI's order engine, which sends a marketable limit when the price pulls back.
#'
#' Unlike a `TrailPricing` stop, nothing rests at the broker: the engine watches the best price and, once the last price pulls back five rupees from it, sends a protecting order a few ticks past the other side of the book. The program builds that order as a then join behind an entry and prints it. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/trails/trails/engine_side_trailing_exit.R

library(tradeR)

#' An entry followed by an exit that fires on a five-rupee pullback.
#'
#' @field pullback_points The numeric pullback in rupees that fires the exit.
EngineTrailingExit <- R6::R6Class(
  "EngineTrailingExit",
  public = list(
    pullback_points = NULL,

    #' @description
    #' Sets the pullback distance.
    #' @return A new `EngineTrailingExit` object.
    initialize = function() {
      self$pullback_points <- 5.0
    },

    #' @description
    #' Builds the entry and its trailing exit.
    #' @return The `ThenPart`.
    build_plan = function() {
      ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          trigger = Trails$new(points = self$pullback_points),
          pricing = MarketablePricing$new(buffer_ticks = 3)
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
      cat("The exit does nothing while the order engine is down.\n")
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  EngineTrailingExit$new()$run()
}
