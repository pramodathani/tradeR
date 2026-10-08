#' Buy one share intraday, report the position, and close it.
#'
#' The program buys one Vodafone Idea share under the intraday product with a marketable limit order, which fills at once at the best offer and, unlike a market order, is accepted by every broker's API. It waits for the position to grow by that share, prints the order, the trade, the position's value and its profit or loss, and then sells the share back through reduce_position, which UBI routes to the broker holding the position, so the position ends where it began apart from charges.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/tradeable_instrument/intraday_round_trip_report.R

library(tradeR)

#' One intraday buy and sell of a single share, with a report in between.
#'
#' @field share The `Equity` that is traded.
#' @field start_quantity The integer intraday quantity held before the program traded.
IntradayRoundTripReport <- R6::R6Class(
  "IntradayRoundTripReport",
  public = list(
    share = NULL,
    start_quantity = NULL,

    #' @description
    #' Looks Vodafone Idea up in UBI.
    #' @return A new `IntradayRoundTripReport` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$start_quantity <- 0L
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Reads the quantity of the share's open intraday position.
    #' @return The integer quantity, positive when long, negative when short and zero when none is open.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    intraday_quantity = function() {
      positions <- self$share$net_positions
      if (is.null(positions)) {
        return(0L)
      }
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      as.integer(sum(intraday$quantity))
    },

    #' @description
    #' Waits up to thirty seconds for the intraday position to reach a quantity.
    #' @param wanted The integer quantity to wait for.
    #' @return A logical that is `TRUE` when the position reached the quantity in time.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    wait_for_quantity = function(wanted) {
      for (attempt in seq_len(30)) {
        if (self$intraday_quantity() == wanted) {
          return(TRUE)
        }
        Sys.sleep(1)
      }
      FALSE
    },

    #' @description
    #' Prints the buy order, its trade and the position's value and profit.
    #' @param order_id The character id of the buy order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the books.
    report = function(order_id) {
      orders <- self$share$orders
      order_columns <- c(
        "order_id",
        "status",
        "average_price",
        "filled_quantity"
      )
      order <- orders[orders$order_id == order_id, order_columns, drop = FALSE]
      print(order)
      trades <- self$share$trades
      if (is.null(trades)) {
        cat("The trade book does not show the trade yet.\n")
      } else {
        trade_columns <- c(
          "trade_id",
          "quantity",
          "price"
        )
        print(trades[trades$order_id == order_id, trade_columns, drop = FALSE])
      }
      cat(
        "Position value:",
        self$display_text(self$share$positions_value),
        "\n"
      )
      pnl <- self$share$positions_pnl
      pnl_text <- "NULL"
      if (!is.null(pnl)) {
        pnl_text <- jsonlite::toJSON(pnl, auto_unbox = TRUE, null = "null")
      }
      cat("Profit or loss:", pnl_text, "\n")
      invisible(NULL)
    },

    #' @description
    #' Sends one order that brings the intraday position from a quantity back to where it started.
    #'
    #' The order is a limit a per cent through the market, which fills at once. When it shrinks the position it is sent through `reduce_position()`, so UBI routes it against the brokers that hold the position rather than leaving one broker long and another short.
    #' @param quantity The integer intraday quantity held now.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI or the broker refused the order.
    trade_difference = function(quantity) {
      difference <- as.integer(quantity - self$start_quantity)
      if (difference > 0) {
        price <- round(self$share$last_price * 0.99, 2)
      } else {
        price <- round(self$share$last_price * 1.01, 2)
      }
      if ((difference > 0) == (quantity > 0)) {
        self$share$reduce_position(
          quantity = abs(difference),
          product = "mis",
          price = price
        )
      } else if (difference > 0) {
        self$share$sell_at_limit_price(
          price = price,
          quantity = difference,
          product = "mis",
          hold = FALSE
        )
      } else {
        self$share$buy_at_limit_price(
          price = price,
          quantity = -difference,
          product = "mis",
          hold = FALSE
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Trades back to the intraday quantity the program started from, trying again when a broker refuses.
    #'
    #' Each attempt waits five seconds for the positions to settle, so an order whose outcome was unknown is counted before another is sent, and then trades the difference through `trade_difference()`.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals an error when the position could not be brought back after six attempts, and a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    restore_position = function() {
      quantity <- NULL
      for (attempt in seq_len(6)) {
        Sys.sleep(5)
        caught_error <- tryCatch(
          {
            quantity <- self$intraday_quantity()
            if (quantity != self$start_quantity) {
              self$trade_difference(quantity)
            }
            NULL
          },
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (!is.null(caught_error)) {
          quantity <- NULL
          cat(
            "Closing failed, trying again:",
            conditionMessage(caught_error),
            "\n"
          )
        } else if (quantity == self$start_quantity) {
          break
        }
      }
      if (is.null(quantity) || quantity != self$start_quantity) {
        stop(
          sprintf(
            "The position is %s, not %s.",
            self$display_text(quantity),
            self$start_quantity
          ),
          call. = FALSE
        )
      }
      cat("Intraday quantity back at", quantity, "\n")
      invisible(NULL)
    },

    #' @description
    #' Buys, reports and sells back, selling back even when the report fails.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals an error when the position could not be brought back to where it started, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      options(width = 120)
      self$start_quantity <- self$intraday_quantity()
      bought <- NULL
      tryCatch(
        {
          bought <- self$share$buy_at_marketable_price(
            quantity = 1,
            product = "mis"
          )
          cat("Bought:", bought[["outcome"]], bought[["order_id"]], "\n")
          if (self$wait_for_quantity(self$start_quantity + 1)) {
            self$report(bought[["order_id"]])
          } else {
            cat("The position did not grow within thirty seconds.\n")
          }
        },
        finally = {
          if (!is.null(bought)) {
            tryCatch(
              self$share$cancel_parent(bought[["parent_id"]]),
              ConflictError = function(error) {
                cat("The buy had already finished.\n")
              },
              UnifiedBrokerInterfaceError = function(error) {
                cat("Could not cancel the buy:", conditionMessage(error), "\n")
              }
            )
          }
          self$restore_position()
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IntradayRoundTripReport$new()$run()
}
