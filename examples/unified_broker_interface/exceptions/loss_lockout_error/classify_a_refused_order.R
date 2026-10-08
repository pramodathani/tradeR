#' Place an order and sort any refusal by its status code, catching UnifiedBrokerInterfaceError.
#'
#' A trading program needs to tell a lockout, which ends the day's trading, from refusals that call for fixing the order or retrying. The program places a buy limit order for one IDEA share about 3% below the last price, which UBI's order engine holds rather than sends, and catches the base class UnifiedBrokerInterfaceError so that a LossLockoutError, recognised by its status code 403, is told apart from every other refusal. The order is cancelled at once if it was accepted, including when its outcome was unknown and the engine's answer to its intent shows it was held.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/loss_lockout_error/classify_a_refused_order.R

library(tradeR)

#' A held limit order whose refusal, if any, is sorted by what to do next.
#'
#' @field share The `Equity` the order is for.
#' @field trading_account The `Account` whose engine answers are read when the order's outcome is unknown.
#' @field advice_for_status_code A named character vector of advice for a refused order, named by the status code as text.
RefusalClassifier <- R6::R6Class(
  "RefusalClassifier",
  public = list(
    share = NULL,
    trading_account = NULL,
    advice_for_status_code = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `RefusalClassifier` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_account <- Account$new()
      self$advice_for_status_code <- c(
        "400" = "fix the order and send it again",
        "403" = "stop trading for the day, because the loss limit is reached",
        "422" = "read the broker's reason in the order document",
        "429" = "wait and retry, because the broker is at its order limit",
        "503" = "check that the order engine is running",
        "504" = "do not resend, because the order may be working; read the engine's answer to its intent"
      )
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
    #' Places the order, prints the advice for any refusal, and cancels an accepted order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the cancel.
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
        advice <- "report the failure"
        if (!is.null(status_code)) {
          status_key <- as.character(status_code)
          if (status_key %in% names(self$advice_for_status_code)) {
            advice <- self$advice_for_status_code[[status_key]]
          }
        }
        cat(
          sprintf(
            "Refused with %s (%s): %s\n",
            ErrorCatalogue$name_of(answer),
            toString(status_code),
            advice
          )
        )
        if (is.null(status_code) || status_code != 504) {
          return(invisible(NULL))
        }
        parent_id <- self$parent_id_from_intent(answer$detail[["intent_id"]])
        if (!is.null(parent_id)) {
          cancel_answer <- self$share$cancel_parent(parent_id)
          cat(
            sprintf(
              "Cancelled parent %s: %s\n",
              parent_id,
              cancel_answer[["state"]]
            )
          )
        }
        return(invisible(NULL))
      }
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          cat(
            sprintf(
              "Accepted: outcome %s, so there is no lockout today.\n",
              answer[["outcome"]]
            )
          )
        },
        finally = {
          cancel_answer <- self$share$cancel_parent(parent_id)
          cat(
            sprintf(
              "Cancelled parent %s: %s\n",
              parent_id,
              cancel_answer[["state"]]
            )
          )
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RefusalClassifier$new()$run()
}
