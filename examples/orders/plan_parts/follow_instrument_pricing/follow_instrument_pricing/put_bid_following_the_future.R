#' Build a bid for a Nifty put whose price follows the nearest Nifty future, falling as the future rises.
#'
#' The program finds the nearest Nifty future and the put on the nearest weekly expiry closest to the future's price, and builds a plan order whose template is a limit buy of one lot at the put's last price, with an order that moves that price by minus 0.45 times every move in the future, only in steps of two ticks. It prints the plan's synthetic object. The plan order is only built; nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/follow_instrument_pricing/follow_instrument_pricing/put_bid_following_the_future.R

library(tradeR)

#' A bid for the at-the-money Nifty put that follows the nearest Nifty future.
#'
#' @field future The `EquityIndexFutures` for the nearest Nifty future.
#' @field option The `EquityIndexOption` put nearest the future's price on the nearest expiry.
PutBidFollowingTheFuture <- R6::R6Class(
  "PutBidFollowingTheFuture",
  public = list(
    future = NULL,
    option = NULL,

    #' @description
    #' Looks up the future and the put nearest to it.
    #' @return A new `PutBidFollowingTheFuture` object.
    #' @details Errors: signals `ValueError` when UBI has no last price for the future, or no put on the nearest expiry; and `InstrumentError` when the future or the option could not be found in UBI.
    initialize = function() {
      future_expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      self$future <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = future_expiries[1]
      )
      future_price <- self$future$last_price
      if (is.null(future_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$future$format())
        )
      }
      option_expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      chain <- EquityIndexOption$chain(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = option_expiries[1]
      )
      strike_prices <- numeric(0)
      if (!is.null(chain)) {
        puts <- chain[chain$option_type == "PE", ]
        strike_prices <- puts$strike_price
      }
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in strike_prices) {
        distance <- abs(strike_price - future_price)
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
            format(option_expiries[1])
          )
        )
      }
      self$option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = option_expiries[1],
        strike_price = nearest_strike,
        option_type = "PE"
      )
    },

    #' @description
    #' Prints the future, the put and the plan's synthetic object.
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
            instrument = self$future,
            delta = -0.45,
            step_ticks = 2
          )
        )
      )
      cat(
        sprintf(
          "Future expiring %s at %s\n",
          format(self$future$expiry_date),
          self$future$last_price
        )
      )
      cat(
        sprintf(
          "Put %s expiring %s, last price %s\n",
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
  PutBidFollowingTheFuture$new()$run()
}
