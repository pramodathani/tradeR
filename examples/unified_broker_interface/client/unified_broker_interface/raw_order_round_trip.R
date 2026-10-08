#' Place, change and cancel an order with the client's raw POST, PUT and DELETE calls.
#'
#' The program reads Vodafone Idea's last price with a GET request, asks UBI's order engine with a POST request to hold a buy limit order for one share about 3% below it, lowers the price by five paise with a PUT request, and cancels the held order with a DELETE request. The cancellation runs whatever happens after the order is placed, so nothing is left behind.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/client/unified_broker_interface/raw_order_round_trip.R

library(tradeR)

#' One held limit order placed, changed and cancelled through raw REST calls.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the requests are sent through.
RawOrderRoundTrip <- R6::R6Class(
  "RawOrderRoundTrip",
  public = list(
    unified_broker_interface = NULL,

    #' @description
    #' Creates the client, which reads its api key and secret from MongoDB.
    #' @return A new `RawOrderRoundTrip` object.
    #' @details Errors: signals a plain error when the base url or the MongoDB settings are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
    },

    #' @description
    #' Reads Vodafone Idea's last price and instrument id.
    #' @return The named list UBI answers from `GET /api/instruments/ltp`, holding `instrument_id` and `last_price`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    last_price = function() {
      self$unified_broker_interface$get(
        "/api/instruments/ltp",
        params = list(
          exchange = "nse",
          segment = "equities",
          symbol = "IDEA"
        )
      )
    },

    #' @description
    #' Asks the order engine to hold a buy limit order for one share.
    #' @param instrument_id The character UBI instrument id of the share.
    #' @param price The numeric limit price in rupees.
    #' @return The named list UBI answers, holding `outcome`, `parent_id` and `intent_id`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the order or could not be reached.
    place = function(instrument_id, price) {
      self$unified_broker_interface$post(
        "/api/orders/place",
        body = list(
          instrument_id = instrument_id,
          transaction_type = "buy",
          order_type = "limit",
          product = "mis",
          quantity = 1,
          price = price,
          after_market = FALSE,
          dry_run = FALSE
        )
      )
    },

    #' @description
    #' Places the order, changes its price, and cancels it whatever happens after it was placed.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      quote <- self$last_price()
      price <- round(quote[["last_price"]] * 0.97, 2)
      cat(
        sprintf(
          "IDEA last price %s, buying at %s\n",
          quote[["last_price"]],
          price
        )
      )
      placed <- self$place(quote[["instrument_id"]], price)
      parent_id <- placed[["parent_id"]]
      cat(
        sprintf(
          "POST:   outcome %s, parent %s\n",
          placed[["outcome"]],
          parent_id
        )
      )
      tryCatch(
        {
          changed <- self$unified_broker_interface$put(
            "/api/orders/modify",
            body = list(
              parent_id = parent_id,
              price = round(price - 0.05, 2)
            )
          )
          cat(
            sprintf(
              "PUT:    outcome %s, new price %s\n",
              changed[["outcome"]],
              changed[["price"]]
            )
          )
        },
        finally = {
          cancelled <- self$unified_broker_interface$delete(
            "/api/orders/parents",
            body = list(
              parent_id = parent_id
            )
          )
          cat(sprintf("DELETE: the parent is now %s\n", cancelled[["state"]]))
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RawOrderRoundTrip$new()$run()
}
