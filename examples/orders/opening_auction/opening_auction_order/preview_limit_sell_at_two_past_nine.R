#' Preview and schedule a pre-open limit sell for 09:02, then cancel it.
#'
#' The program previews, then schedules, an opening-auction sell of one Vodafone Idea share with a limit 3% above the last price, to be sent at 09:02 India time on the next trading day, before the pre-open stops collecting limit orders at 09:10. UBI answers HTTP 202 `armed` and sends nothing to a broker until then; the program prints the parent and cancels it. On a trading day after the pre-open has stopped collecting the order, UBI refuses it with HTTP 400 rather than keep it for the next day, and the program prints that refusal and stops, since nothing was placed. It refuses to run between 08:55 and 09:20 India time, because then the order would go straight into the pre-open and could trade at the auction before it was cancelled.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/opening_auction/opening_auction_order/preview_limit_sell_at_two_past_nine.R

library(tradeR)

#' A limit sell scheduled for a chosen moment in the opening call auction's collection period.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field order The `OpeningAuctionOrder` the program places, or `NULL` before `run()` builds it.
LimitSellAtTwoPastNine <- R6::R6Class(
  "LimitSellAtTwoPastNine",
  public = list(
    trading_account = NULL,
    share = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `LimitSellAtTwoPastNine` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
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
    #' Refuses to run between 08:55 and 09:20 India time.
    #'
    #' In that window the order would go straight into the pre-open and could trade at the auction before it is cancelled.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the program was started between 08:55 and 09:20 India time.
    refuse_near_pre_open = function() {
      now <- TimeConverter$new()$now()
      time_of_day <- format(now, "%H:%M:%S")
      if (time_of_day >= "08:55:00" && time_of_day <= "09:20:00") {
        stop(
          sprintf(
            "It is %s India time, so the order would go straight into the pre-open; run this after 09:20",
            format(now, "%H:%M")
          ),
          call. = FALSE
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Builds a limit sell 3% above the market for 09:02 in the next pre-open session.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `OpeningAuctionOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      OpeningAuctionOrder$new(
        self$share,
        transaction_type = "sell",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = self$price_from_market(self$share, 3),
        at_time = "09:02:00",
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
    #' Previews the sell, schedules it, prints the parent and the broker orders, of which there are none, then cancels it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the program was started between 08:55 and 09:20 India time, `ValueError` when UBI has no last price for a share, and `UnifiedBrokerInterfaceError` when UBI refused a request or could not be reached.
    run = function() {
      self$refuse_near_pre_open()
      preview <- self$build_order(dry_run = TRUE)$place()
      cat("A dry run, which sends and records nothing, says UBI would send:\n")
      request <- preview[["request"]]
      if (is.null(request)) {
        request <- preview
      }
      cat(self$text_of(request), "\n", sep = "")
      self$order <- self$build_order(dry_run = FALSE)
      answer <- tryCatch(
        self$place_order(),
        BadRequestError = function(error) {
          cat(sprintf(
            "UBI refused the order, so nothing was placed: %s\n",
            conditionMessage(error)
          ))
          NULL
        }
      )
      if (is.null(answer)) {
        return(invisible(NULL))
      }
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
  LimitSellAtTwoPastNine$new()$run()
}
