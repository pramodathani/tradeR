#' Build a NIFTY calendar spread legged in, the far month sold for whatever the near month has bought.
#'
#' The program finds the two nearest NIFTY futures contracts and builds a then join: a buy of two lots of the near month two ticks past the offer, followed under `each_fill` by a sell of the next month on the same terms. The second leg uses `TopUpExecution`, as UBI's `attached_hedge` and `legged_spread` presets do, so each fill of the first sends a new sell for what is missing rather than resizing one resting order. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/top_up_execution/top_up_execution/calendar_spread_legged_in.R

library(tradeR)

#' A near-month NIFTY buy whose far-month sell is topped up with each fill.
#'
#' @field near_month The `EquityIndexFutures` for the nearest NIFTY future.
#' @field far_month The `EquityIndexFutures` for the next NIFTY future.
LeggedCalendarSpread <- R6::R6Class(
  "LeggedCalendarSpread",
  public = list(
    near_month = NULL,
    far_month = NULL,

    #' @description
    #' Finds the two nearest contracts.
    #' @return A new `LeggedCalendarSpread` object.
    #' @details Errors: signals `InstrumentError` when a contract could not be found in UBI.
    initialize = function() {
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      self$near_month <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[1]
      )
      self$far_month <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[2]
      )
    },

    #' @description
    #' Prints the join's object.
    #' @return `NULL`, invisibly.
    run = function() {
      lot_size <- as.integer(self$near_month$lot_size)
      join <- ThenPart$new(
        first = OrderPart$new(
          instrument = self$near_month,
          transaction_type = "buy",
          quantity = 2 * lot_size,
          product = "nrml",
          pricing = MarketablePricing$new(buffer_ticks = 2)
        ),
        each_fill = OrderPart$new(
          instrument = self$far_month,
          transaction_type = "sell",
          product = "nrml",
          pricing = MarketablePricing$new(buffer_ticks = 2),
          execution = TopUpExecution$new()
        )
      )
      cat(
        sprintf(
          "Buying the %s future, selling the %s future\n",
          format(self$near_month$expiry_date),
          format(self$far_month$expiry_date)
        )
      )
      cat(
        jsonlite::toJSON(
          join$document(),
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
  LeggedCalendarSpread$new()$run()
}
