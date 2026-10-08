#' Report which shares on a watch list are in a golden-cross or a death-cross trend.
#'
#' The program compares the 50-day and 200-day simple moving averages of each share over three years, finds the latest crossing in either direction with `is_cross_over` and `is_cross_under`, and prints the share's current trend with the date it began.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/signals/signals/golden_cross_watch.R

library(tradeR)

#' A trend report over a watch list of shares.
#'
#' @field symbols The character vector of nse symbols to report on.
GoldenCrossWatch <- R6::R6Class(
  "GoldenCrossWatch",
  public = list(
    symbols = NULL,

    #' @description
    #' Creates the report over four large nse shares.
    #' @return A new `GoldenCrossWatch` object.
    initialize = function() {
      self$symbols <- c(
        "INFY",
        "TCS",
        "RELIANCE",
        "HDFCBANK"
      )
    },

    #' @description
    #' Builds one frame holding the 50-day and the 200-day averages of a share.
    #' @param share The `Equity` to read.
    #' @return A `data.frame` of three years of candles with `sma_50` and `sma_200` columns, or `NULL` when UBI has no candles.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    averages = function(share) {
      fast_frame <- share$simple_moving_average(window = 50, days = 1095)
      slow_frame <- share$simple_moving_average(window = 200, days = 1095)
      if (is.null(fast_frame) || is.null(slow_frame)) {
        return(NULL)
      }
      fast_frame$sma_200 <- slow_frame$sma_200
      fast_frame
    },

    #' @description
    #' Finds the date of the last marked row of a crossing frame.
    #' @param crossings The `data.frame` returned by `is_cross_over` or `is_cross_under`.
    #' @param column The character name of the logical column to read, `cross_over` or `cross_under`.
    #' @return The `POSIXct` time of the last crossing, or `NULL` when there is none.
    latest_date = function(crossings, column) {
      marked <- crossings[crossings[[column]], ]
      if (nrow(marked) == 0) {
        return(NULL)
      }
      marked$datetime[[nrow(marked)]]
    },

    #' @description
    #' Prints the current trend of one share.
    #' @param symbol The character nse symbol of the share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    report = function(symbol) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      frame <- self$averages(share)
      if (is.null(frame)) {
        cat(sprintf("%s: no candles\n", symbol))
        return(invisible(NULL))
      }
      golden <- share$is_cross_over(frame, "sma_50", "sma_200")
      death <- share$is_cross_under(frame, "sma_50", "sma_200")
      golden_date <- self$latest_date(golden, "cross_over")
      death_date <- self$latest_date(death, "cross_under")
      latest <- frame[nrow(frame), ]
      if (isTRUE(latest$sma_50 > latest$sma_200)) {
        trend <- "golden-cross trend"
        since <- golden_date
      } else {
        trend <- "death-cross trend"
        since <- death_date
      }
      if (is.null(since)) {
        cat(sprintf("%s: %s, no crossing in three years\n", symbol, trend))
      } else {
        since_day <- format(since, "%Y-%m-%d")
        cat(sprintf("%s: %s since %s\n", symbol, trend, since_day))
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the trend of every share on the watch list.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat("Trend by the 50-day and 200-day simple moving averages\n")
      for (symbol in self$symbols) {
        self$report(symbol)
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  GoldenCrossWatch$new()$run()
}
