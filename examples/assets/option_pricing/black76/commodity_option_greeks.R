#' Price a call and a put on a commodity future with Black-76 and show how they respond.
#'
#' The program prices options on a future trading at 9125 with seventeen days to run at 59 per cent volatility, prints the price and greeks of each, and then shows how the call's price moves when the future, the volatility and the time left each change on their own. It needs no market data.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/option_pricing/black76/commodity_option_greeks.R

library(tradeR)

#' A Black-76 report on options written on one future.
#'
#' @field forward_price The numeric price of the future.
#' @field strike_price The numeric strike of both options.
#' @field days_to_expiry The integer number of calendar days left.
#' @field risk_free_rate The numeric annual risk-free rate.
#' @field volatility The numeric annual volatility of the future.
CommodityOptionGreeks <- R6::R6Class(
  "CommodityOptionGreeks",
  public = list(
    forward_price = NULL,
    strike_price = NULL,
    days_to_expiry = NULL,
    risk_free_rate = NULL,
    volatility = NULL,

    #' @description
    #' Sets the future and the options to price.
    #' @return A new `CommodityOptionGreeks` object.
    initialize = function() {
      self$forward_price <- 9125.0
      self$strike_price <- 9100.0
      self$days_to_expiry <- 17
      self$risk_free_rate <- 0.065
      self$volatility <- 0.59
    },

    #' @description
    #' Prints the greeks of the call and the put, then the call's price under three changes.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when a price, strike, time to expiry or volatility is not above zero.
    run = function() {
      for (is_call in c(
        TRUE,
        FALSE
      )) {
        model <- private$model(
          self$forward_price,
          self$volatility,
          self$days_to_expiry,
          is_call
        )
        private$print_greeks(model)
      }
      base <- private$model(
        self$forward_price,
        self$volatility,
        self$days_to_expiry,
        TRUE
      )
      higher_future <- private$model(
        self$forward_price + 100,
        self$volatility,
        self$days_to_expiry,
        TRUE
      )
      higher_volatility <- private$model(
        self$forward_price,
        self$volatility + 0.05,
        self$days_to_expiry,
        TRUE
      )
      a_week_later <- private$model(
        self$forward_price,
        self$volatility,
        self$days_to_expiry - 7,
        TRUE
      )
      cat(sprintf("Call price now: %.2f\n", base$price))
      cat(sprintf("Future 100 higher: %.2f\n", higher_future$price))
      cat(sprintf(
        "Volatility 5 points higher: %.2f\n",
        higher_volatility$price
      ))
      cat(sprintf("A week later: %.2f\n", a_week_later$price))
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Builds one Black-76 model at the strike and rate this report uses.
    #' @param forward_price The numeric price of the future.
    #' @param volatility The numeric annual volatility.
    #' @param days_to_expiry The integer number of calendar days left.
    #' @param is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    #' @return The `Black76` model.
    #' @details Errors: signals `ValueError` when a price, strike, time to expiry or volatility is not above zero.
    model = function(forward_price, volatility, days_to_expiry, is_call) {
      Black76$new(
        forward_price = forward_price,
        strike_price = self$strike_price,
        years_to_expiry = days_to_expiry / 365,
        risk_free_rate = self$risk_free_rate,
        volatility = volatility,
        is_call = is_call
      )
    },

    #' @description
    #' Prints the price and the five greeks of one option.
    #' @param model The `Black76` model to report.
    #' @return `NULL`, invisibly.
    print_greeks = function(model) {
      if (model$is_call) {
        cat("Call\n")
      } else {
        cat("Put\n")
      }
      cat(sprintf("  price %.2f\n", model$price))
      cat(sprintf("  delta %.4f\n", model$delta))
      cat(sprintf("  gamma %.6f\n", model$gamma))
      cat(sprintf("  theta %.2f per day\n", model$theta))
      cat(sprintf("  vega  %.2f per point\n", model$vega))
      cat(sprintf("  rho   %.4f per point\n", model$rho))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CommodityOptionGreeks$new()$run()
}
