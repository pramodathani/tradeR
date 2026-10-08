#' Build a limit target and a market exit for one position, the two common uses of fixed pricing.
#'
#' The program reads Vodafone Idea's last price and builds two protecting orders, one priced as a limit 2% above the market for taking profit, and one priced at market for getting out at once. UBI writes the order type in capitals here, `LIMIT` and `MARKET`. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/fixed_pricing/fixed_pricing/limit_target_and_market_exit.R

library(tradeR)

#' A limit target and a market exit for a position in Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
TargetAndMarketExit <- R6::R6Class(
  "TargetAndMarketExit",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `TargetAndMarketExit` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the target price and both orders' objects.
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
      target_price <- round(last_price * 1.02, 2)
      target <- OrderPart$new(
        side = "protect",
        pricing = FixedPricing$new(price = target_price, order_type = "LIMIT")
      )
      market_exit <- OrderPart$new(
        side = "protect",
        pricing = FixedPricing$new(order_type = "MARKET")
      )
      cat(
        sprintf(
          "Last price of %s: %s, target: %s\n",
          self$share$symbol,
          last_price,
          target_price
        )
      )
      cat(
        jsonlite::toJSON(
          target$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat(
        jsonlite::toJSON(
          market_exit$document(),
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
  TargetAndMarketExit$new()$run()
}
