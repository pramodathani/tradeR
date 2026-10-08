#' Build an offer for a Nifty put priced at a chosen implied volatility, using the nearest Nifty future as the forward.
#'
#' The program finds the nearest Nifty future and the put on the nearest weekly expiry closest to its price, and builds a plan order whose template is a limit sell of one lot at the put's last price, the least it will take, with an order that UBI prices at 15% implied volatility from the future, which needs no interest rate because a future is already the forward. The premium is kept between half and twice the last price and moved in steps of two ticks. It prints the plan's synthetic object. The plan order is only built; nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/option_model_pricing/option_model_pricing/put_offer_priced_off_the_future.R

library(tradeR)

#' An offer for the at-the-money Nifty put priced at 15% implied volatility off the future.
#'
#' @field future The `EquityIndexFutures` for the nearest Nifty future.
#' @field option The `EquityIndexOption` put nearest the future's price on the nearest expiry.
PutOfferOffTheFuture <- R6::R6Class(
  "PutOfferOffTheFuture",
  public = list(
    future = NULL,
    option = NULL,

    #' @description
    #' Looks up the future and the put nearest to it.
    #' @return A new `PutOfferOffTheFuture` object.
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
      puts <- chain[chain$option_type == "PE", ]
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in puts$strike_price) {
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
        transaction_type = "sell",
        product = "nrml",
        order_type = "limit",
        quantity = as.integer(self$option$lot_size),
        price = option_price,
        plan = OrderPart$new(
          pricing = OptionModelPricing$new(
            instrument = self$future,
            volatility = 15.0,
            lowest = round(option_price * 0.5, 1),
            highest = round(option_price * 2, 1),
            step_ticks = 2
          )
        )
      )
      cat(
        sprintf(
          "Future expiring %s at %s\n",
          format(self$future$expiry_date),
          format(self$future$last_price)
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
  PutOfferOffTheFuture$new()$run()
}
