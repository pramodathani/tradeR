#' Build buys that chase the offer at three different paces, the last one crossing the book after a minute.
#'
#' The program builds three chasing buys of Vodafone Idea: one with UBI's defaults of a tick every five seconds, one that steps two ticks every ten seconds, and one that walks a tick every three seconds and moves to the offer once a minute has passed. It prints the order object UBI would read for each. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/chase_pricing/chase_pricing/walk_to_the_offer_then_cross.R

library(tradeR)

#' Three chasing buys of Vodafone Idea at different paces.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ChasePaces <- R6::R6Class(
  "ChasePaces",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ChasePaces` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the three orders' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      rules <- list(
        "with UBI's defaults" = ChasePricing$new(),
        "two ticks every ten seconds" = ChasePricing$new(
          step_ticks = 2,
          step_seconds = 10
        ),
        "a tick every three seconds, crossing after a minute" = (
          ChasePricing$new(
            step_ticks = 1,
            step_seconds = 3,
            cross_after_seconds = 60
          )
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
          sprintf(
            "Chasing buy of %s, %s:\n",
            self$share$symbol,
            description
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
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ChasePaces$new()$run()
}
