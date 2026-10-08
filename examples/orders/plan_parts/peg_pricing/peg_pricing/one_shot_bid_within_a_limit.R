#' Build a buy priced once at the bid and never above a limit worked out from the last price.
#'
#' The program reads Vodafone Idea's last price and builds a plan order whose template is a limit buy 1% above it, with one order pegged to its own side of the book that does not follow it afterwards and treats the template's limit as the worst price it takes. This is how each purchase of UBI's accumulation type is priced. It prints the plan's synthetic object. The plan order is only built; nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/peg_pricing/peg_pricing/one_shot_bid_within_a_limit.R

library(tradeR)

#' A buy of Vodafone Idea priced once at the bid, within a limit.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
OneShotBid <- R6::R6Class(
  "OneShotBid",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `OneShotBid` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the limit and the plan's synthetic object.
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
      limit_price <- round(last_price * 1.01, 2)
      order <- PlanOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = limit_price,
        plan = OrderPart$new(
          pricing = PegPricing$new(
            reference = "own_touch",
            follows = FALSE,
            within_body_price = TRUE
          )
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("Template limit, the most the buy pays: %s\n", limit_price))
      cat(
        jsonlite::toJSON(
          order$synthetic,
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
  OneShotBid$new()$run()
}
