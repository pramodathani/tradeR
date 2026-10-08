#' Ask for a share as a non-tradeable instrument, catch NonTradeableInstrumentError and read it as tradeable instead.
#'
#' Only an index is a NonTradeableInstrument, so building one for the IDEA share raises NonTradeableInstrumentError. The program catches it, builds a TradeableInstrument for the same share, and prints its best bid and offer from the order book, which only a tradeable instrument has.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/non_tradeable_instrument_error/fall_back_to_a_tradeable_instrument.R

library(tradeR)

#' A lookup that tries an instrument as an index first and as tradeable second.
#'
#' @field exchange The character exchange of the instrument.
#' @field segment The character UBI segment of the instrument.
#' @field symbol The character symbol of the instrument.
TradeableFallback <- R6::R6Class(
  "TradeableFallback",
  public = list(
    exchange = NULL,
    segment = NULL,
    symbol = NULL,

    #' @description
    #' Creates the lookup for the IDEA share.
    #' @return A new `TradeableFallback` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equities"
      self$symbol <- "IDEA"
    },

    #' @description
    #' Builds the instrument, recovers from the error and prints its best prices.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the instrument; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      index <- tryCatch(
        NonTradeableInstrument$new(
          exchange = self$exchange,
          segment = self$segment,
          symbol = self$symbol
        ),
        NonTradeableInstrumentError = function(error) {
          cat(
            sprintf(
              "NonTradeableInstrumentError: %s\n",
              conditionMessage(error)
            )
          )
          NULL
        }
      )
      if (!is.null(index)) {
        cat(
          sprintf(
            "%s is an index, with last value %s\n",
            index$format(),
            format(index$last_price)
          )
        )
        return(invisible(NULL))
      }
      share <- TradeableInstrument$new(
        exchange = self$exchange,
        segment = self$segment,
        symbol = self$symbol
      )
      cat(sprintf("Built %s instead\n", share$format()))
      cat(sprintf("Best bid: %s\n", format(share$best_bid)))
      cat(sprintf("Best offer: %s\n", format(share$best_offer)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TradeableFallback$new()$run()
}
