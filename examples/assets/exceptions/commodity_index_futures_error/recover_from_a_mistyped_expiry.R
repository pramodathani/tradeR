#' Recover from a mistyped expiry date by catching CommodityIndexFuturesError.
#'
#' The program asks for an MCXBULLDEX futures contract on a day no contract expires, catches CommodityIndexFuturesError, then reads the expiries that are listed and builds the contract for the first one on or after the day asked for.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/commodity_index_futures_error/recover_from_a_mistyped_expiry.R

library(tradeR)

#' A lookup of a futures contract that falls back to a listed expiry.
#'
#' @field exchange The character exchange the contract trades on.
#' @field underlying_symbol The character symbol the contract is written on.
#' @field wanted_expiry_date The `Date` the person asked for, on which no contract expires.
MistypedExpiryRecovery <- R6::R6Class(
  "MistypedExpiryRecovery",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,
    wanted_expiry_date = NULL,

    #' @description
    #' Creates the lookup with the contract the person asked for.
    #' @return A new `MistypedExpiryRecovery` object.
    initialize = function() {
      self$exchange <- "mcx"
      self$underlying_symbol <- "MCXBULLDEX"
      self$wanted_expiry_date <- as.Date("2026-12-25")
    },

    #' @description
    #' Looks one contract up in UBI.
    #' @param expiry_date The `Date` the contract expires on.
    #' @return The `CommodityIndexFutures` UBI knows for that expiry.
    #' @details Errors: signals `CommodityIndexFuturesError` when UBI has no such contract; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    build_contract = function(expiry_date) {
      CommodityIndexFutures$new(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
    },

    #' @description
    #' Picks the listed expiry closest after the day asked for.
    #' @return The first listed `Date` on or after wanted_expiry_date, or the last listed one when every expiry is earlier, or `NULL` when nothing is listed.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    listed_expiry_on_or_after = function() {
      listed_expiries <- CommodityIndexFutures$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      for (index in seq_along(listed_expiries)) {
        expiry_date <- listed_expiries[index]
        if (expiry_date >= self$wanted_expiry_date) {
          return(expiry_date)
        }
      }
      if (length(listed_expiries) > 0) {
        return(listed_expiries[length(listed_expiries)])
      }
      NULL
    },

    #' @description
    #' Asks for the mistyped contract, recovers from the error and prints the contract found.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- tryCatch(
        self$build_contract(self$wanted_expiry_date),
        CommodityIndexFuturesError = function(error) {
          cat(
            sprintf(
              "CommodityIndexFuturesError: %s\n",
              conditionMessage(error)
            )
          )
          NULL
        }
      )
      if (is.null(contract)) {
        listed_expiry <- self$listed_expiry_on_or_after()
        if (is.null(listed_expiry)) {
          cat(
            sprintf(
              "No %s contract is listed on the %s, which is expected for a mistyped name.\n",
              self$underlying_symbol,
              self$exchange
            )
          )
          return(invisible(NULL))
        }
        cat(
          sprintf(
            "Using the listed expiry %s instead.\n",
            format(listed_expiry)
          )
        )
        contract <- self$build_contract(listed_expiry)
      }
      cat(sprintf("Contract: %s\n", contract$format()))
      cat(
        sprintf(
          "Expires on %s, in %s days\n",
          format(contract$expiry_date),
          format(contract$days_to_expiry)
        )
      )
      cat(sprintf("Lot size: %s\n", format(contract$lot_size)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MistypedExpiryRecovery$new()$run()
}
