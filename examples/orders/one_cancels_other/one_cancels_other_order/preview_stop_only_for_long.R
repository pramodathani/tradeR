#' Preview and place a stop-only one-cancels-other order on an intraday long.
#'
#' An `oco` order may carry a stop alone. UBI refuses one with HTTP 409 when no position is held on the side that opened it, so the program previews the order, then opens its own position by buying one Vodafone Idea share at the best offer as an intraday position. It places a reduce-only `oco` order with `transaction_type` `buy` whose only exit is a stop-limit sell triggering 5% below the market, which cannot trigger in the seconds it rests. It prints the parent and the broker order, cancels the parent and sells the share back. It refuses to start when Vodafone Idea is already held intraday, so that it never acts on a position it did not open.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/one_cancels_other/one_cancels_other_order/preview_stop_only_for_long.R

library(tradeR)

#' An intraday long in one share protected by a stop alone, sent as a one-cancels-other order.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field quantity_before The integer intraday quantity of Vodafone Idea held before the program bought its share.
#' @field order The `OneCancelsOtherOrder` the program places, or `NULL` before `run()` builds it.
StopOnlyProtectedLong <- R6::R6Class(
  "StopOnlyProtectedLong",
  public = list(
    trading_account = NULL,
    share = NULL,
    quantity_before = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `StopOnlyProtectedLong` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$quantity_before <- 0L
      self$order <- NULL
    },

    #' @description
    #' Writes a value UBI returned as text for printing, the way Python's f-strings print it.
    #'
    #' A list is written as one line of JSON, `NULL` as `"NULL"` and anything else with `format()`, so a missing field still prints rather than emptying the whole line.
    #' @param value Any value, such as a character, a number, a named list or `NULL`.
    #' @return A character value.
    text_of = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        json <- jsonlite::toJSON(
          value,
          auto_unbox = TRUE,
          null = "null"
        )
        return(as.character(json))
      }
      paste(format(value), collapse = ", ")
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
          sprintf("UBI has no last price for %s", instrument$format())
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
    #' Builds a reduce-only stop-limit sell triggering 5% below the market, with no target.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `OneCancelsOtherOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      stop_limit_price <- self$price_from_market(self$share, -6)
      OneCancelsOtherOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = stop_limit_price,
        stop_price = self$price_from_market(self$share, -5),
        stop_limit_price = stop_limit_price,
        reduce_only = TRUE,
        dry_run = dry_run
      )
    },

    #' @description
    #' Prints the state the order engine holds the order in and each leg it has.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the parent.
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
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the order book.
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
    #' @details Errors: signals `OrderRejectedError` when brokers refused the order three times, `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds, and `UnifiedBrokerInterfaceError` when UBI refused the order or could not be reached.
    place_order = function() {
      for (attempt in 0:2) {
        answer <- tryCatch(
          self$order$place(),
          OrderRejectedError = function(error) {
            if (attempt == 2) {
              stop(error)
            }
            cat(sprintf(
              "A broker refused the order, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            Sys.sleep(1)
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            self$read_late_answer(error)
          }
        )
        if (!identical(answer, "refused")) {
          return(answer)
        }
      }
      list()
    },

    #' @description
    #' Reads the order engine's stored answer to a placement it answered too late, and keeps its parent id.
    #' @param error The `OrderOutcomeUnknownError` the placement raised.
    #' @return The named list answer the placement would have given.
    #' @details Errors: signals `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds.
    read_late_answer = function(error) {
      intent_id <- error$detail[["intent_id"]]
      cat(sprintf(
        "The engine answered late, so intent %s is read.\n",
        self$text_of(intent_id)
      ))
      for (attempt in 0:14) {
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
    #' @details Errors: signals a plain error when the parent was still not cancelled after five attempts, so a leg may still be live, and `UnifiedBrokerInterfaceError` when UBI refused the cancel or could not be reached.
    cancel_order = function() {
      if (is.null(self$order) || is.null(self$order$parent_id)) {
        cat("No order was placed, so there is nothing to cancel.\n")
        return(invisible(NULL))
      }
      for (attempt in 0:4) {
        answer <- tryCatch(
          self$order$cancel(),
          ConflictError = function(error) {
            cat(sprintf(
              "The parent has already finished: %s\n",
              self$text_of(self$order$parent[["state"]])
            ))
            "finished"
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the cancel late, so it is sent again.\n")
            Sys.sleep(3)
            "late"
          }
        )
        if (identical(answer, "finished")) {
          return(invisible(NULL))
        }
        if (identical(answer, "late")) {
          next
        }
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
    #' Gives the net intraday quantity of Vodafone Idea held now.
    #' @return The integer quantity, positive when long, negative when short and 0 when nothing is held.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the positions.
    held_quantity = function() {
      positions <- self$share$net_positions
      if (is.null(positions)) {
        return(0L)
      }
      total <- 0L
      for (index in seq_len(nrow(positions))) {
        if (identical(positions[["product"]][[index]], "intraday")) {
          total <- total + as.integer(positions[["quantity"]][[index]])
        }
      }
      total
    },

    #' @description
    #' Buys one share at the best offer as an intraday position and waits until UBI reports it.
    #'
    #' The buy is a marketable limit half a percent above the best offer rather than a market order, because brokers refuse market orders sent through an API, and it is immediate-or-cancel so that nothing is left resting if it cannot fill at once. UBI chooses the broker for each order, so a buy one broker refuses is sent again up to four times, and a buy the engine answers late is not sent again but waited for.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the position did not appear within thirty seconds, and `UnifiedBrokerInterfaceError` when UBI refused the order or could not be reached.
    open_position = function() {
      for (attempt in 0:3) {
        answer <- tryCatch(
          self$share$buy_at_marketable_price(
            quantity = 1,
            product = "mis",
            validity = "ioc",
            buffer_percent = 0.5
          ),
          OrderRejectedError = function(error) {
            cat(sprintf(
              "A broker refused the buy, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the buy late, so the position is watched.\n")
            "late"
          }
        )
        if (identical(answer, "refused")) {
          next
        }
        if (identical(answer, "late")) {
          break
        }
        cat(sprintf(
          "Opened with marketable buy %s\n",
          self$text_of(answer[["order_id"]])
        ))
        break
      }
      for (attempt in 0:29) {
        if (self$held_quantity() > self$quantity_before) {
          cat(sprintf("Now holding %d intraday\n", self$held_quantity()))
          return(invisible(NULL))
        }
        Sys.sleep(1)
      }
      stop(
        "The buy did not show as a position within 30 seconds",
        call. = FALSE
      )
    },

    #' @description
    #' Sells back the share this program bought, if the position shows that it was bought, trying up to five times.
    #'
    #' The sell is sent with `reduce_position`, whose quantity reference UBI sizes and routes against the broker that actually holds the position, so the account is left as it was found rather than long at one broker and short at another. It is a limit half a percent below the last price, because brokers refuse market orders sent through an API.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not be reached.
    close_position = function() {
      for (attempt in 0:4) {
        if (self$held_quantity() <= self$quantity_before) {
          cat(sprintf(
            "Back to %d intraday, as before.\n",
            self$held_quantity()
          ))
          return(invisible(NULL))
        }
        answer <- tryCatch(
          self$share$reduce_position(
            quantity = 1,
            product = "mis",
            price = self$price_from_market(self$share, -0.5)
          ),
          OrderRejectedError = function(error) {
            cat(sprintf(
              "A broker refused the sell, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            Sys.sleep(2)
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the sell late, so the position is read again.\n")
            Sys.sleep(10)
            "late"
          }
        )
        if (identical(answer, "refused") || identical(answer, "late")) {
          next
        }
        cat(sprintf(
          "Reducing the position with sell %s\n",
          self$text_of(answer[["order_id"]])
        ))
        Sys.sleep(4)
      }
      cat("The position could still be open, so check it by hand.\n")
      invisible(NULL)
    },

    #' @description
    #' Previews the stop, opens the position, places the stop, prints it, cancels it and closes the position.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when Vodafone Idea was already held intraday, so the program does not touch it, `ValueError` when UBI has no last price for a share, a plain error when the opening buy did not show as a position in time, and `UnifiedBrokerInterfaceError` when UBI refused a request or could not be reached.
    run = function() {
      self$quantity_before <- self$held_quantity()
      if (self$quantity_before != 0) {
        stop(
          sprintf(
            "Vodafone Idea is already held intraday (%d), so the program leaves that position alone",
            self$quantity_before
          ),
          call. = FALSE
        )
      }
      preview <- self$build_order(dry_run = TRUE)$place()
      cat("A dry run, which sends and records nothing, says UBI would send:\n")
      request <- preview[["request"]]
      if (is.null(request)) {
        request <- preview
      }
      cat(self$text_of(request), "\n", sep = "")
      tryCatch(
        {
          self$open_position()
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
        },
        finally = self$close_position()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StopOnlyProtectedLong$new()$run()
}
