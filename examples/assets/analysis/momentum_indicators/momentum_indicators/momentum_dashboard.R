#' Print a momentum dashboard for a list of NSE shares and the NIFTY 50 index.
#'
#' The program reads half a year of daily candles for each instrument through five of the momentum indicators that `MomentumIndicators` gives every instrument, and prints one line per instrument with the latest relative strength index, MACD histogram, average directional movement index, Williams %R and rate of change, followed by a one-word reading of the relative strength index.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/momentum_indicators/momentum_indicators/momentum_dashboard.R

library(tradeR)

#' A one-line-per-instrument summary of momentum readings.
#'
#' @field instruments A named list mapping a label to the instrument whose momentum is read.
#' @field days The integer number of days of daily candles to read for each instrument.
MomentumDashboard <- R6::R6Class(
  "MomentumDashboard",
  public = list(
    instruments = NULL,
    days = NULL,

    #' @description
    #' Creates the dashboard over four shares and the NIFTY 50 index.
    #' @param days The integer number of days of daily candles to read for each instrument.
    #' @return A new `MomentumDashboard` object.
    initialize = function(days = 180) {
      self$instruments <- list(
        NIFTY = EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        INFY = Equity$new(exchange = "nse", symbol = "INFY"),
        TCS = Equity$new(exchange = "nse", symbol = "TCS"),
        HDFCBANK = Equity$new(exchange = "nse", symbol = "HDFCBANK"),
        RELIANCE = Equity$new(exchange = "nse", symbol = "RELIANCE")
      )
      self$days <- days
    },

    #' @description
    #' Turns a relative strength index value into a one-word reading.
    #' @param relative_strength The numeric relative strength index, between 0 and 100.
    #' @return The character value `"overbought"` above 70, `"oversold"` below 30, and `"neutral"` otherwise.
    reading = function(relative_strength) {
      if (relative_strength > 70) {
        return("overbought")
      }
      if (relative_strength < 30) {
        return("oversold")
      }
      "neutral"
    },

    #' @description
    #' Reads one instrument's indicators and describes their latest values.
    #' @param label The character name printed for the instrument.
    #' @param instrument The `Instrument` whose indicators are read, a share or an index.
    #' @return A character line of the latest indicator values, or a line saying there were no candles.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(label, instrument) {
      relative_strength_frame <- instrument$relative_strength_index(
        window = 14,
        days = self$days
      )
      if (is.null(relative_strength_frame)) {
        return(sprintf("%-10s no candles", label))
      }
      convergence_frame <- instrument$moving_average_convergence_divergence(
        days = self$days
      )
      directional_frame <- instrument$average_directional_movement_index(
        window = 14,
        days = self$days
      )
      williams_frame <- instrument$williams_percent_r(
        window = 14,
        days = self$days
      )
      change_frame <- instrument$rate_of_change(window = 20, days = self$days)
      relative_strength <- utils::tail(relative_strength_frame$rsi_14, 1)
      histogram <- utils::tail(convergence_frame$macd_12_26_9_hist, 1)
      directional_index <- utils::tail(directional_frame$adx_14, 1)
      williams <- utils::tail(williams_frame$willr_14, 1)
      change <- utils::tail(change_frame$roc_20, 1)
      sprintf(
        "%-10s %6.1f %10.2f %6.1f %8.1f %8.2f  %s",
        label,
        relative_strength,
        histogram,
        directional_index,
        williams,
        change,
        self$reading(relative_strength)
      )
    },

    #' @description
    #' Prints a header and one line per instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "%-10s %6s %10s %6s %8s %8s  Reading\n",
          "Symbol",
          "RSI 14",
          "MACD hist",
          "ADX 14",
          "%R 14",
          "ROC 20"
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
  MomentumDashboard$new()$run()
}
