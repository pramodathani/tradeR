#' Build a buy of Vodafone Idea that follows the market's volume once the price breaks out, each slice shown as an iceberg.
#'
#' The program reads Vodafone Idea's last price and builds an order for 5000 shares that waits for the price to rise through 2% above it and then takes 8% of the volume traded from that moment, at most sixty slices by UBI's default, with each slice shown 100 at a time. This is a nested execution: `ParticipationExecution` is the outer one and `IcebergExecution` the inner one; participation may only be the outer. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/participation_execution/participation_execution/follow_the_volume_after_a_breakout.R

library(tradeR)

#' A breakout buy of Vodafone Idea that follows the volume in icebergs.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
BreakoutParticipation <- R6::R6Class(
  "BreakoutParticipation",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `BreakoutParticipation` object.
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
      level <- round(last_price * 1.02, 2)
      part <- OrderPart$new(
        instrument = self$share,
        transaction_type = "buy",
        quantity = 5000,
        product = "mis",
        trigger = PriceCrosses$new(level = level, direction = "at_or_above"),
        pricing = MarketablePricing$new(buffer_ticks = 1),
        execution = ParticipationExecution$new(percent = 8.0),
        inner_execution = IcebergExecution$new(
          visible_quantity = 100
        )
      )
      cat(
        sprintf(
          "Last price of %s: %s; buying above %s\n",
          self$share$symbol,
          last_price,
          level
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
  BreakoutParticipation$new()$run()
}
