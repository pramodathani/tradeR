#' Scan shares and NIFTY for closes outside their 20-day high and low channel.
#'
#' The program reads three months of daily candles for each instrument through `maximum`, `minimum` and `minimum_maximum_index`, builds a channel from the highest high and lowest low of the 20 days before the latest session, and prints whether the latest close broke above it, broke below it or stayed inside, together with the dates on which the channel's high and low were made.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/math_operators/math_operators/channel_breakout_scan.R

library(tradeR)

#' A scan for breakouts from a 20-day price channel.
#'
#' @field instruments A named list mapping a label to the instrument that is scanned.
#' @field window The integer number of candles in the channel.
#' @field days The integer number of days of daily candles to read.
ChannelBreakoutScan <- R6::R6Class(
  "ChannelBreakoutScan",
  public = list(
    instruments = NULL,
    window = NULL,
    days = NULL,

    #' @description
    #' Creates the scan over the NIFTY 50 index and four shares.
    #' @param window The integer number of candles in the channel.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `ChannelBreakoutScan` object.
    initialize = function(window = 20, days = 90) {
      self$instruments <- list(
        NIFTY = EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        INFY = Equity$new(exchange = "nse", symbol = "INFY"),
        TCS = Equity$new(exchange = "nse", symbol = "TCS"),
        HDFCBANK = Equity$new(exchange = "nse", symbol = "HDFCBANK"),
        RELIANCE = Equity$new(exchange = "nse", symbol = "RELIANCE")
      )
      self$window <- window
      self$days <- days
    },

    #' @description
    #' Says where a close sits relative to the channel.
    #' @param close The numeric latest close.
    #' @param channel_high The numeric highest high of the channel.
    #' @param channel_low The numeric lowest low of the channel.
    #' @return The character value `"broke above"`, `"broke below"` or `"inside"`.
    classify = function(close, channel_high, channel_low) {
      if (close > channel_high) {
        return("broke above")
      }
      if (close < channel_low) {
        return("broke below")
      }
      "inside"
    },

    #' @description
    #' Scans one instrument. The `minindex` and `maxindex` columns hold positions counted from 0, as in Python, so the row they name is the position plus 1.
    #' @param label The character name printed for the instrument.
    #' @param instrument The `Instrument` that is scanned.
    #' @return A character line with the close, the channel, the verdict and the dates of the channel's extremes.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(label, instrument) {
      high_frame <- instrument$maximum(
        column = "high",
        window = self$window,
        days = self$days
      )
      if (is.null(high_frame)) {
        return(sprintf("%-10s no candles", label))
      }
      low_frame <- instrument$minimum(
        column = "low",
        window = self$window,
        days = self$days
      )
      position_frame <- instrument$minimum_maximum_index(
        column = "close",
        window = self$window,
        days = self$days
      )
      last_row <- nrow(high_frame)
      close <- high_frame$close[last_row]
      channel_high <- high_frame$max[last_row - 1]
      channel_low <- low_frame$min[nrow(low_frame) - 1]
      verdict <- self$classify(close, channel_high, channel_low)
      last_position_row <- nrow(position_frame)
      lowest_row <- as.integer(position_frame$minindex[last_position_row]) + 1
      highest_row <- as.integer(position_frame$maxindex[last_position_row]) + 1
      lowest_day <- format(position_frame$datetime[lowest_row], "%Y-%m-%d")
      highest_day <- format(position_frame$datetime[highest_row], "%Y-%m-%d")
      sprintf(
        "%-10s %10.2f %10.2f %10.2f  %-12s lowest close %s, highest close %s",
        label,
        close,
        channel_low,
        channel_high,
        verdict,
        lowest_day,
        highest_day
      )
    },

    #' @description
    #' Prints a header and one line per instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "%-10s %10s %10s %10s  Verdict\n",
          "Symbol",
          "Close",
          "Low",
          "High"
        )
      )
      for (label in names(self$instruments)) {
        cat(self$describe(label, self$instruments[[label]]), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ChannelBreakoutScan$new()$run()
}
