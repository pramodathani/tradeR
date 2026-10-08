#' Build an exit that sells into the first bid large enough, without resting anything in the book beforehand.
#'
#' The program builds a protecting sell for 1500 units that waits until at least 1000 are bid at or above 1000 rupees across the levels of the book, then strikes for what is shown, and its lifetime ends it at 15:00 if no such bid has appeared. The pricing is a fixed limit at 1000, so a strike that partly fills rests there. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/book_depth_execution/book_depth_execution/quiet_exit_on_a_bid.R

library(tradeR)

#' A protecting sell that strikes only into a large enough bid before 15:00.
#'
#' @field part The `OrderPart` the program prints.
QuietExit <- R6::R6Class(
  "QuietExit",
  public = list(
    part = NULL,

    #' @description
    #' Builds the exit.
    #' @return A new `QuietExit` object.
    initialize = function() {
      self$part <- OrderPart$new(
        side = "protect",
        quantity = 1500,
        pricing = FixedPricing$new(
          price = 1000.0,
          order_type = "LIMIT"
        ),
        execution = BookDepthExecution$new(
          limit_price = 1000.0,
          minimum_quantity = 1000
        ),
        lifetime = Lifetime$new(at_time = "15:00")
      )
    },

    #' @description
    #' Prints the exit's object.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(
        jsonlite::toJSON(
          self$part$document(),
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
  QuietExit$new()$run()
}
