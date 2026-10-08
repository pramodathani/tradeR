#' Describe NIFTY's trend with a regression channel two standard deviations wide.
#'
#' The program reads half a year of NIFTY 50 daily candles, fits a 50-day rolling regression line through the close, and prints the line's latest value, slope, angle and intercept, a channel two standard deviations either side of the line, and where the latest close sits in that channel.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/statistic_functions/statistic_functions/regression_channel.R

library(tradeR)

#' A regression channel drawn around an index's close.
#'
#' @field index The `EquityIndex` whose trend is described.
#' @field window The integer number of candles the regression line is fitted over.
#' @field days The integer number of days of daily candles to read.
RegressionChannel <- R6::R6Class(
  "RegressionChannel",
  public = list(
    index = NULL,
    window = NULL,
    days = NULL,

    #' @description
    #' Creates the channel over the NIFTY 50 index.
    #' @param window The integer number of candles the regression line is fitted over.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `RegressionChannel` object.
    initialize = function(window = 50, days = 180) {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$window <- window
      self$days <- days
    },

    #' @description
    #' Gives the last value of one column.
    #' @param frame The `data.frame` of candles with the column added.
    #' @param column The character name of the column.
    #' @return The numeric value in the column's last row.
    #' @details Errors: signals a plain error when the frame has no such column.
    latest = function(frame, column) {
      if (!(column %in% names(frame))) {
        stop(sprintf("No such column: %s", column))
      }
      as.numeric(tail(frame[[column]], 1))
    },

    #' @description
    #' Fits the line, draws the channel and prints the description.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      line_frame <- self$index$linear_regression(
        window = self$window,
        days = self$days
      )
      if (is.null(line_frame)) {
        cat("UBI has no NIFTY candles for the range.\n")
        return(invisible(NULL))
      }
      suffix <- as.character(self$window)
      line <- self$latest(line_frame, paste0("lin_regr_", suffix))
      slope <- self$latest(
        self$index$linear_regression_slope(
          window = self$window,
          days = self$days
        ),
        paste0("lin_regr_slope_", suffix)
      )
      angle <- self$latest(
        self$index$linear_regression_angle(
          window = self$window,
          days = self$days
        ),
        paste0("lin_regr_angle_", suffix)
      )
      intercept <- self$latest(
        self$index$linear_regression_intercept(
          window = self$window,
          days = self$days
        ),
        paste0("lin_regr_int_", suffix)
      )
      width <- self$latest(
        self$index$standard_deviation(
          window = self$window,
          standard_deviations = 2,
          days = self$days
        ),
        paste0("std_dev_", suffix)
      )
      close <- self$latest(line_frame, "close")
      cat(sprintf("Regression line %.2f, intercept %.2f\n", line, intercept))
      cat(
        sprintf(
          "Slope %+.2f points a day, angle %+.2f degrees\n",
          slope,
          angle
        )
      )
      cat(sprintf("Channel from %.2f to %.2f\n", line - width, line + width))
      position <- (close - (line - width)) / (2 * width)
      cat(
        sprintf(
          "Close %.2f sits %.0f%% of the way up the channel\n",
          close,
          position * 100
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RegressionChannel$new()$run()
}
