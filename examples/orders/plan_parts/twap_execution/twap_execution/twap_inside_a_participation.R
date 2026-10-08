#' Build a participation order whose every slice is itself spread out as a short TWAP.
#'
#' The program builds an order for 3000 shares of Vodafone Idea that takes a tenth of the traded volume, at most twenty slices, and works each slice as a TWAP of three pieces over three minutes, so a burst of volume does not send one large order at once. This is a nested execution: `ParticipationExecution` is the outer one and `TwapExecution` the inner one. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/twap_execution/twap_execution/twap_inside_a_participation.R

library(tradeR)

#' A buy of Vodafone Idea that follows the volume, each slice worked as a TWAP.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ParticipationOfTwaps <- R6::R6Class(
  "ParticipationOfTwaps",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ParticipationOfTwaps` object.
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
        quantity = 3000,
        product = "mis",
        pricing = MarketablePricing$new(buffer_ticks = 1),
        execution = ParticipationExecution$new(
          percent = 10.0,
          most_slices = 20
        ),
        inner_execution = TwapExecution$new(
          slices = 3,
          over_minutes = 3
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
  ParticipationOfTwaps$new()$run()
}
