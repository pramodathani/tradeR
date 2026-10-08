#' Summarise a year of daily candles for a few instruments.
#'
#' The program fetches one year of adjusted daily candles for each instrument in one request apiece, and prints its first and last close, its highest high and lowest low, its return over the year and how far the last close sits below the year's high.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/instrument/yearly_candle_summary.R

library(tradeR)

#' A one-year summary of daily candles for several instruments.
#'
#' @field summarised_instruments A list of `Instrument` objects to summarise.
#' @field days The integer number of days of candles to read, counting back from today.
YearlyCandleSummary <- R6::R6Class(
  "YearlyCandleSummary",
  public = list(
    summarised_instruments = NULL,
    days = NULL,

    #' @description
    #' Looks the instruments up in UBI.
    #' @param days The integer number of days of candles to read.
    #' @return A new `YearlyCandleSummary` object.
    #' @details Errors: signals `InstrumentError` when UBI has no instrument for one of the symbols, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function(days = 365) {
      self$days <- days
      self$summarised_instruments <- list(
        Instrument$new(
          exchange = "nse",
          segment = "equity_indices",
          symbol = "NIFTY"
        ),
        Instrument$new(
          exchange = "nse",
          segment = "equities",
          symbol = "TCS"
        ),
        Instrument$new(
          exchange = "nse",
          segment = "equities",
          symbol = "ITC"
        )
      )
    },

    #' @description
    #' Works out the figures of the summary from one instrument's candles.
    #' @param candles The `data.frame` that `Instrument$prices()` returned.
    #' @return A named list with `first_close`, `last_close`, `high`, `low`, `return_percent` and `below_high_percent`, each numeric.
    summarise = function(candles) {
      first_close <- as.numeric(candles$close[[1]])
      last_close <- as.numeric(candles$close[[nrow(candles)]])
      high <- as.numeric(max(candles$high))
      low <- as.numeric(min(candles$low))
      list(
        first_close = first_close,
        last_close = last_close,
        high = high,
        low = low,
        return_percent = (last_close - first_close) / first_close * 100,
        below_high_percent = (high - last_close) / high * 100
      )
    },

    #' @description
    #' Prints the summary of every instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      for (instrument in self$summarised_instruments) {
        candles <- instrument$prices(interval = "day", days = self$days)
        if (is.null(candles)) {
          cat(sprintf("%s: UBI has no candles\n", instrument$symbol))
          next
        }
        summary <- self$summarise(candles)
        cat(sprintf(
          "%s over %d sessions:\n",
          instrument$symbol,
          nrow(candles)
        ))
        cat(sprintf(
          "  close %.2f -> %.2f\n",
          summary[["first_close"]],
          summary[["last_close"]]
        ))
        cat(sprintf(
          "  range %.2f - %.2f\n",
          summary[["low"]],
          summary[["high"]]
        ))
        cat(sprintf("  return %+.2f%%\n", summary[["return_percent"]]))
        cat(sprintf(
          "  %.2f%% below the year's high\n",
          summary[["below_high_percent"]]
        ))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  YearlyCandleSummary$new()$run()
}
