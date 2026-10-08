#' Arm a bracket whose entry waits for the price to touch a level, two existing types combined as presets.
#'
#' The program names two presets on one order: `market_if_touched`, which holds a buy of one Vodafone Idea share until the price falls 3% below the market, and `bracket`, which puts a stop 5% below the market and a target 3% above it behind every fill. UBI turns the pair into a `then` join, which the dry run shows. Because nothing is sent until the price is touched, the plan is armed rather than placed; the program prints each part's state and cancels it.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan/plan_order/touch_entry_with_bracket.R

library(tradeR)

#' A buy that waits for a touch and is bracketed by a stop and a target, run as a plan.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field order The `PlanOrder` the program places, or `NULL` before `run()` builds it.
TouchEntryWithBracket <- R6::R6Class(
  "TouchEntryWithBracket",
  public = list(
    trading_account = NULL,
    share = NULL,
    order = NULL,

    #' @description
    #' Looks up the share the program trades.
    #' @return A new `TouchEntryWithBracket` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
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
    #' Builds a buy that waits for a touch 3% below the market, bracketed by a stop 5% below and a target 3% above.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `PlanOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    build_order = function(dry_run) {
      entry_price <- self$price_from_market(self$share, -3)
      stop_price <- self$price_from_market(self$share, -5)
      touch <- Preset$new(
        "market_if_touched",
        trigger_price = entry_price
      )
      exits <- Preset$new(
        "bracket",
        stop_price = stop_price,
        stop_limit_price = round(stop_price - 0.05, 2),
        target_price = self$price_from_market(self$share, 3)
      )
      PlanOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = entry_price,
        plan = OrderPart$new(
          presets = list(
            touch,
            exits
          )
        ),
        dry_run = dry_run
      )
    },

    #' @description
    #' Sends the plan as a dry run and prints the broker request and the plan as UBI would run it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share, and `UnifiedBrokerInterfaceError` when UBI refused the plan or could not be reached.
    preview = function() {
      answer <- self$build_order(dry_run = TRUE)$place()
      cat("Dry run of the plan:\n")
      cat(sprintf(
        "  first broker request: %s\n",
        self$text_of(answer[["request"]])
      ))
      cat(sprintf(
        "  plan as it would run: %s\n",
        self$text_of(answer[["plan"]])
      ))
      invisible(NULL)
    },

    #' @description
    #' Prints the state the order engine holds the plan in and the state of each of its parts.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI could not read the parent.
    print_parent = function() {
      parent <- self$order$parent
      cat(sprintf("Parent state: %s\n", self$text_of(parent[["state"]])))
      parts <- parent[["parameters"]][["parts"]]
      for (path in names(parts)) {
        part <- parts[[path]]
        cat(sprintf(
          "  part %s: %s, target %s\n",
          path,
          self$text_of(part[["state"]]),
          self$text_of(part[["target"]])
        ))
      }
      for (leg in parent[["legs"]]) {
        cat(sprintf(
          "  leg %s: %s %s at %s, %s\n",
          self$text_of(leg[["role"]]),
          self$text_of(leg[["transaction_type"]]),
          self$text_of(leg[["quantity"]]),
          self$text_of(leg[["price"]]),
          self$text_of(leg[["state"]])
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
    #' Cancels the plan in the order engine, with every leg it still has at a broker, and prints the result.
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
    #' Previews the plan, places it, prints its parts, then cancels it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share, and `UnifiedBrokerInterfaceError` when UBI refused a request or could not be reached.
    run = function() {
      self$preview()
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
        },
        finally = self$cancel_order()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TouchEntryWithBracket$new()$run()
}
