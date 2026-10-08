#' Build a held limit order that is given up at 15:15 if the book never reaches it.
#'
#' The program joins `limit_marketable` with a `time_before` condition, so the order is sent only while the morning and early afternoon last, and gives it a lifetime that ends the wait at 15:15. The order is held at the template's own limit price and takes no pricing of its own. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/limit_marketable/limit_marketable/held_limit_until_the_afternoon.R

library(tradeR)

#' A held limit order with a deadline for its wait.
#'
#' @field deadline The character time of day the wait ends.
HeldLimitUntilAfternoon <- R6::R6Class(
  "HeldLimitUntilAfternoon",
  public = list(
    deadline = NULL,

    #' @description
    #' Sets the deadline.
    #' @return A new `HeldLimitUntilAfternoon` object.
    initialize = function() {
      self$deadline <- "15:15"
    },

    #' @description
    #' Prints the order's object.
    #' @return `NULL`, invisibly.
    run = function() {
      part <- OrderPart$new(
        trigger = AllConditions$new(
          list(
            LimitMarketable$new(),
            TimeBefore$new(self$deadline)
          )
        ),
        lifetime = Lifetime$new(
          at_time = self$deadline,
          applies_to = "waiting"
        )
      )
      cat(
        sprintf("The limit order is held until %s at most:\n", self$deadline)
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
  HeldLimitUntilAfternoon$new()$run()
}
