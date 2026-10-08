#' Ask for a RELIANCE future through the Option class and handle the OptionError.
#'
#' The program reads the soonest RELIANCE futures expiry and looks that contract up through the Option class. UBI finds the contract, but it is a future rather than an option, so the Option class raises OptionError, which the program catches before building the contract as a Futures instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/option_error/ask_for_a_future_as_an_option.R

library(tradeR)

#' A lookup of a RELIANCE future through the Option class.
#'
#' @field exchange The character exchange the future trades on.
#' @field segment The character UBI segment of share futures.
#' @field underlying_symbol The character symbol of the share.
FutureAsOption <- R6::R6Class(
  "FutureAsOption",
  public = list(
    exchange = NULL,
    segment = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the lookup for a RELIANCE future.
    #' @return A new `FutureAsOption` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equity_futures"
      self$underlying_symbol <- "RELIANCE"
    },

    #' @description
    #' Looks the future up as an option, catches the error and builds it as a future.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the future; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- EquityFutures$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )[1]
      contract <- tryCatch(
        Option$new(
          exchange = self$exchange,
          segment = self$segment,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        ),
        OptionError = function(error) {
          cat(sprintf("OptionError: %s\n", conditionMessage(error)))
          Futures$new(
            exchange = self$exchange,
            segment = self$segment,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date
          )
        }
      )
      cat(sprintf("Built %s\n", contract$format()))
      cat(sprintf("Lot size: %s\n", format(contract$lot_size)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FutureAsOption$new()$run()
}
