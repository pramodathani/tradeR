#' Build a closing-window buy that starts at 15:00, or at once when placed after it.
#'
#' A plan placed at 15:05 with `time_at` set to 15:00 would be refused, because that time has passed. The program uses `time_from` instead, so the same plan works whether it is placed before the window opens or inside it, and prices the order as a marketable limit. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_from/time_from/closing_window_entry.R

library(tradeR)

#' A buy that waits for the closing window to open, or starts at once inside it.
#'
#' @field window_start The character time of day the closing window opens.
ClosingWindowEntry <- R6::R6Class(
  "ClosingWindowEntry",
  public = list(
    window_start = NULL,

    #' @description
    #' Sets the time the closing window opens.
    #' @return A new `ClosingWindowEntry` object.
    initialize = function() {
      self$window_start <- "15:00"
    },

    #' @description
    #' Prints the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        trigger = TimeFrom$new(self$window_start),
        pricing = MarketablePricing$new(buffer_ticks = 1)
      )
      cat(
        sprintf("The order is sent from %s, or at once:\n", self$window_start)
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
  ClosingWindowEntry$new()$run()
}
