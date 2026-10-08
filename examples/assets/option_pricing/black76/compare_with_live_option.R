#' Check Black-76 against the greeks a live NIFTY option reports when it is priced off a future.
#'
#' The program builds the at-the-money NIFTY call of the second listed expiry and gives it, as its underlying, the NIFTY future that expires first on or after the option. That makes the option work out its greeks with Black-76. The program then prices the same option directly with `Black76` from the future's last price, the option's implied volatility and the time left, and prints both sets of figures side by side.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/black76/compare_with_live_option.R

library(tradeR)

#' A side-by-side check of a live option's Black-76 greeks against the model itself.
#'
#' @field future The `EquityIndexFutures` the option is priced off.
#' @field option The `EquityIndexOption` compared, the at-the-money call of the second expiry.
CompareWithLiveOption <- R6::R6Class(
  "CompareWithLiveOption",
  public = list(
    future = NULL,
    option = NULL,

    #' @description
    #' Picks the option's expiry, the future that covers it, and the at-the-money strike.
    #' @return A new `CompareWithLiveOption` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      option_expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      option_expiry <- option_expiries[2]
      future_expiries <- EquityIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      future_expiry <- NULL
      for (index in seq_along(future_expiries)) {
        expiry_date <- future_expiries[index]
        if (expiry_date >= option_expiry) {
          future_expiry <- expiry_date
          break
        }
      }
      self$future <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = future_expiry
      )
      strike_price <- round(self$future$last_price / 50) * 50
      self$option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = option_expiry,
        strike_price = strike_price,
        option_type = "ce",
        underlying = self$future
      )
    },

    #' @description
    #' Prints the option's own greeks next to the ones `Black76` gives for the same inputs.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      forward_price <- self$future$last_price
      greeks <- self$option$greeks(underlying_price = forward_price)
      if (is.null(greeks)) {
        cat(sprintf(
          "No greeks could be worked out for %s\n",
          self$option$format()
        ))
        return(invisible(NULL))
      }
      model <- Black76$new(
        forward_price = forward_price,
        strike_price = self$option$strike_price,
        years_to_expiry = private$years_to_expiry(),
        risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
        volatility = greeks[["volatility"]],
        is_call = TRUE
      )
      cat(self$option$format(), "\n", sep = "")
      cat(sprintf(
        "Priced off %s at %s\n",
        self$future$format(),
        format(forward_price)
      ))
      cat(sprintf("Model named by the option: %s\n", greeks[["model"]]))
      cat(sprintf("Implied volatility: %.4f\n", greeks[["volatility"]]))
      cat("measure   option.greeks()   Black76\n")
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
