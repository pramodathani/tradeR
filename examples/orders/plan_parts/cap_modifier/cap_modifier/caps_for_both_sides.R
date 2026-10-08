#' Build a capped buy and a capped sell, to show that a cap is the most a buy pays and the least a sell takes.
#'
#' The program reads Vodafone Idea's last price and builds two chasing orders, a buy capped 1% above the last price and a sell capped 1% below it, so the same modifier is a ceiling on one side and a floor on the other. It prints the order object UBI would read for each. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/cap_modifier/cap_modifier/caps_for_both_sides.R

library(tradeR)

#' A capped chasing buy and a capped chasing sell of Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
CapsForBothSides <- R6::R6Class(
  "CapsForBothSides",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `CapsForBothSides` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints both orders' objects.
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
      worst_prices <- list(
        buy = round(last_price * 1.01, 2),
        sell = round(last_price * 0.99, 2)
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      for (side in names(worst_prices)) {
        worst_price <- worst_prices[[side]]
        part <- OrderPart$new(
          instrument = self$share,
          transaction_type = side,
          quantity = 1,
          pricing = ChasePricing$new(),
          cap = CapModifier$new(worst_price = worst_price)
        )
        cat(sprintf("Chasing %s capped at %s:\n", side, worst_price))
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
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CapsForBothSides$new()$run()
}
