#' Summarise a share's daily ranges, its open-to-close moves and the value it traded.
#'
#' The program reads three months of Infosys daily candles through `subtract`, `divide`, `add` and `multiply`, and prints the average daily range in rupees and as a percentage, the number of days that closed above their open, the average midpoint, and the average and largest rupee value traded in a day.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/math_operators/math_operators/daily_range_statistics.R

library(tradeR)

#' A summary of how a share moves within each day.
#'
#' @field share The `Equity` that is summarised.
#' @field days The integer number of days of daily candles to read.
DailyRangeStatistics <- R6::R6Class(
  "DailyRangeStatistics",
  public = list(
    share = NULL,
    days = NULL,

    #' @description
    #' Creates the summary over the Infosys share.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `DailyRangeStatistics` object.
    initialize = function(days = 90) {
      self$share <- Equity$new(exchange = "nse", symbol = "INFY")
      self$days <- days
    },

    #' @description
    #' Reads the candles through the four operators and prints the summary. Missing values are skipped in the averages and counts, as pandas skips them.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      range_frame <- self$share$subtract(days = self$days)
      if (is.null(range_frame)) {
        cat("UBI has no Infosys candles for the range.\n")
        return(invisible(NULL))
      }
      ratio_frame <- self$share$divide(days = self$days)
      move_frame <- self$share$divide(
        first_column = "close",
        second_column = "open",
        days = self$days
      )
      midpoint_frame <- self$share$add(days = self$days)
      value_frame <- self$share$multiply(
        first_column = "close",
        second_column = "volume",
        days = self$days
      )
      range_percent <- (ratio_frame$quotient - 1) * 100
      up_days <- sum(move_frame$quotient > 1, na.rm = TRUE)
      midpoint <- midpoint_frame$sum / 2
      crores <- value_frame$product / 10000000
      cat(sprintf("Infosys over %d sessions:\n", nrow(range_frame)))
      cat(
        sprintf(
          "Average daily range: Rs %.2f\n",
          mean(range_frame$difference, na.rm = TRUE)
        )
      )
      cat(
        sprintf(
          "Average daily range: %.2f%% of the low\n",
          mean(range_percent, na.rm = TRUE)
        )
      )
      cat(sprintf("Closed above the open on %d days\n", as.integer(up_days)))
      cat(
        sprintf(
          "Average midpoint of high and low: Rs %.2f\n",
          mean(midpoint, na.rm = TRUE)
        )
      )
      cat(
        sprintf(
          "Average value traded: Rs %.1f crore\n",
          mean(crores, na.rm = TRUE)
        )
      )
      cat(
        sprintf(
          "Largest value traded: Rs %.1f crore\n",
          max(crores, na.rm = TRUE)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DailyRangeStatistics$new()$run()
}
