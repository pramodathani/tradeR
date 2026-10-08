#' Build an accumulation: a buy of Vodafone Idea every half hour, six times, stopped if the price runs 3% higher.
#'
#' The program reads the share's last price and repeats one marketable buy of 500 shares every 30 minutes, the first at once. The `until` condition ends every copy still waiting once the price rises 3% above today's level, while copies already sent are left as they are. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/repeat_part/repeat_part/accumulate_every_half_hour.R

library(tradeR)

#' Six buys half an hour apart, ended early by a rally.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
#' @field purchases The integer number of buys.
#' @field minutes_apart The numeric minutes between buys.
HalfHourlyAccumulation <- R6::R6Class(
  "HalfHourlyAccumulation",
  public = list(
    share = NULL,
    purchases = NULL,
    minutes_apart = NULL,

    #' @description
    #' Looks the share up and sets the schedule.
    #' @return A new `HalfHourlyAccumulation` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      self$purchases <- 6L
      self$minutes_apart <- 30.0
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
      stop_buying_level <- round(last_price * 1.03, 2)
      plan <- RepeatPart$new(
        child = OrderPart$new(
          quantity = 500,
          pricing = MarketablePricing$new(buffer_ticks = 2)
        ),
        times = self$purchases,
        every_minutes = self$minutes_apart,
        until = PriceCrosses$new(
          level = stop_buying_level,
          direction = "at_or_above"
        )
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
  HalfHourlyAccumulation$new()$run()
}
