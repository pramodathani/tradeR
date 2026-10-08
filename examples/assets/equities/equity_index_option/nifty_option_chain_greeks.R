#' Print the Nifty options around the money with their premiums and deltas.
#'
#' The program reads the Nifty option chain for the soonest expiry after today, keeps the five strikes nearest the index, and prints the call and the put at each with its last price, implied volatility and delta.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index_option/nifty_option_chain_greeks.R

library(tradeR)

#' A slice of the Nifty option chain around the money, with greeks.
#'
#' @field index The `EquityIndex` the options are written on.
#' @field strike_count The integer number of strikes to show.
NiftyOptionChainGreeks <- R6::R6Class(
  "NiftyOptionChainGreeks",
  public = list(
    index = NULL,
    strike_count = NULL,

    #' @description
    #' Looks the Nifty 50 up in UBI.
    #' @param strike_count The integer number of strikes nearest the index to show.
    #' @return A new `NiftyOptionChainGreeks` object.
    #' @details Errors: signals `EquityIndexError` when UBI has no Nifty 50 index.
    initialize = function(strike_count = 5) {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$strike_count <- strike_count
    },

    #' @description
    #' Chooses the soonest option expiry after today, or the soonest listed when none is later than today.
    #' @return The `Date` of the expiry.
    #' @details Errors: signals `ValueError` when no options are listed on the index, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    next_expiry = function() {
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise("ValueError", "No options are listed on the Nifty")
      }
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          return(expiry)
        }
      }
      expiries[[1]]
    },

    #' @description
    #' Keeps the listed strikes closest to the index's level.
    #' @param expiry_date The `Date` of the expiry.
    #' @return A numeric vector of strike prices, lowest first.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    strikes_near_the_money = function(expiry_date) {
      level <- self$index$last_price
      strikes <- EquityIndexOption$strikes(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date
      )
      by_distance <- strikes[order(abs(strikes - level))]
      sort(head(by_distance, self$strike_count))
    },

    #' @description
    #' Builds each option near the money and prints its line.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no options are listed on the index; `EquityIndexOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- self$next_expiry()
      cat(
        sprintf(
          "Nifty at %s, options expiring %s\n",
          self$index$last_price,
          format(expiry_date)
        )
      )
      option_types <- c(
        "CE",
        "PE"
      )
      for (strike_price in self$strikes_near_the_money(expiry_date)) {
        for (option_type in option_types) {
          option <- EquityIndexOption$new(
            exchange = "nse",
            underlying_symbol = "NIFTY",
            expiry_date = expiry_date,
            strike_price = strike_price,
            option_type = option_type,
            underlying = self$index
          )
          greeks <- option$greeks()
          if (is.null(greeks)) {
            cat(sprintf("%s %s: no greeks\n", strike_price, option_type))
            next
          }
          cat(
            sprintf(
              "%s %s: premium %s, volatility %.1f%%, delta %.2f\n",
              strike_price,
              option_type,
              option$last_price,
              greeks[["volatility"]] * 100,
              greeks[["delta"]]
            )
          )
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftyOptionChainGreeks$new()$run()
}
