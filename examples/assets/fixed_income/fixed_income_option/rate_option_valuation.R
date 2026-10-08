#' Value an option on an interest rate underlying off the future it settles into.
#'
#' The program picks the soonest option expiry on the 6.33 per cent government security of 2035 and the call whose strike is nearest the price of the future the option is priced off. It prints the option's premium, the future's price and, when the option has traded, its implied volatility and greeks under Black-76.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_option/rate_option_valuation.R

library(tradeR)

#' A valuation of the call nearest the money on one interest rate underlying.
#'
#' @field underlying_symbol The character rate code of the security, such as `"633GS2035"`.
RateOptionValuation <- R6::R6Class(
  "RateOptionValuation",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the security whose option to value.
    #' @param underlying_symbol The character rate code of the security.
    #' @return A new `RateOptionValuation` object.
    initialize = function(underlying_symbol = "633GS2035") {
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
    #' Chooses the option, builds it and prints its valuation. When the future's price is unknown, the lowest strike is used.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeOptionError` when UBI has no such option; `UnderlyingError` when the option's future cannot be found; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- FixedIncomeOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      strikes <- FixedIncomeOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]]
      )
      first_option <- FixedIncomeOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]],
        strike_price = strikes[[1]],
        option_type = "CE"
      )
      future_price <- first_option$underlying_price
      cat(
        sprintf(
          "Priced off the future at %s\n",
          self$display_text(future_price)
        )
      )
      strike_price <- strikes[[1]]
      if (!is.null(future_price)) {
        for (strike in strikes) {
          if (abs(strike - future_price) < abs(strike_price - future_price)) {
            strike_price <- strike
          }
        }
      }
      option <- FixedIncomeOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]],
        strike_price = strike_price,
        option_type = "CE"
      )
      cat(
        sprintf(
          "Call at %s expiring %s\n",
          strike_price,
          format(option$expiry_date)
        )
      )
      cat(sprintf("Premium: %s\n", self$display_text(option$last_price)))
      cat(
        sprintf(
          "Intrinsic value: %s\n",
          self$display_text(option$intrinsic_value)
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
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateOptionValuation$new()$run()
}
