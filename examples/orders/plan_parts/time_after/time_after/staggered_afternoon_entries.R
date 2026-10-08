#' Build three entries that start at noon, one o'clock and two o'clock, to spread a purchase over the afternoon.
#'
#' Each entry is its own order held by a `time_after` condition, so a position can be built in three parts without watching the clock. The program prints each entry's object. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_after/time_after/staggered_afternoon_entries.R

library(tradeR)

#' Three entries held until successive hours of the afternoon.
#'
#' @field start_times The character vector of times of day the entries start at.
StaggeredEntries <- R6::R6Class(
  "StaggeredEntries",
  public = list(
    start_times = NULL,

    #' @description
    #' Sets the start times.
    #' @return A new `StaggeredEntries` object.
    initialize = function() {
      self$start_times <- c(
        "12:00",
        "13:00",
        "14:00"
      )
    },

    #' @description
    #' Prints each entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      for (start_time in self$start_times) {
        part <- OrderPart$new(trigger = TimeAfter$new(start_time))
        document <- jsonlite::toJSON(
          part$document(),
          auto_unbox = TRUE,
          null = "null",
          digits = NA
        )
        cat(sprintf("Entry from %s: %s\n", start_time, document))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StaggeredEntries$new()$run()
}
