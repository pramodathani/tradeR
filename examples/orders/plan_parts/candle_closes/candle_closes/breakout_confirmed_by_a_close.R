#' Build a breakout entry that buys only after a five-minute bar closes above resistance.
#'
#' A price that pokes through a level and falls straight back is not a breakout. The program reads the day's high of NSE IDEA and waits for a five-minute bar, UBI's default length, to close at or above it before buying at a marketable limit. The market data read is read-only, and nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/candle_closes/candle_closes/breakout_confirmed_by_a_close.R

library(tradeR)

#' A buy above the day's high, confirmed by a bar's close.
#'
#' @field share The `Equity` bought on the breakout.
ConfirmedBreakout <- R6::R6Class(
  "ConfirmedBreakout",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `ConfirmedBreakout` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the entry's object with the level it watches.
    #' @return `NULL`, invisibly.
    run = function() {
      day_high <- self$share$ohlc[["high"]]
      part <- OrderPart$new(
        trigger = CandleCloses$new(
          level = day_high,
          direction = "at_or_above"
        ),
        pricing = MarketablePricing$new(buffer_ticks = 1)
      )
      cat(
        sprintf(
          "The entry waits for a five-minute close at or above %s:\n",
          day_high
        )
      )
      cat(
        jsonlite::toJSON(
          part$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ConfirmedBreakout$new()$run()
}
