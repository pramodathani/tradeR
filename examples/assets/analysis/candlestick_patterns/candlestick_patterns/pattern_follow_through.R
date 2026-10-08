#' Measure how the Nifty moved in the week after an engulfing or a harami pattern.
#'
#' The program fetches five years of Nifty candles through two pattern methods, then for each pattern splits the matches into bullish and bearish ones and prints how many there were and the average return over the following five candles.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/candlestick_patterns/candlestick_patterns/pattern_follow_through.R

library(tradeR)

#' A study of what the index did after bullish and bearish pattern signals.
#'
#' @field index The `EquityIndex` whose candles are studied.
#' @field holding_candles The integer number of candles after a signal over which the return is measured.
PatternFollowThrough <- R6::R6Class(
  "PatternFollowThrough",
  public = list(
    index = NULL,
    holding_candles = NULL,

    #' @description
    #' Creates the study over the Nifty index on the nse.
    #' @return A new `PatternFollowThrough` object.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$holding_candles <- 5
    },

    #' @description
    #' Calculates each candle's return over the following holding period.
    #' @param frame A `data.frame` of candles with a `close` column.
    #' @return A numeric vector of fractional returns, which is `NA` for the last candles that have no full holding period after them.
    forward_returns = function(frame) {
      closes <- frame$close
      later_closes <- rep(NA_real_, length(closes))
      for (index in seq_along(closes)) {
        later_index <- index + self$holding_candles
        if (later_index <= length(closes)) {
          later_closes[index] <- closes[later_index]
        }
      }
      later_closes / closes - 1
    },

    #' @description
    #' Prints the count and average forward return of the bullish and bearish matches of one pattern.
    #' @param name The character name of the pattern to print.
    #' @param frame The `data.frame` the pattern method returned.
    #' @param column The character name of the pattern column in `frame`.
    #' @return `NULL`, invisibly.
    describe = function(name, frame, column) {
      returns <- self$forward_returns(frame)
      bullish_returns <- returns[which(frame[[column]] > 0)]
      bullish_returns <- bullish_returns[!is.na(bullish_returns)]
      bearish_returns <- returns[which(frame[[column]] < 0)]
      bearish_returns <- bearish_returns[!is.na(bearish_returns)]
      cat(name, "\n", sep = "")
      self$print_group("  bullish", bullish_returns)
      self$print_group("  bearish", bearish_returns)
      invisible(NULL)
    },

    #' @description
    #' Prints the size and mean of one group of forward returns.
    #' @param label The character label printed before the figures.
    #' @param returns A numeric vector of forward returns in the group.
    #' @return `NULL`, invisibly.
    print_group = function(label, returns) {
      if (length(returns) == 0) {
        cat(sprintf("%s: no signal\n", label))
        return(invisible(NULL))
      }
      average <- mean(returns)
      cat(
        sprintf(
          "%s: %d signals, %.2f%% over the next week\n",
          label,
          length(returns),
          average * 100
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Runs both patterns over five years of candles and prints the study.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      engulfing_frame <- self$index$candle_engulfing(days = 1825)
      harami_frame <- self$index$candle_harami(days = 1825)
      if (is.null(engulfing_frame) || is.null(harami_frame)) {
        cat("UBI has no Nifty candles for the last five years.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Nifty over %d daily candles\n", nrow(engulfing_frame)))
      self$describe("Engulfing", engulfing_frame, "candle_engulfing")
      self$describe("Harami", harami_frame, "candle_harami")
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PatternFollowThrough$new()$run()
}
