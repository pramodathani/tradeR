#' Print a dashboard of the main NSE indices.
#'
#' The program builds each index as a NonTradeableInstrument, reads its level and its change on the day, and works out its return over the last month and the last year from UBI's daily candles.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/non_tradeable_instrument/index_dashboard.R

library(tradeR)

#' A dashboard of index levels and returns.
#'
#' @field indices A list of `NonTradeableInstrument` objects, one per index shown.
IndexDashboard <- R6::R6Class(
  "IndexDashboard",
  public = list(
    indices = NULL,

    #' @description
    #' Looks each index up in UBI.
    #' @return A new `IndexDashboard` object.
    #' @details Errors: signals `NonTradeableInstrumentError` when a symbol names something that is not an index, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      symbols <- c(
        "NIFTY",
        "BANKNIFTY",
        "FINNIFTY",
        "MIDCPNIFTY"
      )
      self$indices <- list()
      for (symbol in symbols) {
        index <- NonTradeableInstrument$new(
          exchange = "nse",
          segment = "equity_indices",
          symbol = symbol
        )
        self$indices[[length(self$indices) + 1]] <- index
      }
    },

    #' @description
    #' Works out an index's return over a number of days from its daily closes.
    #' @param index The `NonTradeableInstrument` to measure.
    #' @param days The integer number of days to count back from today.
    #' @return The numeric return in per cent, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    return_over = function(index, days) {
      candles <- index$prices(interval = "day", days = days)
      if (is.null(candles)) {
        return(NULL)
      }
      first_close <- candles$close[[1]]
      last_close <- candles$close[[nrow(candles)]]
      (last_close - first_close) / first_close * 100
    },

    #' @description
    #' Formats a percentage for the dashboard, or a dash when it is unknown.
    #' @param value The numeric percentage, or `NULL`.
    #' @return The character string to print.
    format_percent = function(value) {
      if (is.null(value)) {
        return("-")
      }
      sprintf("%+.2f%%", value)
    },

    #' @description
    #' Prints one line per index.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat(sprintf(
        "%-12s %10s %9s %9s %9s\n",
        "Index",
        "Level",
        "Day",
        "Month",
        "Year"
      ))
      for (index in self$indices) {
        day <- index$ohlc
        month_return <- self$return_over(index, 30)
        year_return <- self$return_over(index, 365)
        cat(sprintf(
          "%-12s %10.2f %9s %9s %9s\n",
          index$symbol,
          day[["last_price"]],
          self$format_percent(day[["change_percent"]]),
          self$format_percent(month_return),
          self$format_percent(year_return)
        ))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexDashboard$new()$run()
}
