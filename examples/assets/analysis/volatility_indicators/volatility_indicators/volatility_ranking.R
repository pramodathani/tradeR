#' Rank NSE shares from the most to the least volatile.
#'
#' The program reads three months of daily candles for each share through the three volatility indicators that `VolatilityIndicators` gives every instrument, and prints the shares ranked by their latest average true range as a percentage of the close, alongside the average true range in rupees and the latest day's true range.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/volatility_indicators/volatility_indicators/volatility_ranking.R

library(tradeR)

#' A ranking of shares by how widely their prices range each day.
#'
#' @field symbols A character vector of NSE symbols of the shares that are ranked.
#' @field window The integer number of candles in each average true range window.
#' @field days The integer number of days of daily candles to read for each share.
VolatilityRanking <- R6::R6Class(
  "VolatilityRanking",
  public = list(
    symbols = NULL,
    window = NULL,
    days = NULL,

    #' @description
    #' Creates the ranking over six NSE shares.
    #' @param window The integer number of candles in each average true range window.
    #' @param days The integer number of days of daily candles to read for each share.
    #' @return A new `VolatilityRanking` object.
    initialize = function(window = 14, days = 90) {
      self$symbols <- c(
        "INFY",
        "TCS",
        "HDFCBANK",
        "RELIANCE",
        "ITC",
        "IDEA"
      )
      self$window <- window
      self$days <- days
    },

    #' @description
    #' Reads one share's volatility indicators and keeps their latest values.
    #' @param symbol The character NSE symbol of the share.
    #' @return A named list with the names `symbol`, `close`, `average_true_range`, `normalized` and `true_range`, or `NULL` when UBI has no candles for the share.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    measure = function(symbol) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      average_frame <- share$average_true_range(
        window = self$window,
        days = self$days
      )
      if (is.null(average_frame)) {
        return(NULL)
      }
      normalized_frame <- share$normalized_average_true_range(
        window = self$window,
        days = self$days
      )
      range_frame <- share$true_range(days = self$days)
      average_column <- paste0("atr_", self$window)
      normalized_column <- paste0("natr", self$window)
      list(
        symbol = symbol,
        close = tail(average_frame$close, 1),
        average_true_range = tail(average_frame[[average_column]], 1),
        normalized = tail(normalized_frame[[normalized_column]], 1),
        true_range = tail(range_frame$tr, 1)
      )
    },

    #' @description
    #' Gives the value the ranking sorts on.
    #' @param measurement A named list returned by `measure`.
    #' @return The numeric average true range as a percentage of the close.
    normalized_value = function(measurement) {
      measurement[["normalized"]]
    },

    #' @description
    #' Measures every share and prints them from the most to the least volatile.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      measurements <- list()
      for (symbol in self$symbols) {
        measurement <- self$measure(symbol)
        if (is.null(measurement)) {
          cat(sprintf("%s: no candles\n", symbol))
          next
        }
        measurements[[length(measurements) + 1]] <- measurement
      }
      sort_values <- numeric(0)
      for (measurement in measurements) {
        sort_values <- c(sort_values, self$normalized_value(measurement))
      }
      ranking <- order(sort_values, decreasing = TRUE)
      cat(
        sprintf(
          "%-10s %10s %9s %7s %9s\n",
          "Symbol",
          "Close",
          "ATR",
          "ATR %",
          "Last TR"
        )
      )
      for (position in ranking) {
        measurement <- measurements[[position]]
        cat(
          sprintf(
            "%-10s %10.2f %9.2f %6.2f%% %9.2f\n",
            measurement[["symbol"]],
            measurement[["close"]],
            measurement[["average_true_range"]],
            measurement[["normalized"]],
            measurement[["true_range"]]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  VolatilityRanking$new()$run()
}
