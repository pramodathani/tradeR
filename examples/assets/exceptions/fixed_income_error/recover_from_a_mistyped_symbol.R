#' Recover from a mistyped bond symbol by catching FixedIncomeError.
#'
#' The program tries the spellings a person might type for a government bond, whose ISIN is IN000126C010, one after another, catches FixedIncomeError for each one UBI does not know, and prints the identity of the first bond that UBI does know.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/fixed_income_error/recover_from_a_mistyped_symbol.R

library(tradeR)

#' A search for the first spelling of a bond symbol that UBI knows.
#'
#' @field exchange The character exchange the bond is listed on.
#' @field candidate_symbols The character vector of spellings to try, in order.
MistypedSymbolRecovery <- R6::R6Class(
  "MistypedSymbolRecovery",
  public = list(
    exchange = NULL,
    candidate_symbols = NULL,

    #' @description
    #' Creates the search with the spellings to try.
    #' @return A new `MistypedSymbolRecovery` object.
    initialize = function() {
      self$exchange <- "nse"
      self$candidate_symbols <- c(
        "IN000126C01",
        "IN000126C010"
      )
    },

    #' @description
    #' Builds a FixedIncome from each spelling in turn until UBI knows one.
    #' @return The first `FixedIncome` UBI knows, or `NULL` when UBI knows none of the spellings.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup for a reason other than an unknown symbol.
    find_first_known = function() {
      for (symbol in self$candidate_symbols) {
        found <- tryCatch(
          FixedIncome$new(exchange = self$exchange, symbol = symbol),
          FixedIncomeError = function(error) {
            cat(
              sprintf(
                "FixedIncomeError for '%s': %s\n",
                symbol,
                conditionMessage(error)
              )
            )
            NULL
          }
        )
        if (!is.null(found)) {
          return(found)
        }
      }
      NULL
    },

    #' @description
    #' Finds the first known spelling and prints the identity UBI gives it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    run = function() {
      found <- self$find_first_known()
      if (is.null(found)) {
        cat(
          sprintf(
            "UBI knows none of %s on the %s, which is expected for a mistyped name.\n",
            jsonlite::toJSON(self$candidate_symbols),
            self$exchange
          )
        )
        return(invisible(NULL))
      }
      cat(sprintf("Found: %s\n", found$format()))
      cat(sprintf("Instrument id: %s\n", found$instrument_id))
      cat(sprintf("Tick size: %s\n", format(found$tick_size)))
      cat(sprintf("Lot size: %s\n", format(found$lot_size)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MistypedSymbolRecovery$new()$run()
}
