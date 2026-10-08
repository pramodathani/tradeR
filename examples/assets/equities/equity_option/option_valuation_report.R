#' Value the share option nearest the money and print its greeks.
#'
#' The program finds the soonest RELIANCE option expiry after today, picks the call whose strike is closest to the share's price, and prints its premium, its implied volatility and the greeks the Black-Scholes model gives for it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_option/option_valuation_report.R

library(tradeR)

#' A valuation of the call nearest the money on one share.
#'
#' @field share The `Equity` the option is written on.
ShareOptionValuationReport <- R6::R6Class(
  "ShareOptionValuationReport",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up in UBI.
    #' @param underlying_symbol The character nse symbol of the share.
    #' @return A new `ShareOptionValuationReport` object.
    #' @details Errors: signals `EquityError` when UBI has no nse share with that symbol.
    initialize = function(underlying_symbol = "RELIANCE") {
      self$share <- Equity$new(exchange = "nse", symbol = underlying_symbol)
    },

    #' @description
    #' Chooses the soonest option expiry after today, or the soonest listed when none is later than today.
    #' @return The `Date` of the expiry.
    #' @details Errors: signals `ValueError` when no options are listed on the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    next_expiry = function() {
      expiries <- EquityOption$expiries(
        exchange = "nse",
        underlying_symbol = self$share$symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No options are listed on %s", self$share$symbol)
        )
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
    #' Finds the listed strike closest to the share's last price.
    #' @param expiry_date The `Date` of the expiry whose strikes to search.
    #' @return The numeric strike price in rupees.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    nearest_strike = function(expiry_date) {
      share_price <- self$share$last_price
      strikes <- EquityOption$strikes(
        exchange = "nse",
        underlying_symbol = self$share$symbol,
        expiry_date = expiry_date
      )
      nearest <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - share_price) < abs(nearest - share_price)) {
          nearest <- strike
        }
      }
      nearest
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      as.character(value)
    },

    #' @description
    #' Builds the option and prints its valuation.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no options are listed on the share; `EquityOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- self$next_expiry()
      option <- EquityOption$new(
        exchange = "nse",
        underlying_symbol = self$share$symbol,
        expiry_date = expiry_date,
        strike_price = self$nearest_strike(expiry_date),
        option_type = "CE",
        underlying = self$share
      )
      cat(
        sprintf(
          "%s %s %s expiring %s\n",
          option$underlying_symbol,
          option$strike_price,
          option$option_type,
          format(option$expiry_date)
        )
      )
      cat(sprintf("Lot size: %s shares\n", self$display_text(option$lot_size)))
      cat(
        sprintf(
          "Share price: %s\n",
          self$display_text(option$underlying_price)
        )
      )
      cat(sprintf("Premium: %s\n", self$display_text(option$last_price)))
      cat(sprintf("Moneyness: %.2f%%\n", option$moneyness_percent))
      cat(
        sprintf(
          "Intrinsic value: %s\n",
          self$display_text(option$intrinsic_value)
        )
      )
      cat(sprintf("Time value: %s\n", self$display_text(option$time_value)))
      cat(
        sprintf(
          "Breakeven price: %s\n",
          self$display_text(option$breakeven_price)
        )
      )
      cat(
        sprintf(
          "Premium per lot: %s\n",
          self$display_text(option$premium_per_lot)
        )
      )
      greeks <- option$greeks()
      if (is.null(greeks)) {
        cat("The greeks cannot be worked out from the prices available.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Model: %s\n", greeks[["model"]]))
      cat(
        sprintf(
          "Implied volatility: %.1f%%\n",
          greeks[["volatility"]] * 100
        )
      )
      cat(sprintf("Delta: %.3f\n", greeks[["delta"]]))
      cat(sprintf("Gamma: %.5f\n", greeks[["gamma"]]))
      cat(sprintf("Theta per day: %.2f\n", greeks[["theta"]]))
      cat(sprintf("Vega per point of volatility: %.2f\n", greeks[["vega"]]))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareOptionValuationReport$new()$run()
}
