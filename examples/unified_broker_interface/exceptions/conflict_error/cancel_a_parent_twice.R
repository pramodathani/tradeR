#' Cancel a held order twice and handle the ConflictError the second cancel signals.
#'
#' The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends, and cancels it at once. It then cancels it again, which UBI refuses with HTTP 409 because the parent is already cancelled, and prints the ConflictError. If anything goes wrong before the first cancel, the order is still cancelled on the way out.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/conflict_error/cancel_a_parent_twice.R

library(tradeR)

#' A held limit order that is cancelled twice.
#'
#' @field share The `Equity` the order is for.
#' @field parent_id The character parent id of the held order, or `NULL` before it is placed.
#' @field cancelled A logical that is `TRUE` once the first cancel went through.
DoubleCancel <- R6::R6Class(
  "DoubleCancel",
  public = list(
    share = NULL,
    parent_id = NULL,
    cancelled = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `DoubleCancel` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$parent_id <- NULL
      self$cancelled <- FALSE
    },

    #' @description
    #' Works out a buy price about 3% below the last price, rounded down to the tick. The number of ticks is rounded to six places before it is floored, so that floating-point error cannot drop a whole tick, and the price is rounded to four places to remove the error that multiplying back leaves.
    #' @return The numeric limit price in rupees.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not give the last price.
    limit_price = function() {
      target <- self$share$last_price * 0.97
      ticks <- floor(round(target / self$share$tick_size, 6))
      round(ticks * self$share$tick_size, 4)
    },

    #' @description
    #' Places the held order, cancels it twice and prints the second answer.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or the first cancel.
    run = function() {
      price <- self$limit_price()
      answer <- self$share$buy_at_limit_price(
        price = price,
        quantity = 1,
        product = "cnc"
      )
      self$parent_id <- answer[["parent_id"]]
      cat(
        sprintf(
          "Held buy at %s: parent %s, outcome %s\n",
          price,
          self$parent_id,
          answer[["outcome"]]
        )
      )
      tryCatch(
        {
          first_answer <- self$share$cancel_parent(self$parent_id)
          self$cancelled <- TRUE
          cat(sprintf("First cancel: %s\n", first_answer[["state"]]))
          second_answer <- tryCatch(
            self$share$cancel_parent(self$parent_id),
            ConflictError = function(error) error
          )
          if (inherits(second_answer, "ConflictError")) {
            cat(
              sprintf(
                "Second cancel: ConflictError (%s): %s\n",
                second_answer$status_code,
                conditionMessage(second_answer)
              )
            )
          } else {
            cat("Second cancel: unexpectedly accepted\n")
          }
        },
        finally = {
          if (!self$cancelled) {
            self$share$cancel_parent(self$parent_id)
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DoubleCancel$new()$run()
}
