#' Place a small batch of held orders, catching UnifiedBrokerInterfaceError and counting rate limits.
#'
#' A program sending many orders at once may meet a broker's order limit, which arrives as RateLimitError with status code 429. The program places three buy limit orders for one IDEA share each, at about 3%, 4% and 5% below the last price, which UBI's order engine holds rather than sends. It catches the base class UnifiedBrokerInterfaceError for each, counts the refusals with status code 429 apart from any others, finds the parent of any order whose outcome is unknown (status code 504) through the engine's answer to its intent, and cancels every order that was accepted before it finishes.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/rate_limit_error/place_a_batch_and_count_refusals.R

library(tradeR)

#' A batch of held limit orders whose refusals are counted by kind.
#'
#' @field share The `Equity` the orders are for.
#' @field trading_account The `Account` whose engine answers are read when an order's outcome is unknown.
#' @field discounts A numeric vector of the fractions below the last price to bid at.
#' @field parent_ids A character vector of the parent ids of the orders accepted.
#' @field rate_limited_count The integer number of orders refused with HTTP 429.
#' @field other_refusal_count The integer number of orders refused for another reason.
HeldOrderBatch <- R6::R6Class(
  "HeldOrderBatch",
  public = list(
    share = NULL,
    trading_account = NULL,
    discounts = NULL,
    parent_ids = NULL,
    rate_limited_count = NULL,
    other_refusal_count = NULL,

    #' @description
    #' Creates the batch for the IDEA share.
    #' @return A new `HeldOrderBatch` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_account <- Account$new()
      self$discounts <- c(
        0.03,
        0.04,
        0.05
      )
      self$parent_ids <- character(0)
      self$rate_limited_count <- 0
      self$other_refusal_count <- 0
    },

    #' @description
    #' Works out a buy price a fraction below the last price, rounded down to the tick. The number of ticks is rounded to six places before it is floored, so that floating-point error cannot drop a whole tick, and the price is rounded to four places to remove the error that multiplying back leaves.
    #' @param last_price The numeric last price in rupees.
    #' @param discount The numeric fraction to bid below it, such as `0.03`.
    #' @return The numeric limit price in rupees.
    limit_price = function(last_price, discount) {
      factor <- 1 - discount
      target <- last_price * factor
      ticks <- floor(round(target / self$share$tick_size, 6))
      round(ticks * self$share$tick_size, 4)
    },

    #' @description
    #' Finds the parent an order with an unknown outcome became, by reading the engine's answer to its intent.
    #' @param intent_id The character intent id from the error's detail, or `NULL` when the detail has none.
    #' @return The character parent id the engine gave the order, or `NULL` when it gave none or did not answer within ten seconds.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than an answer not being stored yet.
    parent_id_from_intent = function(intent_id) {
      if (is.null(intent_id)) {
        return(NULL)
      }
      for (attempt in 0:9) {
        answer <- tryCatch(
          self$trading_account$intent(intent_id),
          NotFoundError = function(error) error
        )
        if (inherits(answer, "NotFoundError")) {
          cat(
            sprintf("No answer to the intent yet after %d seconds.\n", attempt)
          )
          Sys.sleep(1)
          next
        }
        return(answer[["response"]][["parent_id"]])
      }
      NULL
    },

    #' @description
    #' Places every order in the batch, counting the refusals.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not give the last price.
    place_all = function() {
      last_price <- self$share$last_price
      for (discount in self$discounts) {
        price <- self$limit_price(last_price, discount)
        answer <- tryCatch(
          self$share$buy_at_limit_price(
            price = price,
            quantity = 1,
            product = "cnc"
          ),
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(answer, "UnifiedBrokerInterfaceError")) {
          status_code <- answer$status_code
          if (!is.null(status_code) && status_code == 504) {
            parent_id <- self$parent_id_from_intent(
              answer$detail[["intent_id"]]
            )
            if (!is.null(parent_id)) {
              self$parent_ids <- c(self$parent_ids, parent_id)
            }
            cat(
              sprintf(
                "Buy at %s: outcome unknown, parent %s\n",
                price,
                toString(parent_id)
              )
            )
            next
          }
          if (!is.null(status_code) && status_code == 429) {
            self$rate_limited_count <- self$rate_limited_count + 1
          } else {
            self$other_refusal_count <- self$other_refusal_count + 1
          }
          cat(
            sprintf(
              "Buy at %s: refused with %s\n",
              price,
              ErrorCatalogue$name_of(answer)
            )
          )
          next
        }
        self$parent_ids <- c(self$parent_ids, answer[["parent_id"]])
        cat(
          sprintf(
            "Buy at %s: held as parent %s\n",
            price,
            answer[["parent_id"]]
          )
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Places the batch, prints the counts and cancels every accepted order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a cancel.
    run = function() {
      tryCatch(
        {
          self$place_all()
          cat(sprintf("Accepted: %d\n", length(self$parent_ids)))
          cat(sprintf("Rate limited: %d\n", self$rate_limited_count))
          cat(
            sprintf(
              "Refused for another reason: %d\n",
              self$other_refusal_count
            )
          )
        },
        finally = {
          for (parent_id in self$parent_ids) {
            cancel_answer <- self$share$cancel_parent(parent_id)
            cat(
              sprintf(
                "Cancelled parent %s: %s\n",
                parent_id,
                cancel_answer[["state"]]
              )
            )
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HeldOrderBatch$new()$run()
}
