#' List the mcx commodity indices and show that they have no quote.
#'
#' The program searches the mcx for commodity indices, builds each one, and tries to read its level. No tick stream resolves a commodity index, so every read signals `ServiceUnavailableError`, which the program catches and reports.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index/index_list.R

library(tradeR)

#' The commodity indices one exchange publishes.
#'
#' @field exchange The character exchange to list, `"mcx"` or `"ncdex"`.
CommodityIndexList <- R6::R6Class(
  "CommodityIndexList",
  public = list(
    exchange = NULL,

    #' @description
    #' Stores the exchange to list.
    #' @param exchange The character exchange, `"mcx"` or `"ncdex"`.
    #' @return A new `CommodityIndexList` object.
    initialize = function(exchange = "mcx") {
      self$exchange <- exchange
    },

    #' @description
    #' Lists the indices and prints what each one gives.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityIndexError` when a listed index could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
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
      cat(
        sprintf(
          "%d commodity indices on the %s\n",
          nrow(matches),
          self$exchange
        )
      )
      for (symbol in matches$symbol) {
        index <- CommodityIndex$new(exchange = self$exchange, symbol = symbol)
        level <- tryCatch(
          index$last_price,
          ServiceUnavailableError = function(error) {
            "no quote"
          }
        )
        if (is.null(level)) {
          level <- "NULL"
        }
        cat(sprintf("%-14s %s\n", index$symbol, level))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityIndexList$new()$run()
}
