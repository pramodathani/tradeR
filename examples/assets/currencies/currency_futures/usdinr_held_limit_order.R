#' Bid for one lot of a dollar-rupee future well below the market, then cancel the bid.
#'
#' The program bids for one lot of the most traded of the six soonest USDINR futures, one per cent below its last price, which for a currency pair is far outside a day's move. The quantity is counted in dollars and must be a whole number of lots, so the program sends the exchange's lot of 1,000 dollars rather than the contract's `lot_size`, which for currencies is not the lot an order is measured against. UBI's order engine holds a plain day limit order until the offer comes down to its price, so the program cancels the parent at once.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_futures/usdinr_held_limit_order.R

library(tradeR)

#' One far-away bid for a currency future, held by the order engine and then cancelled.
#'
#' @field LOT_IN_DOLLARS The integer number of dollars in one lot of an nse USDINR future, which is what an order's quantity is counted against.
#' @field contract The `CurrencyFutures` the bid is for.
#' @field discount The numeric fraction below the last price at which to bid.
DollarRupeeHeldLimitOrder <- R6::R6Class(
  "DollarRupeeHeldLimitOrder",
  public = list(
    LOT_IN_DOLLARS = 1000,
    contract = NULL,
    discount = NULL,

    #' @description
    #' Builds the most traded of the soonest USDINR contracts.
    #' @param discount The numeric fraction below the last price at which to bid.
    #' @return A new `DollarRupeeHeldLimitOrder` object.
    #' @details Errors: signals `ValueError` when no USDINR futures are listed, and `CurrencyFuturesError` when UBI has no such contract.
    initialize = function(discount = 0.01) {
      expiries <- CurrencyFutures$expiries(
        exchange = "nse",
        underlying_symbol = "USDINR"
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise("ValueError", "No USDINR futures are listed")
      }
      best_contract <- NULL
      best_volume <- -1
      soonest_expiries <- head(expiries, 6)
      for (expiry_index in seq_along(soonest_expiries)) {
        contract <- CurrencyFutures$new(
          exchange = "nse",
          underlying_symbol = "USDINR",
          expiry_date = soonest_expiries[[expiry_index]]
        )
        volume <- contract$total_traded_volume
        if (is.null(volume)) {
          volume <- 0
        }
        if (volume > best_volume) {
          best_volume <- volume
          best_contract <- contract
        }
      }
      self$contract <- best_contract
      self$discount <- discount
    },

    #' @description
    #' Works out the bid price, rounded down to the contract's tick size.
    #' @return The numeric rate in rupees per dollar.
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
        sprintf("USDINR future expiring %s\n", format(contract$expiry_date))
      )
      cat(sprintf("Last price %s, bidding %s\n", contract$last_price, price))
      cat(
        sprintf("Quantity: one lot of %s dollars\n", self$LOT_IN_DOLLARS)
      )
      answer <- contract$buy_at_limit_price(
        price = price,
        quantity = self$LOT_IN_DOLLARS,
        product = "nrml",
        tag = "exampleusdinrbid"
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
  DollarRupeeHeldLimitOrder$new()$run()
}
