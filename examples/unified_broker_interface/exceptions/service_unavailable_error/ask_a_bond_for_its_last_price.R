#' Ask a government bond for its last price and handle the ServiceUnavailableError.
#'
#' No broker that serves quotes carries a cash bond, so UBI answers a request for a bond's last price with HTTP 503. The program catches ServiceUnavailableError and falls back to the bond's details, which UBI does have, printing its lot size and tick size instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/service_unavailable_error/ask_a_bond_for_its_last_price.R

library(tradeR)

#' A report on one government bond that copes with having no quote.
#'
#' @field bond The `FixedIncome` reported on.
BondQuoteReport <- R6::R6Class(
  "BondQuoteReport",
  public = list(
    bond = NULL,

    #' @description
    #' Creates the report for the bond with ISIN IN000126C010.
    #' @return A new `BondQuoteReport` object.
    #' @details Errors: signals `FixedIncomeError` when UBI does not know the bond, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$bond <- FixedIncome$new(exchange = "nse", symbol = "IN000126C010")
    },

    #' @description
    #' Asks for the last price and prints it, or the bond's details when there is none.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than a missing quote.
    run = function() {
      cat(sprintf("Bond: %s\n", self$bond$format()))
      last_price <- tryCatch(
        self$bond$last_price,
        ServiceUnavailableError = function(error) error
      )
      if (inherits(last_price, "ServiceUnavailableError")) {
        cat(
          sprintf(
            "ServiceUnavailableError (%s): %s\n",
            last_price$status_code,
            conditionMessage(last_price)
          )
        )
        cat(sprintf("Lot size: %s\n", toString(self$bond$lot_size)))
        cat(sprintf("Tick size: %s\n", toString(self$bond$tick_size)))
        return(invisible(NULL))
      }
      cat(sprintf("Last price: %s\n", toString(last_price)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BondQuoteReport$new()$run()
}
