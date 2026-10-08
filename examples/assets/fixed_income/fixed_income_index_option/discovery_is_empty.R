#' Check whether any option on a fixed income index is listed, on either exchange.
#'
#' The discovery calls fail cleanly rather than signalling an error when a segment is empty: `expiries` returns an empty `Date` vector and `chain` returns `NULL`. The program asks both exchanges for the overnight MIBOR option expiries and chain, and reports what it finds, which is nothing today.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index_option/discovery_is_empty.R

library(tradeR)

#' A search for options on one fixed income index across two exchanges.
#'
#' @field underlying_symbol The character symbol of the index, such as `"ONMIBOR"`.
#' @field exchanges A character vector of the exchanges to ask, such as `"nse"` and `"bse"`.
RateIndexOptionDiscovery <- R6::R6Class(
  "RateIndexOptionDiscovery",
  public = list(
    underlying_symbol = NULL,
    exchanges = NULL,

    #' @description
    #' Stores the index and the exchanges to ask.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `RateIndexOptionDiscovery` object.
    initialize = function(underlying_symbol = "ONMIBOR") {
      self$underlying_symbol <- underlying_symbol
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Asks each exchange for expiries and a chain, and prints the answers.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        expiries <- FixedIncomeIndexOption$expiries(
          exchange = exchange,
          underlying_symbol = self$underlying_symbol
        )
        if (length(expiries) > 0) {
          chain <- FixedIncomeIndexOption$chain(
            exchange = exchange,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiries[[1]]
          )
          cat(
            sprintf(
              "%s: %d options expiring %s\n",
              exchange,
              nrow(chain),
              format(expiries[[1]])
            )
          )
          next
        }
        chain <- FixedIncomeIndexOption$chain(
          exchange = exchange,
          underlying_symbol = self$underlying_symbol,
          expiry_date = "2026-12-31"
        )
        cat(sprintf("%s: no expiries listed, and the chain is ", exchange))
        print(chain)
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateIndexOptionDiscovery$new()$run()
}
