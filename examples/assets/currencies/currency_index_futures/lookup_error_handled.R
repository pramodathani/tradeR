#' Try to build a currency index future and handle the error UBI gives today.
#'
#' UBI holds no rows in its currency index futures segment, so every lookup fails with `CurrencyIndexFuturesError`. The program asks for a future on a dollar index at the expiry of the soonest USDINR future, which is a date on which currency contracts do expire, catches the error, and prints it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index_futures/lookup_error_handled.R

library(tradeR)

#' An attempt to build one currency index futures contract.
#'
#' @field underlying_symbol The character symbol of the index, such as `"USDINR"`.
CurrencyIndexFuturesLookup <- R6::R6Class(
  "CurrencyIndexFuturesLookup",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the index whose future to look for.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `CurrencyIndexFuturesLookup` object.
    initialize = function(underlying_symbol = "USDINR") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Tries to build the contract and prints either the contract or the error.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      pair_expiries <- CurrencyFutures$expiries(
        exchange = "nse",
        underlying_symbol = "USDINR"
      )
      if (length(pair_expiries) == 0) {
        cat("No USDINR futures are listed to borrow an expiry from.\n")
        return(invisible(NULL))
      }
      expiry_date <- pair_expiries[[1]]
      contract <- tryCatch(
        CurrencyIndexFutures$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        ),
        CurrencyIndexFuturesError = function(error) {
          cat(sprintf("Not available today: %s\n", conditionMessage(error)))
          NULL
        }
      )
      if (is.null(contract)) {
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Found %s expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      last_price <- contract$last_price
      if (is.null(last_price)) {
        last_price <- "NULL"
      }
      cat(sprintf("Last price: %s\n", last_price))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexFuturesLookup$new()$run()
}
