#' Build a buy of Vodafone Idea sent into the pre-open session at two minutes past nine, so it trades at the opening auction's price.
#'
#' The program reads the share's last price and builds a limit buy 1% above it, which the auction fills at its single opening price if that price is at or below the limit. The order takes no trigger, because UBI sends it at the venue's `at_time` through a trigger of its own, and it is a `LIMIT` order, one of the two order types the pre-open takes. It prints the plan, and the venue entry alone at UBI's default time of 09:00:30. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/pre_open_venue/pre_open_venue/opening_auction_buy.R

library(tradeR)

#' A limit buy sent into the pre-open session.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
OpeningAuctionBuy <- R6::R6Class(
  "OpeningAuctionBuy",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `OpeningAuctionBuy` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the plan and the default venue entry.
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
      plan <- OrderPart$new(
        quantity = 1000,
        product = "cnc",
        pricing = FixedPricing$new(
          price = round(last_price * 1.01, 2),
          order_type = "LIMIT"
        ),
        venue = PreOpenVenue$new(at_time = "09:02")
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
      cat("The venue at UBI's default time:\n")
      cat(
        jsonlite::toJSON(
          PreOpenVenue$new()$document(),
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
  OpeningAuctionBuy$new()$run()
}
