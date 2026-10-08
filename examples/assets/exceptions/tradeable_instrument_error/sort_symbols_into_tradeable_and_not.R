#' Sort a list of symbols into ones that can be traded and ones that cannot, catching InstrumentError.
#'
#' The program builds a TradeableInstrument for every entry of a list mixing shares and indices. An index raises TradeableInstrumentError, and a symbol UBI does not know raises the base InstrumentError, so one handler for the base class catches both and the error's class says which list the entry belongs in.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/tradeable_instrument_error/sort_symbols_into_tradeable_and_not.R

library(tradeR)

#' A sorter of symbols by whether UBI lets them be traded.
#'
#' @field entries The list of (character segment, character symbol) lists on the nse to sort.
#' @field tradeable The character vector of symbols that can be traded.
#' @field not_tradeable The character vector of symbols that are indices.
#' @field unknown The character vector of symbols UBI does not know.
TradeableSorter <- R6::R6Class(
  "TradeableSorter",
  public = list(
    entries = NULL,
    tradeable = NULL,
    not_tradeable = NULL,
    unknown = NULL,

    #' @description
    #' Creates the sorter with the entries to sort.
    #' @return A new `TradeableSorter` object.
    initialize = function() {
      self$entries <- list(
        c(
          "equities",
          "IDEA"
        ),
        c(
          "equity_indices",
          "NIFTY"
        ),
        c(
          "equities",
          "RELIANCE"
        ),
        c(
          "equity_indices",
          "BANKNIFTY"
        ),
        c(
          "equities",
          "NOTASHARE"
        )
      )
      self$tradeable <- character(0)
      self$not_tradeable <- character(0)
      self$unknown <- character(0)
    },

    #' @description
    #' Builds one entry as tradeable and records which list it belongs in.
    #' @param segment The character UBI segment of the entry.
    #' @param symbol The character symbol of the entry.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    sort_entry = function(segment, symbol) {
      outcome <- tryCatch(
        {
          TradeableInstrument$new(
            exchange = "nse",
            segment = segment,
            symbol = symbol
          )
          "tradeable"
        },
        InstrumentError = function(error) {
          if (inherits(error, "TradeableInstrumentError")) {
            return("not_tradeable")
          }
          "unknown"
        }
      )
      if (outcome == "tradeable") {
        self$tradeable <- c(
          self$tradeable,
          symbol
        )
      } else if (outcome == "not_tradeable") {
        self$not_tradeable <- c(
          self$not_tradeable,
          symbol
        )
      } else {
        self$unknown <- c(
          self$unknown,
          symbol
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Sorts every entry and prints the three lists.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    run = function() {
      for (entry in self$entries) {
        self$sort_entry(entry[[1]], entry[[2]])
      }
      cat(sprintf("Tradeable: %s\n", jsonlite::toJSON(self$tradeable)))
      cat(
        sprintf(
          "Indices, which cannot be traded: %s\n",
          jsonlite::toJSON(self$not_tradeable)
        )
      )
      cat(sprintf("Unknown to UBI: %s\n", jsonlite::toJSON(self$unknown)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TradeableSorter$new()$run()
}
