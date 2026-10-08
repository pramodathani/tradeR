#' Backtest a moving average crossover strategy on two years of Infosys candles.
#'
#' The program defines a strategy that goes long when the 10-day simple moving average crosses above the 30-day one and short when it crosses below, runs it through `run_backtest` with a 0.03 percent commission, and prints the main statistics of the result together with the return of simply holding the share.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/strategy_backtests/strategy_backtests/moving_average_crossover_backtest.R

library(tradeR)

#' A strategy that follows the crossings of a fast and a slow simple moving average.
#'
#' @field fast_window The integer number of candles in the fast average.
#' @field slow_window The integer number of candles in the slow average.
MovingAverageCrossover <- R6::R6Class(
  "MovingAverageCrossover",
  inherit = BacktestStrategy,
  public = list(
    fast_window = 10,
    slow_window = 30,

    #' @description
    #' Prepares the two moving averages over the closing prices.
    #'
    #' This is the R form of backtesting.py's `init()` hook; the averages are declared by name and read back as `self$indicators$fast_average` and `self$indicators$slow_average`.
    #' @return `NULL`, invisibly.
    initialize_strategy = function() {
      closes <- self$data$Close
      self$indicator(
        "fast_average",
        talib::SMA(closes, timePeriod = self$fast_window)
      )
      self$indicator(
        "slow_average",
        talib::SMA(closes, timePeriod = self$slow_window)
      )
      invisible(NULL)
    },

    #' @description
    #' Reverses the position whenever the averages cross.
    #'
    #' This is the R form of backtesting.py's `next()` hook.
    #' @return `NULL`, invisibly.
    next_candle = function() {
      fast_average <- self$indicators$fast_average
      slow_average <- self$indicators$slow_average
      if (self$crossover(fast_average, slow_average)) {
        self$position$close()
        self$buy()
      } else if (self$crossover(slow_average, fast_average)) {
        self$position$close()
        self$sell()
      }
      invisible(NULL)
    }
  )
)

#' A backtest of the moving average crossover strategy on one share.
#'
#' @field share The `Equity` the strategy trades.
#' @field starting_cash The numeric cash the backtest starts with.
MovingAverageCrossoverBacktest <- R6::R6Class(
  "MovingAverageCrossoverBacktest",
  public = list(
    share = NULL,
    starting_cash = NULL,

    #' @description
    #' Creates the backtest over Infosys on the nse with Rs 1,00,000.
    #' @return A new `MovingAverageCrossoverBacktest` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "INFY")
      self$starting_cash <- 100000.0
    },

    #' @description
    #' Runs the backtest and prints its main statistics.
    #'
    #' The statistics come back as a named list; a fractional number is printed with two decimals, and anything else, such as the start and end times and the whole-number trade count, is printed as it is.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      statistics <- self$share$run_backtest(
        MovingAverageCrossover,
        cash = self$starting_cash,
        commission = 0.0003,
        days = 730
      )
      if (is.null(statistics)) {
        cat("UBI has no Infosys candles for the last two years.\n")
        return(invisible(NULL))
      }
      measures <- c(
        "Start",
        "End",
        "Return [%]",
        "Buy & Hold Return [%]",
        "Max. Drawdown [%]",
        "# Trades",
        "Win Rate [%]",
        "Sharpe Ratio"
      )
      cat("Moving average crossover on INFY, 10 and 30 days\n")
      for (measure in measures) {
        value <- statistics[[measure]]
        if (is.double(value) && !inherits(value, "POSIXct")) {
          cat(sprintf("%-24s%.2f\n", measure, value))
        } else {
          cat(sprintf("%-24s%s\n", measure, format(value)))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MovingAverageCrossoverBacktest$new()$run()
}
