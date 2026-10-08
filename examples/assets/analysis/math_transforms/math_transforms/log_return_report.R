#' Report the log returns of a share and an index from the natural logarithm of their closes.
#'
#' The program reads a year of daily candles for Infosys and for the NIFTY 50 index through `natural_logarithm`, turns the day-to-day differences of the logarithm into log returns, and prints each instrument's total return, its annualised volatility, and its best and worst days. It then checks the result with `exponential` on Vodafone Idea, whose close is small enough for the exponential not to overflow.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/math_transforms/math_transforms/log_return_report.R

library(tradeR)

#' A return and volatility report built on log prices.
#'
#' @field instruments A named list mapping a label to the instrument whose returns are reported.
#' @field days The integer number of days of daily candles to read.
LogReturnReport <- R6::R6Class(
  "LogReturnReport",
  public = list(
    instruments = NULL,
    days = NULL,

    #' @description
    #' Creates the report over Infosys and NIFTY.
    #' @param days The integer number of days of daily candles to read.
    #' @return A new `LogReturnReport` object.
    initialize = function(days = 365) {
      self$instruments <- list(
        INFY = Equity$new(exchange = "nse", symbol = "INFY"),
        NIFTY = EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      )
      self$days <- days
    },

    #' @description
    #' Prints the return figures of one instrument. Each log return is the difference of the logarithm from the previous candle, and missing differences are left out, keeping the row each return belongs to so its date can be printed.
    #' @param label The character name printed for the instrument.
    #' @param instrument The `Instrument` whose returns are reported.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    report = function(label, instrument) {
      frame <- instrument$natural_logarithm(days = self$days)
      if (is.null(frame)) {
        cat(sprintf("%s: no candles\n", label))
        return(invisible(NULL))
      }
      log_returns <- c()
      return_rows <- c()
      for (index in seq_len(nrow(frame))) {
        if (index == 1) {
          next
        }
        difference <- frame$ln[index] - frame$ln[index - 1]
        if (!is.na(difference)) {
          log_returns <- c(log_returns, difference)
          return_rows <- c(return_rows, index)
        }
      }
      total <- exp(sum(log_returns)) - 1
      volatility <- stats::sd(log_returns) * sqrt(252)
      best <- which.max(log_returns)
      worst <- which.min(log_returns)
      best_day <- format(frame$datetime[return_rows[best]], "%Y-%m-%d")
      worst_day <- format(frame$datetime[return_rows[worst]], "%Y-%m-%d")
      cat(
        sprintf(
          "%s: total return %+.2f%% over %d days\n",
          label,
          total * 100,
          length(log_returns)
        )
      )
      cat(sprintf("  annualised volatility %.2f%%\n", volatility * 100))
      cat(
        sprintf(
          "  best day %s %+.2f%%\n",
          best_day,
          (exp(log_returns[best]) - 1) * 100
        )
      )
      cat(
        sprintf(
          "  worst day %s %+.2f%%\n",
          worst_day,
          (exp(log_returns[worst]) - 1) * 100
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Checks that the logarithm of the exponential gives Vodafone Idea's close back.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    check_round_trip = function() {
      share <- Equity$new(exchange = "nse", symbol = "IDEA")
      frame <- share$exponential(days = 30)
      if (is.null(frame)) {
        cat("IDEA: no candles\n")
        return(invisible(NULL))
      }
      largest_error <- 0.0
      for (index in seq_len(nrow(frame))) {
        exponential_value <- frame$exp[index]
        close <- frame$close[index]
        error <- abs(log(exponential_value) - close)
        if (error > largest_error) {
          largest_error <- error
        }
      }
      cat(
        sprintf(
          "IDEA round trip through exp and ln: largest error %.2e\n",
          largest_error
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Prints the report for every instrument and the round-trip check.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (label in names(self$instruments)) {
        self$report(label, self$instruments[[label]])
      }
      self$check_round_trip()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  LogReturnReport$new()$run()
}
