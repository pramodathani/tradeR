#' Report on the nse's fixed income indices and the gap in their quotes.
#'
#' The program lists every fixed income index on the nse, builds each one, and prints its identity. Asking for a level signals `ServiceUnavailableError`, because no broker that serves quotes carries a rate index, so the program catches that and says so.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index/rate_index_report.R

library(tradeR)

#' A report on every fixed income index on one exchange.
#'
#' @field exchange The character exchange to report on, such as `"nse"`.
RateIndexReport <- R6::R6Class(
  "RateIndexReport",
  public = list(
    exchange = NULL,

    #' @description
    #' Stores the exchange to report on.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @return A new `RateIndexReport` object.
    initialize = function(exchange = "nse") {
      self$exchange <- exchange
    },

    #' @description
    #' Lists the indices and prints what is known of each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeIndexError` when a listed index could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      matches <- FixedIncomeIndex$search(
        exchange = self$exchange,
        term = ""
      )
      if (is.null(matches)) {
        cat(sprintf("No fixed income index on the %s.\n", self$exchange))
        return(invisible(NULL))
      }
      for (symbol in matches$symbol) {
        index <- FixedIncomeIndex$new(
          exchange = self$exchange,
          symbol = symbol
        )
        cat(
          sprintf(
            "%s: %s, id %s\n",
            index$symbol,
            index$segment,
            index$instrument_id
          )
        )
        tryCatch(
          {
            level <- index$last_price
            if (is.null(level)) {
              level <- "NULL"
            }
            cat(sprintf("    level %s\n", level))
          },
          ServiceUnavailableError = function(error) {
            cat(
              "    no quote, because no broker that serves quotes carries it\n"
            )
          }
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateIndexReport$new()$run()
}
