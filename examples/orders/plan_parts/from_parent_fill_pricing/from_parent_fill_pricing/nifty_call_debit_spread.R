#' Build a Nifty call debit spread whose second leg is priced from what the first leg filled at.
#'
#' The program finds the nearest weekly Nifty call closest to the index and the call about 200 points above it, and builds a Then join: a buy of one lot of the nearer call at its last price, and on each of its fills a sale of the further call priced so that the spread costs the difference between their last prices. UBI works the sale's price out from the buy's average fill. It prints the join's object as UBI would read it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/from_parent_fill_pricing/from_parent_fill_pricing/nifty_call_debit_spread.R

library(tradeR)

#' A Nifty call spread, bought near the money and sold about 200 points higher.
#'
#' @field bought_call The `EquityIndexOption` call nearest the index.
#' @field sold_call The `EquityIndexOption` call nearest 200 points above the index.
CallDebitSpread <- R6::R6Class(
  "CallDebitSpread",
  public = list(
    bought_call = NULL,
    sold_call = NULL,

    #' @description
    #' Looks up the index and the two calls.
    #' @return A new `CallDebitSpread` object.
    #' @details Errors: signals `ValueError` when UBI has no last price for the index, or no call on its nearest expiry; and `InstrumentError` when the index or an option could not be found in UBI.
    initialize = function() {
      index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      index_price <- index$last_price
      if (is.null(index_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", index$format())
        )
      }
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      chain <- EquityIndexOption$chain(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[1]
      )
      calls <- chain[chain$option_type == "CE", ]
      self$bought_call <- private$call_nearest(
        calls,
        index_price,
        expiries[1]
      )
      self$sold_call <- private$call_nearest(
        calls,
        index_price + 200,
        expiries[1]
      )
    },

    #' @description
    #' Prints the two calls, the net price and the join's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for one of the calls.
    run = function() {
      bought_price <- self$bought_call$last_price
      sold_price <- self$sold_call$last_price
      if (is.null(bought_price) || is.null(sold_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          "UBI has no last price for one of the calls"
        )
      }
      net_price <- round(bought_price - sold_price, 2)
      lot_size <- as.integer(self$bought_call$lot_size)
      part <- ThenPart$new(
        first = OrderPart$new(
          instrument = self$bought_call,
          transaction_type = "buy",
          quantity = lot_size,
          pricing = FixedPricing$new(
            price = bought_price,
            order_type = "LIMIT"
          )
        ),
        each_fill = OrderPart$new(
          instrument = self$sold_call,
          transaction_type = "sell",
          pricing = FromParentFillPricing$new(
            net_price = net_price
          )
        )
      )
      cat(
        sprintf(
          "Buy the %s call at %s\n",
          self$bought_call$strike_price,
          bought_price
        )
      )
      cat(
        sprintf(
          "Sell the %s call, last at %s\n",
          self$sold_call$strike_price,
          sold_price
        )
      )
      cat(sprintf("Net debit aimed at: %s\n", net_price))
      cat(
        jsonlite::toJSON(
          part$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  ),
  private = list(
    # @description
    # Looks up the call whose strike is nearest a price.
    # @param calls The `data.frame` of calls from the option chain.
    # @param price The numeric price the strike should be nearest.
    # @param expiry_date The `Date` the calls expire on.
    # @return The `EquityIndexOption` call nearest the price.
    # @details Errors: signals `ValueError` when the chain holds no calls; and `InstrumentError` when the option could not be found in UBI.
    call_nearest = function(calls, price, expiry_date) {
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in calls$strike_price) {
        distance <- abs(strike_price - price)
        if (is.null(nearest_distance) || distance < nearest_distance) {
          nearest_strike <- strike_price
          nearest_distance <- distance
        }
      }
      if (is.null(nearest_strike)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "UBI has no Nifty call expiring on %s",
            format(expiry_date)
          )
        )
      }
      EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date,
        strike_price = nearest_strike,
        option_type = "CE"
      )
    }
  )
)

if (sys.nframe() == 0) {
  CallDebitSpread$new()$run()
}
