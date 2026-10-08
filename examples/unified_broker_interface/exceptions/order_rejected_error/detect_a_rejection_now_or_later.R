#' Send a limit order outside the day's price band and detect its rejection, whether it comes at once or later.
#'
#' A broker can refuse an order as it is sent, which UBI reports as OrderRejectedError with HTTP 422, or accept it and have its risk checks or the exchange reject it a moment later, which shows only as a `REJECTED` status in the order book. The program sends a buy limit order for one IDEA share at half the last price straight to the broker, far below the day's lower price band, catches the base class UnifiedBrokerInterfaceError and recognises an outright rejection by its status code 422, and otherwise waits for the order's status. The order can never fill at that price, and if it is still open after the wait it is cancelled.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/order_rejected_error/detect_a_rejection_now_or_later.R

library(tradeR)

#' A limit order far outside the price band, followed until it is rejected.
#'
#' @field share The `Equity` the order is for.
#' @field wait_seconds The integer number of seconds to wait for the order's final status.
#' @field finished_statuses A character vector of the statuses after which an order can no longer change.
PriceBandRejection <- R6::R6Class(
  "PriceBandRejection",
  public = list(
    share = NULL,
    wait_seconds = NULL,
    finished_statuses = NULL,

    #' @description
    #' Creates the order's setting for the IDEA share.
    #' @return A new `PriceBandRejection` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$wait_seconds <- 20
      self$finished_statuses <- c(
        "REJECTED",
        "CANCELLED",
        "COMPLETE"
      )
    },

    #' @description
    #' Works out half the last price, rounded down to the tick. The number of ticks is rounded to six places before it is floored, so that floating-point error cannot drop a whole tick, and the price is rounded to four places to remove the error that multiplying back leaves.
    #' @return The numeric limit price in rupees.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not give the last price.
    half_price = function() {
      target <- self$share$last_price / 2
      ticks <- floor(round(target / self$share$tick_size, 6))
      round(ticks * self$share$tick_size, 4)
    },

    #' @description
    #' Finds the order in today's orders for the share.
    #' @param order_id The character broker order id.
    #' @return A named list holding the order's row, or `NULL` when the order book does not show it yet.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the orders.
    order_row = function(order_id) {
      orders <- self$share$orders
      if (is.null(orders)) {
        return(NULL)
      }
      for (index in seq_len(nrow(orders))) {
        if (identical(as.character(orders$order_id[[index]]), order_id)) {
          return(as.list(orders[index, ]))
        }
      }
      NULL
    },

    #' @description
    #' Reads the order's row once a second until its status is final.
    #' @param order_id The character broker order id.
    #' @return A named list holding the row with a final status, or the last row seen, or `NULL` when the order never appeared.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the orders.
    wait_for_final_status = function(order_id) {
      row <- NULL
      for (attempt in seq_len(self$wait_seconds)) {
        row <- self$order_row(order_id)
        if (!is.null(row) && row[["status"]] %in% self$finished_statuses) {
          return(row)
        }
        Sys.sleep(1)
      }
      row
    },

    #' @description
    #' Sends the order, reports how it was rejected, and cancels it if it is still open.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order for a reason other than a rejection, or refused the cancel.
    run = function() {
      price <- self$half_price()
      answer <- tryCatch(
        self$share$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "cnc",
          hold = FALSE
        ),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(answer, "UnifiedBrokerInterfaceError")) {
        status_code <- answer$status_code
        if (is.null(status_code) || status_code != 422) {
          stop(answer)
        }
        cat(
          sprintf(
            "Rejected at once with %s: %s\n",
            ErrorCatalogue$name_of(answer),
            conditionMessage(answer)
          )
        )
        return(invisible(NULL))
      }
      order_id <- answer[["order_id"]]
      cat(
        sprintf(
          "Buy at %s accepted by %s as %s\n",
          price,
          answer[["broker"]],
          order_id
        )
      )
      row <- self$wait_for_final_status(order_id)
      if (!is.null(row) && identical(row[["status"]], "REJECTED")) {
        cat(sprintf("Rejected afterwards: %s\n", row[["status_message"]]))
        return(invisible(NULL))
      }
      status_text <- "NULL"
      if (!is.null(row)) {
        status_text <- row[["status"]]
      }
      cat(sprintf("Not rejected; status %s, so cancelling it.\n", status_text))
      cancel_answer <- self$share$cancel_order(
        order_id = order_id,
        broker = answer[["broker"]]
      )
      cat(
        "Cancelled: ",
        jsonlite::toJSON(cancel_answer, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PriceBandRejection$new()$run()
}
