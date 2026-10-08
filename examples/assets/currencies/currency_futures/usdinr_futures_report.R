#' Find the most traded dollar-rupee future on the nse and report on it.
#'
#' USDINR futures on the nse expire every week as well as every month, and most of the trading is in one or two of them. The program builds the first six contracts, picks the one with the highest volume today, and prints its prices and order book. It also prints the contract's `lot_size`, which here is the plurality of the brokers' figures rather than the lot an order is measured against, so it must not be used to size an order.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_futures/usdinr_futures_report.R

library(tradeR)

#' A report on the most traded futures contract on one currency pair.
#'
#' @field underlying_symbol The character symbol of the pair, such as `"USDINR"`.
#' @field contracts_to_compare The integer number of soonest contracts to compare.
DollarRupeeFuturesReport <- R6::R6Class(
  "DollarRupeeFuturesReport",
  public = list(
    underlying_symbol = NULL,
    contracts_to_compare = NULL,

    #' @description
    #' Stores the pair and how many contracts to compare.
    #' @param underlying_symbol The character symbol of the pair.
    #' @param contracts_to_compare The integer number of soonest contracts to compare.
    #' @return A new `DollarRupeeFuturesReport` object.
    initialize = function(
      underlying_symbol = "USDINR",
      contracts_to_compare = 6
    ) {
      self$underlying_symbol <- underlying_symbol
      self$contracts_to_compare <- contracts_to_compare
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
    #' Builds the soonest contracts and keeps the one with the highest volume.
    #' @return The `CurrencyFutures` traded most today, or `NULL` when none is listed.
    #' @details Errors: signals `CurrencyFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    most_traded = function() {
      expiries <- CurrencyFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      best_contract <- NULL
      best_volume <- -1
      soonest_expiries <- head(expiries, self$contracts_to_compare)
      for (expiry_index in seq_along(soonest_expiries)) {
        expiry_date <- soonest_expiries[[expiry_index]]
        contract <- CurrencyFutures$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        )
        volume <- contract$total_traded_volume
        if (is.null(volume)) {
          volume <- 0
        }
        cat(sprintf("%s: volume %s\n", format(expiry_date), volume))
        if (volume > best_volume) {
          best_volume <- volume
          best_contract <- contract
        }
      }
      best_contract
    },

    #' @description
    #' Chooses the contract and prints the report.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$most_traded()
      if (is.null(contract)) {
        cat(sprintf("No futures are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Most traded: %s %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Kind of expiry: %s\n", contract$expiry_kind))
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      cat(sprintf("Tick size: %s\n", self$display_text(contract$tick_size)))
      cat(sprintf("Best bid: %s\n", self$display_text(contract$best_bid)))
      cat(sprintf("Best offer: %s\n", self$display_text(contract$best_offer)))
      cat(
        sprintf("Spread: %s\n", self$display_text(contract$bid_offer_spread))
      )
      cat(
        sprintf(
          "Open interest: %s\n",
          self$display_text(contract$open_interest)
        )
      )
      cat(
        sprintf(
          "lot_size says %s, which is not the order lot\n",
          self$display_text(contract$lot_size)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DollarRupeeFuturesReport$new()$run()
}
