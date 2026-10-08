#' Build a limit buy held in UBI's engine until the offer comes down to it.
#'
#' The program reads NSE IDEA's last price, which the plan's template would carry as its `LIMIT` price, and holds the order with a `limit_marketable` trigger, so nothing rests at the exchange until it would fill at once. The order takes no pricing of its own, because UBI holds it at the template's limit price. The market data read is read-only, and nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/limit_marketable/limit_marketable/bid_held_in_the_engine.R

library(tradeR)

#' A limit buy at the last price, held until the offer reaches it.
#'
#' @field share The `Equity` bought.
HeldBid <- R6::R6Class(
  "HeldBid",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `HeldBid` object.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the template's terms and the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      limit_price <- self$share$last_price
      part <- OrderPart$new(
        trigger = LimitMarketable$new()
      )
      cat(
        sprintf(
          "Template: a LIMIT buy at %s, held in the engine:\n",
          format(limit_price)
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
  HeldBid$new()$run()
}
