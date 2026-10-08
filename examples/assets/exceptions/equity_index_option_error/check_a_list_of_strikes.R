#' Check a list of strike prices and report every one with no option.
#'
#' The program looks up a NIFTY call option at several strike prices for the soonest expiry, one listed and the others not. It catches InstrumentError, the base class of every instrument error, so one handler covers EquityIndexOptionError and anything else the lookup raises about the option, and it prints the chain of errors behind each strike that was not found.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/equity_index_option_error/check_a_list_of_strikes.R

library(tradeR)

#' A check of several strike prices of one expiry against UBI.
#'
#' @field exchange The character exchange the options trade on.
#' @field underlying_symbol The character symbol the options are written on.
#' @field fallback_expiry_date The `Date` to ask for when no expiry is listed at all.
#' @field strike_prices The numeric vector of strikes to check, with a listed strike added when there is one.
StrikeListCheck <- R6::R6Class(
  "StrikeListCheck",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,
    fallback_expiry_date = NULL,
    strike_prices = NULL,

    #' @description
    #' Creates the check with the strikes to look up.
    #' @return A new `StrikeListCheck` object.
    initialize = function() {
      self$exchange <- "nse"
      self$underlying_symbol <- "NIFTY"
      self$fallback_expiry_date <- as.Date("2026-10-06")
      self$strike_prices <- c(
        25010.0,
        1.0
      )
    },

    #' @description
    #' Names an error and every error it was raised from.
    #' @param error The condition to describe.
    #' @return A character value such as `EquityIndexOptionError <- InstrumentError <- NotFoundError`.
    describe_error_chain = function(error) {
      class_names <- class(error)[[1]]
      cause <- error$parent
      while (!is.null(cause)) {
        class_names <- c(
          class_names,
          class(cause)[[1]]
        )
        cause <- cause$parent
      }
      paste(class_names, collapse = " <- ")
    },

    #' @description
    #' Looks one call option up and describes the outcome.
    #' @param expiry_date The `Date` the option expires on.
    #' @param strike_price The numeric strike price to look up.
    #' @return A character line saying whether UBI knows the option, and why not when it does not.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup for a reason other than an unknown option.
    check_strike = function(expiry_date, strike_price) {
      tryCatch(
        {
          option <- EquityIndexOption$new(
            exchange = self$exchange,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date,
            strike_price = strike_price,
            option_type = "CE"
          )
          sprintf(
            "%s: found, lot size %s",
            format(strike_price),
            format(option$lot_size)
          )
        },
        InstrumentError = function(error) {
          chain <- self$describe_error_chain(error)
          sprintf("%s: not found (%s)", format(strike_price), chain)
        }
      )
    },

    #' @description
    #' Picks the soonest expiry, adds a listed strike, checks each strike and prints a line for it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      listed_expiries <- EquityIndexOption$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      expiry_date <- self$fallback_expiry_date
      if (length(listed_expiries) > 0) {
        expiry_date <- listed_expiries[1]
      }
      listed_strikes <- EquityIndexOption$strikes(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      if (length(listed_strikes) > 0) {
        middle_strike <- listed_strikes[length(listed_strikes) %/% 2 + 1]
        self$strike_prices <- c(
          middle_strike,
          self$strike_prices
        )
      } else {
        cat(
          sprintf(
            "No strike is listed for %s, which is expected for a mistyped name.\n",
            format(expiry_date)
          )
        )
      }
      cat(
        sprintf(
          "Checking %s calls expiring %s:\n",
          self$underlying_symbol,
          format(expiry_date)
        )
      )
      for (strike_price in self$strike_prices) {
        cat(self$check_strike(expiry_date, strike_price), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StrikeListCheck$new()$run()
}
