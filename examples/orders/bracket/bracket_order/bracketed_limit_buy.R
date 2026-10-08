#' Rest a limit buy with a stop and a target that arm only when it fills.
#'
#' The program rests a buy of one Vodafone Idea share 3% below the market, with a stop 5% below the market and a target 3% above it. Because the entry does not fill, neither exit is sent; the program prints the parent and cancels it. It passes `hold_limits = FALSE`, so UBI sends the order to the broker at once instead of holding it until the market reaches its price.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/bracket/bracket_order/bracketed_limit_buy.R

library(tradeR)

#' A limit buy with its stop and target, run by the order engine as a bracket.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field order The `BracketOrder` the program places, or `NULL` before `run()` builds it.
BracketedLimitBuy <- R6::R6Class(
  "BracketedLimitBuy",
  public = list(
    trading_account = NULL,
    share = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `BracketedLimitBuy` object.
    #' @details Errors: signals an `InstrumentError` subclass when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(
        exchange = "nse",
        symbol = "IDEA"
      )
      self$order <- NULL
    },

    #' @description
    #' Gives the text of one value from UBI's answer for printing, writing a missing value as `NULL`.
    #' @param value A value read from a named list or a data frame row, or `NULL`.
    #' @return A character value.
    text_of = function(value) {
      if (is.null(value) || length(value) == 0) {
        return("NULL")
      }
      format(value[[1]])
    },

    #' @description
    #' Gives a price a percentage away from an instrument's last price, rounded to its tick size.
    #' @param instrument The `TradeableInstrument` to price.
    #' @param percent The numeric percentage to move from the last price, negative for a price below the market.
    #' @return The numeric price in rupees.
    #' @details Errors: signals `ValueError` when UBI has no last price for the instrument.
    price_from_market = function(instrument, percent) {
      last_price <- instrument$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", format(instrument))
        )
      }
      tick_size <- 0.05
      if (!is.null(instrument$tick_size)) {
        tick_size <- as.numeric(instrument$tick_size)
      }
      ticks <- round(last_price * (1 + percent / 100) / tick_size)
      round(ticks * tick_size, 2)
    },

    #' @description
    #' Builds a buy 3% below the market with a stop 5% below and a target 3% above.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `BracketOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      stop_price <- self$price_from_market(self$share, -5)
      BracketOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = self$price_from_market(self$share, -3),
        stop_price = stop_price,
        stop_limit_price = round(stop_price - 0.05, 2),
        target_price = self$price_from_market(self$share, 3),
        hold_limits = FALSE,
        dry_run = dry_run
      )
    },

    #' @description
    #' Prints the state the order engine holds the order in and each leg it has.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the parent.
    print_parent = function() {
      parent <- self$order$parent
      cat(sprintf("Parent state: %s\n", self$text_of(parent[["state"]])))
      for (leg in parent[["legs"]]) {
        cat(sprintf(
          "  leg %s: %s %s at %s trigger %s, %s\n",
          self$text_of(leg[["role"]]),
          self$text_of(leg[["transaction_type"]]),
          self$text_of(leg[["quantity"]]),
          self$text_of(leg[["price"]]),
          self$text_of(leg[["trigger_price"]]),
          self$text_of(leg[["state"]])
        ))
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the broker orders the order has placed so far.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the order book.
    print_broker_orders = function() {
      broker_orders <- self$order$orders
      if (is.null(broker_orders)) {
        cat("No broker order has been placed yet.\n")
        return(invisible(NULL))
      }
      for (index in seq_len(nrow(broker_orders))) {
        row <- broker_orders[index, , drop = FALSE]
        cat(sprintf(
          "  order %s: %s %s at %s, %s\n",
          self$text_of(row[["order_id"]]),
          self$text_of(row[["transaction_type"]]),
          self$text_of(row[["quantity"]]),
          self$text_of(row[["price"]]),
          self$text_of(row[["status"]])
        ))
      }
      invisible(NULL)
    },

    #' @description
    #' Places the order, sending it again when a broker refuses it, and reading the engine's stored answer when the engine answers too late, so that the order can always be cancelled.
    #' @return The named list answer of the placement, whose `parent_id` is also kept on the order.
    #' @details Errors: signals `OrderRejectedError` when brokers refused the order three times; `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds; and another `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    place_order = function() {
      for (attempt in 1:3) {
        result <- tryCatch(
          list(
            kind = "placed",
            answer = self$order$place()
          ),
          OrderRejectedError = function(error) {
            if (attempt == 3) {
              stop(error)
            }
            list(
              kind = "rejected",
              message = conditionMessage(error)
            )
          },
          OrderOutcomeUnknownError = function(error) {
            list(
              kind = "late",
              error = error
            )
          }
        )
        if (result[["kind"]] == "placed") {
          return(result[["answer"]])
        }
        if (result[["kind"]] == "late") {
          return(self$read_late_answer(result[["error"]]))
        }
        cat(sprintf(
          "A broker refused the order, so it is sent again: %s\n",
          result[["message"]]
        ))
        Sys.sleep(1)
      }
      list()
    },

    #' @description
    #' Reads the order engine's stored answer to a placement it answered too late, and keeps its parent id.
    #' @param error The `OrderOutcomeUnknownError` condition the placement signalled.
    #' @return The named list answer the placement would have given.
    #' @details Errors: signals the same `OrderOutcomeUnknownError` again when the engine's answer could not be read within thirty seconds.
    read_late_answer = function(error) {
      intent_id <- error$detail[["intent_id"]]
      cat(sprintf(
        "The engine answered late, so intent %s is read.\n",
        self$text_of(intent_id)
      ))
      for (attempt in 1:15) {
        Sys.sleep(2)
        stored <- tryCatch(
          self$trading_account$intent(intent_id),
          NotFoundError = function(not_found_error) {
            NULL
          }
        )
        if (is.null(stored)) {
          next
        }
        answer <- stored[["response"]]
        self$order$parent_id <- answer[["parent_id"]]
        return(answer)
      }
      stop(error)
    },

    #' @description
    #' Cancels the order in the order engine, with every leg it still has at a broker, and prints the result.
    #'
    #' A broker can refuse or be slow to answer one leg's cancel, which leaves the parent `cancelling`, and the engine itself can answer late, so the cancel is sent again until the parent is `cancelled`, up to five times.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the parent was still not cancelled after five attempts, so a leg may still be live; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the cancel or could not be reached.
    cancel_order = function() {
      if (is.null(self$order) || is.null(self$order$parent_id)) {
        cat("No order was placed, so there is nothing to cancel.\n")
        return(invisible(NULL))
      }
      for (attempt in 1:5) {
        result <- tryCatch(
          list(
            kind = "answered",
            answer = self$order$cancel()
          ),
          ConflictError = function(error) {
            list(kind = "finished")
          },
          OrderOutcomeUnknownError = function(error) {
            list(kind = "late")
          }
        )
        if (result[["kind"]] == "finished") {
          cat(sprintf(
            "The parent has already finished: %s\n",
            self$text_of(self$order$parent[["state"]])
          ))
          return(invisible(NULL))
        }
        if (result[["kind"]] == "late") {
          cat("The engine answered the cancel late, so it is sent again.\n")
          Sys.sleep(3)
          next
        }
        answer <- result[["answer"]]
        cat(sprintf(
          "Cancelled: state %s, %d legs cancelled\n",
          self$text_of(answer[["state"]]),
          length(answer[["cancelled_legs"]])
        ))
        for (leg in answer[["cancelled_legs"]]) {
          cat(sprintf(
            "  %s %s: %s\n",
            self$text_of(leg[["broker"]]),
            self$text_of(leg[["order_id"]]),
            self$text_of(leg[["outcome"]])
          ))
        }
        if (identical(answer[["state"]], "cancelled")) {
          return(invisible(NULL))
        }
        Sys.sleep(3)
      }
      stop(
        sprintf(
          "Parent %s is still not cancelled, so check it by hand",
          self$order$parent_id
        ),
        call. = FALSE
      )
    },

    #' @description
    #' Places the bracket, prints the parent and its entry at the broker, then cancels it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$order <- self$build_order(dry_run = FALSE)
      answer <- self$place_order()
      cat(sprintf(
        "Placed a %s order: outcome %s, parent %s\n",
        self$order$SYNTHETIC_TYPE,
        self$text_of(answer[["outcome"]]),
        self$text_of(self$order$parent_id)
      ))
      tryCatch(
        {
          Sys.sleep(2)
          self$print_parent()
          self$print_broker_orders()
        },
        finally = self$cancel_order()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BracketedLimitBuy$new()$run()
}
