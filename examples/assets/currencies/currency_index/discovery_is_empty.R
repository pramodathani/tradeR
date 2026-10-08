#' Check whether UBI carries any currency index yet.
#'
#' Searching an empty segment returns `NULL` rather than signalling an error, so a program can check for currency indices without catching anything. The program searches both exchanges with an empty term, which matches every row, and either prints what it finds or says that the segment is still empty.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index/discovery_is_empty.R

library(tradeR)

#' A search for currency indices on the exchanges that trade currencies.
#'
#' @field exchanges A character vector of the exchanges to search, `"nse"` and `"bse"`.
CurrencyIndexDiscovery <- R6::R6Class(
  "CurrencyIndexDiscovery",
  public = list(
    exchanges = NULL,

    #' @description
    #' Stores the exchanges to search.
    #' @return A new `CurrencyIndexDiscovery` object.
    initialize = function() {
      self$exchanges <- c(
        "nse",
        "bse"
      )
    },

    #' @description
    #' Searches each exchange and prints the result.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      found_any <- FALSE
      for (exchange in self$exchanges) {
        matches <- CurrencyIndex$search(
          exchange = exchange,
          term = "",
          limit = 200
        )
        if (is.null(matches)) {
          cat(
            sprintf("%s: the currency indices segment is empty\n", exchange)
          )
          next
        }
        found_any <- TRUE
        cat(
          sprintf(
            "%s: [%s]\n",
            exchange,
            paste(matches$symbol, collapse = ", ")
          )
        )
      }
      if (!found_any) {
        cat("UBI carries no currency index yet.\n")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexDiscovery$new()$run()
}
