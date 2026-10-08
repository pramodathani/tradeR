#' Ask for a NIFTY option through the Futures class and handle the FuturesError.
#'
#' The program reads the soonest NIFTY option expiry and a strike listed for it, then looks that option up through the Futures class. UBI finds the contract, but it is an option rather than a future, so the Futures class raises FuturesError, which the program catches before building the contract as an Option instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/futures_error/ask_for_an_option_as_a_future.R

library(tradeR)

#' A lookup of a NIFTY option through the Futures class.
#'
#' @field exchange The character exchange the option trades on.
#' @field segment The character UBI segment of NIFTY options.
#' @field underlying_symbol The character symbol of the index.
OptionAsFuture <- R6::R6Class(
  "OptionAsFuture",
  public = list(
    exchange = NULL,
    segment = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the lookup for a NIFTY option.
    #' @return A new `OptionAsFuture` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equity_index_options"
      self$underlying_symbol <- "NIFTY"
    },

    #' @description
    #' Looks the option up as a future, catches the error and builds it as an option.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- EquityIndexOption$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )[1]
      strike_prices <- EquityIndexOption$strikes(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      strike_price <- strike_prices[length(strike_prices) %/% 2 + 1]
      contract <- tryCatch(
        Futures$new(
          exchange = self$exchange,
          segment = self$segment,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = "CE"
        ),
        FuturesError = function(error) {
          cat(sprintf("FuturesError: %s\n", conditionMessage(error)))
          Option$new(
            exchange = self$exchange,
            segment = self$segment,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date,
            strike_price = strike_price,
            option_type = "CE"
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
  OptionAsFuture$new()$run()
}
