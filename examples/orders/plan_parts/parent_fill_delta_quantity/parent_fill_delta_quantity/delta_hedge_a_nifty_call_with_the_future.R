#' Build a delta hedge: buy a Nifty call near the money and hedge each fill with the Nifty future, sized by the call's delta.
#'
#' The program finds the soonest Nifty option expiry after today, the strike nearest the future's price, and the nearest Nifty future. The plan is meant to be placed on the call, because UBI works out the delta of the plan's own instrument: at each fill it takes the call's Black-76 delta at 13% volatility, with the future's last price as the forward, and sizes the hedge on the future to that delta times what filled, in whole lots. The hedge's side is `against_delta`, which sells the future against a bought call. It prints the call and the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/parent_fill_delta_quantity/parent_fill_delta_quantity/delta_hedge_a_nifty_call_with_the_future.R

library(tradeR)

#' A Nifty call bought and hedged with the Nifty future by its delta.
#'
#' @field volatility_percent The numeric volatility in percent the delta is worked out at.
DeltaHedgedCall <- R6::R6Class(
  "DeltaHedgedCall",
  public = list(
    volatility_percent = NULL,

    #' @description
    #' Sets the volatility.
    #' @return A new `DeltaHedgedCall` object.
    initialize = function() {
      self$volatility_percent <- 13.0
    },

    #' @description
    #' Chooses the first expiry after today.
    #' @param expiries A `Date` vector of expiries, soonest first.
    #' @return The `Date` of the chosen expiry.
    #' @details Errors: signals `ValueError` when no expiry is listed.
    soonest_after_today = function(expiries) {
      if (length(expiries) == 0) {
        ErrorCatalogue$raise("ValueError", "No Nifty expiry is listed")
      }
      today <- TimeConverter$new()$today()
      for (index in seq_along(expiries)) {
        expiry <- expiries[index]
        if (expiry > today) {
          return(expiry)
        }
      }
      expiries[1]
    },

    #' @description
    #' Finds the call and the future and prints the plan.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no expiry is listed or UBI has no price for the future, and `InstrumentError` when UBI has no such contract.
    run = function() {
      future <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = self$soonest_after_today(
          EquityIndexFutures$expiries(
            exchange = "nse",
            underlying_symbol = "NIFTY"
          )
        )
      )
      forward <- future$last_price
      if (is.null(forward)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", future$format())
        )
      }
      option_expiry <- self$soonest_after_today(
        EquityIndexOption$expiries(
          exchange = "nse",
          underlying_symbol = "NIFTY"
        )
      )
      strikes <- EquityIndexOption$strikes(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = option_expiry
      )
      nearest_strike <- strikes[1]
      for (strike in strikes) {
        if (abs(strike - forward) < abs(nearest_strike - forward)) {
          nearest_strike <- strike
        }
      }
      call <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = option_expiry,
        strike_price = nearest_strike,
        option_type = "CE",
        underlying = future
      )
      plan <- ThenPart$new(
        first = OrderPart$new(
          pricing = MarketablePricing$new()
        ),
        each_fill = OrderPart$new(
          instrument = future,
          side = "against_delta",
          product = "nrml",
          pricing = MarketablePricing$new(),
          quantity = ParentFillDeltaQuantity$new(
            volatility = self$volatility_percent,
            whole_lots = TRUE
          )
        )
      )
      cat(
        sprintf(
          "Place the plan on the NIFTY %s %s expiring %s, instrument %s, with the future at %s\n",
          call$strike_price,
          call$option_type,
          format(call$expiry_date),
          call$instrument_id,
          forward
        )
      )
      cat(
        jsonlite::toJSON(
          plan$document(),
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
  DeltaHedgedCall$new()$run()
}
