#' Print `time_from` beside `time_at` for the same time, to show the one difference between them.
#'
#' Both hold from the time onwards. A time already passed today makes UBI refuse `time_at` when the plan is placed, while `time_from` holds at once. The program prints both conditions for a morning time, with the rule each follows. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/time_from/time_from/time_from_beside_time_at.R

library(tradeR)

#' Two orders waiting for the same time of day, one by `time_at` and one by `time_from`.
#'
#' @field time The character time of day both orders wait for.
TimeFromBesideTimeAt <- R6::R6Class(
  "TimeFromBesideTimeAt",
  public = list(
    time = NULL,

    #' @description
    #' Sets the time of day.
    #' @return A new `TimeFromBesideTimeAt` object.
    initialize = function() {
      self$time <- "09:20"
    },

    #' @description
    #' Prints both orders' objects with the rule each follows.
    #' @return `NULL`, invisibly.
    run = function() {
      refused <- OrderPart$new(trigger = TimeAt$new(self$time))
      started <- OrderPart$new(trigger = TimeFrom$new(self$time))
      cat(
        sprintf(
          "With time_at, a plan placed after %s is refused:\n",
          self$time
        )
      )
      cat(
        jsonlite::toJSON(
          refused$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat(
        sprintf(
          "With time_from, a plan placed after %s starts:\n",
          self$time
        )
      )
      cat(
        jsonlite::toJSON(
          started$document(),
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
  TimeFromBesideTimeAt$new()$run()
}
