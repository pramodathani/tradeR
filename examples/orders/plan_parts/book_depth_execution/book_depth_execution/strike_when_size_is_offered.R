#' Build a buy of Vodafone Idea that shows nothing and strikes only when enough size is offered at an acceptable price.
#'
#' The program reads Vodafone Idea's last price and builds an order for 20000 shares that waits until at least 5000 are offered at or below half a percent above that price, then takes the smaller of what is shown and what is left. It is the `liquidity_seeking` preset written out: the pricing is a fixed limit at the same price, so a strike that only partly fills rests there. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/book_depth_execution/book_depth_execution/strike_when_size_is_offered.R

library(tradeR)

#' A liquidity-seeking buy of Vodafone Idea.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
StrikeOnDisplayedSize <- R6::R6Class(
  "StrikeOnDisplayedSize",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `StrikeOnDisplayedSize` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the order's object.
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
        transaction_type = "buy",
        quantity = 20000,
        product = "cnc",
        pricing = FixedPricing$new(
          price = limit_price,
          order_type = "LIMIT"
        ),
        execution = BookDepthExecution$new(
          limit_price = limit_price,
          minimum_quantity = 5000
        )
      )
      cat(
        sprintf(
          "Last price of %s: %s; striking at %s or better\n",
          self$share$symbol,
          last_price,
          limit_price
        )
      )
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
  StrikeOnDisplayedSize$new()$run()
}
