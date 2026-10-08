#' Show what separates an index from a tradeable instrument, and read its stored constituents.
#'
#' The program builds the Nifty 50 as a NonTradeableInstrument, shows that asking for it as a TradeableInstrument is refused because an index cannot be traded, and then reads the basket of the index's members stored in MongoDB, if one has been saved.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/non_tradeable_instrument/index_refusal_and_constituents.R

library(tradeR)

#' A short tour of one index as a NonTradeableInstrument.
#'
#' @field symbol The character symbol of the index.
#' @field index The `NonTradeableInstrument` for the index.
IndexRefusalAndConstituents <- R6::R6Class(
  "IndexRefusalAndConstituents",
  public = list(
    symbol = NULL,
    index = NULL,

    #' @description
    #' Looks the index up in UBI.
    #' @param symbol The character symbol of an NSE equity index.
    #' @return A new `IndexRefusalAndConstituents` object.
    #' @details Errors: signals `NonTradeableInstrumentError` when the symbol names something that is not an index, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function(symbol = "NIFTY") {
      self$symbol <- symbol
      self$index <- NonTradeableInstrument$new(
        exchange = "nse",
        segment = "equity_indices",
        symbol = symbol
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Tries to build the index as a TradeableInstrument and prints the refusal.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached.
    show_refusal = function() {
      tryCatch(
        TradeableInstrument$new(instrument_id = self$index$instrument_id),
        TradeableInstrumentError = function(error) {
          cat("Refused as tradeable:", conditionMessage(error), "\n")
        }
      )
      invisible(NULL)
    },

    #' @description
    #' Prints the stored basket of the index's members, or says that none is stored.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI could not find a stored member, and an error from mongolite when MongoDB could not be reached.
    show_constituents = function() {
      basket <- self$index$constituents
      if (is.null(basket)) {
        cat(sprintf(
          "No constituents of %s are stored for today.\n",
          self$symbol
        ))
        return(invisible(NULL))
      }
      cat(sprintf(
        "%s members stored, day change %s\n",
        format(basket$size),
        self$display_text(basket$day_change_percent)
      ))
      print(basket$top_gainers(count = 3))
      invisible(NULL)
    },

    #' @description
    #' Prints the index, the refusal and the constituents.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached, and an error from mongolite when MongoDB could not be reached.
    run = function() {
      cat(
        self$index$format(),
        "at",
        self$display_text(self$index$last_price),
        "\n"
      )
      self$show_refusal()
      self$show_constituents()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexRefusalAndConstituents$new()$run()
}
