#' Change the price of a held order after it was cancelled, catching UnifiedBrokerInterfaceError.
#'
#' A program that changes orders can race with a cancel from elsewhere. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds, cancels it, and then asks to lower its price. UBI refuses with HTTP 409, and the program catches the ConflictError through the base class UnifiedBrokerInterfaceError and recognises it by its status code. If anything goes wrong before the cancel, the order is still cancelled on the way out.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/conflict_error/change_an_order_after_cancelling_it.R

library(tradeR)

#' A held limit order whose price is changed after it was cancelled.
#'
#' @field share The `Equity` the order is for.
#' @field parent_id The character parent id of the held order, or `NULL` before it is placed.
#' @field cancelled A logical that is `TRUE` once the cancel went through.
LateModification <- R6::R6Class(
  "LateModification",
  public = list(
    share = NULL,
    parent_id = NULL,
    cancelled = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `LateModification` object.
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
    #' Places the held order, cancels it, then tries to change it and prints the refusal.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or the cancel, or refused the change for a reason other than a conflict.
    run = function() {
      price <- self$limit_price()
      answer <- self$share$buy_at_limit_price(
        price = price,
        quantity = 1,
        product = "cnc"
      )
      self$parent_id <- answer[["parent_id"]]
      cat(sprintf("Held buy at %s: parent %s\n", price, self$parent_id))
      tryCatch(
        {
          self$share$cancel_parent(self$parent_id)
          self$cancelled <- TRUE
          cat("Cancelled the held order.\n")
          lower_price <- round(price - self$share$tick_size, 4)
          outcome <- tryCatch(
            self$share$modify_order(
              parent_id = self$parent_id,
              price = lower_price
            ),
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(outcome, "UnifiedBrokerInterfaceError")) {
            status_code <- outcome$status_code
            if (is.null(status_code) || status_code != 409) {
              stop(outcome)
            }
            cat(
              sprintf(
                "Change refused with %s: %s\n",
                ErrorCatalogue$name_of(outcome),
                conditionMessage(outcome)
              )
            )
          } else {
            cat("Change unexpectedly accepted.\n")
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
  LateModification$new()$run()
}
