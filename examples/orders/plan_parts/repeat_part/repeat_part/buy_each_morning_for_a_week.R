#' Build a weekly buying programme: a delivery buy of Vodafone Idea at twenty past nine on each of the next five trading days.
#'
#' With `every_trading_day_at`, UBI sends each copy at that time on its own trading day, skipping weekends and holidays, and keeps the plan across days; the first copy goes today if the time has not passed and the day trades. Each copy is a limit order 1% below the last price read now, so a copy that does not fill is left resting until the day ends. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/repeat_part/repeat_part/buy_each_morning_for_a_week.R

library(tradeR)

#' Five delivery buys, one each trading morning.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field trading_days The integer number of mornings.
#' @field send_time The character time of day each buy is sent.
MorningBuys <- R6::R6Class(
  "MorningBuys",
  public = list(
    share = NULL,
    trading_days = NULL,
    send_time = NULL,

    #' @description
    #' Looks the share up and sets the schedule.
    #' @return A new `MorningBuys` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$trading_days <- 5L
      self$send_time <- "09:20"
    },

    #' @description
    #' Prints the plan.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      limit_price <- round(last_price * 0.99, 2)
      plan <- RepeatPart$new(
        child = OrderPart$new(
          quantity = 200,
          product = "cnc",
          pricing = FixedPricing$new(
            price = limit_price,
            order_type = "LIMIT"
          )
        ),
        times = self$trading_days,
        every_trading_day_at = self$send_time
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
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
  MorningBuys$new()$run()
}
