#' Check whether any currency index option is listed, on either exchange.
#'
#' The discovery calls fail cleanly on an empty segment: `expiries` and `strikes` return empty vectors and `chain` returns `NULL`. The program asks both exchanges for dollar index option expiries, strikes and a chain, and reports what it finds, which is nothing today.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index_option/discovery_is_empty.R

library(tradeR)

#' A search for currency index options on the exchanges that trade currencies.
#'
#' @field underlying_symbol The character symbol of the index, such as `"USDINR"`.
#' @field exchanges A character vector of the exchanges to ask, `"nse"` and `"bse"`.
CurrencyIndexOptionDiscovery <- R6::R6Class(
  "CurrencyIndexOptionDiscovery",
  public = list(
    underlying_symbol = NULL,
    exchanges = NULL,

    #' @description
    #' Stores the index and the exchanges to ask.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `CurrencyIndexOptionDiscovery` object.
    initialize = function(underlying_symbol = "USDINR") {
      self$underlying_symbol <- underlying_symbol
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Writes a vector the way Python prints a list, such as `[a, b]`.
    #' @param values A vector of dates or numbers, which may be empty.
    #' @return A character string.
    list_text = function(values) {
      sprintf("[%s]", paste(format(values), collapse = ", "))
    },

    #' @description
    #' Asks each exchange for expiries, strikes and a chain, and prints the answers.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        expiries <- CurrencyIndexOption$expiries(
          exchange = exchange,
          underlying_symbol = self$underlying_symbol
        )
        if (length(expiries) > 0) {
          cat(
            sprintf(
              "%s: options listed for %s\n",
              exchange,
              self$list_text(expiries)
            )
          )
          next
        }
        pair_expiries <- CurrencyOption$expiries(
          exchange = "nse",
          underlying_symbol = "USDINR"
        )
        if (length(pair_expiries) == 0) {
          cat(sprintf("%s: no expiries listed\n", exchange))
          next
        }
        strikes <- CurrencyIndexOption$strikes(
          exchange = exchange,
          underlying_symbol = self$underlying_symbol,
          expiry_date = pair_expiries[[1]]
        )
        chain <- CurrencyIndexOption$chain(
          exchange = exchange,
          underlying_symbol = self$underlying_symbol,
          expiry_date = pair_expiries[[1]]
        )
        cat(
          sprintf(
            "%s: expiries %s, strikes %s, chain ",
            exchange,
            self$list_text(expiries),
            self$list_text(strikes)
          )
        )
        print(chain)
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexOptionDiscovery$new()$run()
}
