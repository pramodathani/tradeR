#' Tabulate how closely NSE shares follow the NIFTY 50 index.
#'
#' The program reads a year of daily candles for each share and for the index, and prints each share's latest 60-day beta against NIFTY, its latest 60-day correlation with NIFTY's returns, and the average of that correlation over the year.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/statistic_functions/statistic_functions/market_sensitivity_table.R

library(tradeR)

#' A table of each share's beta and correlation against the index.
#'
#' @field benchmark The `EquityIndex` the shares are measured against.
#' @field symbols A character vector of NSE symbols of the shares that are measured.
#' @field window The integer number of candles in each beta and correlation window.
#' @field days The integer number of days of daily candles to read.
MarketSensitivityTable <- R6::R6Class(
  "MarketSensitivityTable",
  public = list(
    benchmark = NULL,
    symbols = NULL,
    window = NULL,
    days = NULL,

    #' @description
    #' Creates the table over five shares measured against NIFTY.
    #' @param window The integer number of candles in each beta and correlation window.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `MarketSensitivityTable` object.
    initialize = function(window = 60, days = 365) {
      self$benchmark <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$symbols <- c(
        "INFY",
        "TCS",
        "HDFCBANK",
        "RELIANCE",
        "IDEA"
      )
      self$window <- window
      self$days <- days
    },

    #' @description
    #' Measures one share against the benchmark.
    #'
    #' The average correlation leaves out the missing values at the start of the range, as pandas' `mean()` does.
    #' @param symbol The character NSE symbol of the share.
    #' @return A character line with the share's latest beta, latest correlation and average correlation.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    describe = function(symbol) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      beta_frame <- share$beta(
        benchmark = self$benchmark,
        window = self$window,
        days = self$days
      )
      if (is.null(beta_frame)) {
        return(sprintf("%-10s no candles", symbol))
      }
      correlation_frame <- share$correlation_coefficient(
        benchmark = self$benchmark,
        window = self$window,
        days = self$days
      )
      beta <- tail(beta_frame[[paste0("beta_", self$window)]], 1)
      correlation <- correlation_frame[[paste0("corr_", self$window)]]
      sprintf(
        "%-10s %6.2f %12.2f %12.2f",
        symbol,
        beta,
        tail(correlation, 1),
        mean(correlation, na.rm = TRUE)
      )
    },

    #' @description
    #' Prints a header and one line per share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(sprintf("Measured against NIFTY over %d-day windows:\n", self$window))
      cat(
        sprintf(
          "%-10s %6s %12s %12s\n",
          "Symbol",
          "Beta",
          "Correlation",
          "Average"
        )
      )
      for (symbol in self$symbols) {
        cat(self$describe(symbol), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MarketSensitivityTable$new()$run()
}
