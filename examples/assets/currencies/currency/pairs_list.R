#' List the currency pairs UBI carries on each exchange and the futures on each.
#'
#' The program searches the nse and the bse for every currency pair, and for each pair prints how many futures and option expiries are listed on it, which shows at a glance where currency derivatives actually trade.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency/pairs_list.R

library(tradeR)

#' The currency pairs on two exchanges and the derivatives listed on each.
#'
#' @field exchanges A character vector of the exchanges to search, `"nse"` and `"bse"`.
CurrencyPairsList <- R6::R6Class(
  "CurrencyPairsList",
  public = list(
    exchanges = NULL,

    #' @description
    #' Stores the exchanges to search.
    #' @return A new `CurrencyPairsList` object.
    initialize = function() {
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Searches each exchange and prints one line per pair.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        matches <- Currency$search(
          exchange = exchange,
          term = "",
          limit = 200
        )
        if (is.null(matches)) {
          cat(sprintf("%s: no currency pairs\n", exchange))
          next
        }
        cat(sprintf("%s: %d pairs\n", exchange, nrow(matches)))
        for (symbol in matches$symbol) {
          futures_expiries <- CurrencyFutures$expiries(
            exchange = exchange,
            underlying_symbol = symbol
          )
          option_expiries <- CurrencyOption$expiries(
            exchange = exchange,
            underlying_symbol = symbol
          )
          cat(
            sprintf(
              "    %-12s %d futures expiries, %d option expiries\n",
              symbol,
              length(futures_expiries),
              length(option_expiries)
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyPairsList$new()$run()
}
