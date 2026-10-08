#' Collect the indices out of a mixed list of symbols, catching InstrumentError.
#'
#' The program builds a NonTradeableInstrument for every entry of a list mixing indices and shares, keeps the ones that are indices, and prints their last values. A share raises NonTradeableInstrumentError and a symbol UBI does not know raises the base InstrumentError, and one handler for the base class skips both.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/non_tradeable_instrument_error/collect_only_the_indices.R

library(tradeR)

#' A collector of the indices in a list of symbols.
#'
#' @field entries The list of (character segment, character symbol) lists on the nse to look at.
#' @field indices The list of `NonTradeableInstrument` found.
IndexCollector <- R6::R6Class(
  "IndexCollector",
  public = list(
    entries = NULL,
    indices = NULL,

    #' @description
    #' Creates the collector with the entries to look at.
    #' @return A new `IndexCollector` object.
    initialize = function() {
      self$entries <- list(
        c(
          "equity_indices",
          "NIFTY"
        ),
        c(
          "equities",
          "IDEA"
        ),
        c(
          "equity_indices",
          "BANKNIFTY"
        ),
        c(
          "equity_indices",
          "NIFTYSMALLCAPXYZ"
        )
      )
      self$indices <- list()
    },

    #' @description
    #' Builds every entry as an index, skips the ones that are not and prints the rest.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (entry in self$entries) {
        segment <- entry[[1]]
        symbol <- entry[[2]]
        index <- tryCatch(
          NonTradeableInstrument$new(
            exchange = "nse",
            segment = segment,
            symbol = symbol
          ),
          InstrumentError = function(error) {
            cat(sprintf("Skipped %s: %s\n", symbol, class(error)[[1]]))
            NULL
          }
        )
        if (is.null(index)) {
          next
        }
        self$indices[[length(self$indices) + 1]] <- index
      }
      for (index in self$indices) {
        cat(sprintf("%s: %s\n", index$symbol, format(index$last_price)))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexCollector$new()$run()
}
