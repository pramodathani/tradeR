#' Place an order with handling for the OrderRejectedError UBI signals when a broker refuses it outright.
#'
#' When a broker refuses an order as it is sent, UBI answers HTTP 422 and the client signals OrderRejectedError, whose detail holds the order document with the broker's reason. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends, prints the broker's reason if the order is refused, and cancels the held order at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/order_rejected_error/read_the_brokers_reason_for_a_rejection.R

library(tradeR)

#' A held limit order whose outright rejection is explained from the order document.
#'
#' @field share The `Equity` the order is for.
RejectionAwareOrder <- R6::R6Class(
  "RejectionAwareOrder",
  public = list(
    share = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `RejectionAwareOrder` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
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
    #' Places the order, explains a rejection, and cancels an accepted order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order for a reason other than a broker rejection, or refused the cancel.
    run = function() {
      answer <- tryCatch(
        self$share$buy_at_limit_price(
          price = self$limit_price(),
          quantity = 1,
          product = "cnc"
        ),
        OrderRejectedError = function(error) error
      )
      if (inherits(answer, "OrderRejectedError")) {
        cat(sprintf("OrderRejectedError: %s\n", conditionMessage(answer)))
        cat(sprintf("Broker: %s\n", toString(answer$detail[["broker"]])))
        cat(
          sprintf(
            "Broker's reason: %s\n",
            toString(answer$detail[["status_message"]])
          )
        )
        return(invisible(NULL))
      }
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "Not rejected: outcome %s, parent %s\n",
              answer[["outcome"]],
              parent_id
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
  RejectionAwareOrder$new()$run()
}
