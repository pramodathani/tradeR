#' Value a dollar-rupee put nearest the money with Black-76.
#'
#' A currency option is priced off the future on the same pair that expires first on or after it. The program picks the USDINR put nearest that future's rate on the soonest expiry after today, and prints its premium, the future it is priced off, and its implied volatility and greeks.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_option/usdinr_option_valuation.R

library(tradeR)

#' A valuation of the put nearest the money on one currency pair.
#'
#' @field underlying_symbol The character symbol of the pair, such as `"USDINR"`.
DollarRupeeOptionValuation <- R6::R6Class(
  "DollarRupeeOptionValuation",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the pair whose option to value.
    #' @param underlying_symbol The character symbol of the pair.
    #' @return A new `DollarRupeeOptionValuation` object.
    initialize = function(underlying_symbol = "USDINR") {
      self$underlying_symbol <- underlying_symbol
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
    #' Chooses the option, builds it and prints its valuation.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CurrencyOptionError` when UBI has no such option; `UnderlyingError` when the option's future cannot be found; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- CurrencyOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      expiry_date <- expiries[[1]]
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          expiry_date <- expiry
          break
        }
      }
      strikes <- CurrencyOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      probe <- CurrencyOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strikes[[1]],
        option_type = "PE"
      )
      future <- probe$underlying
      future_rate <- future$last_price
      strike_price <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - future_rate) < abs(strike_price - future_rate)) {
          strike_price <- strike
        }
      }
      option <- CurrencyOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = "PE",
        underlying = future
      )
      cat(
        sprintf(
          "Put at %s expiring %s\n",
          strike_price,
          format(option$expiry_date)
        )
      )
      cat(
        sprintf(
          "Priced off the future expiring %s at %s\n",
          format(future$expiry_date),
          future_rate
        )
      )
      cat(sprintf("Premium: %s\n", self$display_text(option$last_price)))
      cat(
        sprintf(
          "Breakeven rate: %s\n",
          self$display_text(option$breakeven_price)
        )
      )
      greeks <- option$greeks()
      if (is.null(greeks)) {
        cat("No greeks, because the prices needed are not known.\n")
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
      cat(sprintf("Vega per point of volatility: %.4f\n", greeks[["vega"]]))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DollarRupeeOptionValuation$new()$run()
}
