#' List the government securities that interest rate futures are written on.
#'
#' The program searches the nse's fixed income segment for rate codes such as `633GS2035`, which name the interest rate underlyings, and prints how many futures and option expiries are listed on each.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income/rate_underlyings_report.R

library(tradeR)

#' The interest rate underlyings on the nse and the derivatives written on them.
#'
#' @field term The character text the rate codes must contain, such as `"GS2035"`.
RateUnderlyingsReport <- R6::R6Class(
  "RateUnderlyingsReport",
  public = list(
    term = NULL,

    #' @description
    #' Stores the part of the rate code to search for.
    #' @param term The character text the rate codes must contain, such as `"GS2035"` for securities maturing in 2035.
    #' @return A new `RateUnderlyingsReport` object.
    initialize = function(term = "GS2035") {
      self$term <- term
    },

    #' @description
    #' Finds the underlyings and prints the derivatives listed on each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeError` when an underlying found could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      matches <- FixedIncome$search(exchange = "nse", term = self$term)
      if (is.null(matches)) {
        cat(sprintf("No rate code contains %s.\n", self$term))
        return(invisible(NULL))
      }
      for (rate_code in matches$symbol) {
        security <- FixedIncome$new(exchange = "nse", symbol = rate_code)
        futures_expiries <- FixedIncomeFutures$expiries(
          exchange = "nse",
          underlying_symbol = security$symbol
        )
        option_expiries <- FixedIncomeOption$expiries(
          exchange = "nse",
          underlying_symbol = security$symbol
        )
        cat(
          sprintf(
            "%s: %d futures expiries, %d option expiries\n",
            security$symbol,
            length(futures_expiries),
            length(option_expiries)
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateUnderlyingsReport$new()$run()
}
