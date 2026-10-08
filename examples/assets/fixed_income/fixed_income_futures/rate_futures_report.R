#' Print the price of the soonest interest rate future on each underlying on the nse.
#'
#' The program lists the live contracts in the nse's fixed income futures segment, keeps the soonest contract on each underlying, builds it from its row, and prints its last price, or says that no broker quotes it, its lot size and the days it has left. Keeping one contract per underlying keeps the number of quote requests small, because the brokers behind UBI limit how fast quotes can be read.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_futures/rate_futures_report.R

library(tradeR)

#' The live interest rate futures contracts on one exchange.
#'
#' @field exchange The character exchange to list, such as `"nse"`.
RateFuturesReport <- R6::R6Class(
  "RateFuturesReport",
  public = list(
    exchange = NULL,

    #' @description
    #' Stores the exchange to list.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @return A new `RateFuturesReport` object.
    initialize = function(exchange = "nse") {
      self$exchange <- exchange
    },

    #' @description
    #' Lists the contracts and prints one line for the soonest on each underlying.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      rows <- FixedIncomeFutures$contracts(exchange = self$exchange)
      if (is.null(rows)) {
        cat(sprintf("No live rate futures on the %s.\n", self$exchange))
        return(invisible(NULL))
      }
      cat(
        sprintf("%d live contracts on the %s\n", nrow(rows), self$exchange)
      )
      seen_underlyings <- character(0)
      for (row_index in seq_len(nrow(rows))) {
        underlying_symbol <- rows$underlying_symbol[[row_index]]
        if (underlying_symbol %in% seen_underlyings) {
          next
        }
        seen_underlyings <- c(
          seen_underlyings,
          underlying_symbol
        )
        contract <- FixedIncomeFutures$new(
          exchange = self$exchange,
          underlying_symbol = underlying_symbol,
          expiry_date = rows$expiry_date[[row_index]]
        )
        price <- tryCatch(
          contract$last_price,
          ServiceUnavailableError = function(error) {
            "no quote"
          }
        )
        if (is.null(price)) {
          price <- "NULL"
        }
        lot_size <- contract$lot_size
        if (is.null(lot_size)) {
          lot_size <- "NULL"
        }
        cat(
          sprintf(
            "%-12s %s price %s, lot %s, %s days left\n",
            contract$underlying_symbol,
            format(contract$expiry_date),
            price,
            lot_size,
            contract$days_to_expiry
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateFuturesReport$new()$run()
}
