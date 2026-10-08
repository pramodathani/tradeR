#' Print every live commodity index future on the mcx, grouped by index.
#'
#' The program lists the live contracts in the mcx commodity index futures segment and prints, for each index, the last price of each expiry, soonest first.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index_futures/index_futures_curve.R

library(tradeR)

#' The live futures on every commodity index on one exchange.
#'
#' @field exchange The character exchange to list, such as `"mcx"`.
CommodityIndexFuturesCurve <- R6::R6Class(
  "CommodityIndexFuturesCurve",
  public = list(
    exchange = NULL,

    #' @description
    #' Stores the exchange to list.
    #' @param exchange The character exchange, such as `"mcx"`.
    #' @return A new `CommodityIndexFuturesCurve` object.
    initialize = function(exchange = "mcx") {
      self$exchange <- exchange
    },

    #' @description
    #' Lists the contracts and prints them index by index.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityIndexFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      rows <- CommodityIndexFutures$contracts(exchange = self$exchange)
      if (is.null(rows)) {
        cat(sprintf("No commodity index futures on the %s.\n", self$exchange))
        return(invisible(NULL))
      }
      sort_order <- order(rows$underlying_symbol, rows$expiry_date)
      rows <- rows[sort_order, , drop = FALSE]
      current_symbol <- NULL
      for (row_index in seq_len(nrow(rows))) {
        underlying_symbol <- rows$underlying_symbol[[row_index]]
        if (is.null(current_symbol) || underlying_symbol != current_symbol) {
          current_symbol <- underlying_symbol
          cat(current_symbol, "\n", sep = "")
        }
        contract <- CommodityIndexFutures$new(
          exchange = self$exchange,
          underlying_symbol = underlying_symbol,
          expiry_date = rows$expiry_date[[row_index]]
        )
        last_price <- contract$last_price
        if (is.null(last_price)) {
          last_price <- "NULL"
        }
        cat(
          sprintf(
            "    %s: %s\n",
            format(contract$expiry_date),
            last_price
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityIndexFuturesCurve$new()$run()
}
