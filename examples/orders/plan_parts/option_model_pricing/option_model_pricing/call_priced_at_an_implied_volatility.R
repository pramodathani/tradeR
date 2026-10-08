#' Build a bid for a Nifty call priced at a chosen implied volatility off the index.
#'
#' The program finds the nearest weekly Nifty call closest to the index and builds a plan order whose template is a limit buy of one lot at the call's last price, the most it will pay, with an order that UBI prices from the Black-76 model at 13% implied volatility, growing the index at 6.5% a year to expiry, and re-prices as the index moves. It prints the plan's synthetic object. The plan order is only built; nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/option_model_pricing/option_model_pricing/call_priced_at_an_implied_volatility.R

library(tradeR)

#' A bid for the at-the-money Nifty call priced at 13% implied volatility.
#'
#' @field index The `EquityIndex` for the Nifty 50 on the NSE.
#' @field option The `EquityIndexOption` call nearest the index on the nearest expiry.
CallAtAnImpliedVolatility <- R6::R6Class(
  "CallAtAnImpliedVolatility",
  public = list(
    index = NULL,
    option = NULL,

    #' @description
    #' Looks up the index and the call nearest to it.
    #' @return A new `CallAtAnImpliedVolatility` object.
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
      calls <- chain[chain$option_type == "CE", ]
      nearest_strike <- NULL
      nearest_distance <- NULL
      for (strike_price in calls$strike_price) {
        distance <- abs(strike_price - index_price)
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
            format(expiries[1])
          )
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
    #' Prints the call and the plan's synthetic object.
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
          pricing = OptionModelPricing$new(
            instrument = self$index,
            volatility = 13.0,
            interest_rate = 6.5
          )
        )
      )
      cat(sprintf("Index at %s\n", format(self$index$last_price)))
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
  CallAtAnImpliedVolatility$new()$run()
}
