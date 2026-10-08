#' Buy one Vodafone Idea share intraday through a portfolio and sell it straight back.
#'
#' The program builds a portfolio of one IDEA share, sends it to the market with `place_orders()` as an intraday market order, waits for the order book to show the order's final status, and, once it has filled, sells the share again with the same call in the opposite direction. An order still open after the wait is cancelled instead, so the program leaves nothing behind. It places real orders and should be run while the market is open.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/portfolio/portfolio/intraday_round_trip.R

library(tradeR)

FINAL_STATUSES <- c(
  "COMPLETE",
  "REJECTED",
  "CANCELLED"
)

OPEN_STATUSES <- c(
  "OPEN",
  "PENDING"
)

WAIT_ATTEMPTS <- 15

WAIT_SECONDS <- 2

#' One IDEA share bought and sold again through a one-member portfolio.
#'
#' @field idea The `Equity` for Vodafone Idea on the NSE.
#' @field one_share The `Portfolio` holding one IDEA share.
IntradayRoundTrip <- R6::R6Class(
  "IntradayRoundTrip",
  public = list(
    idea = NULL,
    one_share = NULL,

    #' @description
    #' Looks the share up in UBI and builds the portfolio.
    #' @return A new `IntradayRoundTrip` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share.
    initialize = function() {
      self$idea <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$one_share <- Portfolio$new(
        name = "one IDEA share",
        members = list(
          BasketMember$new(self$idea, quantity = 1)
        )
      )
    },

    #' @description
    #' Reads the order book until the order reaches a final status or the wait ends.
    #' @param order_id The character broker order id to look for.
    #' @return The character last status seen, such as `"COMPLETE"`, or `NULL` when the order never appeared.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the order book.
    wait_for_status = function(order_id) {
      status <- NULL
      for (attempt in seq_len(WAIT_ATTEMPTS)) {
        Sys.sleep(WAIT_SECONDS)
        orders <- self$idea$orders
        if (is.null(orders)) {
          next
        }
        matching <- orders[which(as.character(orders$order_id) == order_id), ]
        if (nrow(matching) == 0) {
          next
        }
        status <- matching$status[[1]]
        if (status %in% FINAL_STATUSES) {
          break
        }
      }
      status
    },

    #' @description
    #' Sells the share again through the portfolio, falling back to reducing the position. UBI chooses a broker for every order on its own, so the sale may go to a broker that does not hold the share, and some brokers refuse that. When the sale is not accepted, the position is reduced by one share instead, which UBI sends in the direction and at the size the position needs.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    sell_back = function() {
      sold <- self$one_share$place_orders(
        product = "mis",
        transaction_type = "sell",
        tag = "roundtrip"
      )
      columns <- c(
        "label",
        "transaction_type",
        "status",
        "outcome",
        "error"
      )
      print(sold[, columns])
      if (!identical(sold$outcome[[1]], "accepted")) {
        closed <- self$idea$reduce_position(
          quantity = 1,
          product = "mis",
          tag = "roundtrip"
        )
        cat(
          sprintf(
            "The sale was refused, so the position was reduced: %s\n",
            closed[["outcome"]]
          )
        )
        return(invisible(NULL))
      }
      sell_status <- self$wait_for_status(as.character(sold$order_id[[1]]))
      sell_status_text <- "NULL"
      if (!is.null(sell_status)) {
        sell_status_text <- sell_status
      }
      cat(sprintf("The sell order is %s\n", sell_status_text))
      invisible(NULL)
    },

    #' @description
    #' Buys the share, waits for the fill, and sells it back or cancels the buy.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      bought <- self$one_share$place_orders(product = "mis", tag = "roundtrip")
      columns <- c(
        "label",
        "transaction_type",
        "status",
        "outcome",
        "order_id"
      )
      print(bought[, columns])
      if (!identical(bought$outcome[[1]], "accepted")) {
        cat(
          sprintf("The buy was not accepted: %s\n", toString(bought$error[[1]]))
        )
        return(invisible(NULL))
      }
      order_id <- as.character(bought$order_id[[1]])
      status <- self$wait_for_status(order_id)
      status_text <- "NULL"
      if (!is.null(status)) {
        status_text <- status
      }
      cat(sprintf("The buy order is %s\n", status_text))
      if (identical(status, "COMPLETE")) {
        self$sell_back()
      } else if (is.null(status) || status %in% OPEN_STATUSES) {
        cancelled <- self$idea$cancel_order(order_id)
        cat(sprintf("Cancelled the buy: %s\n", cancelled[["outcome"]]))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IntradayRoundTrip$new()$run()
}
