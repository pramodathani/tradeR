#' Print a live price board for a mix of shares and indices.
#'
#' The program builds each instrument once from its exchange, segment and symbol, then reads the last price and the day's open, high, low and previous close from UBI and prints one line per instrument with its change on the day.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/instrument/live_price_board.R

library(tradeR)

#' A board of live prices for a fixed list of instruments.
#'
#' @field board_instruments A list of `Instrument` objects, one per row of the board.
LivePriceBoard <- R6::R6Class(
  "LivePriceBoard",
  public = list(
    board_instruments = NULL,

    #' @description
    #' Looks every instrument on the board up in UBI.
    #' @return A new `LivePriceBoard` object.
    #' @details Errors: signals `InstrumentError` when UBI has no instrument for one of the symbols, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      index_symbols <- c(
        "NIFTY",
        "BANKNIFTY"
      )
      share_symbols <- c(
        "INFY",
        "RELIANCE",
        "HDFCBANK"
      )
      self$board_instruments <- list()
      for (symbol in index_symbols) {
        index <- Instrument$new(
          exchange = "nse",
          segment = "equity_indices",
          symbol = symbol
        )
        self$board_instruments[[length(self$board_instruments) + 1]] <- index
      }
      for (symbol in share_symbols) {
        share <- Instrument$new(
          exchange = "nse",
          segment = "equities",
          symbol = symbol
        )
        self$board_instruments[[length(self$board_instruments) + 1]] <- share
      }
    },

    #' @description
    #' Builds one line of the board for one instrument.
    #' @param instrument The `Instrument` to describe.
    #' @return A character string with the symbol, last price, day range and change on the day.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI has no quote for the instrument or could not be reached.
    describe = function(instrument) {
      day <- instrument$ohlc
      last_price <- day[["last_price"]]
      previous_close <- day[["previous_close"]]
      no_close <- is.null(previous_close) || previous_close == 0
      if (is.null(last_price) || no_close) {
        return(sprintf("%-12s no price today", instrument$symbol))
      }
      change_percent <- (last_price - previous_close) / previous_close * 100
      day_range <- sprintf(
        "%s - %s",
        format(day[["ohlc"]][["low"]]),
        format(day[["ohlc"]][["high"]])
      )
      sprintf(
        "%-12s %12.2f %24s %+8.2f%%",
        instrument$symbol,
        last_price,
        day_range,
        change_percent
      )
    },

    #' @description
    #' Prints the board, one line per instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI has no quote for an instrument or could not be reached.
    run = function() {
      cat(sprintf(
        "%-12s %12s %24s %9s\n",
        "Symbol",
        "Last",
        "Day range",
        "Change"
      ))
      for (instrument in self$board_instruments) {
        cat(self$describe(instrument), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  LivePriceBoard$new()$run()
}
