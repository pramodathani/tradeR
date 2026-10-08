#' Build a stepped stop whose milestones only lock in gains and never hand over to a trail.
#'
#' The program builds four milestones for a stop on Vodafone Idea, each a quarter of a rupee further up, that move the stop to a smaller loss, to breakeven and then to two gains, and puts them on a protecting order's `stages` pricing. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/stage_rule/stage_rule/lock_in_without_trailing.R

library(tradeR)

#' A stepped stop for Vodafone Idea that locks in gains without trailing.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
LockInStops <- R6::R6Class(
  "LockInStops",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `LockInStops` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the protecting order's object.
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
      entry_price <- round(last_price, 2)
      stop_price <- round(last_price - 0.5, 2)
      rules <- list(
        StageRule$new(gain = 0.25, stop_at_gain = -0.25),
        StageRule$new(gain = 0.5, stop_at_gain = 0.0),
        StageRule$new(gain = 0.75, stop_at_gain = 0.25),
        StageRule$new(gain = 1.0, stop_at_gain = 0.5)
      )
      part <- OrderPart$new(
        side = "protect",
        pricing = StagesPricing$new(
          entry_price = entry_price,
          stop_price = stop_price,
          limit_offset = 0.05,
          rules = rules
        )
      )
      cat(sprintf("Entry at %s, first stop at %s:\n", entry_price, stop_price))
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
  LockInStops$new()$run()
}
