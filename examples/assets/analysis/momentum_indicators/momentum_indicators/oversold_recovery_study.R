#' Study what NIFTY did after its relative strength index recovered from oversold.
#'
#' The program reads two years of NIFTY 50 daily candles with the 14-day relative strength index and the slow stochastic oscillator, finds each day on which the relative strength index climbed back above 30, and prints the slow stochastic reading that day and how far the index moved over the following ten trading days.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/momentum_indicators/momentum_indicators/oversold_recovery_study.R

library(tradeR)

#' A study of the index's moves after each recovery from an oversold reading.
#'
#' @field index The `EquityIndex` that is studied.
#' @field days The integer number of days of daily candles to study.
#' @field horizon The integer number of trading days after a recovery over which the move is measured.
OversoldRecoveryStudy <- R6::R6Class(
  "OversoldRecoveryStudy",
  public = list(
    index = NULL,
    days = NULL,
    horizon = NULL,

    #' @description
    #' Creates the study over the NIFTY 50 index.
    #' @param days The integer number of days of daily candles to study.
    #' @param horizon The integer number of trading days after a recovery over which the move is measured.
    #' @return A new `OversoldRecoveryStudy` object.
    initialize = function(days = 730, horizon = 10) {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$days <- days
      self$horizon <- horizon
    },

    #' @description
    #' Finds the rows on which the relative strength index crossed back above 30. A comparison with a missing value counts as false, as it does in Python.
    #' @param relative_strength A numeric vector of relative strength index values, one per candle.
    #' @return An integer vector of row numbers, one for each recovery.
    recovery_rows = function(relative_strength) {
      rows <- integer(0)
      for (position in seq_along(relative_strength)) {
        if (position == 1) {
          next
        }
        previous <- relative_strength[position - 1]
        current <- relative_strength[position]
        if (isTRUE(previous < 30 && current >= 30)) {
          rows <- c(rows, position)
        }
      }
      rows
    },

    #' @description
    #' Prints one line for each recovery and the average move after it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      relative_strength_frame <- self$index$relative_strength_index(
        window = 14,
        days = self$days
      )
      if (is.null(relative_strength_frame)) {
        cat("UBI has no NIFTY candles for the range.\n")
        return(invisible(NULL))
      }
      stochastic_frame <- self$index$stochastic_oscillator(
        fast_k_period = 14,
        days = self$days
      )
      closes <- relative_strength_frame$close
      rows <- self$recovery_rows(relative_strength_frame$rsi_14)
      cat(
        sprintf(
          "Recoveries above 30 in the last %d days: %d\n",
          as.integer(self$days),
          length(rows)
        )
      )
      moves <- c()
      for (row in rows) {
        day <- format(relative_strength_frame$datetime[row], "%Y-%m-%d")
        slow_k <- stochastic_frame$slowk_3[row]
        later_row <- row + self$horizon
        if (later_row > length(closes)) {
          cat(
            sprintf(
              "%s  slow %%K %5.1f  too recent to measure\n",
              day,
              slow_k
            )
          )
          next
        }
        move <- (closes[later_row] / closes[row] - 1) * 100
        moves <- c(moves, move)
        cat(
          sprintf(
            "%s  slow %%K %5.1f  next %d days %+.2f%%\n",
            day,
            slow_k,
            as.integer(self$horizon),
            move
          )
        )
      }
      if (length(moves) > 0) {
        average <- sum(moves) / length(moves)
        cat(
          sprintf(
            "Average move over %d days: %+.2f%%\n",
            as.integer(self$horizon),
            average
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OversoldRecoveryStudy$new()$run()
}
