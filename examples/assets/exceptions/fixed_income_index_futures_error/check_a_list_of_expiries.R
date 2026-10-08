#' Check a list of expiry dates and report every one with no contract.
#'
#' The program looks up an overnight MIBOR futures contract for each date in a list, one listed and the others not. It catches InstrumentError, the base class of every instrument error, so one handler covers FixedIncomeIndexFuturesError and anything else the lookup raises about the contract, and it prints the chain of errors behind each date that was not found.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/fixed_income_index_futures_error/check_a_list_of_expiries.R

library(tradeR)

#' A check of several expiry dates of one underlying against UBI.
#'
#' @field exchange The character exchange the contracts trade on.
#' @field underlying_symbol The character symbol the contracts are written on.
#' @field expiry_dates The `Date` vector of dates to check, with the first listed expiry added when there is one.
ExpiryListCheck <- R6::R6Class(
  "ExpiryListCheck",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,
    expiry_dates = NULL,

    #' @description
    #' Creates the check with the dates to look up.
    #' @return A new `ExpiryListCheck` object.
    initialize = function() {
      self$exchange <- "nse"
      self$underlying_symbol <- "ONMIBOR"
      self$expiry_dates <- as.Date(
        c(
          "2026-12-25",
          "2030-01-31"
        )
      )
    },

    #' @description
    #' Names an error and every error it was raised from.
    #' @param error The condition to describe.
    #' @return A character value such as `FixedIncomeIndexFuturesError <- InstrumentError <- NotFoundError`.
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
    #' Looks one contract up and describes the outcome.
    #' @param expiry_date The `Date` to look a contract up for.
    #' @return A character line saying whether UBI knows the contract, and why not when it does not.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup for a reason other than an unknown contract.
    check_expiry = function(expiry_date) {
      tryCatch(
        {
          contract <- FixedIncomeIndexFutures$new(
            exchange = self$exchange,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date
          )
          sprintf(
            "%s: found, lot size %s",
            format(expiry_date),
            format(contract$lot_size)
          )
        },
        InstrumentError = function(error) {
          chain <- self$describe_error_chain(error)
          sprintf("%s: not found (%s)", format(expiry_date), chain)
        }
      )
    },

    #' @description
    #' Adds the first listed expiry to the dates, checks each one and prints a line for it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      listed_expiries <- FixedIncomeIndexFutures$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      if (length(listed_expiries) > 0) {
        self$expiry_dates <- c(
          listed_expiries[1],
          self$expiry_dates
        )
      } else {
        cat(
          sprintf(
            "No %s contract is listed, which is expected for a mistyped name.\n",
            self$underlying_symbol
          )
        )
      }
      for (index in seq_along(self$expiry_dates)) {
        cat(self$check_expiry(self$expiry_dates[index]), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ExpiryListCheck$new()$run()
}
