#' Check whether any currency index future is listed, on either exchange.
#'
#' The discovery calls fail cleanly on an empty segment: `expiries` returns an empty `Date` vector and `contracts` returns `NULL`. The program asks both exchanges for every currency index future and reports what it finds, which is nothing today.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index_futures/discovery_is_empty.R

library(tradeR)

#' A search for currency index futures on the exchanges that trade currencies.
#'
#' @field exchanges A character vector of the exchanges to ask, `"nse"` and `"bse"`.
CurrencyIndexFuturesDiscovery <- R6::R6Class(
  "CurrencyIndexFuturesDiscovery",
  public = list(
    exchanges = NULL,

    #' @description
    #' Stores the exchanges to ask.
    #' @return A new `CurrencyIndexFuturesDiscovery` object.
    initialize = function() {
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Asks each exchange for its contracts and prints the answers.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        rows <- CurrencyIndexFutures$contracts(exchange = exchange)
        expiries <- CurrencyIndexFutures$expiries(
          exchange = exchange,
          underlying_symbol = "USDINR"
        )
        if (is.null(rows)) {
          cat(
            sprintf(
              "%s: no contracts, and USDINR expiries are [%s]\n",
              exchange,
              paste(format(expiries), collapse = ", ")
            )
          )
        } else {
          cat(sprintf("%s: %d contracts listed\n", exchange, nrow(rows)))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexFuturesDiscovery$new()$run()
}
