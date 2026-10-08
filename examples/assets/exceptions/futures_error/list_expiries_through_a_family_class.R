#' Call a futures discovery method on a base class, catch InstrumentError and use a family class instead.
#'
#' The discovery class methods `expiries`, `contracts` and the like read the segment a family class such as EquityIndexFutures names. Called on the Futures base class, which names none, `expiries` raises FuturesError. The program catches it through its base class InstrumentError and asks EquityIndexFutures instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/futures_error/list_expiries_through_a_family_class.R

library(tradeR)

#' A listing of the NIFTY futures expiries.
#'
#' @field exchange The character exchange the futures trade on.
#' @field underlying_symbol The character symbol of the index.
FuturesExpiryListing <- R6::R6Class(
  "FuturesExpiryListing",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the listing for NIFTY futures.
    #' @return A new `FuturesExpiryListing` object.
    initialize = function() {
      self$exchange <- "nse"
      self$underlying_symbol <- "NIFTY"
    },

    #' @description
    #' Lists the expiries through the base class, recovers from the error and prints them.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      expiry_dates <- tryCatch(
        Futures$expiries(
          exchange = self$exchange,
          underlying_symbol = self$underlying_symbol
        ),
        InstrumentError = function(error) {
          cat(
            sprintf("%s: %s\n", class(error)[[1]], conditionMessage(error))
          )
          EquityIndexFutures$expiries(
            exchange = self$exchange,
            underlying_symbol = self$underlying_symbol
          )
        }
      )
      cat(sprintf("%s futures expire on:\n", self$underlying_symbol))
      for (index in seq_along(expiry_dates)) {
        cat(sprintf("  %s\n", format(expiry_dates[index])))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FuturesExpiryListing$new()$run()
}
