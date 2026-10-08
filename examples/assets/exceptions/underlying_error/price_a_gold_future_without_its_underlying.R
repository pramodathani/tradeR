#' Ask a gold future for its underlying and handle the UnderlyingError.
#'
#' A commodity future's underlying is physical gold, which has no price in UBI, and UBI links the contract to no underlying, so `underlying` raises UnderlyingError unless one was given when the contract was built. The program catches it and reports the future's own last price and days to expiry, which do not need the underlying.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/underlying_error/price_a_gold_future_without_its_underlying.R

library(tradeR)

#' A short report on the nearest GOLDM futures contract.
#'
#' @field contract The `CommodityFutures` reported on, or `NULL` before run.
GoldFutureReport <- R6::R6Class(
  "GoldFutureReport",
  public = list(
    contract = NULL,

    #' @description
    #' Creates the report with no contract yet.
    #' @return A new `GoldFutureReport` object.
    initialize = function() {
      self$contract <- NULL
    },

    #' @description
    #' Builds the nearest GOLDM future, asks for its underlying and prints what is known.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityFuturesError` when UBI does not know the contract; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- CommodityFutures$expiries("mcx", "GOLDM")[1]
      self$contract <- CommodityFutures$new(
        exchange = "mcx",
        underlying_symbol = "GOLDM",
        expiry_date = expiry_date
      )
      cat(sprintf("Contract: %s\n", self$contract$format()))
      underlying <- tryCatch(
        self$contract$underlying,
        UnderlyingError = function(error) {
          cat(sprintf("UnderlyingError: %s\n", conditionMessage(error)))
          NULL
        }
      )
      if (!is.null(underlying)) {
        cat(sprintf("Underlying: %s\n", underlying$format()))
      }
      cat(
        sprintf(
          "Days to expiry: %s\n",
          format(self$contract$days_to_expiry)
        )
      )
      cat(sprintf("Last price: %s\n", format(self$contract$last_price)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  GoldFutureReport$new()$run()
}
