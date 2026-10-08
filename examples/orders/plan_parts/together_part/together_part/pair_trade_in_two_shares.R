#' Build a pair trade: buy Vodafone Idea and sell Yes Bank at the same moment, each leg trading its own quantity.
#'
#' The program looks both shares up, sizes each leg to about 20,000 rupees from its last price, and joins a buy of one and a sell of the other in a together join. The join keeps UBI's default `group_margin`, so the broker selector chooses one broker that can afford both legs. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/together_part/together_part/pair_trade_in_two_shares.R

library(tradeR)

#' A long leg in Vodafone Idea and a short leg in Yes Bank, started together.
#'
#' @field long_share The `Equity` bought.
#' @field short_share The `Equity` sold.
#' @field rupees_per_leg The numeric amount each leg is sized to.
PairTrade <- R6::R6Class(
  "PairTrade",
  public = list(
    long_share = NULL,
    short_share = NULL,
    rupees_per_leg = NULL,

    #' @description
    #' Looks both shares up.
    #' @return A new `PairTrade` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$long_share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$short_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
      self$rupees_per_leg <- 20000.0
    },

    #' @description
    #' Works out how many shares make up one leg.
    #' @param share The `Equity` to size.
    #' @return The integer number of shares worth about `rupees_per_leg`.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    quantity_for = function(share) {
      last_price <- share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", share$format())
        )
      }
      as.integer(self$rupees_per_leg %/% last_price)
    },

    #' @description
    #' Prints the pair trade's plan.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for one of the shares.
    run = function() {
      plan <- TogetherPart$new(
        children = list(
          OrderPart$new(
            instrument = self$long_share,
            transaction_type = "buy",
            quantity = self$quantity_for(self$long_share),
            product = "mis",
            pricing = MarketablePricing$new(buffer_ticks = 2)
          ),
          OrderPart$new(
            instrument = self$short_share,
            transaction_type = "sell",
            quantity = self$quantity_for(self$short_share),
            product = "mis",
            pricing = MarketablePricing$new(buffer_ticks = 2)
          )
        )
      )
      cat(
        jsonlite::toJSON(
          plan$document(),
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
  PairTrade$new()$run()
}
