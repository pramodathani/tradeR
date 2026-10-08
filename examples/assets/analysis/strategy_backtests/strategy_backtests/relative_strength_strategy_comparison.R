#' Compare one RSI mean-reversion strategy across several shares.
#'
#' The program defines a strategy that buys when the 14-day relative strength index falls below 30 and sells when it rises above 70, backtests it on three years of candles for each of four shares, writes the plot of the best one to the temporary directory as a plain HTML page, and prints a table of the results.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/strategy_backtests/strategy_backtests/relative_strength_strategy_comparison.R

library(tradeR)

#' A strategy that buys oversold dips and sells overbought rallies.
#'
#' @field oversold_level The integer RSI level below which the strategy buys.
#' @field overbought_level The integer RSI level above which the strategy sells.
RelativeStrengthReversal <- R6::R6Class(
  "RelativeStrengthReversal",
  inherit = BacktestStrategy,
  public = list(
    oversold_level = 30,
    overbought_level = 70,

    #' @description
    #' Prepares the 14-day relative strength index of the closes.
    #'
    #' This is the R form of backtesting.py's `init()` hook; the index is declared by name and read back as `self$indicators$strength`.
    #' @return `NULL`, invisibly.
    initialize_strategy = function() {
      self$indicator(
        "strength",
        talib::RSI(self$data$Close, timePeriod = 14)
      )
      invisible(NULL)
    },

    #' @description
    #' Buys below the oversold level and closes the position above the overbought level.
    #'
    #' This is the R form of backtesting.py's `next()` hook.
    #' @return `NULL`, invisibly.
    next_candle = function() {
      strength <- tail(self$indicators$strength, 1)
      has_position <- self$position$size != 0
      if (strength < self$oversold_level && !has_position) {
        self$buy()
      } else if (strength > self$overbought_level && has_position) {
        self$position$close()
      }
      invisible(NULL)
    }
  )
)

#' A comparison of the RSI reversal strategy across a list of shares.
#'
#' @field symbols The character vector of nse symbols to backtest.
#' @field plot_path The character path the best share's plot is written to.
RelativeStrengthStrategyComparison <- R6::R6Class(
  "RelativeStrengthStrategyComparison",
  public = list(
    symbols = NULL,
    plot_path = NULL,

    #' @description
    #' Creates the comparison over four large nse shares.
    #' @return A new `RelativeStrengthStrategyComparison` object.
    initialize = function() {
      self$symbols <- c(
        "INFY",
        "TCS",
        "RELIANCE",
        "HDFCBANK"
      )
      self$plot_path <- file.path(tempdir(), "relative_strength_best.html")
    },

    #' @description
    #' Runs the strategy on one share.
    #' @param symbol The character nse symbol of the share.
    #' @param plot_filename The character path to write the plot to, or `NULL` for no plot.
    #' @return A named list of the backtest's statistics, or `NULL` when UBI has no candles.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    backtest = function(symbol, plot_filename) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      share$run_backtest(
        RelativeStrengthReversal,
        cash = 1000000,
        commission = 0.0003,
        plot_filename = plot_filename,
        days = 1095
      )
    },

    #' @description
    #' Backtests every share, prints the table and plots the best share.
    #'
    #' The table has one row per share, named by its symbol, rounded to two decimals.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      symbols_with_results <- character(0)
      return_percent <- numeric(0)
      buy_and_hold_percent <- numeric(0)
      trades <- numeric(0)
      win_rate_percent <- numeric(0)
      for (symbol in self$symbols) {
        statistics <- self$backtest(symbol, NULL)
        if (is.null(statistics)) {
          cat(sprintf("%s: no candles\n", symbol))
          next
        }
        symbols_with_results <- c(symbols_with_results, symbol)
        return_percent <- c(return_percent, statistics[["Return [%]"]])
        buy_and_hold_percent <- c(
          buy_and_hold_percent,
          statistics[["Buy & Hold Return [%]"]]
        )
        trades <- c(trades, statistics[["# Trades"]])
        win_rate_percent <- c(win_rate_percent, statistics[["Win Rate [%]"]])
      }
      if (length(symbols_with_results) == 0) {
        cat("No share had candles to backtest.\n")
        return(invisible(NULL))
      }
      table <- data.frame(
        return_percent = round(return_percent, 2),
        buy_and_hold_percent = round(buy_and_hold_percent, 2),
        trades = trades,
        win_rate_percent = round(win_rate_percent, 2),
        row.names = symbols_with_results
      )
      print(table)
      best_symbol <- symbols_with_results[[which.max(return_percent)]]
      self$backtest(best_symbol, self$plot_path)
      cat(
        sprintf(
          "Best share: %s, plot written to %s\n",
          best_symbol,
          self$plot_path
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RelativeStrengthStrategyComparison$new()$run()
}
