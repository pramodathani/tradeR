#' Print a trend and risk report on an equity index.
#'
#' The program reads the Nifty 50's level and today's range, then works out its momentum, return, volatility and worst fall over the last year from daily candles.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index/index_trend_report.R

library(tradeR)

#' A trend and risk report on one equity index.
#'
#' @field index The `EquityIndex` the report describes.
IndexTrendReport <- R6::R6Class(
  "IndexTrendReport",
  public = list(
    index = NULL,

    #' @description
    #' Looks the index up in UBI.
    #' @param symbol The character nse symbol of the index, such as `"NIFTY"`.
    #' @return A new `IndexTrendReport` object.
    #' @details Errors: signals `EquityIndexError` when UBI has no nse index with that symbol.
    initialize = function(symbol = "NIFTY") {
      self$index <- EquityIndex$new(exchange = "nse", symbol = symbol)
    },

    #' @description
    #' Prints the level, the day's range and the yearly measures.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      level <- self$index$last_price
      if (is.null(level)) {
        level <- "NULL"
      }
      cat(sprintf("%s: %s\n", self$index$symbol, level))
      day <- self$index$ohlc
      day_range <- day[["ohlc"]]
      cat(
        sprintf(
          "Open %s, high %s\n",
          day_range[["open"]],
          day_range[["high"]]
        )
      )
      cat(
        sprintf(
          "Low %s, previous close %s\n",
          day_range[["low"]],
          day[["previous_close"]]
        )
      )
      cat(sprintf("Change today: %s%%\n", day[["change_percent"]]))
      strength_frame <- self$index$relative_strength_index(
        window = 14,
        days = 365
      )
      if (is.null(strength_frame)) {
        cat("UBI has no candles for the last year.\n")
        return(invisible(NULL))
      }
      latest_strength <- strength_frame$rsi_14[[nrow(strength_frame)]]
      cat(
        sprintf(
          "Relative strength index (14 days): %.1f\n",
          latest_strength
        )
      )
      cat(
        sprintf(
          "Return over the year: %.1f%%\n",
          self$index$cumulative_return(days = 365) * 100
        )
      )
      cat(
        sprintf(
          "Volatility: %.1f%%\n",
          self$index$annualised_volatility(days = 365) * 100
        )
      )
      cat(
        sprintf(
          "Worst fall: %.1f%%\n",
          self$index$maximum_drawdown(days = 365) * 100
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexTrendReport$new()$run()
}
