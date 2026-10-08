#' Build a fixed-price sell that is refused rather than sent if it would trade at once.
#'
#' The program reads Vodafone Idea's last price and builds a limit sell half a percent above it, with a post-only guard left at UBI's default of `refuse`, so if the bid has risen to the price by the time the order is sent, the order ends as refused instead of trading. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/post_only_guard/post_only_guard/refuse_a_limit_that_would_cross.R

library(tradeR)

#' A post-only limit sell of Vodafone Idea above the last price.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
RefusedIfCrossing <- R6::R6Class(
  "RefusedIfCrossing",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `RefusedIfCrossing` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the limit and the order's object.
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
      limit_price <- round(last_price * 1.005, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "sell",
        quantity = 10,
        pricing = FixedPricing$new(
          price = limit_price,
          order_type = "LIMIT"
        ),
        guard = PostOnlyGuard$new()
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(sprintf("Post-only sell limit: %s\n", limit_price))
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
  RefusedIfCrossing$new()$run()
}
