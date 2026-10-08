#' Build a buy that follows the bid and is held on its own side rather than ever allowed to cross.
#'
#' The program builds a buy of Vodafone Idea pegged to its own side of the book with a post-only guard set to `rest`, so a move that would cross the offer is held at the bid instead. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/post_only_guard/post_only_guard/maker_bid_that_rests.R

library(tradeR)

#' A pegged buy of Vodafone Idea that only ever rests.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
RestingMakerBid <- R6::R6Class(
  "RestingMakerBid",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `RestingMakerBid` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 10,
        pricing = PegPricing$new(reference = "own_touch"),
        guard = PostOnlyGuard$new(on_crossing = "rest")
      )
      cat(sprintf("Post-only buy of %s on the bid:\n", self$share$symbol))
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
  RestingMakerBid$new()$run()
}
