#' Report whether money is flowing into or out of a few shares.
#'
#' The program reads three months of daily candles for Infosys, Reliance Industries and State Bank of India, and for each prints the last five sessions of the Chaikin accumulation distribution line and the Chaikin oscillator, with a verdict of buying or selling pressure from the oscillator's sign.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/volume_indicators/volume_indicators/accumulation_distribution_report.R

library(tradeR)

#' A report of the Chaikin money flow measures of several shares.
#'
#' @field shares A list of `Equity` objects to report on.
#' @field days The integer number of days of candles to read.
AccumulationDistributionReport <- R6::R6Class(
  "AccumulationDistributionReport",
  public = list(
    shares = NULL,
    days = NULL,

    #' @description
    #' Creates the report over three NSE shares.
    #' @param days The integer number of days of candles to read.
    #' @return A new `AccumulationDistributionReport` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the shares.
    initialize = function(days = 90) {
      symbols <- c(
        "INFY",
        "RELIANCE",
        "SBIN"
      )
      self$shares <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$shares[[length(self$shares) + 1]] <- share
      }
      self$days <- days
    },

    #' @description
    #' Prints one share's last five sessions and its verdict.
    #' @param share The `Equity` to report on.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    report_share = function(share) {
      line <- share$chaikin_accumulation_distribution_line(days = self$days)
      oscillator <- share$chaikin_accumulation_distribution_oscillator(
        days = self$days
      )
      if (is.null(line) || is.null(oscillator)) {
        cat(sprintf("%s: no candles\n", share$symbol))
        return(invisible(NULL))
      }
      line$chaikin_adosc3_10 <- oscillator$chaikin_adosc3_10
      cat(sprintf("%s:\n", share$symbol))
      columns <- c(
        "datetime",
        "close",
        "chaikin_ad",
        "chaikin_adosc3_10"
      )
      print(tail(line[columns], 5), row.names = FALSE)
      if (isTRUE(tail(oscillator$chaikin_adosc3_10, 1) > 0)) {
        cat("Verdict: buying pressure\n")
      } else {
        cat("Verdict: selling pressure\n")
      }
      cat("\n")
      invisible(NULL)
    },

    #' @description
    #' Prints the report for every share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (share in self$shares) {
        self$report_share(share)
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  AccumulationDistributionReport$new()$run()
}
