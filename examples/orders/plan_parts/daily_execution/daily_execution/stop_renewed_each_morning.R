#' Build a protective stop for a Vodafone Idea holding that is sent again every trading morning for a week.
#'
#' A native stop dies at the close, so a position held for days needs a new one each morning. The program reads Vodafone Idea's last price and builds a protecting stop 5% below it, sent by `DailyExecution` at UBI's default time of 09:20 and ended after five days by a lifetime in `after_days`. Once the stop trades no more is sent. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/daily_execution/daily_execution/stop_renewed_each_morning.R

library(tradeR)

#' A stop for a Vodafone Idea holding renewed every morning for five days.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
DailyRenewedStop <- R6::R6Class(
  "DailyRenewedStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `DailyRenewedStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the stop's object.
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
      tick_size <- 0.01
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      trigger_price <- round(last_price * 0.95, 2)
      limit_price <- round(trigger_price - 5 * tick_size, 2)
      part <- OrderPart$new(
        side = "protect",
        product = "cnc",
        pricing = NativeStopPricing$new(
          trigger_price = trigger_price,
          limit_price = limit_price
        ),
        execution = DailyExecution$new(),
        lifetime = Lifetime$new(after_days = 5)
      )
      cat(
        sprintf(
          "Last price of %s: %s; stop at %s\n",
          self$share$symbol,
          last_price,
          trigger_price
        )
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
  )
)

if (sys.nframe() == 0) {
  DailyRenewedStop$new()$run()
}
