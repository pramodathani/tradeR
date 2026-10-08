#' Scan a few stock futures for the richest and cheapest cost of carry.
#'
#' The program lists the stock futures of the next monthly expiry, builds the future for each of a handful of well-known shares, and ranks them by the annual cost of carry their basis implies, which is how a cash-and-carry trader looks for futures that are dear or cheap against the share.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/futures/stock_futures_carry_scan.R

library(tradeR)

#' A ranking of stock futures by their implied cost of carry.
#'
#' @field symbols A character vector of share symbols to scan.
StockFuturesCarryScan <- R6::R6Class(
  "StockFuturesCarryScan",
  public = list(
    symbols = NULL,

    #' @description
    #' Stores the shares to scan.
    #' @return A new `StockFuturesCarryScan` object.
    initialize = function() {
      self$symbols <- c(
        "RELIANCE",
        "INFY",
        "TCS",
        "HDFCBANK",
        "SBIN"
      )
    },

    #' @description
    #' Finds the first stock futures expiry with at least a week left, so the carry figure is meaningful.
    #' @return The `Date` of the chosen expiry.
    #' @details Errors: signals `ValueError` when no stock futures expiry has a week left, and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    next_expiry = function() {
      contracts <- EquityFutures$contracts(exchange = "nse")
      today <- TimeConverter$new()$today()
      expiries <- sort(unique(contracts$expiry_date))
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        if (as.integer(expiry_date - today) >= 7) {
          return(expiry_date)
        }
      }
      ErrorCatalogue$raise(
        "ValueError",
        sprintf("No stock futures expiry has a week left: today=%s", today)
      )
    },

    #' @description
    #' Prints the shares ranked by the carry of their future, highest first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no stock futures expiry has a week left, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      expiry_date <- self$next_expiry()
      cat(sprintf("Stock futures expiring %s:\n", format(expiry_date)))
      carries <- c()
      result_symbols <- c()
      basis_percents <- c()
      for (symbol in self$symbols) {
        future <- EquityFutures$new(
          exchange = "nse",
          underlying_symbol = symbol,
          expiry_date = expiry_date
        )
        carry <- future$cost_of_carry
        if (is.null(carry)) {
          cat(sprintf("  %s: a last price is missing\n", symbol))
          next
        }
        carries <- c(carries, carry)
        result_symbols <- c(result_symbols, symbol)
        basis_percents <- c(basis_percents, future$basis_percent)
      }
      ranking <- order(carries, result_symbols, decreasing = TRUE)
      for (position in ranking) {
        cat(sprintf(
          "  %-10s basis %+.3f%%  carry %+.2f%% a year\n",
          result_symbols[[position]],
          basis_percents[[position]],
          carries[[position]]
        ))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StockFuturesCarryScan$new()$run()
}
