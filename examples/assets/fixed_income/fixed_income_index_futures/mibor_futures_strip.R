#' Print the strip of overnight MIBOR futures, one line per expiry.
#'
#' The program lists every live futures contract on the overnight MIBOR index on the nse and prints each one's last price and the days it has left, which together show where the market expects the overnight rate to go.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index_futures/mibor_futures_strip.R

library(tradeR)

#' The live futures on one fixed income index, soonest first.
#'
#' @field exchange The character exchange the futures trade on, such as `"nse"`.
#' @field underlying_symbol The character symbol of the index, such as `"ONMIBOR"`.
MiborFuturesStrip <- R6::R6Class(
  "MiborFuturesStrip",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Stores the index whose futures to list.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `MiborFuturesStrip` object.
    initialize = function(exchange = "nse", underlying_symbol = "ONMIBOR") {
      self$exchange <- exchange
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Builds each live contract and prints its line.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeIndexFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- FixedIncomeIndexFutures$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No futures are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        contract <- FixedIncomeIndexFutures$new(
          exchange = self$exchange,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        )
        last_price <- contract$last_price
        if (is.null(last_price)) {
          last_price <- "NULL"
        }
        cat(
          sprintf(
            "%s: last %s, %s days left, %s expiry\n",
            format(expiry_date),
            last_price,
            contract$days_to_expiry,
            contract$expiry_kind
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MiborFuturesStrip$new()$run()
}
