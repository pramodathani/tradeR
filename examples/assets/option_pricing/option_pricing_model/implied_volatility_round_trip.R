#' Recover a known volatility from the prices both pricing models give.
#'
#' The program prices a NIFTY call with Black-Scholes and a crude oil put with Black-76 at volatilities chosen in advance, then hands each price back to the shared implied volatility search and prints how closely it finds the volatility it started from. It needs no market data.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/option_pricing_model/implied_volatility_round_trip.R

library(tradeR)

#' A check that the implied volatility search undoes each pricing model.
#'
#' @field risk_free_rate The numeric annual risk-free rate every option is priced at.
#' @field volatilities The numeric vector of volatilities each model is priced at and recovered from.
ImpliedVolatilityRoundTrip <- R6::R6Class(
  "ImpliedVolatilityRoundTrip",
  public = list(
    risk_free_rate = NULL,
    volatilities = NULL,

    #' @description
    #' Sets the rate and the volatilities to test.
    #' @return A new `ImpliedVolatilityRoundTrip` object.
    initialize = function() {
      self$risk_free_rate <- 0.065
      self$volatilities <- c(
        0.08,
        0.15,
        0.35,
        0.80
      )
    },

    #' @description
    #' Prices each option at each volatility and prints the volatility recovered from the price.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike or time to expiry is not above zero.
    run = function() {
      cat("Black-Scholes, NIFTY call, spot 24000, strike 24100, 7 days\n")
      for (volatility in self$volatilities) {
        private$check_black_scholes(volatility)
      }
      cat("Black-76, crude oil put, future 5850, strike 5800, 20 days\n")
      for (volatility in self$volatilities) {
        private$check_black_76(volatility)
      }
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Prices the NIFTY call with Black-Scholes and prints the volatility the search recovers.
    #' @param volatility The numeric volatility to price at.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike or time to expiry is not above zero.
    check_black_scholes = function(volatility) {
      model <- BlackScholes$new(
        underlying_price = 24000.0,
        strike_price = 24100.0,
        years_to_expiry = 7 / 365,
        risk_free_rate = self$risk_free_rate,
        volatility = volatility,
        is_call = TRUE
      )
      recovered <- BlackScholes$implied_volatility(
        premium = model$price,
        reference_price = 24000.0,
        strike_price = 24100.0,
        years_to_expiry = 7 / 365,
        risk_free_rate = self$risk_free_rate,
        is_call = TRUE
      )
      private$print_row(volatility, model$price, recovered)
    },

    #' @description
    #' Prices the crude oil put with Black-76 and prints the volatility the search recovers.
    #' @param volatility The numeric volatility to price at.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike or time to expiry is not above zero.
    check_black_76 = function(volatility) {
      model <- Black76$new(
        forward_price = 5850.0,
        strike_price = 5800.0,
        years_to_expiry = 20 / 365,
        risk_free_rate = self$risk_free_rate,
        volatility = volatility,
        is_call = FALSE
      )
      recovered <- Black76$implied_volatility(
        premium = model$price,
        reference_price = 5850.0,
        strike_price = 5800.0,
        years_to_expiry = 20 / 365,
        risk_free_rate = self$risk_free_rate,
        is_call = FALSE
      )
      private$print_row(volatility, model$price, recovered)
    },

    #' @description
    #' Prints one line comparing the volatility used with the one recovered.
    #' @param volatility The numeric volatility the option was priced at.
    #' @param premium The numeric price the model gave.
    #' @param recovered The numeric volatility the search found, or `NULL` when it found none.
    #' @return `NULL`, invisibly.
    print_row = function(volatility, premium, recovered) {
      if (is.null(recovered)) {
        cat(sprintf(
          "  %.2f: premium %.2f, nothing recovered\n",
          volatility,
          premium
        ))
        return(invisible(NULL))
      }
      error <- abs(recovered - volatility)
      cat(sprintf(
        "  %.2f: premium %9.2f, recovered %.6f, error %.1e\n",
        volatility,
        premium,
        recovered,
        error
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ImpliedVolatilityRoundTrip$new()$run()
}
