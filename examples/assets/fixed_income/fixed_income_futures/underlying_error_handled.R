#' Show why a bond future's basis cannot be worked out, and handle it cleanly.
#'
#' The program builds the soonest future on the 6.33 per cent government security of 2035. It asks for the future's basis twice: first without an underlying, which signals `UnderlyingError` because a rate future has no default underlying, and then with the security given as the underlying, which signals `ServiceUnavailableError` because no broker quotes a cash bond. Both errors are caught and explained, and the future's own price is printed.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_futures/underlying_error_handled.R

library(tradeR)

#' A check of what a rate future can and cannot say about its underlying.
#'
#' @field underlying_symbol The character rate code of the security the future is written on, such as `"633GS2035"`.
RateFuturesUnderlyingCheck <- R6::R6Class(
  "RateFuturesUnderlyingCheck",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the security whose future to check.
    #' @param underlying_symbol The character rate code of the security.
    #' @return A new `RateFuturesUnderlyingCheck` object.
    initialize = function(underlying_symbol = "633GS2035") {
      self$underlying_symbol <- underlying_symbol
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
    #' Builds the future and asks for its basis with and without an underlying.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeFuturesError` when UBI has no such contract, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- FixedIncomeFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No futures are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      contract <- FixedIncomeFutures$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]]
      )
      cat(
        sprintf(
          "%s future expiring %s\n",
          self$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      tryCatch(
        cat(sprintf("Basis: %s\n", self$display_text(contract$basis))),
        UnderlyingError = function(error) {
          cat(
            sprintf("Without an underlying: %s\n", conditionMessage(error))
          )
        }
      )
      security <- FixedIncome$new(
        exchange = "nse",
        symbol = self$underlying_symbol
      )
      given <- FixedIncomeFutures$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]],
        underlying = security
      )
      tryCatch(
        cat(sprintf("Basis: %s\n", self$display_text(given$basis))),
        ServiceUnavailableError = function(error) {
          cat(
            sprintf(
              "With the security as underlying: %s\n",
              conditionMessage(error)
            )
          )
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateFuturesUnderlyingCheck$new()$run()
}
