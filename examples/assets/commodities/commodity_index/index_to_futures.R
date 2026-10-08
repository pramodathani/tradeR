#' Read a commodity index's level from its soonest future.
#'
#' An mcx commodity index has no quote of its own, but some of them have futures that do. The program goes through the mcx indices, and for each one with futures listed, prints the soonest contract's last price as the market's view of the index.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index/index_to_futures.R

library(tradeR)

#' The soonest future on each mcx commodity index that has one.
#'
#' @field exchange The character exchange to search, such as `"mcx"`.
CommodityIndexThroughFutures <- R6::R6Class(
  "CommodityIndexThroughFutures",
  public = list(
    exchange = NULL,

    #' @description
    #' Stores the exchange to search.
    #' @param exchange The character exchange, such as `"mcx"`.
    #' @return A new `CommodityIndexThroughFutures` object.
    initialize = function(exchange = "mcx") {
      self$exchange <- exchange
    },

    #' @description
    #' Goes through the indices and prints the soonest future on each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityIndexFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      matches <- CommodityIndex$search(
        exchange = self$exchange,
        term = "",
        limit = 200
      )
      if (is.null(matches)) {
        cat(sprintf("No commodity index on the %s.\n", self$exchange))
        return(invisible(NULL))
      }
      for (symbol in matches$symbol) {
        index <- CommodityIndex$new(exchange = self$exchange, symbol = symbol)
        expiries <- CommodityIndexFutures$expiries(
          exchange = self$exchange,
          underlying_symbol = index$symbol
        )
        if (length(expiries) == 0) {
          cat(sprintf("%s: no futures listed\n", symbol))
          next
        }
        contract <- CommodityIndexFutures$new(
          exchange = self$exchange,
          underlying_symbol = index$symbol,
          expiry_date = expiries[[1]],
          underlying = index
        )
        last_price <- contract$last_price
        if (is.null(last_price)) {
          last_price <- "NULL"
        }
        cat(
          sprintf(
            "%s: future expiring %s at %s\n",
            symbol,
            format(expiries[[1]]),
            last_price
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityIndexThroughFutures$new()$run()
}
