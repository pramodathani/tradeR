#' Build a protective stop that leaves only when a fifteen-minute bar closes below a level.
#'
#' A stop on a touch can be taken out by one wild tick on a thin book. The program reads the last price of NSE IDEA, puts the level five percent below it, and protects the position with a `candle_closes` trigger on fifteen-minute bars, leaving at a marketable limit once a bar closes there. The market data read is read-only, and nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/candle_closes/candle_closes/stop_on_a_closing_basis.R

library(tradeR)

#' A protective exit that fires on a bar's close rather than on a touch.
#'
#' @field share The `Equity` whose position is protected.
#' @field bar_minutes The numeric length of one bar in minutes.
ClosingBasisStop <- R6::R6Class(
  "ClosingBasisStop",
  public = list(
    share = NULL,
    bar_minutes = NULL,

    #' @description
    #' Looks the share up and sets the bar length.
    #' @return A new `ClosingBasisStop` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$bar_minutes <- 15
    },

    #' @description
    #' Prints the exit's object with the level it watches.
    #' @return `NULL`, invisibly.
    run = function() {
      last_price <- self$share$last_price
      level <- round(last_price * 0.95, 2)
      part <- OrderPart$new(
        side = "protect",
        trigger = CandleCloses$new(
          level = level,
          bar_minutes = self$bar_minutes
        ),
        pricing = MarketablePricing$new()
      )
      cat(sprintf("Last price %s, closing stop at %s:\n", last_price, level))
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
  ClosingBasisStop$new()$run()
}
