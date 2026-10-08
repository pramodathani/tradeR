#' List futures expiries on an exchange UBI does not know, catching UnifiedBrokerInterfaceError.
#'
#' UBI knows the nse, bse, mcx and ncdex exchanges. The program asks for RELIANCE futures expiries on the nyse, catches the BadRequestError UBI answers with through its base class UnifiedBrokerInterfaceError, prints UBI's list of valid exchanges and asks again on the nse.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/bad_request_error/list_expiries_on_an_unknown_exchange.R

library(tradeR)

#' A listing of RELIANCE futures expiries that corrects a wrong exchange.
#'
#' @field exchanges A character vector of the exchanges to try, in order.
#' @field underlying_symbol The character symbol of the share.
ExpiryListing <- R6::R6Class(
  "ExpiryListing",
  public = list(
    exchanges = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the listing with the exchanges to try.
    #' @return A new `ExpiryListing` object.
    initialize = function() {
      self$exchanges <- c(
        "nyse",
        "nse"
      )
      self$underlying_symbol <- "RELIANCE"
    },

    #' @description
    #' Tries each exchange in turn until UBI accepts one.
    #' @return A `Date` vector of the expiries from the first exchange UBI accepts, or an empty `Date` vector when it accepts none.
    list_expiries = function() {
      for (exchange in self$exchanges) {
        expiry_dates <- tryCatch(
          EquityFutures$expiries(
            exchange = exchange,
            underlying_symbol = self$underlying_symbol
          ),
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (!inherits(expiry_dates, "UnifiedBrokerInterfaceError")) {
          return(expiry_dates)
        }
        cat(
          sprintf(
            "%s: %s (%s): %s\n",
            exchange,
            ErrorCatalogue$name_of(expiry_dates),
            toString(expiry_dates$status_code),
            conditionMessage(expiry_dates)
          )
        )
      }
      as.Date(character(0))
    },

    #' @description
    #' Lists the expiries and prints them.
    #' @return `NULL`, invisibly.
    run = function() {
      expiry_dates <- self$list_expiries()
      cat(sprintf("%s futures expire on:\n", self$underlying_symbol))
      for (index in seq_along(expiry_dates)) {
        cat(sprintf("  %s\n", format(expiry_dates[index])))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ExpiryListing$new()$run()
}
