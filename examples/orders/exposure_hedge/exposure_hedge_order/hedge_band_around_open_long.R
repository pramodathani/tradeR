#' Watch a one-share long and keep its exposure inside a band with a hedge.
#'
#' The program buys one Vodafone Idea share at the best offer as an intraday position, then starts an exposure hedge in Yes Bank that watches it and trades only if the net exposure leaves a band from five below to five above the exposure held once the share is bought, so no hedge is traded; the program prints the parent, cancels it and sells the share back.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/exposure_hedge/exposure_hedge_order/hedge_band_around_open_long.R

library(tradeR)

#' A hedge that the order engine trades only when the exposure of a watched position leaves a band.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field second_share The `Equity` for Yes Bank on the NSE.
#' @field quantity_before The numeric intraday quantity of Vodafone Idea held before the program bought its share.
#' @field order The `ExposureHedgeOrder` the program places, or `NULL` before `run()` builds it.
BandedExposureHedge <- R6::R6Class(
  "BandedExposureHedge",
  public = list(
    trading_account = NULL,
    share = NULL,
    second_share = NULL,
    quantity_before = 0,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `BandedExposureHedge` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
      self$quantity_before <- 0
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
    #' Builds a hedge in Yes Bank watching the Vodafone Idea position, with a band five either side of the exposure held now.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `ExposureHedgeOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      exposure <- self$net_quantity(self$share)
      ExposureHedgeOrder$new(
        self$second_share,
        watched = list(
          ExposureWatch$new(self$share)
        ),
        lower_band = exposure - 5,
        upper_band = exposure + 5,
        product = "mis",
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
    #' Gives the net intraday quantity of Vodafone Idea held now.
    #' @return The numeric quantity, positive when long, negative when short and 0 when nothing is held.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    held_quantity = function() {
      positions <- self$share$net_positions
      if (is.null(positions)) {
        return(0)
      }
      total <- 0
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
    #' @details Errors: signals a plain error when the position did not appear within thirty seconds; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    open_position = function() {
      for (attempt in seq_len(4)) {
        answer <- NULL
        status <- tryCatch(
          {
            answer <- self$share$buy_at_marketable_price(
              quantity = 1,
              product = "mis",
              validity = "ioc",
              buffer_percent = 0.5
            )
            "answered"
          },
          OrderRejectedError = function(error) {
            cat(sprintf(
              "A broker refused the buy, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            cat(
              "The engine answered the buy late, so the position is watched.\n"
            )
            "late"
          }
        )
        if (status == "refused") {
          next
        }
        if (status == "answered") {
          cat(sprintf("Opened with marketable buy %s\n", answer[["order_id"]]))
        }
        break
      }
      for (attempt in seq_len(30)) {
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
    #' The sell is sent with `reduce_position()`, whose quantity reference UBI sizes and routes against the broker that actually holds the position, so the account is left as it was found rather than long at one broker and short at another. It is a limit half a percent below the last price, because brokers refuse market orders sent through an API.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached.
    close_position = function() {
      for (attempt in seq_len(5)) {
        if (self$held_quantity() <= self$quantity_before) {
          cat(sprintf(
            "Back to %d intraday, as before.\n",
            self$held_quantity()
          ))
          return(invisible(NULL))
        }
        answer <- NULL
        status <- tryCatch(
          {
            answer <- self$share$reduce_position(
              quantity = 1,
              product = "mis",
              price = self$price_from_market(self$share, -0.5)
            )
            "answered"
          },
          OrderRejectedError = function(error) {
            cat(sprintf(
              "A broker refused the sell, so it is sent again: %s\n",
              conditionMessage(error)
            ))
            Sys.sleep(2)
            "refused"
          },
          OrderOutcomeUnknownError = function(error) {
            cat(
              "The engine answered the sell late, so the position is read again.\n"
            )
            Sys.sleep(10)
            "late"
          }
        )
        if (status != "answered") {
          next
        }
        cat(sprintf(
          "Reducing the position with sell %s\n",
          answer[["order_id"]]
        ))
        Sys.sleep(4)
      }
      cat("The position could still be open, so check it by hand.\n")
      invisible(NULL)
    },

    #' @description
    #' Adds up the net quantity held in an instrument across every product, as the exposure hedge counts it.
    #' @param instrument The `TradeableInstrument` to read.
    #' @return The numeric net quantity, positive when long and negative when short.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not read the positions.
    net_quantity = function(instrument) {
      positions <- instrument$net_positions
      if (is.null(positions)) {
        return(0)
      }
      total <- 0
      for (index in seq_len(nrow(positions))) {
        total <- total + as.integer(positions[["quantity"]][[index]])
      }
      total
    },

    #' @description
    #' Opens the position, starts the hedge, prints it, cancels it and closes the position.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share; a plain error when the opening buy did not show as a position in time; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$quantity_before <- self$held_quantity()
      tryCatch(
        {
          self$open_position()
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
        },
        finally = self$close_position()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BandedExposureHedge$new()$run()
}
