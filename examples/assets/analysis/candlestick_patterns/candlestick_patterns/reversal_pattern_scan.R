#' Scan a share for the common reversal candlestick patterns of the last month.
#'
#' The program runs six well-known reversal patterns over two months of Infosys candles and prints, for each pattern, the dates in the last thirty days on which it appeared and whether each match was bullish or bearish.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/candlestick_patterns/candlestick_patterns/reversal_pattern_scan.R

library(tradeR)

#' A scan of one share for recent reversal candlestick patterns.
#'
#' @field share The `Equity` whose candles are scanned.
#' @field lookback_days The integer number of recent days whose matches are printed.
ReversalPatternScan <- R6::R6Class(
  "ReversalPatternScan",
  public = list(
    share = NULL,
    lookback_days = NULL,

    #' @description
    #' Creates the scan over Infosys on the nse.
    #' @return A new `ReversalPatternScan` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "INFY")
      self$lookback_days <- 30
    },

    #' @description
    #' Runs each reversal pattern over two months of candles.
    #' @return A named list mapping the name of each pattern to a list with `frame`, the `data.frame` the pattern method returned or `NULL`, and `column`, the character name of its pattern column.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    pattern_frames = function() {
      days <- self$lookback_days * 2
      list(
        "hammer" = list(
          frame = self$share$candle_hammer(days = days),
          column = "candle_hammer"
        ),
        "hanging man" = list(
          frame = self$share$candle_hanging_man(days = days),
          column = "candle_hangingman"
        ),
        "engulfing" = list(
          frame = self$share$candle_engulfing(days = days),
          column = "candle_engulfing"
        ),
        "harami" = list(
          frame = self$share$candle_harami(days = days),
          column = "candle_harami"
        ),
        "morning star" = list(
          frame = self$share$candle_morning_star(days = days),
          column = "candle_morning_star"
        ),
        "evening star" = list(
          frame = self$share$candle_evening_star(days = days),
          column = "candle_evening_star"
        )
      )
    },

    #' @description
    #' Keeps the rows of the lookback period on which a pattern matched.
    #' @param frame The `data.frame` a pattern method returned.
    #' @param column The character name of the pattern column in `frame`.
    #' @return A `data.frame` of the matching rows, which may have no rows.
    recent_matches = function(frame, column) {
      today <- TimeConverter$new()$today()
      first_day <- today - self$lookback_days
      dates <- as.Date(format(frame$datetime, "%Y-%m-%d"))
      is_recent <- dates >= first_day
      is_match <- frame[[column]] != 0
      frame[which(is_recent & is_match), , drop = FALSE]
    },

    #' @description
    #' Scans every pattern and prints its recent matches.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      cat(
        sprintf(
          "Reversal patterns on INFY in the last %d days\n",
          self$lookback_days
        )
      )
      frames <- self$pattern_frames()
      for (name in names(frames)) {
        frame <- frames[[name]][["frame"]]
        column <- frames[[name]][["column"]]
        if (is.null(frame)) {
          cat(sprintf("%s: UBI has no candles\n", name))
          next
        }
        matches <- self$recent_matches(frame, column)
        if (nrow(matches) == 0) {
          cat(sprintf("%s: no match\n", name))
          next
        }
        for (position in seq_len(nrow(matches))) {
          if (matches[[column]][position] > 0) {
            direction <- "bullish"
          } else {
            direction <- "bearish"
          }
          match_date <- format(matches$datetime[position], "%Y-%m-%d")
          cat(
            sprintf(
              "%s: %s on %s, close %s\n",
              name,
              direction,
              match_date,
              format(matches$close[position])
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ReversalPatternScan$new()$run()
}
