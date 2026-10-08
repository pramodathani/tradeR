#' Measure the volatility smile of the next NIFTY weekly expiry from live prices.
#'
#' The program finds the second NIFTY option expiry, so that it never works on a contract expiring today, reads the index's last price, and for seven strikes around the money builds the out-of-the-money option, reads its last price and asks Black-Scholes for the volatility that premium implies. The resulting table shows how implied volatility changes with the strike.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/option_pricing_model/live_nifty_volatility_smile.R

library(tradeR)

#' A table of NIFTY implied volatilities across strikes for one expiry.
#'
#' @field index The `EquityIndex` for NIFTY.
#' @field expiry_date The `Date` of the expiry measured.
#' @field strike_step The numeric distance between the strikes measured.
#' @field risk_free_rate The numeric annual risk-free rate used in the search.
LiveNiftyVolatilitySmile <- R6::R6Class(
  "LiveNiftyVolatilitySmile",
  public = list(
    index = NULL,
    expiry_date = NULL,
    strike_step = NULL,
    risk_free_rate = NULL,

    #' @description
    #' Reads the NIFTY index and picks the second expiry listed.
    #' @return A new `LiveNiftyVolatilitySmile` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      self$expiry_date <- expiries[2]
      self$strike_step <- 100.0
      self$risk_free_rate <- OPTION_PRICING_DEFAULT_RISK_FREE_RATE
    },

    #' @description
    #' Prints the implied volatility of the out-of-the-money option at seven strikes.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      spot_price <- self$index$last_price
      years_to_expiry <- private$years_to_expiry()
      middle_strike <- round(spot_price / self$strike_step) * self$strike_step
      cat(sprintf(
        "NIFTY %s, expiry %s\n",
        format(spot_price),
        format(self$expiry_date)
      ))
      cat(sprintf("Years to expiry: %.5f\n", years_to_expiry))
      for (step in -3:3) {
        strike_price <- middle_strike + step * self$strike_step
        private$print_strike(spot_price, strike_price, years_to_expiry)
      }
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Prints the implied volatility of the out-of-the-money option at one strike.
    #' @param spot_price The numeric last price of the index.
    #' @param strike_price The numeric strike to measure.
    #' @param years_to_expiry The numeric time left until expiry, in years.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_strike = function(spot_price, strike_price, years_to_expiry) {
      if (strike_price >= spot_price) {
        option_type <- "ce"
      } else {
        option_type <- "pe"
      }
      option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = self$expiry_date,
        strike_price = strike_price,
        option_type = option_type
      )
      premium <- option$last_price
      if (is.null(premium)) {
        cat(sprintf("%.0f %s: no last price\n", strike_price, option_type))
        return(invisible(NULL))
      }
      volatility <- BlackScholes$implied_volatility(
        premium = premium,
        reference_price = spot_price,
        strike_price = strike_price,
        years_to_expiry = years_to_expiry,
        risk_free_rate = self$risk_free_rate,
        is_call = option_type == "ce"
      )
      if (is.null(volatility)) {
        cat(sprintf(
          "%.0f %s: premium %s, none\n",
          strike_price,
          option_type,
          format(premium)
        ))
        return(invisible(NULL))
      }
      cat(sprintf(
        "%.0f %s: premium %8.2f, implied volatility %.2f per cent\n",
        strike_price,
        option_type,
        premium,
        volatility * 100
      ))
      invisible(NULL)
    },

    #' @description
    #' Works out the time from now until 15:30 India time on the expiry date.
    #' @return The numeric number of years left.
    years_to_expiry = function() {
      converter <- TimeConverter$new()
      expiry_moment <- converter$moment_on(self$expiry_date, "15:30")
      now <- converter$now()
      seconds_left <- as.numeric(expiry_moment) - as.numeric(now)
      seconds_left / (365 * 24 * 60 * 60)
    }
  )
)

if (sys.nframe() == 0) {
  LiveNiftyVolatilitySmile$new()$run()
}
