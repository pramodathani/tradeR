#' Go from a few commodities to the price of the soonest future on each.
#'
#' A commodity has no price of its own, so the way to see where it trades is its nearest future. The program builds each commodity, lists the futures expiries written on it, and prints the soonest contract's last price and lot size.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity/commodity_to_futures.R

library(tradeR)

#' The soonest future on each of a few mcx commodities.
#'
#' @field symbols A character vector of the mcx commodity symbols to report on.
CommodityNearestFutures <- R6::R6Class(
  "CommodityNearestFutures",
  public = list(
    symbols = NULL,

    #' @description
    #' Stores the commodities to report on.
    #' @return A new `CommodityNearestFutures` object.
    initialize = function() {
      self$symbols <- c(
        "GOLDM",
        "SILVERM",
        "CRUDEOILM",
        "NATGASMINI"
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      as.character(value)
    },

    #' @description
    #' Builds each commodity and prints its soonest future.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityError` when a commodity is not in UBI; `CommodityFuturesError` when a listed contract could not be built; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (symbol in self$symbols) {
        commodity <- Commodity$new(exchange = "mcx", symbol = symbol)
        expiries <- CommodityFutures$expiries(
          exchange = "mcx",
          underlying_symbol = commodity$symbol
        )
        if (length(expiries) == 0) {
          cat(sprintf("%s: no futures listed\n", symbol))
          next
        }
        contract <- CommodityFutures$new(
          exchange = "mcx",
          underlying_symbol = commodity$symbol,
          expiry_date = expiries[[1]]
        )
        cat(
          sprintf(
            "%s: %d expiries, soonest %s at %s, lot %s\n",
            symbol,
            length(expiries),
            format(expiries[[1]]),
            self$display_text(contract$last_price),
            self$display_text(contract$lot_size)
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityNearestFutures$new()$run()
}
