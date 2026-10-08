#' Print the basis term structure of Nifty futures.
#'
#' The program builds every live Nifty future with the index given as its underlying, so the index is looked up only once, and prints each future's basis in points and per cent and the annual cost of carry it implies.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/futures/basis_term_structure.R

library(tradeR)

#' The basis and cost of carry of every live future on one index.
#'
#' @field underlying_symbol The character symbol of the index.
#' @field index The `EquityIndex` the futures are written on.
BasisTermStructure <- R6::R6Class(
  "BasisTermStructure",
  public = list(
    underlying_symbol = NULL,
    index = NULL,

    #' @description
    #' Looks the index up in UBI.
    #' @param underlying_symbol The character symbol of an NSE index with futures.
    #' @return A new `BasisTermStructure` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function(underlying_symbol = "NIFTY") {
      self$underlying_symbol <- underlying_symbol
      self$index <- EquityIndex$new(
        exchange = "nse",
        symbol = underlying_symbol
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Prints one line per live future, soonest first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      cat(sprintf(
        "%s at %s\n",
        self$underlying_symbol,
        self$display_text(self$index$last_price)
      ))
      cat(sprintf(
        "%-12s %5s %9s %9s %9s\n",
        "Expiry",
        "Days",
        "Basis",
        "Basis %",
        "Carry %"
      ))
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        future <- EquityIndexFutures$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          underlying = self$index
        )
        basis <- future$basis
        basis_percent <- future$basis_percent
        carry <- future$cost_of_carry
        if (is.null(basis) || is.null(basis_percent)) {
          cat(sprintf("%-12s a last price is missing\n", format(expiry_date)))
          next
        }
        carry_text <- "-"
        if (!is.null(carry)) {
          carry_text <- sprintf("%.2f", carry)
        }
        cat(sprintf(
          "%-12s %5d %9.2f %9.3f %9s\n",
          format(expiry_date),
          future$days_to_expiry,
          basis,
          basis_percent,
          carry_text
        ))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BasisTermStructure$new()$run()
}
