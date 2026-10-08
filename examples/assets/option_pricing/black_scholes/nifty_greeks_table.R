#' Print a table of Black-Scholes prices and greeks across NIFTY strikes.
#'
#' The program prices a call and a put at five strikes around a NIFTY level of 24000, a week from expiry at 12 per cent volatility, and prints the fair price, delta, gamma, theta, vega and rho of each, the way a broker's option chain shows them. It needs no market data.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/black_scholes/nifty_greeks_table.R

library(tradeR)

#' A small option chain priced by Black-Scholes.
#'
#' @field underlying_price The numeric NIFTY level every option is priced from.
#' @field years_to_expiry The numeric time left until expiry, in years.
#' @field risk_free_rate The numeric annual risk-free rate.
#' @field volatility The numeric annual volatility.
#' @field strike_prices The numeric vector of strikes to price.
NiftyGreeksTable <- R6::R6Class(
  "NiftyGreeksTable",
  public = list(
    underlying_price = NULL,
    years_to_expiry = NULL,
    risk_free_rate = NULL,
    volatility = NULL,
    strike_prices = NULL,

    #' @description
    #' Sets the market the chain is priced in.
    #' @return A new `NiftyGreeksTable` object.
    initialize = function() {
      self$underlying_price <- 24000.0
      self$years_to_expiry <- 7 / 365
      self$risk_free_rate <- 0.065
      self$volatility <- 0.12
      self$strike_prices <- c(
        23800.0,
        23900.0,
        24000.0,
        24100.0,
        24200.0
      )
    },

    #' @description
    #' Prints one row for the call and one for the put at every strike.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike, time to expiry or volatility is not above zero.
    run = function() {
      cat("strike side    price   delta     gamma   theta   vega    rho\n")
      for (strike_price in self$strike_prices) {
        for (is_call in c(
          TRUE,
          FALSE
        )) {
          private$print_row(strike_price, is_call)
        }
      }
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Prices one option and prints its row.
    #' @param strike_price The numeric strike of the option.
    #' @param is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike, time to expiry or volatility is not above zero.
    print_row = function(strike_price, is_call) {
      model <- BlackScholes$new(
        underlying_price = self$underlying_price,
        strike_price = strike_price,
        years_to_expiry = self$years_to_expiry,
        risk_free_rate = self$risk_free_rate,
        volatility = self$volatility,
        is_call = is_call
      )
      if (is_call) {
        side <- "call"
      } else {
        side <- "put "
      }
      cat(sprintf(
        "%6.0f %s %8.2f %7.4f %9.6f %7.2f %6.2f %6.2f\n",
        strike_price,
        side,
        model$price,
        model$delta,
        model$gamma,
        model$theta,
        model$vega,
        model$rho
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftyGreeksTable$new()$run()
}
