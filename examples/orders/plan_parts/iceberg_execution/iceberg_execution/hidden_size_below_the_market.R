#' Build icebergs that rest a little below the market, with fixed and with varied piece sizes.
#'
#' The program reads Vodafone Idea's last price and tick size and builds two orders for 2000 shares limited two ticks below the last price, one showing 200 at a time and one whose pieces vary by up to a quarter either way so other traders cannot spot a repeating size. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/iceberg_execution/iceberg_execution/hidden_size_below_the_market.R

library(tradeR)

#' Two icebergs for Vodafone Idea, one regular and one randomised.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
HiddenSizeBelowTheMarket <- R6::R6Class(
  "HiddenSizeBelowTheMarket",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `HiddenSizeBelowTheMarket` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints both orders' objects.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      tick_size <- 0.01
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      limit_price <- round(last_price - 2 * tick_size, 2)
      executions <- list(
        "200 at a time" = IcebergExecution$new(
          visible_quantity = 200
        ),
        "about 200 at a time, varied by up to 25%" = IcebergExecution$new(
          visible_quantity = 200,
          randomise_percent = 25
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      for (description in names(executions)) {
        execution <- executions[[description]]
        part <- OrderPart$new(
          instrument = self$share,
          transaction_type = "buy",
          quantity = 2000,
          product = "cnc",
          pricing = FixedPricing$new(
            price = limit_price,
            order_type = "LIMIT"
          ),
          execution = execution
        )
        cat(sprintf("An iceberg showing %s:\n", description))
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
  HiddenSizeBelowTheMarket$new()$run()
}
