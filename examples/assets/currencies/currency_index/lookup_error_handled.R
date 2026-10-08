#' Try to build a currency index and handle the error UBI gives today.
#'
#' UBI holds no rows in its currency indices segment on any exchange, so every lookup fails with `CurrencyIndexError`. The program asks the nse and the bse for a dollar index, catches the error for each, and prints it, so the same code will simply start working the day UBI carries one.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index/lookup_error_handled.R

library(tradeR)

#' An attempt to build one currency index on each exchange that trades currencies.
#'
#' @field symbol The character symbol of the index to look for, such as `"USDINR"`.
#' @field exchanges A character vector of the exchanges to ask, `"nse"` and `"bse"`.
CurrencyIndexLookup <- R6::R6Class(
  "CurrencyIndexLookup",
  public = list(
    symbol = NULL,
    exchanges = NULL,

    #' @description
    #' Stores the index to look for and the exchanges to ask.
    #' @param symbol The character symbol of the index.
    #' @return A new `CurrencyIndexLookup` object.
    initialize = function(symbol = "USDINR") {
      self$symbol <- symbol
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Tries each exchange and prints either the index or the error.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      for (exchange in self$exchanges) {
        index <- tryCatch(
          CurrencyIndex$new(exchange = exchange, symbol = self$symbol),
          CurrencyIndexError = function(error) {
            cat(
              sprintf(
                "%s: not available today: %s\n",
                exchange,
                conditionMessage(error)
              )
            )
            NULL
          }
        )
        if (is.null(index)) {
          next
        }
        cat(
          sprintf(
            "%s: found %s, id %s\n",
            exchange,
            index$symbol,
            index$instrument_id
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexLookup$new()$run()
}
