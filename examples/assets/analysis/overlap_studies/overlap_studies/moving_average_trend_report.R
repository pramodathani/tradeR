#' Report the moving average trend of the NIFTY 50 index and a few shares.
#'
#' The program reads about a year and a half of daily candles for each instrument, works out its fifty-day and two-hundred-day simple moving averages and its twenty-day exponential moving average, and prints whether the fifty-day average is above the two-hundred-day one, the golden cross, and whether the close is above the short average.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/overlap_studies/overlap_studies/moving_average_trend_report.R

library(tradeR)

#' A trend report built from three moving averages of each instrument.
#'
#' @field instruments A list of the `Equity` and `EquityIndex` instruments to report on.
#' @field days The integer number of days of candles to read, enough for the two-hundred-day average.
MovingAverageTrendReport <- R6::R6Class(
  "MovingAverageTrendReport",
  public = list(
    instruments = NULL,
    days = NULL,

    #' @description
    #' Creates the report over the NIFTY 50 index and three shares.
    #' @param days The integer number of days of candles to read.
    #' @return A new `MovingAverageTrendReport` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the instruments.
    initialize = function(days = 450) {
      self$instruments <- list(
        EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        Equity$new(exchange = "nse", symbol = "RELIANCE"),
        Equity$new(exchange = "nse", symbol = "INFY"),
        Equity$new(exchange = "nse", symbol = "HDFCBANK")
      )
      self$days <- days
    },

    #' @description
    #' Describes one instrument's trend.
    #' @param instrument The instrument whose moving averages are read.
    #' @return A character line with the close, the three averages and the verdicts.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(instrument) {
      fifty_day <- instrument$simple_moving_average(
        window = 50,
        days = self$days
      )
      two_hundred_day <- instrument$simple_moving_average(
        window = 200,
        days = self$days
      )
      twenty_day <- instrument$exponential_moving_average(
        window = 20,
        days = self$days
      )
      if (is.null(fifty_day)) {
        return(sprintf("%s: no candles", instrument$symbol))
      }
      close <- utils::tail(fifty_day$close, 1)
      fifty_day_average <- utils::tail(fifty_day$sma_50, 1)
      two_hundred_day_average <- utils::tail(two_hundred_day$sma_200, 1)
      twenty_day_average <- utils::tail(twenty_day$ema_20, 1)
      if (isTRUE(fifty_day_average > two_hundred_day_average)) {
        long_verdict <- "golden cross"
      } else {
        long_verdict <- "death cross"
      }
      if (isTRUE(close > twenty_day_average)) {
        short_verdict <- "above its 20-day average"
      } else {
        short_verdict <- "below its 20-day average"
      }
      sprintf(
        "%-10s close %9.2f  sma50 %9.2f  sma200 %9.2f  ema20 %9.2f  %s, %s",
        instrument$symbol,
        close,
        fifty_day_average,
        two_hundred_day_average,
        twenty_day_average,
        long_verdict,
        short_verdict
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
  MovingAverageTrendReport$new()$run()
}
