#' Compare three ways of confirming a breakout before it counts: at once, two last prices in a row, and held for a time.
#'
#' A breakout that pokes through a level for one trade and falls back is a common false signal. The program builds three `price_crosses` conditions on the same level, the first firing at once on the last price, the second needing two last prices in a row past it, and the third needing the bid to stay past it for fifteen seconds, and prints each. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/price_crosses/price_crosses/three_ways_to_confirm_a_breakout.R

library(tradeR)

#' Three breakout conditions on one level, each confirmed differently.
#'
#' @field level The numeric breakout level in rupees.
ConfirmedBreakout <- R6::R6Class(
  "ConfirmedBreakout",
  public = list(
    level = NULL,

    #' @description
    #' Sets the breakout level.
    #' @return A new `ConfirmedBreakout` object.
    initialize = function() {
      self$level <- 1010.0
    },

    #' @description
    #' Builds the three conditions.
    #' @return A named list of a character description to the `PriceCrosses` it describes.
    conditions = function() {
      list(
        "at once" = PriceCrosses$new(
          level = self$level,
          direction = "at_or_above"
        ),
        "two last prices in a row" = PriceCrosses$new(
          level = self$level,
          direction = "at_or_above",
          confirm = "double_last"
        ),
        "the bid held for fifteen seconds" = PriceCrosses$new(
          level = self$level,
          direction = "at_or_above",
          field = "bid",
          confirm = "held",
          hold_seconds = 15
        )
      )
    },

    #' @description
    #' Prints each condition's object.
    #' @return `NULL`, invisibly.
    run = function() {
      conditions <- self$conditions()
      for (description in names(conditions)) {
        condition <- conditions[[description]]
        cat(sprintf("Confirmed %s:\n", description))
        cat(
          jsonlite::toJSON(
            condition$document(),
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
  ConfirmedBreakout$new()$run()
}
