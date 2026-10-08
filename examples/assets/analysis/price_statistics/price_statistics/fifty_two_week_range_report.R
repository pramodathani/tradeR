#' Report where a few shares trade within their fifty-two-week range.
#'
#' The program reads a year of daily candles for each share in a list and prints its fifty-two-week high and low, its average close, and where its latest close sits in that range, from 0 at the low to 100 at the high.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_statistics/price_statistics/fifty_two_week_range_report.R

library(tradeR)

#' A report of several NSE shares' positions within their yearly range.
#'
#' @field shares A list of `Equity` objects to report on.
FiftyTwoWeekRangeReport <- R6::R6Class(
  "FiftyTwoWeekRangeReport",
  public = list(
    shares = NULL,

    #' @description
    #' Creates the report over four large NSE shares.
    #' @return A new `FiftyTwoWeekRangeReport` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the shares.
    initialize = function() {
      symbols <- c(
        "RELIANCE",
        "INFY",
        "HDFCBANK",
        "TCS"
      )
      self$shares <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$shares[[length(self$shares) + 1]] <- share
      }
    },

    #' @description
    #' Works out one share's position in its range.
    #' @param share The `Equity` to report on.
    #' @return A character line with the share's low, high, average close and position in the range.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    report_share = function(share) {
      year_high <- share$price_high(days = 365)
      year_low <- share$price_low(days = 365)
      average_close <- share$price_mean(days = 365)
      if (is.null(year_high) || is.null(year_low)) {
        return(sprintf("%s: no candles", share$symbol))
      }
      last_close <- tail(share$prices(days = 10)$close, 1)
      position <- (last_close - year_low) / (year_high - year_low) * 100
      sprintf(
        "%-10s low %9.2f  high %9.2f  average %9.2f  last %9.2f  position %5.1f",
        share$symbol,
        year_low,
        year_high,
        average_close,
        last_close,
        position
      )
    },

    #' @description
    #' Prints one line for each share.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat("Fifty-two-week range, where position 0 is the low and 100 is the high\n")
      for (share in self$shares) {
        cat(self$report_share(share), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FiftyTwoWeekRangeReport$new()$run()
}
