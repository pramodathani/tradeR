#' Rest a reduce-only exit for a one-share intraday long, then cancel it.
#'
#' The program buys one Vodafone Idea share at the best offer as an intraday position, previews and then rests a reduce-only sell of that share 3% above the market, which UBI checks against the position before sending. It prints the parent, cancels the exit and sells the share back.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/synthetic_order/synthetic_order/reduce_only_exit_for_long.R

library(tradeR)

#' A reduce-only exit resting above the market for an intraday long.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field quantity_before The integer intraday quantity of Vodafone Idea held before the program bought its share.
#' @field order The `SyntheticOrder` the program places, or `NULL` before `run()` builds it.
ReduceOnlyExit <- R6::R6Class(
  "ReduceOnlyExit",
  public = list(
    trading_account = NULL,
    share = NULL,
    quantity_before = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `ReduceOnlyExit` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$quantity_before <- 0L
      self$order <- NULL
    },

    #' @description
    #' Gives a value as text for a printed line, showing `NULL` as `"NULL"` where Python showed `None`, because `sprintf()` prints nothing at all for a `NULL` argument.
    #' @param value The value to show, of any type, or `NULL`.
    #' @return A character value.
    text_of = function(value) {
      if (is.null(value)) {
        return("NULL")
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
    #' Builds a reduce-only sell of one share 3% above the market.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `SyntheticOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      SyntheticOrder$new(
        self$share,
        transaction_type = "sell",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = self$price_from_market(self$share, 3),
        closes_position = TRUE,
        reduce_only = TRUE,
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
        cat(
          sprintf(
            "  leg %s: %s %s at %s trigger %s, %s\n",
            self$text_of(leg[["role"]]),
            self$text_of(leg[["transaction_type"]]),
            self$text_of(leg[["quantity"]]),
            self$text_of(leg[["price"]]),
            self$text_of(leg[["trigger_price"]]),
            self$text_of(leg[["state"]])
          )
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Places the order, sending it again when a broker refuses it, and reading the engine's stored answer when the engine answers too late, so that the order can always be cancelled.
    #' @return The named list answer of the placement, whose `parent_id` is also kept on the order.
    #' @details Errors: signals `OrderRejectedError` when brokers refused the order three times; `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    place_order = function() {
      for (attempt in 0:2) {
        outcome <- tryCatch(
          list(
            answer = self$order$place()
          ),
          OrderRejectedError = function(error) {
            if (attempt == 2) {
              stop(error)
            }
            cat(
              sprintf(
                "A broker refused the order, so it is sent again: %s\n",
                conditionMessage(error)
              )
            )
            Sys.sleep(1)
            NULL
          },
          OrderOutcomeUnknownError = function(error) {
            list(
              answer = self$read_late_answer(error)
            )
          }
        )
        if (!is.null(outcome)) {
          return(outcome[["answer"]])
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
      cat(
        sprintf(
          "The engine answered late, so intent %s is read.\n",
          self$text_of(intent_id)
        )
      )
      for (attempt in seq_len(15)) {
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
      for (attempt in seq_len(5)) {
        outcome <- tryCatch(
          list(
            answer = self$order$cancel()
          ),
          ConflictError = function(error) {
            cat(
              sprintf(
                "The parent has already finished: %s\n",
                self$text_of(self$order$parent[["state"]])
              )
            )
            list(
              finished = TRUE
            )
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the cancel late, so it is sent again.\n")
            Sys.sleep(3)
            list(
              retry = TRUE
            )
          }
        )
        if (isTRUE(outcome[["finished"]])) {
          return(invisible(NULL))
        }
        if (isTRUE(outcome[["retry"]])) {
          next
        }
        answer <- outcome[["answer"]]
        cat(
          sprintf(
            "Cancelled: state %s, %d legs cancelled\n",
            self$text_of(answer[["state"]]),
            length(answer[["cancelled_legs"]])
          )
        )
        for (leg in answer[["cancelled_legs"]]) {
          cat(
            sprintf(
              "  %s %s: %s\n",
              self$text_of(leg[["broker"]]),
              self$text_of(leg[["order_id"]]),
              self$text_of(leg[["outcome"]])
            )
          )
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
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    held_quantity = function() {
      positions <- self$share$net_positions
      if (is.null(positions)) {
        return(0L)
      }
      total <- 0L
      for (index in seq_len(nrow(positions))) {
        if (isTRUE(positions[["product"]][[index]] == "intraday")) {
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
    #' @details Errors: signals a plain error when the position did not appear within thirty seconds; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    open_position = function() {
      for (attempt in seq_len(4)) {
        outcome <- tryCatch(
          list(
            answer = self$share$buy_at_marketable_price(
              quantity = 1,
              product = "mis",
              validity = "ioc",
              buffer_percent = 0.5
            )
          ),
          OrderRejectedError = function(error) {
            cat(
              sprintf(
                "A broker refused the buy, so it is sent again: %s\n",
                conditionMessage(error)
              )
            )
            list(
              retry = TRUE
            )
          },
          OrderOutcomeUnknownError = function(error) {
            cat(
              "The engine answered the buy late, so the position is watched.\n"
            )
            list(
              watch = TRUE
            )
          }
        )
        if (isTRUE(outcome[["retry"]])) {
          next
        }
        if (isTRUE(outcome[["watch"]])) {
          break
        }
        cat(
          sprintf(
            "Opened with marketable buy %s\n",
            self$text_of(outcome[["answer"]][["order_id"]])
          )
        )
        break
      }
      for (attempt in seq_len(30)) {
        if (self$held_quantity() > self$quantity_before) {
          cat(sprintf("Now holding %s intraday\n", self$held_quantity()))
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
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached.
    close_position = function() {
      for (attempt in seq_len(5)) {
        if (self$held_quantity() <= self$quantity_before) {
          cat(
            sprintf("Back to %s intraday, as before.\n", self$held_quantity())
          )
          return(invisible(NULL))
        }
        outcome <- tryCatch(
          list(
            answer = self$share$reduce_position(
              quantity = 1,
              product = "mis",
              price = self$price_from_market(self$share, -0.5)
            )
          ),
          OrderRejectedError = function(error) {
            cat(
              sprintf(
                "A broker refused the sell, so it is sent again: %s\n",
                conditionMessage(error)
              )
            )
            Sys.sleep(2)
            list(
              retry = TRUE
            )
          },
          OrderOutcomeUnknownError = function(error) {
            cat(
              "The engine answered the sell late, so the position is read again.\n"
            )
            Sys.sleep(10)
            list(
              retry = TRUE
            )
          }
        )
        if (isTRUE(outcome[["retry"]])) {
          next
        }
        cat(
          sprintf(
            "Reducing the position with sell %s\n",
            self$text_of(outcome[["answer"]][["order_id"]])
          )
        )
        Sys.sleep(4)
      }
      cat("The position could still be open, so check it by hand.\n")
      invisible(NULL)
    },

    #' @description
    #' Opens the position, rests the exit, prints it, cancels it and closes the position.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share; a plain error when the opening buy did not show as a position in time; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$quantity_before <- self$held_quantity()
      tryCatch(
        {
          self$open_position()
          preview <- self$build_order(dry_run = TRUE)$place()
          cat(
            "A dry run, which sends and records nothing, says UBI would send:\n"
          )
          request <- preview[["request"]]
          if (is.null(request)) {
            request <- preview
          }
          cat(
            jsonlite::toJSON(request, auto_unbox = TRUE, null = "null"),
            "\n",
            sep = ""
          )
          self$order <- self$build_order(dry_run = FALSE)
          answer <- self$place_order()
          cat(
            sprintf(
              "Placed a %s order: outcome %s, parent %s\n",
              self$order$SYNTHETIC_TYPE,
              self$text_of(answer[["outcome"]]),
              self$text_of(self$order$parent_id)
            )
          )
          tryCatch(
            {
              Sys.sleep(2)
              self$print_parent()
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
  ReduceOnlyExit$new()$run()
}
