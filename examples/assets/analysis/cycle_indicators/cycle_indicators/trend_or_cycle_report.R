#' Report whether the NIFTY 50 index and a few shares are trending or cycling.
#'
#' The program reads a year of daily candles for each instrument and uses the Hilbert transform to print its dominant cycle length, whether it is in a trend or a cycle today, how many of the last sixty sessions were trending, and how far the close sits from the instantaneous trend line.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/cycle_indicators/cycle_indicators/trend_or_cycle_report.R

library(tradeR)

#' A Hilbert transform report of each instrument's market mode.
#'
#' @field instruments A list of the `Equity` and `EquityIndex` instruments to report on.
#' @field days The integer number of days of candles to read, enough for the Hilbert transform to settle.
#' @field recent_sessions The integer number of recent sessions whose trend mode is counted.
TrendOrCycleReport <- R6::R6Class(
  "TrendOrCycleReport",
  public = list(
    instruments = NULL,
    days = NULL,
    recent_sessions = NULL,

    #' @description
    #' Creates the report over the NIFTY 50 index and three shares.
    #' @param days The integer number of days of candles to read.
    #' @param recent_sessions The integer number of recent sessions whose trend mode is counted.
    #' @return A new `TrendOrCycleReport` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the instruments.
    initialize = function(days = 365, recent_sessions = 60) {
      self$instruments <- list(
        EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "RELIANCE"),
        Equity$new(exchange = "nse", symbol = "SBIN")
      )
      self$days <- days
      self$recent_sessions <- recent_sessions
    },

    #' @description
    #' Describes one instrument's cycle and trend. A missing trend mode counts as cycling, as it does in Python.
    #' @param instrument The instrument whose candles are analysed.
    #' @return A character line with the cycle length, today's mode, the trending count and the distance from the trend line.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(instrument) {
      period <- instrument$hilbert_transform_dominant_cycle_period(
        days = self$days
      )
      mode <- instrument$hilbert_transform_trend_mode(days = self$days)
      trend_line <- instrument$hilbert_transform_trend_line(days = self$days)
      if (is.null(period)) {
        return(sprintf("%s: no candles", instrument$symbol))
      }
      recent_modes <- utils::tail(mode$ht_trendmode, self$recent_sessions)
      trending_sessions <- 0
      for (value in recent_modes) {
        if (isTRUE(value == 1)) {
          trending_sessions <- trending_sessions + 1
        }
      }
      if (isTRUE(mode$ht_trendmode[nrow(mode)] == 1)) {
        today <- "trending"
      } else {
        today <- "cycling"
      }
      close <- trend_line$close[nrow(trend_line)]
      trend_value <- trend_line$ht_trendline[nrow(trend_line)]
      distance <- (close / trend_value - 1) * 100
      sprintf(
        "%-10s cycle %5.1f days  today %-8s  trending %d/%d  from trend line %+.2f%%",
        instrument$symbol,
        period$ht_dcperiod[nrow(period)],
        today,
        as.integer(trending_sessions),
        as.integer(self$recent_sessions),
        distance
      )
    },

    #' @description
    #' Prints one line for each instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (instrument in self$instruments) {
        cat(self$describe(instrument), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TrendOrCycleReport$new()$run()
}
