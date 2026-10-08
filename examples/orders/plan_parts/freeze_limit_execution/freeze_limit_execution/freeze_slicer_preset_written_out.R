#' Build the same large order from UBI's `freeze_slicer` preset and written out with `FreezeLimitExecution`.
#'
#' UBI's `freeze_slicer` preset is nothing more than the `freeze_limit` execution, so the two documents the program prints ask for the same thing. Neither nests with another execution, so an order above the freeze quantity that should also be spread over time cannot be built. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/freeze_limit_execution/freeze_limit_execution/freeze_slicer_preset_written_out.R

library(tradeR)

#' One large order described from the preset and from the execution.
#'
#' @field orders The named list of character descriptions to `OrderPart` objects the program prints.
FreezeSlicerTwoWays <- R6::R6Class(
  "FreezeSlicerTwoWays",
  public = list(
    orders = NULL,

    #' @description
    #' Builds both orders.
    #' @return A new `FreezeSlicerTwoWays` object.
    initialize = function() {
      self$orders <- list(
        "from the freeze_slicer preset" = OrderPart$new(
          quantity = 3600,
          presets = list(
            Preset$new("freeze_slicer")
          )
        ),
        "with FreezeLimitExecution" = OrderPart$new(
          quantity = 3600,
          execution = FreezeLimitExecution$new()
        )
      )
    },

    #' @description
    #' Prints both orders' objects.
    #' @return `NULL`, invisibly.
    run = function() {
      for (description in names(self$orders)) {
        part <- self$orders[[description]]
        cat(sprintf("A large order %s:\n", description))
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
  FreezeSlicerTwoWays$new()$run()
}
