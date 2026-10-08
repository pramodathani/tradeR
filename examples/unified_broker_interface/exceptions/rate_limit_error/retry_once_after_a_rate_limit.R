#' Place an order that is retried once when UBI signals RateLimitError.
#'
#' When the broker chosen for an order is at its order limit, or has used its daily order cap, UBI answers HTTP 429 and the client signals RateLimitError. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends, waits two seconds and tries once more if it is rate limited, and cancels the order at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/rate_limit_error/retry_once_after_a_rate_limit.R

library(tradeR)

#' A held limit order that waits and retries once when rate limited.
#'
#' @field share The `Equity` the order is for.
#' @field retry_wait_seconds The numeric number of seconds to wait before the retry.
RateLimitedOrder <- R6::R6Class(
  "RateLimitedOrder",
  public = list(
    share = NULL,
    retry_wait_seconds = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `RateLimitedOrder` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$retry_wait_seconds <- 2.0
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
    #' Places the held order once.
    #' @return The named list UBI answered the placement with.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order.
    place = function() {
      self$share$buy_at_limit_price(
        price = self$limit_price(),
        quantity = 1,
        product = "cnc"
      )
    },

    #' @description
    #' Places the held order, waiting and retrying once when rate limited.
    #' @return The named list UBI answered the placement with.
    #' @details Errors: signals `RateLimitError` when the retry was rate limited too, and another `UnifiedBrokerInterfaceError` subclass when UBI refused the order for another reason.
    place_with_one_retry = function() {
      answer <- tryCatch(
        self$place(),
        RateLimitError = function(error) error
      )
      if (!inherits(answer, "RateLimitError")) {
        return(answer)
      }
      cat(
        sprintf(
          "RateLimitError: %s; retrying in %s seconds\n",
          conditionMessage(answer),
          self$retry_wait_seconds
        )
      )
      Sys.sleep(self$retry_wait_seconds)
      self$place()
    },

    #' @description
    #' Places the order and cancels it at once.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or the cancel.
    run = function() {
      answer <- self$place_with_one_retry()
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "Placed without hitting a rate limit: parent %s\n",
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
  RateLimitedOrder$new()$run()
}
