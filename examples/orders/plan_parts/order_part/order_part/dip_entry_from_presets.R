#' Build an entry from two presets: wait until ten in the morning, and then for the price to dip to a level.
#'
#' The program combines the `scheduled` and `market_if_touched` presets in one order, which UBI joins so that both must hold, and adds its own marketable pricing with a wider buffer, which replaces the preset's. It prints the order object, and then a second order with the same presets but no pricing of its own, to show the difference. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/order_part/order_part/dip_entry_from_presets.R

library(tradeR)

#' Two entries built from the same presets, one with pricing of its own.
#'
#' @field presets The list of `Preset` objects both entries use.
DipEntry <- R6::R6Class(
  "DipEntry",
  public = list(
    presets = NULL,

    #' @description
    #' Builds the presets.
    #' @return A new `DipEntry` object.
    initialize = function() {
      self$presets <- list(
        Preset$new("scheduled", at_time = "10:00"),
        Preset$new("market_if_touched", trigger_price = 995.0)
      )
    },

    #' @description
    #' Builds the two entries.
    #' @return A named list of a character description to the `OrderPart` it describes.
    entries = function() {
      list(
        "presets only" = OrderPart$new(presets = self$presets),
        "presets with a five-tick buffer" = OrderPart$new(
          presets = self$presets,
          pricing = MarketablePricing$new(buffer_ticks = 5)
        )
      )
    },

    #' @description
    #' Prints both entries' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      entries <- self$entries()
      for (description in names(entries)) {
        part <- entries[[description]]
        cat(sprintf("Entry with %s:\n", description))
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
  DipEntry$new()$run()
}
