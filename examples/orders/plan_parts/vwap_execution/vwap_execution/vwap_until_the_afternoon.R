#' Build a VWAP sell of Vodafone Idea that runs from whenever it starts until three in the afternoon.
#'
#' The program builds an order for 5000 shares sent as ten VWAP slices with `until` rather than `over_minutes`, so the slices are spread over whatever is left of the day up to 15:00, and sized by UBI's NSE equity volume profile counted from the 09:15 open. A second order does the same with each slice shown as an iceberg of 200, a nested execution. UBI refuses either if it starts after 15:00. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/vwap_execution/vwap_execution/vwap_until_the_afternoon.R

library(tradeR)

#' Two VWAP sells of Vodafone Idea ending at 15:00, one plain and one of icebergs.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
VwapUntilTheAfternoon <- R6::R6Class(
  "VwapUntilTheAfternoon",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `VwapUntilTheAfternoon` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints both orders' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      inner_executions <- list(
        "each slice sent whole" = NULL,
        "each slice shown 200 at a time" = IcebergExecution$new(
          visible_quantity = 200
        )
      )
      for (description in names(inner_executions)) {
        inner_execution <- inner_executions[[description]]
        part <- OrderPart$new(
          instrument = self$share,
          transaction_type = "sell",
          quantity = 5000,
          product = "cnc",
          pricing = MarketablePricing$new(buffer_ticks = 1),
          execution = VwapExecution$new(
            slices = 10,
            until = "15:00"
          ),
          inner_execution = inner_execution
        )
        cat(sprintf("A VWAP until 15:00, %s:\n", description))
        cat(
          jsonlite::toJSON(
            part$document(),
            auto_unbox = TRUE,
            null = "null",
            pretty = TRUE,
            digits = NA
          ),
          "\n",
          sep = ""
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  VwapUntilTheAfternoon$new()$run()
}
