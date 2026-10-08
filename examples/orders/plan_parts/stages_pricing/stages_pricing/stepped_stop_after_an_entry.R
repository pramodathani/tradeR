#' Build an entry followed by a stepped stop that moves to breakeven and then trails.
#'
#' The program reads Vodafone Idea's last price and builds a Then join: a buy, and on each of its fills a protecting stop 3% below the last price that moves to breakeven at a 3% gain and trails 2% behind from a 6% gain. It prints the join's object as UBI would read it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/stages_pricing/stages_pricing/stepped_stop_after_an_entry.R

library(tradeR)

#' A buy of Vodafone Idea protected by a stepped stop.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
SteppedStopAfterEntry <- R6::R6Class(
  "SteppedStopAfterEntry",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `SteppedStopAfterEntry` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the join's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      three_percent <- round(last_price * 0.03, 2)
      stop <- StagesPricing$new(
        entry_price = last_price,
        stop_price = round(last_price - three_percent, 2),
        limit_offset = tick_size,
        rules = list(
          StageRule$new(gain = three_percent, stop_at_gain = 0.0),
          StageRule$new(
            gain = round(three_percent * 2, 2),
            trail_points = round(last_price * 0.02, 2)
          )
        )
      )
      part <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(side = "protect", pricing = stop)
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
  SteppedStopAfterEntry$new()$run()
}
