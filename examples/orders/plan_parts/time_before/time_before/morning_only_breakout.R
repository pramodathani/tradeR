#' Build a breakout entry that counts only before eleven in the morning.
#'
#' Many breakout traders trust a morning breakout and distrust one late in the day. The program joins a rise through 1010 with a `time_before` condition at 11:00 in an `AllConditions` group, so the entry fires only if the breakout happens in the morning. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_before/time_before/morning_only_breakout.R

library(tradeR)

#' An entry on a rise through 1010 before 11:00.
#'
#' @field breakout_level The numeric level in rupees the price must rise to.
#' @field end_time The character time of day after which the breakout no longer counts.
MorningBreakout <- R6::R6Class(
  "MorningBreakout",
  public = list(
    breakout_level = NULL,
    end_time = NULL,

    #' @description
    #' Sets the level and the time.
    #' @return A new `MorningBreakout` object.
    initialize = function() {
      self$breakout_level <- 1010.0
      self$end_time <- "11:00"
    },

    #' @description
    #' Prints the entry's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        trigger = AllConditions$new(
          list(
            PriceCrosses$new(
              level = self$breakout_level,
              direction = "at_or_above"
            ),
            TimeBefore$new(self$end_time)
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
  MorningBreakout$new()$run()
}
