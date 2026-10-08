#' Build a buy that waits for the open to settle and then goes in evenly over an hour.
#'
#' The program builds an order that waits until 09:45 and then sends twelve equal TWAP slices, one every five minutes, each priced two ticks past the offer when it is sent so every slice trades. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/twap_execution/twap_execution/even_slices_after_the_open.R

library(tradeR)

#' A buy sent as twelve TWAP slices from 09:45.
#'
#' @field execution The `TwapExecution` the order is sent with.
#' @field part The `OrderPart` the program prints.
TwapAfterTheOpen <- R6::R6Class(
  "TwapAfterTheOpen",
  public = list(
    execution = NULL,
    part = NULL,

    #' @description
    #' Builds the order.
    #' @return A new `TwapAfterTheOpen` object.
    initialize = function() {
      self$execution <- TwapExecution$new(
        slices = 12,
        over_minutes = 60
      )
      self$part <- OrderPart$new(
        trigger = TimeAt$new("09:45"),
        pricing = MarketablePricing$new(buffer_ticks = 2),
        execution = self$execution
      )
    },

    #' @description
    #' Prints the order's object and the gap between slices.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(
        jsonlite::toJSON(
          self$part$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      seconds_apart <- self$execution$over_minutes * 60 / self$execution$slices
      cat(
        sprintf(
          "One slice every %.0f seconds, the first at 09:45.\n",
          seconds_apart
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TwapAfterTheOpen$new()$run()
}
