#' Build a buy of Vodafone Idea spread over five limit orders from just below the market down to 4% below it.
#'
#' The program reads Vodafone Idea's last price and builds a ladder of five rungs from 1% to 4% below it for 10000 shares, so 2000 rest at each rung. Every rung is sent at once and rounded to the tick on the passive side, and the rung prices replace any pricing, so the order has none. The program prints the document and the rung prices before rounding. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/ladder_execution/ladder_execution/scale_in_below_the_market.R

library(tradeR)

#' A five-rung buy ladder for Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
LadderedEntry <- R6::R6Class(
  "LadderedEntry",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `LadderedEntry` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the order's object and the rung prices.
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
      execution <- LadderExecution$new(
        from_price = round(last_price * 0.99, 2),
        to_price = round(last_price * 0.96, 2),
        steps = 5
      )
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 10000,
        product = "cnc",
        execution = execution
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
      gap <- (execution$to_price - execution$from_price) / (execution$steps - 1)
      for (rung in seq(0, execution$steps - 1)) {
        cat(
          sprintf(
            "Rung %d: about %.4f\n",
            as.integer(rung + 1),
            execution$from_price + rung * gap
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  LadderedEntry$new()$run()
}
