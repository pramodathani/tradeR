#' Check how faithfully two Nifty exchange-traded funds follow the index.
#'
#' The program measures NIFTYBEES and SETFNIF50 against the Nifty over one year with `tracking_error`, `benchmark_beta`, `up_capture_ratio`, `down_capture_ratio` and `cumulative_return`, and prints one row per fund, so the fund that follows the index most closely stands out.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/performance_measures/performance_measures/index_fund_tracking.R

library(tradeR)

#' A comparison of index funds with the index they follow.
#'
#' @field benchmark The `EquityIndex` the funds follow.
#' @field fund_symbols A character vector of the nse symbols of the funds.
#' @field days The integer number of days the comparison covers.
IndexFundTracking <- R6::R6Class(
  "IndexFundTracking",
  public = list(
    benchmark = NULL,
    fund_symbols = NULL,
    days = NULL,

    #' @description
    #' Creates the comparison of two Nifty funds over one year.
    #' @return A new `IndexFundTracking` object.
    initialize = function() {
      self$benchmark <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$fund_symbols <- c(
        "NIFTYBEES",
        "SETFNIF50"
      )
      self$days <- 365
    },

    #' @description
    #' Measures one fund against the benchmark.
    #' @param symbol The character nse symbol of the fund.
    #' @return A named list mapping each measure name to its numeric value, or to `NULL` when it cannot be calculated.
    #' @details Errors: signals `ExchangeTradedFundError` when UBI has no fund for the symbol, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    measure = function(symbol) {
      fund <- ExchangeTradedFund$new(exchange = "nse", symbol = symbol)
      list(
        cumulative_return = fund$cumulative_return(days = self$days),
        tracking_error = fund$tracking_error(
          self$benchmark,
          days = self$days
        ),
        beta = fund$benchmark_beta(self$benchmark, days = self$days),
        up_capture = fund$up_capture_ratio(
          self$benchmark,
          days = self$days
        ),
        down_capture = fund$down_capture_ratio(
          self$benchmark,
          days = self$days
        )
      )
    },

    #' @description
    #' Turns a measure into a number for the table, so a measure that cannot be calculated becomes `NA`, as pandas turns `None` into `NaN`.
    #' @param value The numeric measure, or `NULL`.
    #' @return A numeric value, `NA` when `value` is `NULL`.
    number_or_missing = function(value) {
      if (is.null(value)) {
        return(NA_real_)
      }
      as.numeric(value)
    },

    #' @description
    #' Measures every fund and prints the comparison table.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      index_return <- self$benchmark$cumulative_return(days = self$days)
      cat(
        sprintf(
          "NIFTY return over %d days: %.2f%%\n",
          as.integer(self$days),
          index_return * 100
        )
      )
      table <- NULL
      for (symbol in self$fund_symbols) {
        measures <- self$measure(symbol)
        row <- data.frame(
          cumulative_return = self$number_or_missing(
            measures[["cumulative_return"]]
          ),
          tracking_error = self$number_or_missing(measures[["tracking_error"]]),
          beta = self$number_or_missing(measures[["beta"]]),
          up_capture = self$number_or_missing(measures[["up_capture"]]),
          down_capture = self$number_or_missing(measures[["down_capture"]]),
          row.names = symbol
        )
        table <- rbind(table, row)
      }
      print(round(table, 4))
      closest <- rownames(table)[which.min(table$tracking_error)]
      cat(sprintf("Closest to the index: %s\n", closest))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexFundTracking$new()$run()
}
