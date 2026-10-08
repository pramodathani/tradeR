#' Preview and start a hedge watching two shares weighted as a beta would weight them.
#'
#' The program previews, then starts, an exposure hedge in Vodafone Idea that adds up the positions in Vodafone Idea and Yes Bank, weighting them 1 and 1.5, and trades only if the total moves more than 100 away from what it is now, so no hedge is traded; the program prints the parent and cancels it.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/exposure_hedge/exposure_hedge_order/weighted_two_share_exposure.R

library(tradeR)

#' A hedge that keeps the weighted exposure of two shares inside a wide band.
#'
#' @field trading_account The `Account`, used to read the engine's answer when it comes late.
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field second_share The `Equity` for Yes Bank on the NSE.
#' @field order The `ExposureHedgeOrder` the program places, or `NULL` before `run()` builds it.
WeightedExposureHedge <- R6::R6Class(
  "WeightedExposureHedge",
  public = list(
    trading_account = NULL,
    share = NULL,
    second_share = NULL,
    order = NULL,

    #' @description
    #' Looks up the shares the program trades.
    #' @return A new `WeightedExposureHedge` object.
    #' @details Errors: signals `InstrumentError` when a share could not be found in UBI.
    initialize = function() {
      self$trading_account <- Account$new()
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
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
    #' Builds a hedge in Vodafone Idea over two weighted watched shares, with a band 100 either side of the exposure held now.
    #' @param dry_run A logical that is `TRUE` to build the order as a dry run, which UBI only checks and prices.
    #' @return The `ExposureHedgeOrder`, not yet placed.
    #' @details Errors: signals `ValueError` when UBI has no last price for a share.
    build_order = function(dry_run) {
      exposure <- self$net_quantity(self$share) +
        1.5 * self$net_quantity(self$second_share)
      ExposureHedgeOrder$new(
        self$share,
        watched = list(
          ExposureWatch$new(self$share, exposure_per_unit = 1.0),
          ExposureWatch$new(self$second_share, exposure_per_unit = 1.5)
        ),
        lower_band = exposure - 100,
        upper_band = exposure + 100,
        product = "mis",
        hedge_exposure_per_unit = 1.0,
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
    #' Previews the hedge, starts it, prints it and cancels it.
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
  WeightedExposureHedge$new()$run()
}
