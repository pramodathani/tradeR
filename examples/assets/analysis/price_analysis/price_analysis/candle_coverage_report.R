#' Report how many daily candles a share, an index and a basket supply.
#'
#' The program asks a share, the NIFTY 50 index and an equal-weighted watchlist of three IT shares for a year of daily candles through the `prices` method that `PriceAnalysis` declares, and prints how many candles each returned, the first and last dates, and the latest close.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/price_analysis/price_analysis/candle_coverage_report.R

library(tradeR)

#' A report of the daily candles three different candle sources supply.
#'
#' @field sources A named list mapping a character label to the instrument or basket whose candles are read.
#' @field days The integer number of days to count back from today.
CandleCoverageReport <- R6::R6Class(
  "CandleCoverageReport",
  public = list(
    sources = NULL,
    days = NULL,

    #' @description
    #' Creates the report over a share, an index and a watchlist.
    #' @param days The integer number of days to count back from today.
    #' @return A new `CandleCoverageReport` object.
    initialize = function(days = 365) {
      infosys <- Equity$new(exchange = "nse", symbol = "INFY")
      information_technology <- Watchlist$new(
        name = "information technology",
        instruments = list(
          infosys,
          Equity$new(exchange = "nse", symbol = "TCS"),
          Equity$new(exchange = "nse", symbol = "WIPRO")
        )
      )
      self$sources <- list(
        "Infosys share" = infosys,
        "NIFTY 50 index" = EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
        "IT watchlist" = information_technology
      )
      self$days <- days
    },

    #' @description
    #' Describes one source's candles in a single line.
    #' @param label The character name of the candle source.
    #' @param candles The `data.frame` of candles the source returned, or `NULL` when it had none.
    #' @return A character line naming the source, its candle count, its date range and its latest close.
    describe = function(label, candles) {
      if (is.null(candles)) {
        return(sprintf("%s: no candles", label))
      }
      candle_count <- nrow(candles)
      first_date <- format(candles$datetime[[1]], "%Y-%m-%d")
      last_date <- format(candles$datetime[[candle_count]], "%Y-%m-%d")
      last_close <- candles$close[[candle_count]]
      sprintf(
        "%s: %d candles from %s to %s, last close %.2f",
        label,
        candle_count,
        first_date,
        last_date,
        last_close
      )
    },

    #' @description
    #' Reads each source's candles and prints one line for each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      for (label in names(self$sources)) {
        source <- self$sources[[label]]
        candles <- source$prices(days = self$days)
        cat(self$describe(label, candles), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CandleCoverageReport$new()$run()
}
