#' Build a market-if-touched entry by hand: wait for a dip, then take the offer with a marketable limit.
#'
#' This is what the `market_if_touched` preset stands for, written out as slot values. The program builds an order that waits for the price to fall to 995 and is then sent two ticks past the best offer, so it fills at once without the risk of a plain market order in an empty book. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/marketable_pricing/marketable_pricing/take_the_offer_on_a_touch.R

library(tradeR)

#' A market-if-touched entry written as slot values beside the preset that stands for it.
#'
#' @field touch_level The numeric level in rupees the price must fall to.
TouchEntryByHand <- R6::R6Class(
  "TouchEntryByHand",
  public = list(
    touch_level = NULL,

    #' @description
    #' Sets the level.
    #' @return A new `TouchEntryByHand` object.
    initialize = function() {
      self$touch_level <- 995.0
    },

    #' @description
    #' Prints the slot-value entry and the preset entry.
    #' @return `NULL`, invisibly.
    run = function() {
      by_hand <- OrderPart$new(
        trigger = PriceCrosses$new(level = self$touch_level),
        pricing = MarketablePricing$new(buffer_ticks = 2)
      )
      by_preset <- OrderPart$new(
        presets = list(
          Preset$new("market_if_touched", trigger_price = self$touch_level)
        )
      )
      cat("Written out as slot values:\n")
      cat(
        jsonlite::toJSON(
          by_hand$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat("The same entry as a preset:\n")
      cat(
        jsonlite::toJSON(
          by_preset$document(),
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
  TouchEntryByHand$new()$run()
}
