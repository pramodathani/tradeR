#' List every investment trust UBI carries on the nse with its last price and day change.
#'
#' The program searches the nse's investment trusts segment with an empty term, which returns every trust, builds each one and prints its last price and its move since the previous close, sorted from the best day to the worst.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/investment_trust/trust_catalogue.R

library(tradeR)

#' A table of the day's moves across every listed trust.
#'
#' @field exchange The character exchange whose trusts are listed.
TrustCatalogue <- R6::R6Class(
  "TrustCatalogue",
  public = list(
    exchange = NULL,

    #' @description
    #' Sets the exchange to list.
    #' @return A new `TrustCatalogue` object.
    initialize = function() {
      self$exchange <- "nse"
    },

    #' @description
    #' Finds every trust, reads each one's prices and prints them sorted by the day's move, best first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      matches <- InvestmentTrust$search(exchange = self$exchange, term = "")
      if (is.null(matches)) {
        cat(sprintf("UBI carries no trusts on the %s.\n", self$exchange))
        return(invisible(NULL))
      }
      cat(sprintf("%d trusts on the %s\n", nrow(matches), self$exchange))
      rows <- list()
      for (symbol in matches$symbol) {
        row <- private$read_trust(symbol)
        if (!is.null(row)) {
          rows[[length(rows) + 1]] <- row
        }
      }
      changes <- numeric(0)
      for (row in rows) {
        changes <- c(
          changes,
          private$change_of(row)
        )
      }
      sort_order <- order(changes, decreasing = TRUE)
      for (position in sort_order) {
        row <- rows[[position]]
        cat(
          sprintf(
            "%-12s %10.2f %7.2f%%\n",
            row[["symbol"]],
            row[["last_price"]],
            row[["change"]]
          )
        )
      }
      invisible(NULL)
    }
  ),
  private = list(
    # Builds one trust and reads its last price and previous close.
    # @param symbol The character symbol of the trust.
    # @return A named list with `symbol`, `last_price` and `change` in per cent, or `NULL` when the trust has no price or no broker quotes it.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request for a reason other than a missing quote.
    read_trust = function(symbol) {
      trust <- InvestmentTrust$new(exchange = self$exchange, symbol = symbol)
      quote <- tryCatch(
        trust$ohlc,
        ServiceUnavailableError = function(error) {
          NULL
        }
      )
      if (is.null(quote)) {
        cat(sprintf("%s: no broker has a quote\n", symbol))
        return(NULL)
      }
      last_price <- quote[["last_price"]]
      previous_close <- quote[["previous_close"]]
      no_last_price <- is.null(last_price) || last_price == 0
      no_previous_close <- is.null(previous_close) || previous_close == 0
      if (no_last_price || no_previous_close) {
        cat(sprintf("%s: no price\n", symbol))
        return(NULL)
      }
      list(
        symbol = symbol,
        last_price = last_price,
        change = (last_price / previous_close - 1) * 100
      )
    },

    # Gives the day's move of one row, for sorting.
    # @param row The named list row with a `change` entry.
    # @return The numeric change in per cent.
    change_of = function(row) {
      row[["change"]]
    }
  )
)

if (sys.nframe() == 0) {
  TrustCatalogue$new()$run()
}
