#' Look up the order engine's stored answer to an order by its intent id.
#'
#' The program asks UBI's order engine to hold a buy limit order for one Vodafone Idea share about 3% below the last price, which does not fill, reads the engine's stored answer to that placement back through `Account$intent()`, and cancels the held order before it ends, whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/accounts/account/account/order_intent_lookup.R

library(tradeR)

#' A placement whose outcome is read back from the engine by its intent id.
#'
#' @field trading_account The `Account` the intent is read through.
#' @field idea The `Equity` for Vodafone Idea on the NSE, which the order is placed in.
OrderIntentLookup <- R6::R6Class(
  "OrderIntentLookup",
  public = list(
    trading_account = NULL,
    idea = NULL,

    #' @description
    #' Creates the account and looks the share up in UBI.
    #' @return A new `OrderIntentLookup` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share.
    initialize = function() {
      self$trading_account <- Account$new()
      self$idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Works out a buy price about 3% below the last price, on the tick.
    #' @return The numeric limit price in rupees, rounded to the 0.01 tick.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not give the last price.
    limit_price = function() {
      round(self$idea$last_price * 0.97, 2)
    },

    #' @description
    #' Places the held order, prints the engine's stored answer, and cancels the order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      price <- self$limit_price()
      answer <- self$idea$buy_at_limit_price(
        price = price,
        quantity = 1,
        product = "mis"
      )
      cat(
        sprintf(
          "Placed: outcome %s, parent %s\n",
          answer[["outcome"]],
          answer[["parent_id"]]
        )
      )
      tryCatch(
        {
          engine_answer <- self$trading_account$intent(answer[["intent_id"]])
          response <- engine_answer[["response"]]
          cat(sprintf("Intent %s\n", engine_answer[["intent_id"]]))
          cat(sprintf("Stored HTTP status: %s\n", engine_answer[["status"]]))
          cat(sprintf("Stored outcome: %s\n", response[["outcome"]]))
          cat(sprintf("Stored parent id: %s\n", response[["parent_id"]]))
        },
        finally = {
          cancelled <- self$idea$cancel_parent(answer[["parent_id"]])
          cat(
            sprintf("Cancelled: the parent is now %s\n", cancelled[["state"]])
          )
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OrderIntentLookup$new()$run()
}
