#' Build an entry whose profit target grows with every fill by new orders rather than by resizing one.
#'
#' The program reads Vodafone Idea's last price and builds a then join: a limit buy of 10000 shares one percent below that price, followed under `each_fill` by a target limit sell three percent above it. The target uses `TopUpExecution`, so each fill sends a new order for the shares not yet covered and every order keeps its place in the queue, where the default execution would change one order's size. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/top_up_execution/top_up_execution/target_that_grows_with_each_fill.R

library(tradeR)

#' A buy of Vodafone Idea whose target is topped up with each fill.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
GrowingTarget <- R6::R6Class(
  "GrowingTarget",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `GrowingTarget` object.
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
      entry_price <- round(last_price * 0.99, 2)
      target_price <- round(last_price * 1.03, 2)
      join <- ThenPart$new(
        first = OrderPart$new(
          instrument = self$share,
          transaction_type = "buy",
          quantity = 10000,
          product = "cnc",
          pricing = FixedPricing$new(
            price = entry_price,
            order_type = "LIMIT"
          )
        ),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = FixedPricing$new(
            price = target_price,
            order_type = "LIMIT"
          ),
          execution = TopUpExecution$new()
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        jsonlite::toJSON(
          join$document(),
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
  GrowingTarget$new()$run()
}
