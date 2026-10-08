#' Build a sell that chases the bid but never sells below a floor worked out from the last price.
#'
#' The program reads Vodafone Idea's last price and builds a sell that steps down a tick every five seconds from its own side of the book, with a cap 1% below the last price that every step respects. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/chase_pricing/chase_pricing/sell_chase_with_a_floor.R

library(tradeR)

#' A chasing sell of Vodafone Idea that never goes below 1% under the last price.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
FlooredSellChase <- R6::R6Class(
  "FlooredSellChase",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `FlooredSellChase` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the floor and the order's object.
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
      floor_price <- round(last_price * 0.99, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "sell",
        quantity = 1,
        pricing = ChasePricing$new(step_ticks = 1, step_seconds = 5),
        cap = CapModifier$new(worst_price = floor_price)
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("Least the sell takes: %s\n", floor_price))
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
  FlooredSellChase$new()$run()
}
