#' Print the premium of every live Nifty futures contract over the index.
#'
#' The program builds the Nifty 50 index once, hands it to each live futures contract as its underlying, and prints each contract's premium in points, in per cent and as an annual cost of carry.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index_futures/nifty_futures_basis.R

library(tradeR)

#' The premium of each live futures contract on one equity index.
#'
#' @field index The `EquityIndex` the contracts are written on.
NiftyFuturesBasis <- R6::R6Class(
  "NiftyFuturesBasis",
  public = list(
    index = NULL,

    #' @description
    #' Looks the index up in UBI.
    #' @param symbol The character nse symbol of the index, such as `"NIFTY"`.
    #' @return A new `NiftyFuturesBasis` object.
    #' @details Errors: signals `EquityIndexError` when UBI has no nse index with that symbol.
    initialize = function(symbol = "NIFTY") {
      self$index <- EquityIndex$new(exchange = "nse", symbol = symbol)
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      as.character(value)
    },

    #' @description
    #' Builds every live contract and prints its premium.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityIndexFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      cat(
        sprintf(
          "%s index: %s\n",
          self$index$symbol,
          self$display_text(self$index$last_price)
        )
      )
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$index$symbol
      )
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        contract <- EquityIndexFutures$new(
          exchange = "nse",
          underlying_symbol = self$index$symbol,
          expiry_date = expiry_date,
          underlying = self$index
        )
        basis_percent <- contract$basis_percent
        cost_of_carry <- contract$cost_of_carry
        cat(
          sprintf(
            "%s: price %s\n",
            format(expiry_date),
            self$display_text(contract$last_price)
          )
        )
        if (!is.null(basis_percent)) {
          cat(sprintf("    premium %.2f%% over the index\n", basis_percent))
        }
        if (!is.null(cost_of_carry)) {
          cat(sprintf("    cost of carry %.2f%% a year\n", cost_of_carry))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftyFuturesBasis$new()$run()
}
