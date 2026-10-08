#' Build a buy stop above the market that protects a short position, resting at the broker.
#'
#' For a short position the danger is a rise, so the protecting stop is a buy above the market. The program reads Vodafone Idea's last price, sets the stop's trigger 3% above it and its limit one tick higher, and builds a protecting order with that stop; with a template that sells, `protect` sends a buy. Because the stop rests at the broker it still fires if UBI's order engine is down. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/native_stop_pricing/native_stop_pricing/buy_stop_over_a_short_position.R

library(tradeR)

#' A buy stop 3% above the market for a short position.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ShortCoverStop <- R6::R6Class(
  "ShortCoverStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ShortCoverStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the stop's prices and the protecting order's object.
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
      trigger_ticks <- round(last_price * 1.03 / tick_size)
      trigger_price <- round(trigger_ticks * tick_size, 2)
      limit_price <- round((trigger_ticks + 1) * tick_size, 2)
      part <- OrderPart$new(
        side = "protect",
        pricing = NativeStopPricing$new(
          trigger_price = trigger_price,
          limit_price = limit_price
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        sprintf(
          "Buy stop triggered at %s, limit %s\n",
          trigger_price,
          limit_price
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
  ShortCoverStop$new()$run()
}
