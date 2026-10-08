#' Build an entry that waits until half past nine, when the opening rush has settled.
#'
#' Prices in the first quarter of an hour are often wild, so the program holds an entry with a `time_at` condition until 09:30 on the instrument's next trading day, and prices it as a marketable limit so it fills as soon as it is sent. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_at/time_at/buy_once_the_opening_settles.R

library(tradeR)

#' An entry held until 09:30.
#'
#' @field entry_time The character time of day the entry is sent at.
SettledOpeningEntry <- R6::R6Class(
  "SettledOpeningEntry",
  public = list(
    entry_time = NULL,

    #' @description
    #' Sets the entry time.
    #' @return A new `SettledOpeningEntry` object.
    initialize = function() {
      self$entry_time <- "09:30"
    },

    #' @description
    #' Prints the entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        trigger = TimeAt$new(self$entry_time),
        pricing = MarketablePricing$new()
      )
      cat(sprintf("The entry is held until %s:\n", self$entry_time))
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
  SettledOpeningEntry$new()$run()
}
