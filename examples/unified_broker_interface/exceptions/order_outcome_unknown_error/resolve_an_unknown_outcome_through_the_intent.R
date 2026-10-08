#' Place an order with handling for the OrderOutcomeUnknownError UBI signals when the engine does not answer in time.
#'
#' An OrderOutcomeUnknownError means the order may or may not have been placed, so it must never simply be sent again. Its detail carries the `intent_id`, and the account's `intent` method reads the engine's answer once it arrives. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends; if the outcome is unknown it waits for the engine's answer through the intent, and in every case it cancels the held order at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/order_outcome_unknown_error/resolve_an_unknown_outcome_through_the_intent.R

library(tradeR)

#' A held limit order whose unknown outcome is resolved through the engine's intent.
#'
#' @field share The `Equity` the order is for.
#' @field trading_account The `Account` the intent is read through.
#' @field intent_wait_seconds The integer number of seconds to wait for the engine's answer.
UnknownOutcomeResolution <- R6::R6Class(
  "UnknownOutcomeResolution",
  public = list(
    share = NULL,
    trading_account = NULL,
    intent_wait_seconds = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `UnknownOutcomeResolution` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_account <- Account$new()
      self$intent_wait_seconds <- 30
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
    #' Reads the engine's answer to an intent, waiting a second between tries.
    #' @param intent_id The character intent id from the error's detail.
    #' @return The named list the placement would have answered with, or `NULL` when the engine has not answered in time.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than an answer not being stored yet.
    wait_for_intent = function(intent_id) {
      for (attempt in seq(0, self$intent_wait_seconds - 1)) {
        answer <- tryCatch(
          self$trading_account$intent(intent_id),
          NotFoundError = function(error) error
        )
        if (!inherits(answer, "NotFoundError")) {
          return(answer[["response"]])
        }
        cat(sprintf("No answer yet after %d seconds.\n", attempt))
        Sys.sleep(1)
      }
      NULL
    },

    #' @description
    #' Places the held order and resolves an unknown outcome.
    #' @return The named list answer of the placement, or `NULL` when its outcome stayed unknown.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order.
    place = function() {
      answer <- tryCatch(
        self$share$buy_at_limit_price(
          price = self$limit_price(),
          quantity = 1,
          product = "cnc"
        ),
        OrderOutcomeUnknownError = function(error) error
      )
      if (inherits(answer, "OrderOutcomeUnknownError")) {
        cat(sprintf("OrderOutcomeUnknownError: %s\n", conditionMessage(answer)))
        return(self$wait_for_intent(answer$detail[["intent_id"]]))
      }
      answer
    },

    #' @description
    #' Places the order and cancels it at once.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or the cancel.
    run = function() {
      answer <- self$place()
      if (is.null(answer)) {
        cat(
          "The outcome is still unknown; check the account's parents before sending anything again.\n"
        )
        return(invisible(NULL))
      }
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "Outcome %s, parent %s\n",
              answer[["outcome"]],
              toString(parent_id)
            )
          )
        },
        finally = {
          if (!is.null(parent_id)) {
            cancel_answer <- self$share$cancel_parent(parent_id)
            cat(sprintf("Cancelled: %s\n", cancel_answer[["state"]]))
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnknownOutcomeResolution$new()$run()
}
