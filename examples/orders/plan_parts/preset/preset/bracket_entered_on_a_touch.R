#' Combine two existing synthetic order types: a bracket whose entry waits for the price to touch a level.
#'
#' The program reads Vodafone Idea's last price and names two presets in one order, `market_if_touched` 1% below the market and `bracket` with a stop 4% below and a target 3% above. UBI builds a then join out of the bracket around the touch-triggered entry, which no single fixed type offers. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/preset/preset/bracket_entered_on_a_touch.R

library(tradeR)

#' A bracket around an entry that waits for a touch.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field tick_size The numeric tick size of the share in rupees.
TouchBracket <- R6::R6Class(
  "TouchBracket",
  public = list(
    share = NULL,
    tick_size = NULL,

    #' @description
    #' Looks up the share and its tick size.
    #' @return A new `TouchBracket` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        self$tick_size <- as.numeric(self$share$tick_size)
      }
    },

    #' @description
    #' Gives a price a percentage away from the last price, rounded to the tick size.
    #' @param last_price The numeric last price in rupees.
    #' @param percent The numeric percentage to move, negative for a price below the market.
    #' @return The numeric price in rupees.
    price_from_market = function(last_price, percent) {
      ticks <- round(last_price * (1 + percent / 100) / self$tick_size)
      round(ticks * self$tick_size, 2)
    },

    #' @description
    #' Builds the order from the two presets.
    #' @param last_price The numeric last price in rupees the levels are worked out from.
    #' @return The `OrderPart`.
    build_order = function(last_price) {
      stop_price <- self$price_from_market(last_price, -4)
      OrderPart$new(
        presets = list(
          Preset$new(
            "market_if_touched",
            trigger_price = self$price_from_market(last_price, -1)
          ),
          Preset$new(
            "bracket",
            stop_price = stop_price,
            stop_limit_price = round(stop_price - self$tick_size, 2),
            target_price = self$price_from_market(last_price, 3)
          )
        )
      )
    },

    #' @description
    #' Prints the last price and the order's object.
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
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        jsonlite::toJSON(
          self$build_order(last_price)$document(),
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
  TouchBracket$new()$run()
}
