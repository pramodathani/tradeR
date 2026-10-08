#' Check Black-Scholes against the greeks a live NIFTY option reports.
#'
#' The program builds the at-the-money NIFTY call of the second listed expiry, asks it for its greeks, which it works out with Black-Scholes because its underlying is the index, and then prices the same option directly with `BlackScholes` from the index's last price, the option's implied volatility and the time left. The two sets of figures should agree to several decimal places.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/black_scholes/compare_with_live_option.R

library(tradeR)

#' A side-by-side check of a live option's greeks against the model itself.
#'
#' @field index The `EquityIndex` for NIFTY.
#' @field option The `EquityIndexOption` compared, the at-the-money call of the second expiry.
CompareWithLiveOption <- R6::R6Class(
  "CompareWithLiveOption",
  public = list(
    index = NULL,
    option = NULL,

    #' @description
    #' Reads the NIFTY level and builds the at-the-money call of the second expiry.
    #' @return A new `CompareWithLiveOption` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      strike_price <- round(self$index$last_price / 50) * 50
      self$option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiries[2],
        strike_price = strike_price,
        option_type = "ce",
        underlying = self$index
      )
    },

    #' @description
    #' Prints the option's own greeks next to the ones `BlackScholes` gives for the same inputs.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      spot_price <- self$index$last_price
      greeks <- self$option$greeks(underlying_price = spot_price)
      if (is.null(greeks)) {
        cat(sprintf(
          "No greeks could be worked out for %s\n",
          self$option$format()
        ))
        return(invisible(NULL))
      }
      model <- BlackScholes$new(
        underlying_price = spot_price,
        strike_price = self$option$strike_price,
        years_to_expiry = private$years_to_expiry(),
        risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
        volatility = greeks[["volatility"]],
        is_call = TRUE
      )
      cat(self$option$format(), "\n", sep = "")
      cat(sprintf(
        "NIFTY %s, option last price %s\n",
        format(spot_price),
        format(self$option$last_price)
      ))
      cat(sprintf("Model named by the option: %s\n", greeks[["model"]]))
      cat(sprintf("Implied volatility: %.4f\n", greeks[["volatility"]]))
      cat("measure   option.greeks()   BlackScholes\n")
      private$print_pair("price", greeks[["price"]], model$price)
      private$print_pair("delta", greeks[["delta"]], model$delta)
      private$print_pair("gamma", greeks[["gamma"]], model$gamma)
      private$print_pair("theta", greeks[["theta"]], model$theta)
      private$print_pair("vega", greeks[["vega"]], model$vega)
      private$print_pair("rho", greeks[["rho"]], model$rho)
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Prints one measure from both sources.
    #' @param name The character name of the measure.
    #' @param from_option The numeric value the option's greeks reported.
    #' @param from_model The numeric value the model gave.
    #' @return `NULL`, invisibly.
    print_pair = function(name, from_option, from_model) {
      cat(sprintf("%-8s %16.6f %14.6f\n", name, from_option, from_model))
      invisible(NULL)
    },

    #' @description
    #' Works out the time from now until 15:30 India time on the expiry date, as the option does.
    #' @return The numeric number of years left.
    years_to_expiry = function() {
      converter <- TimeConverter$new()
      expiry_moment <- converter$moment_on(self$option$expiry_date, "15:30")
      now <- converter$now()
      seconds_left <- as.numeric(expiry_moment) - as.numeric(now)
      seconds_left / (365 * 24 * 60 * 60)
    }
  )
)

if (sys.nframe() == 0) {
  CompareWithLiveOption$new()$run()
}
