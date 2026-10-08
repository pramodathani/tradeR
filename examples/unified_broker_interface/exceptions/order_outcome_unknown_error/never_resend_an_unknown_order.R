#' Place an order and refuse to resend it when its outcome is unknown, catching UnifiedBrokerInterfaceError.
#'
#' A refused order can be fixed and sent again, but an order whose outcome is unknown, reported as OrderOutcomeUnknownError with status code 504, may already be working, and sending it again could double the position. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends, catches the base class UnifiedBrokerInterfaceError, and checks the account's open parents instead of resending when the status code is 504. The order is cancelled at once if it was accepted.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/order_outcome_unknown_error/never_resend_an_unknown_order.R

library(tradeR)

#' A held limit order that is never sent twice.
#'
#' @field share The `Equity` the order is for.
#' @field trading_account The `Account` whose open parents are checked.
CarefulPlacement <- R6::R6Class(
  "CarefulPlacement",
  public = list(
    share = NULL,
    trading_account = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `CarefulPlacement` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_account <- Account$new()
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
    #' Places the order, reports an unknown outcome without resending, and cancels an accepted order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order for a reason other than an unknown outcome, or refused the cancel.
    run = function() {
      answer <- tryCatch(
        self$share$buy_at_limit_price(
          price = self$limit_price(),
          quantity = 1,
          product = "cnc"
        ),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(answer, "UnifiedBrokerInterfaceError")) {
        status_code <- answer$status_code
        if (is.null(status_code) || status_code != 504) {
          stop(answer)
        }
        cat(
          sprintf(
            "%s: the order may be working, so it is not sent again.\n",
            ErrorCatalogue$name_of(answer)
          )
        )
        cat("Open parents now:\n")
        print(self$trading_account$parents)
        return(invisible(NULL))
      }
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "The outcome is known: %s, parent %s\n",
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
  CarefulPlacement$new()$run()
}
