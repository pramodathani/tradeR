#' Build a limit sell at a fixed price that takes only part of its quantity when a bid comes within reach.
#'
#' The program reads Vodafone Idea's last price and builds a sell of 100 shares resting 1% above it, with a discretion of a tenth of a rupee that takes 40 shares at a time, so the rest keeps its place at the visible price. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/discretion_modifier/discretion_modifier/take_part_at_discretion.R

library(tradeR)

#' A fixed-price sell of Vodafone Idea that takes part of its quantity at discretion.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
PartialDiscretionSell <- R6::R6Class(
  "PartialDiscretionSell",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `PartialDiscretionSell` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the visible price and the order's object.
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
      visible_price <- round(last_price * 1.01, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "sell",
        quantity = 100,
        pricing = FixedPricing$new(
          price = visible_price,
          order_type = "LIMIT"
        ),
        discretion = DiscretionModifier$new(
          points = 0.1,
          quantity = 40
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("Visible sell price: %s\n", visible_price))
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
  PartialDiscretionSell$new()$run()
}
