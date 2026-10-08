#' Bid for one lot of mini gold well below the market, then cancel the bid.
#'
#' The program bids for one lot of the soonest GOLDM future three per cent below its last price. A commodity quantity is counted in quotation units and must be a whole number of lots, so the program sends the contract's lot size as the quantity. UBI's order engine holds a plain day limit order until the offer comes down to its price, so the program reads back the parent it holds and cancels it at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_futures/mini_gold_held_limit_order.R

library(tradeR)

#' One far-away bid for a commodity future, held by the order engine and then cancelled.
#'
#' @field contract The `CommodityFutures` the bid is for.
#' @field discount The numeric fraction below the last price at which to bid.
MiniGoldHeldLimitOrder <- R6::R6Class(
  "MiniGoldHeldLimitOrder",
  public = list(
    contract = NULL,
    discount = NULL,

    #' @description
    #' Builds the contract with the soonest expiry.
    #' @param underlying_symbol The character mcx symbol of the commodity, such as `"GOLDM"`.
    #' @param discount The numeric fraction below the last price at which to bid.
    #' @return A new `MiniGoldHeldLimitOrder` object.
    #' @details Errors: signals `ValueError` when no futures are listed on the commodity, and `CommodityFuturesError` when UBI has no such contract.
    initialize = function(underlying_symbol = "GOLDM", discount = 0.03) {
      expiries <- CommodityFutures$expiries(
        exchange = "mcx",
        underlying_symbol = underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", underlying_symbol)
        )
      }
      self$contract <- CommodityFutures$new(
        exchange = "mcx",
        underlying_symbol = underlying_symbol,
        expiry_date = expiries[[1]]
      )
      self$discount <- discount
    },

    #' @description
    #' Works out the bid price, rounded down to the contract's tick size.
    #' @return The numeric price in rupees.
    #' @details Errors: signals `ServiceUnavailableError` when UBI has no quote for the contract.
    bid_price = function() {
      tick_size <- as.numeric(self$contract$tick_size)
      target <- self$contract$last_price * (1 - self$discount)
      ticks <- trunc(target / tick_size)
      round(ticks * tick_size, 4)
    },

    #' @description
    #' Places the bid for one lot, prints the engine's answer and cancels it whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$contract
      price <- self$bid_price()
      cat(
        sprintf(
          "%s %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Last price %s, bidding %s\n", contract$last_price, price))
      cat(sprintf("Quantity: one lot of %s units\n", contract$lot_size))
      answer <- contract$buy_at_limit_price(
        price = price,
        quantity = contract$lot_size,
        product = "nrml",
        tag = "examplegoldbid"
      )
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          parent_text <- parent_id
          if (is.null(parent_text)) {
            parent_text <- "NULL"
          }
          cat(
            sprintf(
              "Outcome: %s, parent id: %s\n",
              answer[["outcome"]],
              parent_text
            )
          )
          if (!is.null(parent_id)) {
            parent <- contract$parent(parent_id)
            cat(sprintf("The engine holds it in state %s\n", parent[["state"]]))
          }
        },
        finally = {
          if (!is.null(parent_id)) {
            cancelled <- contract$cancel_parent(parent_id)
            cat(sprintf("After cancelling: %s\n", cancelled[["state"]]))
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MiniGoldHeldLimitOrder$new()$run()
}
