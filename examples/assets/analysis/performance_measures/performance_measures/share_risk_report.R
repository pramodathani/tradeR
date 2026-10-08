#' Print a one-page risk and return report for a share measured against the Nifty.
#'
#' The program asks `performance_summary` for every measure of Infosys against the Nifty over one year, with a 6.5 percent risk-free rate, and prints the figures in three groups: return, risk and the comparison with the benchmark. It then prints the worst stretch of the year from `drawdowns`.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/performance_measures/performance_measures/share_risk_report.R

library(tradeR)

#' A risk and return report for one share against one benchmark.
#'
#' @field share The `Equity` that is measured.
#' @field benchmark The `EquityIndex` it is measured against.
#' @field risk_free_rate The numeric annual risk-free rate as a fraction.
#' @field days The integer number of days the report covers.
ShareRiskReport <- R6::R6Class(
  "ShareRiskReport",
  public = list(
    share = NULL,
    benchmark = NULL,
    risk_free_rate = NULL,
    days = NULL,

    #' @description
    #' Creates the report for Infosys against the Nifty over one year.
    #' @return A new `ShareRiskReport` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "INFY")
      self$benchmark <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$risk_free_rate <- 0.065
      self$days <- 365
    },

    #' @description
    #' Prints one group of measures from the summary.
    #' @param title The character heading of the group.
    #' @param summary The named list returned by `performance_summary()`.
    #' @param measures A character vector of the measure names to print, in order.
    #' @param percentages A character vector of the measure names to print as percentages rather than as plain numbers.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when a measure is not in the summary.
    print_group = function(title, summary, measures, percentages) {
      cat(title, "\n", sep = "")
      for (measure in measures) {
        if (!(measure %in% names(summary))) {
          stop(sprintf("The summary has no measure named %s", measure))
        }
        value <- summary[[measure]]
        label <- gsub("_", " ", measure)
        if (is.null(value)) {
          cat(sprintf("  %-24snot available\n", label))
        } else if (measure %in% percentages) {
          cat(sprintf("  %-24s%.2f%%\n", label, value * 100))
        } else {
          cat(sprintf("  %-24s%.2f\n", label, value))
        }
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the peak before the worst drawdown of the period and the lowest point after it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_worst_stretch = function() {
      frame <- self$share$drawdowns(days = self$days)
      if (is.null(frame)) {
        return(invisible(NULL))
      }
      trough_row <- which.min(frame$drawdown)
      peak_row <- which.max(frame$close[seq_len(trough_row)])
      cat("Worst stretch\n")
      cat(
        sprintf(
          "  peak    %s  %.2f\n",
          format(frame$datetime[peak_row], "%Y-%m-%d"),
          frame$close[peak_row]
        )
      )
      cat(
        sprintf(
          "  trough  %s  %.2f\n",
          format(frame$datetime[trough_row], "%Y-%m-%d"),
          frame$close[trough_row]
        )
      )
      cat(sprintf("  fall    %.2f%%\n", frame$drawdown[trough_row] * 100))
      invisible(NULL)
    },

    #' @description
    #' Calculates the summary and prints the report.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      summary <- self$share$performance_summary(
        benchmark = self$benchmark,
        risk_free_rate = self$risk_free_rate,
        days = self$days
      )
      if (is.null(summary)) {
        cat("UBI has too few Infosys candles for the report.\n")
        return(invisible(NULL))
      }
      percentages <- c(
        "cumulative_return",
        "annualised_return",
        "annualised_volatility",
        "maximum_drawdown",
        "value_at_risk",
        "expected_shortfall",
        "alpha",
        "tracking_error"
      )
      cat(
        sprintf(
          "INFY against the NIFTY over the last %d days\n",
          as.integer(self$days)
        )
      )
      self$print_group(
        "Return",
        summary,
        c(
          "cumulative_return",
          "annualised_return",
          "sharpe_ratio",
          "sortino_ratio",
          "calmar_ratio"
        ),
        percentages
      )
      self$print_group(
        "Risk",
        summary,
        c(
          "annualised_volatility",
          "maximum_drawdown",
          "value_at_risk",
          "expected_shortfall"
        ),
        percentages
      )
      self$print_group(
        "Against the benchmark",
        summary,
        c(
          "benchmark_beta",
          "alpha",
          "tracking_error",
          "information_ratio",
          "up_capture_ratio",
          "down_capture_ratio"
        ),
        percentages
      )
      self$print_worst_stretch()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareRiskReport$new()$run()
}
