#' Place an order with handling for the LossLockoutError UBI signals once the day's loss limit is passed.
#'
#' When the day's loss is past UBI's daily loss limit, the order engine refuses every new order with HTTP 403 and the client signals LossLockoutError. A trading program should then stop sending orders for the day rather than retry. The program places a buy limit order for one IDEA share about 3% below the last price, which the engine holds rather than sends, handles a lockout if there is one, and cancels the order at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/loss_lockout_error/stop_trading_when_locked_out.R

library(tradeR)

#' A held limit order that stops trading for the day when UBI reports a loss lockout.
#'
#' @field share The `Equity` the order is for.
#' @field trading_stopped A logical that is `TRUE` once a lockout has been seen.
LockoutAwareOrder <- R6::R6Class(
  "LockoutAwareOrder",
  public = list(
    share = NULL,
    trading_stopped = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `LockoutAwareOrder` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_stopped <- FALSE
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
    #' Places the held order, or stops trading when UBI reports a lockout.
    #' @return The named list UBI answered the placement with, or `NULL` when the account is locked out.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order for a reason other than a lockout.
    place = function() {
      answer <- tryCatch(
        self$share$buy_at_limit_price(
          price = self$limit_price(),
          quantity = 1,
          product = "cnc"
        ),
        LossLockoutError = function(error) error
      )
      if (inherits(answer, "LossLockoutError")) {
        self$trading_stopped <- TRUE
        cat(sprintf("LossLockoutError: %s\n", conditionMessage(answer)))
        cat(
          "The daily loss limit is reached, so no more orders are sent today.\n"
        )
        return(NULL)
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
        return(invisible(NULL))
      }
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "No lockout: the engine is holding parent %s, outcome %s\n",
              parent_id,
              answer[["outcome"]]
            )
          )
        },
        finally = {
          cancel_answer <- self$share$cancel_parent(parent_id)
          cat(sprintf("Cancelled: %s\n", cancel_answer[["state"]]))
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  LockoutAwareOrder$new()$run()
}
