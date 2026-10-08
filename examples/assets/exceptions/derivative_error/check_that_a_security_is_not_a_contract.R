#' Ask for a share as a derivative and handle the DerivativeError.
#'
#' A Derivative must be a future or an option with an expiry date. The program looks the IDEA share up through the Derivative class, catches DerivativeError, and prints the message, which names the shape UBI gave the instrument.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/derivative_error/check_that_a_security_is_not_a_contract.R

library(tradeR)

#' A lookup of a share through the Derivative class.
#'
#' @field exchange The character exchange of the share.
#' @field segment The character UBI segment of the share.
#' @field symbol The character symbol of the share.
SecurityAsDerivative <- R6::R6Class(
  "SecurityAsDerivative",
  public = list(
    exchange = NULL,
    segment = NULL,
    symbol = NULL,

    #' @description
    #' Creates the lookup for the IDEA share.
    #' @return A new `SecurityAsDerivative` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equities"
      self$symbol <- "IDEA"
    },

    #' @description
    #' Looks the share up as a derivative and prints why it is refused.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    run = function() {
      contract <- tryCatch(
        Derivative$new(
          exchange = self$exchange,
          segment = self$segment,
          symbol = self$symbol
        ),
        DerivativeError = function(error) {
          cat(sprintf("DerivativeError: %s\n", conditionMessage(error)))
          NULL
        }
      )
      if (is.null(contract)) {
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Unexpectedly a contract: %s, expiring %s\n",
          contract$format(),
          format(contract$expiry_date)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SecurityAsDerivative$new()$run()
}
