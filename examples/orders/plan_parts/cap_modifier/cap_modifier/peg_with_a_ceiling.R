#' Build a buy pegged to the midpoint that never pays more than a ceiling worked out from the last price.
#'
#' The program reads Vodafone Idea's last price and builds a buy that follows the midpoint of the book, with a cap half a percent above the last price, so a rising market leaves the order at the cap rather than dragging it up. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/cap_modifier/cap_modifier/peg_with_a_ceiling.R

library(tradeR)

#' A buy of Vodafone Idea pegged to the midpoint, capped above the last price.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
CappedMidpointBuy <- R6::R6Class(
  "CappedMidpointBuy",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `CappedMidpointBuy` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the ceiling and the order's object.
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
      ceiling_price <- round(last_price * 1.005, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 1,
        pricing = PegPricing$new(reference = "mid"),
        cap = CapModifier$new(worst_price = ceiling_price)
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("Most the buy pays: %s\n", ceiling_price))
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
  CappedMidpointBuy$new()$run()
}
