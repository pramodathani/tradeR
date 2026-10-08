#' Print a report on the soonest bullion index future on the mcx.
#'
#' The program builds the soonest MCXBULLDEX future and prints its price, its lot and what one lot is worth, its order book, and the last few daily closes from its candles.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index_futures/bullion_index_futures_report.R

library(tradeR)

#' A report on one commodity index futures contract.
#'
#' @field contract The `CommodityIndexFutures` the report describes.
BullionIndexFuturesReport <- R6::R6Class(
  "BullionIndexFuturesReport",
  public = list(
    contract = NULL,

    #' @description
    #' Builds the contract with the soonest expiry.
    #' @param underlying_symbol The character mcx symbol of the index, such as `"MCXBULLDEX"`.
    #' @return A new `BullionIndexFuturesReport` object.
    #' @details Errors: signals `ValueError` when no futures are listed on the index, and `CommodityIndexFuturesError` when UBI has no such contract.
    initialize = function(underlying_symbol = "MCXBULLDEX") {
      expiries <- CommodityIndexFutures$expiries(
        exchange = "mcx",
        underlying_symbol = underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", underlying_symbol)
        )
      }
      self$contract <- CommodityIndexFutures$new(
        exchange = "mcx",
        underlying_symbol = underlying_symbol,
        expiry_date = expiries[[1]]
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one and one line of JSON for a named list.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        return(jsonlite::toJSON(value, auto_unbox = TRUE, null = "null"))
      }
      as.character(value)
    },

    #' @description
    #' Prints the live values and the recent closes.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$contract
      cat(
        sprintf(
          "%s future expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Days to expiry: %s\n", contract$days_to_expiry))
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      cat(
        sprintf(
          "Lot: %s, one lot worth %s\n",
          self$display_text(contract$lot_size),
          self$display_text(contract$contract_value)
        )
      )
      cat(sprintf("Best bid: %s\n", self$display_text(contract$best_bid)))
      cat(sprintf("Best offer: %s\n", self$display_text(contract$best_offer)))
      candles <- contract$prices(days = 14)
      if (is.null(candles)) {
        cat("UBI has no recent candles for this contract.\n")
        return(invisible(NULL))
      }
      recent <- tail(candles, 5)
      for (row_index in seq_len(nrow(recent))) {
        cat(
          sprintf(
            "%s: close %s\n",
            format(recent$datetime[[row_index]], "%Y-%m-%d"),
            recent$close[[row_index]]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BullionIndexFuturesReport$new()$run()
}
