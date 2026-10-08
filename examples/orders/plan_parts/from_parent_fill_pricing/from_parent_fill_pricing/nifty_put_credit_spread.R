#' Build a Nifty put credit spread, selling first and buying the protection at whatever price keeps the credit.
#'
#' The program finds the nearest weekly Nifty put closest to the index and the put about 200 points below it, and builds a Then join: a sale of one lot of the nearer put at its last price, and on each of its fills a buy of the further put priced so that the two legs bring in the difference between their last prices. The net price is negative because the spread is a credit. It prints the join's object as UBI would read it. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/from_parent_fill_pricing/from_parent_fill_pricing/nifty_put_credit_spread.R

library(tradeR)

#' A Nifty put spread, sold near the money and bought about 200 points lower.
#'
#' @field sold_put The `EquityIndexOption` put nearest the index.
#' @field bought_put The `EquityIndexOption` put nearest 200 points below the index.
PutCreditSpread <- R6::R6Class(
  "PutCreditSpread",
  public = list(
    sold_put = NULL,
    bought_put = NULL,

    #' @description
    #' Looks up the index and the two puts.
    #' @return A new `PutCreditSpread` object.
    #' @details Errors: signals `ValueError` when UBI has no last price for the index, or no put on its nearest expiry; and `InstrumentError` when the index or an option could not be found in UBI.
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
      puts <- chain[chain$option_type == "PE", ]
      self$sold_put <- private$put_nearest(
        puts,
        index_price,
        expiries[1]
      )
      self$bought_put <- private$put_nearest(
        puts,
        index_price - 200,
        expiries[1]
      )
    },

    #' @description
    #' Prints the two puts, the net price and the join's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for one of the puts.
    run = function() {
      sold_price <- self$sold_put$last_price
      bought_price <- self$bought_put$last_price
      if (is.null(sold_price) || is.null(bought_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          "UBI has no last price for one of the puts"
        )
      }
      net_price <- round(bought_price - sold_price, 2)
      lot_size <- as.integer(self$sold_put$lot_size)
      part <- ThenPart$new(
        first = OrderPart$new(
          instrument = self$sold_put,
          transaction_type = "sell",
          quantity = lot_size,
          pricing = FixedPricing$new(
            price = sold_price,
            order_type = "LIMIT"
          )
        ),
        each_fill = OrderPart$new(
          instrument = self$bought_put,
          transaction_type = "buy",
          pricing = FromParentFillPricing$new(
            net_price = net_price
          )
        )
      )
      cat(
        sprintf(
          "Sell the %s put at %s\n",
          self$sold_put$strike_price,
          sold_price
        )
      )
      cat(
        sprintf(
          "Buy the %s put, last at %s\n",
          self$bought_put$strike_price,
          bought_price
        )
      )
      cat(
        sprintf("Net price aimed at, negative for a credit: %s\n", net_price)
      )
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
    # Looks up the put whose strike is nearest a price.
    # @param puts The `data.frame` of puts from the option chain.
    # @param price The numeric price the strike should be nearest.
    # @param expiry_date The `Date` the puts expire on.
    # @return The `EquityIndexOption` put nearest the price.
    # @details Errors: signals `ValueError` when the chain holds no puts; and `InstrumentError` when the option could not be found in UBI.
    put_nearest = function(puts, price, expiry_date) {
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in puts$strike_price) {
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
            "UBI has no Nifty put expiring on %s",
            format(expiry_date)
          )
        )
      }
      EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date,
        strike_price = nearest_strike,
        option_type = "PE"
      )
    }
  )
)

if (sys.nframe() == 0) {
  PutCreditSpread$new()$run()
}
