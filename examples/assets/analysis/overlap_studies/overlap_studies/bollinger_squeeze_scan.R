#' Scan a few shares and a basket for a Bollinger Band squeeze.
#'
#' The program works out each candle source's twenty-day Bollinger Bands over the last six months, measures the band width as a percentage of the middle band, and reports a squeeze when today's width is in the narrowest fifth of the period, which traders read as a quiet spell that often comes before a larger move.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/overlap_studies/overlap_studies/bollinger_squeeze_scan.R

library(tradeR)

#' A scan of several candle sources for narrow Bollinger Bands.
#'
#' @field sources A named list mapping a label to the instrument or basket to scan.
#' @field window The integer number of candles in the bands' moving average.
#' @field days The integer number of days of candles to read.
BollingerSqueezeScan <- R6::R6Class(
  "BollingerSqueezeScan",
  public = list(
    sources = NULL,
    window = NULL,
    days = NULL,

    #' @description
    #' Creates the scan over four banks and a watchlist of them.
    #' @param window The integer number of candles in the bands' moving average.
    #' @param days The integer number of days of candles to read.
    #' @return A new `BollingerSqueezeScan` object.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the shares.
    initialize = function(window = 20, days = 182) {
      symbols <- c(
        "HDFCBANK",
        "ICICIBANK",
        "SBIN",
        "AXISBANK"
      )
      self$sources <- list()
      banks <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$sources[[symbol]] <- share
        banks[[length(banks) + 1]] <- share
      }
      self$sources[["bank watchlist"]] <- Watchlist$new(
        name = "banks",
        instruments = banks
      )
      self$window <- window
      self$days <- days
    },

    #' @description
    #' Works out the band width of every candle as a percentage of the middle band.
    #' @param source The instrument or basket whose bands are read.
    #' @return A numeric vector of widths without the warm-up candles, or `NULL` when there are no candles.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    band_widths = function(source) {
      candles <- source$bollinger_bands(window = self$window, days = self$days)
      if (is.null(candles)) {
        return(NULL)
      }
      upper <- candles[[paste0("bb_upper_", self$window)]]
      lower <- candles[[paste0("bb_lower_", self$window)]]
      middle <- candles[[paste0("bb_middle_", self$window)]]
      widths <- (upper - lower) / middle * 100
      widths[!is.na(widths)]
    },

    #' @description
    #' Prints each source's width today, its narrowest-fifth threshold and the verdict. The threshold is the 20th percentile with linear interpolation, the same rule as pandas' `quantile()`.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (label in names(self$sources)) {
        widths <- self$band_widths(self$sources[[label]])
        if (is.null(widths) || length(widths) == 0) {
          cat(sprintf("%s: no candles\n", label))
          next
        }
        today <- widths[length(widths)]
        threshold <- stats::quantile(widths, 0.2, names = FALSE, type = 7)
        if (today <= threshold) {
          verdict <- "squeeze"
        } else {
          verdict <- "no squeeze"
        }
        cat(
          sprintf(
            "%-15s width %5.2f%%  narrowest fifth below %5.2f%%  %s\n",
            label,
            today,
            threshold,
            verdict
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BollingerSqueezeScan$new()$run()
}
