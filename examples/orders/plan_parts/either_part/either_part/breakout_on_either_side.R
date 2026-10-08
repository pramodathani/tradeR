#' Build a breakout that buys above a range or sells below it, whichever happens first.
#'
#' The program builds an either join with the sibling rule `cancel` around a range from 990 to 1010. A buy waits for the price to reach the top and a sell for it to reach the bottom; the first to fill cancels the other, and with `cancel_before_send` the one whose trigger holds clears its sibling before it is sent, so both can never fill. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/either_part/either_part/breakout_on_either_side.R

library(tradeR)

#' A buy above a range and a sell below it, where the first cancels the other.
#'
#' @field range_low The numeric bottom of the range in rupees.
#' @field range_high The numeric top of the range in rupees.
RangeBreakout <- R6::R6Class(
  "RangeBreakout",
  public = list(
    range_low = NULL,
    range_high = NULL,

    #' @description
    #' Sets the range.
    #' @return A new `RangeBreakout` object.
    initialize = function() {
      self$range_low <- 990.0
      self$range_high <- 1010.0
    },

    #' @description
    #' Builds the two breakout orders as one either join.
    #' @return The `EitherPart`.
    build_join = function() {
      EitherPart$new(
        children = list(
          OrderPart$new(
            side = "buy",
            trigger = PriceCrosses$new(
              level = self$range_high,
              direction = "at_or_above"
            ),
            pricing = MarketablePricing$new()
          ),
          OrderPart$new(
            side = "sell",
            trigger = PriceCrosses$new(
              level = self$range_low,
              direction = "at_or_below"
            ),
            pricing = MarketablePricing$new()
          )
        ),
        sibling_rule = "cancel",
        cancel_before_send = TRUE
      )
    },

    #' @description
    #' Prints the range and the join's object.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(sprintf("Range: %s to %s\n", self$range_low, self$range_high))
      cat(
        jsonlite::toJSON(
          self$build_join()$document(),
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
  RangeBreakout$new()$run()
}
