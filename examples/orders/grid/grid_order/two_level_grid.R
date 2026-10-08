#' Preview and set a grid of two levels each side, then take it down.
#'
#' The program previews, then sets, a grid of two levels on each side of Vodafone Idea's last price, with a step of about 4% of the price, so the nearest rungs are 4% away and the farthest 8%. It prints the parent's rungs and cancels the grid.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/grid/grid_order/two_level_grid.R

library(tradeR)

#' A two-level grid of resting orders on each side of the market.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field order The `GridOrder` the program places, or `NULL` before `run()` builds it.
TwoLevelGrid <- R6::R6Class(
  "TwoLevelGrid",
  public = list(
    trading_account = NULL,
    share = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `TwoLevelGrid` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$order <- NULL
    },

    #' @description
    #' Gives a price a percentage away from an instrument's last price, rounded to its tick size.
    #' @param instrument The `TradeableInstrument` to price.
    #' @param percent A numeric percentage to move from the last price, negative for a price below the market.
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
    #' Builds a grid of two levels each side with a step of about 4% of the price.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `GridOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      last_price <- self$price_from_market(self$share, 0)
      GridOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = last_price,
        levels = 2,
        step_points = round(last_price * 0.04, 2),
        most_inventory = 2,
        dry_run = dry_run
      )
    },

    #' @description
    #' Prints the state the order engine holds the order in and each leg it has.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the parent.
    print_parent = function() {
      parent <- self$order$parent
      cat(sprintf("Parent state: %s\n", parent[["state"]]))
      for (leg in parent[["legs"]]) {
        cat(
          "  leg ", leg[["role"]], ": ", leg[["transaction_type"]], " ",
          leg[["quantity"]], " at ", leg[["price"]],
          " trigger ", leg[["trigger_price"]], ", ", leg[["state"]], "\n",
          sep = ""
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Places the order, sending it again when a broker refuses it, and reading the engine's stored answer when the engine answers too late, so that the order can always be cancelled.
    #' @return The named list answer of the placement, whose `parent_id` is also kept on the order.
    #' @details Errors: signals `OrderRejectedError` when brokers refused the order three times; `OrderOutcomeUnknownError` when the engine's answer could not be read within thirty seconds; and another `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    place_order = function() {
      for (attempt in seq_len(3)) {
        answer <- tryCatch(
          self$order$place(),
          OrderRejectedError = function(error) {
            if (attempt == 3) {
              stop(error)
            }
            cat(sprintf(
              "A broker refused the order, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            Sys.sleep(1)
            NULL
          },
          OrderOutcomeUnknownError = function(error) {
            self$read_late_answer(error)
          }
        )
        if (!is.null(answer)) {
          return(answer)
        }
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
        intent_id
      ))
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
        answer <- NULL
        status <- tryCatch(
          {
            answer <- self$order$cancel()
            "answered"
          },
          ConflictError = function(error) {
            cat(sprintf(
              "The parent has already finished: %s\n",
              self$order$parent[["state"]]
            ))
            "finished"
          },
          OrderOutcomeUnknownError = function(error) {
            cat("The engine answered the cancel late, so it is sent again.\n")
            Sys.sleep(3)
            "late"
          }
        )
        if (status == "finished") {
          return(invisible(NULL))
        }
        if (status == "late") {
          next
        }
        cat(sprintf(
          "Cancelled: state %s, %d legs cancelled\n",
          answer[["state"]],
          length(answer[["cancelled_legs"]])
        ))
        for (leg in answer[["cancelled_legs"]]) {
          cat(
            "  ", leg[["broker"]], " ", leg[["order_id"]], ": ",
            leg[["outcome"]], "\n",
            sep = ""
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
    #' Previews the grid, sets it, prints the parent and cancels it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      preview <- self$build_order(dry_run = TRUE)$place()
      cat("A dry run, which sends and records nothing, says UBI would send:\n")
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
        "Placed a ", self$order$SYNTHETIC_TYPE, " order: outcome ",
        answer[["outcome"]], ", parent ", self$order$parent_id, "\n",
        sep = ""
      )
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
  TwoLevelGrid$new()$run()
}
