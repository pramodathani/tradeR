#' Report the trading activity in the soonest Nifty futures contract after today.
#'
#' The program builds the Nifty futures contract with the soonest expiry after today and prints its order book, its volume, its average traded price and how its open interest has ranged during the day.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index_futures/open_interest_report.R

library(tradeR)

#' A report on the trading activity in one equity index futures contract.
#'
#' @field contract The `EquityIndexFutures` the report describes.
IndexFuturesActivityReport <- R6::R6Class(
  "IndexFuturesActivityReport",
  public = list(
    contract = NULL,

    #' @description
    #' Builds the contract with the soonest expiry after today, or the latest listed when none is later than today.
    #' @param underlying_symbol The character nse symbol of the index, such as `"NIFTY"`.
    #' @return A new `IndexFuturesActivityReport` object.
    #' @details Errors: signals `ValueError` when no futures are listed on the index, and `EquityIndexFuturesError` when UBI has no such contract.
    initialize = function(underlying_symbol = "NIFTY") {
      expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", underlying_symbol)
        )
      }
      expiry_date <- expiries[[length(expiries)]]
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          expiry_date <- expiry
          break
        }
      }
      self$contract <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date
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
      format(value, digits = 15)
    },

    #' @description
    #' Prints the order book and the day's activity.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$contract
      cat(
        sprintf(
          "%s futures expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Kind of expiry: %s\n", contract$expiry_kind))
      cat(sprintf("Lot size: %s\n", self$display_text(contract$lot_size)))
      cat(sprintf("Best bid: %s\n", self$display_text(contract$best_bid)))
      cat(sprintf("Best offer: %s\n", self$display_text(contract$best_offer)))
      cat(sprintf("Mid price: %s\n", self$display_text(contract$mid_price)))
      cat(
        sprintf(
          "Average traded price: %s\n",
          self$display_text(contract$volume_weighted_average_price)
        )
      )
      cat(
        sprintf(
          "Volume: %s\n",
          self$display_text(contract$total_traded_volume)
        )
      )
      cat(
        sprintf(
          "Open interest: %s\n",
          self$display_text(contract$open_interest)
        )
      )
      cat(
        sprintf(
          "Open interest day high: %s\n",
          self$display_text(contract$open_interest_day_high)
        )
      )
      cat(
        sprintf(
          "Open interest day low: %s\n",
          self$display_text(contract$open_interest_day_low)
        )
      )
      cat(
        sprintf(
          "Last trade: %s\n",
          self$display_text(contract$last_trade_time)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexFuturesActivityReport$new()$run()
}
