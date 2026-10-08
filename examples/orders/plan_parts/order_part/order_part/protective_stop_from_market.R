#' Build an order that protects a long position with a stop resting at the broker, priced from the market.
#'
#' The program reads Vodafone Idea's last price, sets a stop 3% below it with its limit one tick lower, and builds an order whose side is `protect`, so it sells against the long position the template's buy opened. It prints the order object UBI would read. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/order_part/order_part/protective_stop_from_market.R

library(tradeR)

#' A protecting order with a native stop 3% below the market.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
ProtectiveStop <- R6::R6Class(
  "ProtectiveStop",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share.
    #' @return A new `ProtectiveStop` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Works out the stop's trigger 3% below the last price, and its limit one tick below that.
    #' @return A named numeric vector with `trigger_price` and `limit_price` in rupees, rounded to the tick size.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    stop_prices = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      tick_size <- 0.05
      if (!is.null(self$share$tick_size)) {
        tick_size <- as.numeric(self$share$tick_size)
      }
      trigger_ticks <- round(last_price * 0.97 / tick_size)
      trigger_price <- round(trigger_ticks * tick_size, 2)
      limit_price <- round((trigger_ticks - 1) * tick_size, 2)
      c(
        trigger_price = trigger_price,
        limit_price = limit_price
      )
    },

    #' @description
    #' Prints the last price and the protecting order's object.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      prices <- self$stop_prices()
      part <- OrderPart$new(
        side = "protect",
        pricing = NativeStopPricing$new(
          trigger_price = prices[["trigger_price"]],
          limit_price = prices[["limit_price"]]
        )
      )
      cat(
        sprintf(
          "Last price of %s: %s\n",
          self$share$symbol,
          format(self$share$last_price)
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
  ProtectiveStop$new()$run()
}
