#' Build a buy that rests on the bid and quietly reaches up to take an offer that comes close.
#'
#' The program reads Vodafone Idea's tick size and builds a buy pegged to its own side of the book, with a discretion of two ticks, so when an offer appears within two ticks of the visible bid UBI takes it with everything still resting. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/discretion_modifier/discretion_modifier/hidden_reach_on_a_resting_bid.R

library(tradeR)

#' A resting buy of Vodafone Idea with two ticks of discretion.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
HiddenReachBid <- R6::R6Class(
  "HiddenReachBid",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `HiddenReachBid` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the discretion and the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      points <- round(tick_size * 2, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 10,
        pricing = PegPricing$new(reference = "own_touch"),
        discretion = DiscretionModifier$new(points = points)
      )
      cat(sprintf("Tick size of %s: %s\n", self$share$symbol, tick_size))
      cat(sprintf("Discretion, two ticks: %s\n", points))
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
  HiddenReachBid$new()$run()
}
