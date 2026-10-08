#' Build a dip entry that ignores the first hour of trading.
#'
#' A dip in the first hour is often the opening auction settling rather than a real move. The program joins a `time_after` condition at 10:15 with a fall to a level in an `AllConditions` group, so the entry counts the dip only after that time. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_after/time_after/ignore_dips_in_the_first_hour.R

library(tradeR)

#' An entry that waits for a dip to 995 after 10:15.
#'
#' @field dip_level The numeric level in rupees the price must fall to.
#' @field start_time The character time of day from which the dip counts.
LateDipEntry <- R6::R6Class(
  "LateDipEntry",
  public = list(
    dip_level = NULL,
    start_time = NULL,

    #' @description
    #' Sets the level and the time.
    #' @return A new `LateDipEntry` object.
    initialize = function() {
      self$dip_level <- 995.0
      self$start_time <- "10:15"
    },

    #' @description
    #' Prints the entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        trigger = AllConditions$new(
          list(
            TimeAfter$new(self$start_time),
            PriceCrosses$new(level = self$dip_level)
          )
        )
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
  LateDipEntry$new()$run()
}
