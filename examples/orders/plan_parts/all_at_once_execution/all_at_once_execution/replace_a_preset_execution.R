#' Build an order whose preset slices it, then send it whole instead.
#'
#' The program builds two orders from UBI's `twap` preset: the first as the preset gives it, and the second with `AllAtOnceExecution` as its own execution, which UBI applies after the preset and so replaces the slicing with a warning. Comparing the two shows how an order's own slot values override a preset. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/all_at_once_execution/all_at_once_execution/replace_a_preset_execution.R

library(tradeR)

#' Two orders built from the TWAP preset, one sliced and one sent whole.
#'
#' @field orders The named list of character descriptions to `OrderPart` objects the program prints.
PresetExecutionReplaced <- R6::R6Class(
  "PresetExecutionReplaced",
  public = list(
    orders = NULL,

    #' @description
    #' Builds both orders.
    #' @return A new `PresetExecutionReplaced` object.
    initialize = function() {
      self$orders <- list(
        "as the preset gives it" = OrderPart$new(
          presets = list(
            Preset$new("twap", slices = 4, over_minutes = 20)
          )
        ),
        "sent whole" = OrderPart$new(
          presets = list(
            Preset$new("twap", slices = 4, over_minutes = 20)
          ),
          execution = AllAtOnceExecution$new()
        )
      )
    },

    #' @description
    #' Prints both orders' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      for (description in names(self$orders)) {
        part <- self$orders[[description]]
        cat(sprintf("The TWAP preset %s:\n", description))
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
  PresetExecutionReplaced$new()$run()
}
