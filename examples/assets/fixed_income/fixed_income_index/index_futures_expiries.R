#' List the futures expiries written on each fixed income index, on both exchanges.
#'
#' The program searches the nse and the bse for fixed income indices and prints, for each index, the expiries of the index futures listed on it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index/index_futures_expiries.R

library(tradeR)

#' The index futures expiries on every fixed income index on two exchanges.
#'
#' @field exchanges A character vector of the exchanges to search, such as `"nse"` and `"bse"`.
RateIndexFuturesExpiries <- R6::R6Class(
  "RateIndexFuturesExpiries",
  public = list(
    exchanges = NULL,

    #' @description
    #' Stores the exchanges to search.
    #' @return A new `RateIndexFuturesExpiries` object.
    initialize = function() {
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Searches each exchange and prints the expiries per index.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        matches <- FixedIncomeIndex$search(
          exchange = exchange,
          term = ""
        )
        if (is.null(matches)) {
          cat(sprintf("%s: no fixed income index\n", exchange))
          next
        }
        for (symbol in matches$symbol) {
          expiries <- FixedIncomeIndexFutures$expiries(
            exchange = exchange,
            underlying_symbol = symbol
          )
          listed <- character(0)
          for (expiry_index in seq_along(expiries)) {
            listed <- c(
              listed,
              format(expiries[[expiry_index]], "%Y-%m-%d")
            )
          }
          if (length(listed) == 0) {
            listed <- "none"
          }
          cat(
            sprintf(
              "%s %s: %s\n",
              exchange,
              symbol,
              paste(listed, collapse = ", ")
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateIndexFuturesExpiries$new()$run()
}
