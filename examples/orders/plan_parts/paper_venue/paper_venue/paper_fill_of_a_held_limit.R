#' Build a paper version of a held limit buy of Vodafone Idea, which UBI fills from its queue estimate without sending anything to a broker.
#'
#' A paper order waits on a `limit_marketable` trigger alone and takes no pricing of its own, because UBI holds it at the plan body's own limit price and fills it as a resting order at that price would have filled. The plan is that single order, since a paper order cannot be joined to orders that trade for real. The program reads the share's last price to suggest the limit price the plan's body should carry, and prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/paper_venue/paper_venue/paper_fill_of_a_held_limit.R

library(tradeR)

#' A limit buy filled on paper.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
PaperHeldLimit <- R6::R6Class(
  "PaperHeldLimit",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `PaperHeldLimit` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the suggested body price and the plan.
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
        trigger = LimitMarketable$new(),
        venue = PaperVenue$new()
      )
      cat(
        sprintf(
          "Body: a LIMIT buy of %s at %s\n",
          self$share$symbol,
          round(last_price * 0.99, 2)
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
  PaperHeldLimit$new()$run()
}
