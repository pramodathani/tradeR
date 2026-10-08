#' Try to redeem a mutual fund scheme that is not held, catching InstrumentError.
#'
#' The program reads the account's holding of one mutual fund scheme first and stops if any is held, so it never redeems a real holding. When none is held, `liquidate_holdings` finds nothing to sell and raises HoldingError before any order is sent, which one handler for the base class InstrumentError catches.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/holding_error/redeem_a_fund_that_is_not_held.R

library(tradeR)

#' An attempt to redeem every unit of a scheme the account does not hold.
#'
#' @field scheme The `MutualFund` to redeem.
UnheldFundRedemption <- R6::R6Class(
  "UnheldFundRedemption",
  public = list(
    scheme = NULL,

    #' @description
    #' Creates the attempt for one Aditya Birla Sun Life scheme.
    #' @return A new `UnheldFundRedemption` object.
    #' @details Errors: signals `MutualFundError` when UBI does not know the scheme; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$scheme <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    },

    #' @description
    #' Checks that nothing is held, then asks to redeem and prints the refusal.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      holding <- self$scheme$holdings
      if (!is.null(holding)) {
        cat(
          sprintf(
            "%s units are held, so this program does not redeem any.\n",
            format(holding[["quantity"]])
          )
        )
        return(invisible(NULL))
      }
      answer <- tryCatch(
        self$scheme$liquidate_holdings(price = 10.0),
        InstrumentError = function(error) {
          cat(
            sprintf("%s: %s\n", class(error)[[1]], conditionMessage(error))
          )
          NULL
        }
      )
      if (is.null(answer)) {
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Unexpectedly sent: %s\n",
          jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null")
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnheldFundRedemption$new()$run()
}
