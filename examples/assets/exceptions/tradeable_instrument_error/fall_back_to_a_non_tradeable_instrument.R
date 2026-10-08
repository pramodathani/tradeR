#' Ask for an index as a tradeable instrument, catch TradeableInstrumentError and read it as an index instead.
#'
#' An index can be followed but not traded, so building a TradeableInstrument for NIFTY raises TradeableInstrumentError. The program catches it, builds a NonTradeableInstrument for the same index, and prints its last value.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/tradeable_instrument_error/fall_back_to_a_non_tradeable_instrument.R

library(tradeR)

#' A lookup that tries an instrument as tradeable first and as an index second.
#'
#' @field exchange The character exchange of the instrument.
#' @field segment The character UBI segment of the instrument.
#' @field symbol The character symbol of the instrument.
IndexFallback <- R6::R6Class(
  "IndexFallback",
  public = list(
    exchange = NULL,
    segment = NULL,
    symbol = NULL,

    #' @description
    #' Creates the lookup for the NIFTY index.
    #' @return A new `IndexFallback` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equity_indices"
      self$symbol <- "NIFTY"
    },

    #' @description
    #' Builds the instrument as tradeable, or as non-tradeable when it is an index.
    #' @return A `TradeableInstrument`, or a `NonTradeableInstrument` when the instrument is an index.
    #' @details Errors: signals `InstrumentError` when UBI does not know the instrument; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    build = function() {
      instrument <- tryCatch(
        TradeableInstrument$new(
          exchange = self$exchange,
          segment = self$segment,
          symbol = self$symbol
        ),
        TradeableInstrumentError = function(error) {
          cat(
            sprintf(
              "TradeableInstrumentError: %s\n",
              conditionMessage(error)
            )
          )
          NULL
        }
      )
      if (!is.null(instrument)) {
        return(instrument)
      }
      NonTradeableInstrument$new(
        exchange = self$exchange,
        segment = self$segment,
        symbol = self$symbol
      )
    },

    #' @description
    #' Builds the instrument and prints its class and last value.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the instrument; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      instrument <- self$build()
      cat(sprintf("Built %s\n", instrument$format()))
      cat(sprintf("Last value: %s\n", format(instrument$last_price)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexFallback$new()$run()
}
