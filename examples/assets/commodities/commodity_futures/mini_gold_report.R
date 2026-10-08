#' Print a market report on the soonest mini gold future on the mcx.
#'
#' The program builds the GOLDM contract with the soonest expiry, prints its live prices, its lot and what one lot is worth, and works out momentum and volatility from its daily candles, which commodity futures have in UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_futures/mini_gold_report.R

library(tradeR)

#' A market report on one commodity futures contract.
#'
#' @field contract The `CommodityFutures` the report describes.
MiniGoldReport <- R6::R6Class(
  "MiniGoldReport",
  public = list(
    contract = NULL,

    #' @description
    #' Builds the contract with the soonest expiry.
    #' @param underlying_symbol The character mcx symbol of the commodity, such as `"GOLDM"`.
    #' @return A new `MiniGoldReport` object.
    #' @details Errors: signals `ValueError` when no futures are listed on the commodity, and `CommodityFuturesError` when UBI has no such contract.
    initialize = function(underlying_symbol = "GOLDM") {
      expiries <- CommodityFutures$expiries(
        exchange = "mcx",
        underlying_symbol = underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", underlying_symbol)
        )
      }
      self$contract <- CommodityFutures$new(
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
    #' Prints the live prices, the lot and the measures from candles.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$contract
      cat(
        sprintf(
          "%s expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      cat(sprintf("Best bid: %s\n", self$display_text(contract$best_bid)))
      cat(sprintf("Best offer: %s\n", self$display_text(contract$best_offer)))
      cat(sprintf("Lot: %s units\n", self$display_text(contract$lot_size)))
      cat(
        sprintf(
          "One lot is worth: %s\n",
          self$display_text(contract$contract_value)
        )
      )
      cat(
        sprintf(
          "Open interest: %s\n",
          self$display_text(contract$open_interest)
        )
      )
      strength_frame <- contract$relative_strength_index(window = 14, days = 90)
      if (is.null(strength_frame)) {
        cat("UBI has no candles for this contract.\n")
        return(invisible(NULL))
      }
      latest_strength <- strength_frame$rsi_14[[nrow(strength_frame)]]
      cat(
        sprintf(
          "Relative strength index (14 days): %.1f\n",
          latest_strength
        )
      )
      volatility <- contract$annualised_volatility(days = 90)
      if (!is.null(volatility)) {
        cat(
          sprintf(
            "Annualised volatility over 90 days: %.1f%%\n",
            volatility * 100
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MiniGoldReport$new()$run()
}
