#' Build the same held limit order three ways: for real, on paper written out, and on paper through the `virtual_limit` preset.
#'
#' The real order waits on a `limit_marketable` trigger and is sent once the other side of the book reaches its price. Adding a `PaperVenue` is the only change needed to trial it on paper. The `virtual_limit` preset with `paper` set expands to the same trigger and venue inside UBI. The program prints all three. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/paper_venue/paper_venue/paper_trial_beside_the_real_order.R

library(tradeR)

#' One held limit order, for real and on paper.
#'
#' @field versions The named list mapping a character description to the `OrderPart` built that way.
PaperTrial <- R6::R6Class(
  "PaperTrial",
  public = list(
    versions = NULL,

    #' @description
    #' Builds the three versions.
    #' @return A new `PaperTrial` object.
    initialize = function() {
      self$versions <- list(
        "for real" = OrderPart$new(
          trigger = LimitMarketable$new()
        ),
        "on paper, written out" = OrderPart$new(
          trigger = LimitMarketable$new(),
          venue = PaperVenue$new()
        ),
        "on paper, through the preset" = OrderPart$new(
          presets = list(
            Preset$new("virtual_limit", paper = TRUE)
          )
        )
      )
    },

    #' @description
    #' Prints each version.
    #' @return `NULL`, invisibly.
    run = function() {
      for (description in names(self$versions)) {
        part <- self$versions[[description]]
        cat(sprintf("The held limit order %s:\n", description))
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
  PaperTrial$new()$run()
}
