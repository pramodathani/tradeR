#' Show that a currency pair has no quote, and read its rate from the nearest future.
#'
#' A currency pair such as USDINR on the nse is the exchange's reference record for the underlying rather than something that trades, so reading its last price signals `ServiceUnavailableError`. The program builds the pair, catches that error, and prints the soonest future's last price instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency/pair_has_no_quote.R

library(tradeR)

#' The rate of one currency pair, read from its soonest future.
#'
#' @field pair The `Currency` whose rate to read.
CurrencyPairRate <- R6::R6Class(
  "CurrencyPairRate",
  public = list(
    pair = NULL,

    #' @description
    #' Looks the pair up on the nse.
    #' @param symbol The character symbol of the pair, such as `"USDINR"`.
    #' @return A new `CurrencyPairRate` object.
    #' @details Errors: signals `CurrencyError` when UBI has no such pair on the nse.
    initialize = function(symbol = "USDINR") {
      self$pair <- Currency$new(exchange = "nse", symbol = symbol)
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
    #' Tries the pair's own quote, then prints the soonest future's price.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CurrencyFuturesError` when UBI has no such contract, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      cat(
        sprintf(
          "%s: %s, %s\n",
          self$pair$symbol,
          self$pair$segment,
          self$pair$shape
        )
      )
      tryCatch(
        cat(
          sprintf("Last price: %s\n", self$display_text(self$pair$last_price))
        ),
        ServiceUnavailableError = function(error) {
          cat(
            sprintf(
              "The pair itself has no quote: %s\n",
              conditionMessage(error)
            )
          )
        }
      )
      expiries <- CurrencyFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$pair$symbol
      )
      if (length(expiries) == 0) {
        cat("No futures are listed on the pair.\n")
        return(invisible(NULL))
      }
      contract <- CurrencyFutures$new(
        exchange = "nse",
        underlying_symbol = self$pair$symbol,
        expiry_date = expiries[[1]]
      )
      cat(
        sprintf(
          "Future expiring %s: %s\n",
          format(contract$expiry_date),
          self$display_text(contract$last_price)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyPairRate$new()$run()
}
