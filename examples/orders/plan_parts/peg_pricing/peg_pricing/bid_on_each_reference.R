#' Build a buy of a share pegged to each of the three places in the book a peg can follow.
#'
#' The program looks up Vodafone Idea and builds three orders, one pegged to its own side of the book, one to the midpoint a tick further from filling, and one to the other side's touch, which fills at once. It prints the order object UBI would read for each. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/peg_pricing/peg_pricing/bid_on_each_reference.R

library(tradeR)

#' Three pegged buys of Vodafone Idea, one for each reference.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
PegReferences <- R6::R6Class(
  "PegReferences",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `PegReferences` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the three orders' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      rules <- list(
        "on the bid" = PegPricing$new(reference = "own_touch"),
        "a tick below the midpoint" = PegPricing$new(
          reference = "mid",
          offset_ticks = 1
        ),
        "on the offer, filling at once" = PegPricing$new(
          reference = "opposite_touch"
        )
      )
      for (description in names(rules)) {
        rule <- rules[[description]]
        part <- OrderPart$new(
          instrument = self$share,
          transaction_type = "buy",
          quantity = 1,
          pricing = rule
        )
        cat(
          sprintf("Buy of %s pegged %s:\n", self$share$symbol, description)
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
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PegReferences$new()$run()
}
