#' Build a bid for a Nifty call whose price follows the index rather than the option's own thin book.
#'
#' The program finds the nearest weekly Nifty call closest to the index, and builds a plan order whose template is a limit buy of one lot at the call's last price, with an order that moves that price by half of every move in the index and keeps it within 20% of where it started. It prints the plan's synthetic object. The plan order is only built; nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/follow_instrument_pricing/follow_instrument_pricing/call_bid_following_the_index.R

library(tradeR)

#' A bid for the at-the-money Nifty call that follows the index with a delta of one half.
#'
#' @field index The `EquityIndex` for the Nifty 50 on the NSE.
#' @field option The `EquityIndexOption` call nearest the index on the nearest expiry.
CallBidFollowingTheIndex <- R6::R6Class(
  "CallBidFollowingTheIndex",
  public = list(
    index = NULL,
    option = NULL,

    #' @description
    #' Looks up the index and the call nearest to it.
    #' @return A new `CallBidFollowingTheIndex` object.
    #' @details Errors: signals `ValueError` when UBI has no last price for the index, or no call on its nearest expiry; and `InstrumentError` when the index or the option could not be found in UBI.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      index_price <- self$index$last_price
      if (is.null(index_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$index$format())
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
      strike_prices <- numeric(0)
      if (!is.null(chain)) {
        calls <- chain[chain$option_type == "CE", ]
        strike_prices <- calls$strike_price
      }
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in strike_prices) {
        distance <- abs(strike_price - index_price)
        if (is.null(nearest_distance) || distance < nearest_distance) {
          nearest_strike <- strike_price
          nearest_distance <- distance
        }
      }
      if (is.null(nearest_strike)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no Nifty call expiring on %s", format(expiries[1]))
        )
      }
      self$option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[1],
        strike_price = nearest_strike,
        option_type = "CE",
        underlying = self$index
      )
    },

    #' @description
    #' Prints the call, its price bounds and the plan's synthetic object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the option.
    run = function() {
      option_price <- self$option$last_price
      if (is.null(option_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$option$format())
        )
      }
      order <- PlanOrder$new(
        self$option,
        transaction_type = "buy",
        product = "nrml",
        order_type = "limit",
        quantity = as.integer(self$option$lot_size),
        price = option_price,
        plan = OrderPart$new(
          pricing = FollowInstrumentPricing$new(
            instrument = self$index,
            delta = 0.5,
            lowest = round(option_price * 0.8, 1),
            highest = round(option_price * 1.2, 1)
          )
        )
      )
      cat(sprintf("Index at %s\n", self$index$last_price))
      cat(
        sprintf(
          "Call %s expiring %s, last price %s\n",
          self$option$strike_price,
          format(self$option$expiry_date),
          option_price
        )
      )
      cat(
        jsonlite::toJSON(
          order$synthetic,
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
  )
)

if (sys.nframe() == 0) {
  CallBidFollowingTheIndex$new()$run()
}
