#' Try to sell shares that are not held and handle the HoldingError.
#'
#' The program reads the account's holding of Vodafone Idea first and stops if any is held, so it never sells a real holding. When none is held, `reduce_holdings` finds nothing to sell and raises HoldingError before any order is sent.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/holding_error/sell_a_share_that_is_not_held.R

library(tradeR)

#' An attempt to sell one share of a stock the account does not hold.
#'
#' @field share The `Equity` to sell.
UnheldShareSale <- R6::R6Class(
  "UnheldShareSale",
  public = list(
    share = NULL,

    #' @description
    #' Creates the attempt for the IDEA share.
    #' @return A new `UnheldShareSale` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Checks that nothing is held, then asks to sell and prints the refusal.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      holding <- self$share$holdings
      if (!is.null(holding)) {
        cat(
          sprintf(
            "%s IDEA shares are held, so this program does not try to sell any.\n",
            format(holding[["quantity"]])
          )
        )
        return(invisible(NULL))
      }
      answer <- tryCatch(
        self$share$reduce_holdings(quantity = 1, price = 100.0),
        HoldingError = function(error) {
          cat(sprintf("HoldingError: %s\n", conditionMessage(error)))
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
  UnheldShareSale$new()$run()
}
