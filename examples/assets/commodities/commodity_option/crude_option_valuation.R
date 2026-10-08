#' Value the crude oil call nearest the money with Black-76.
#'
#' An MCX option settles into a future, so the library prices it off the future on the same commodity that expires first on or after it. The program picks the CRUDEOIL call nearest that future's price on the soonest expiry, and prints its premium, the future it is priced off, and its implied volatility and greeks.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_option/crude_option_valuation.R

library(tradeR)

#' A valuation of the call nearest the money on one commodity.
#'
#' @field underlying_symbol The character mcx symbol of the commodity, such as `"CRUDEOIL"`.
CrudeOptionValuation <- R6::R6Class(
  "CrudeOptionValuation",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the commodity whose option to value.
    #' @param underlying_symbol The character mcx symbol of the commodity.
    #' @return A new `CrudeOptionValuation` object.
    initialize = function(underlying_symbol = "CRUDEOIL") {
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
    #' @details Errors: signals `CommodityOptionError` when UBI has no such option; `UnderlyingError` when the option's future cannot be found; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- CommodityOption$expiries(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      strikes <- CommodityOption$strikes(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]]
      )
      probe <- CommodityOption$new(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]],
        strike_price = strikes[[1]],
        option_type = "CE"
      )
      future <- probe$underlying
      future_price <- future$last_price
      strike_price <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - future_price) < abs(strike_price - future_price)) {
          strike_price <- strike
        }
      }
      option <- CommodityOption$new(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]],
        strike_price = strike_price,
        option_type = "CE",
        underlying = future
      )
      cat(
        sprintf(
          "Call at %s expiring %s\n",
          strike_price,
          format(option$expiry_date)
        )
      )
      cat(
        sprintf(
          "Priced off the future expiring %s at %s\n",
          format(future$expiry_date),
          future_price
        )
      )
      cat(
        sprintf(
          "Premium: %s, per lot %s\n",
          self$display_text(option$last_price),
          self$display_text(option$premium_per_lot)
        )
      )
      cat(sprintf("Time value: %s\n", self$display_text(option$time_value)))
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
      cat(sprintf("Theta per day: %.2f\n", greeks[["theta"]]))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CrudeOptionValuation$new()$run()
}
