#' Default risk-free rate for option pricing
#'
#' @description
#' The annual risk-free interest rate, as a decimal fraction, that the option pricing models use when the caller gives none: 6.5 percent, close to the yield on Indian government bills.
#'
#' @format A numeric value, `0.065`.
#' @export
OPTION_PRICING_DEFAULT_RISK_FREE_RATE <- 0.065
OPTION_PRICING_LOWEST_VOLATILITY <- 0.0001
OPTION_PRICING_HIGHEST_VOLATILITY <- 5.0
OPTION_PRICING_SEARCH_STEPS <- 100
OPTION_PRICING_DAYS_PER_YEAR <- 365
OPTION_PRICING_PERCENT <- 100

#' The mechanism every pricing model here shares: the normal distribution and the search for an implied volatility
#'
#' @description
#' `BlackScholes` prices an option from its underlying's price and `Black76` from a forward price, such as a future's. Each holds one option's inputs and reports its fair price and its five greeks as read-only fields, and each has an `implied_volatility()` function on its class generator that finds the volatility at which the model reproduces a premium seen in the market. `Option` uses Black-76 when the option's underlying is a future and Black-Scholes otherwise, and the models can be used on their own with any figures.
#'
#' The models assume no dividends and a European option, one exercised only at expiry. Theta is given per calendar day, and vega and rho per percentage point, which is how brokers' option chains show them.
#'
#' A subclass takes the price it models from, the strike, the time to expiry, the rate, the volatility and the side, in that order, keeps the volatility in a public `volatility` field, and reports `price` and the greeks as active bindings. This class needs nothing else from it, so the search works for any model that follows that shape.
#'
#' @examples
#' model <- BlackScholes$new(
#'   underlying_price = 24000,
#'   strike_price = 24100,
#'   years_to_expiry = 7 / 365,
#'   risk_free_rate = 0.065,
#'   volatility = 0.12,
#'   is_call = TRUE
#' )
#' model$price
#' model$delta
#'
#' BlackScholes$implied_volatility(
#'   premium = 150,
#'   reference_price = 24000,
#'   strike_price = 24100,
#'   years_to_expiry = 7 / 365,
#'   risk_free_rate = 0.065,
#'   is_call = TRUE
#' )
#' @export
OptionPricingModel <- R6::R6Class(
  "OptionPricingModel",
  public = list(
    #' @description
    #' Finds the volatility at which this model's price equals a premium, keeping every other input of this model.
    #'
    #' The search halves the range from `OPTION_PRICING_LOWEST_VOLATILITY` to `OPTION_PRICING_HIGHEST_VOLATILITY` for `OPTION_PRICING_SEARCH_STEPS` rounds, which is far finer than any premium's tick. A premium outside the prices the model gives at the two ends of that range has no volatility to find, which happens when the premium is below the option's discounted intrinsic value or implausibly high. The class generator functions `BlackScholes$implied_volatility()` and `Black76$implied_volatility()` build the model and call this.
    #' @param premium The numeric price the option trades at.
    #' @return The numeric annual volatility, such as 0.12 for 12 per cent, or `NULL` when the premium is not above zero or lies outside the prices the model can give.
    search_volatility = function(premium) {
      if (premium <= 0) {
        return(NULL)
      }
      lowest_price <- private$with_volatility(
        OPTION_PRICING_LOWEST_VOLATILITY
      )$price
      highest_price <- private$with_volatility(
        OPTION_PRICING_HIGHEST_VOLATILITY
      )$price
      if (premium < lowest_price || premium > highest_price) {
        return(NULL)
      }
      low_volatility <- OPTION_PRICING_LOWEST_VOLATILITY
      high_volatility <- OPTION_PRICING_HIGHEST_VOLATILITY
      for (step in seq_len(OPTION_PRICING_SEARCH_STEPS)) {
        middle_volatility <- (low_volatility + high_volatility) / 2
        middle_price <- private$with_volatility(middle_volatility)$price
        if (middle_price > premium) {
          high_volatility <- middle_volatility
        } else {
          low_volatility <- middle_volatility
        }
      }
      (low_volatility + high_volatility) / 2
    }
  ),
  private = list(
    # Makes a copy of this model with another volatility.
    # @param volatility The numeric annual volatility for the copy.
    # @return A new model object of the same class.
    with_volatility = function(volatility) {
      copy <- self$clone()
      copy$volatility <- volatility
      copy
    },

    # Works out the standard normal distribution's cumulative probability at a value.
    # @param value The numeric point to evaluate at.
    # @return The numeric probability that a standard normal variable is at most `value`.
    normal_cumulative = function(value) {
      stats::pnorm(value)
    },

    # Works out the standard normal distribution's density at a value.
    # @param value The numeric point to evaluate at.
    # @return The numeric density.
    normal_density = function(value) {
      exp(-value * value / 2) / sqrt(2 * pi)
    },

    # Signals `ValueError` unless a model input is above zero.
    # @param value The numeric input.
    # @param description The character description used in the message, such as `"The strike price"`.
    # @param name The character argument name shown in the message.
    # @return `NULL`, invisibly.
    # @details Errors: signals `ValueError` when `value` is not above zero.
    require_positive = function(value, description, name) {
      if (value <= 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "%s must be above zero: %s=%s",
            description,
            name,
            format(value)
          )
        )
      }
      invisible(NULL)
    }
  )
)

#' One European option priced by the Black-Scholes model without dividends
#'
#' @description
#' Holds one option's inputs and reports its fair price and its five greeks. Theta is per calendar day, and vega and rho are per percentage point.
#'
#' The function `BlackScholes$implied_volatility(premium, reference_price, strike_price, years_to_expiry, risk_free_rate, is_call)` on the class generator finds the volatility at which the model's price equals a premium, or `NULL` when the premium is not above zero or lies outside the prices the model can give. It signals `ValueError` when the reference price, strike price or years to expiry is not above zero.
#'
#' @examples
#' model <- BlackScholes$new(
#'   underlying_price = 24000,
#'   strike_price = 24100,
#'   years_to_expiry = 7 / 365,
#'   risk_free_rate = 0.065,
#'   volatility = 0.12,
#'   is_call = TRUE
#' )
#' c(
#'   price = model$price,
#'   delta = model$delta,
#'   theta = model$theta
#' )
#' @export
BlackScholes <- R6::R6Class(
  "BlackScholes",
  inherit = OptionPricingModel,
  public = list(
    #' @field underlying_price The numeric price of the underlying.
    underlying_price = NULL,
    #' @field strike_price The numeric strike price of the option.
    strike_price = NULL,
    #' @field years_to_expiry The numeric time left until expiry, in years.
    years_to_expiry = NULL,
    #' @field risk_free_rate The numeric annual risk-free interest rate, continuously compounded, such as 0.065 for 6.5 per cent.
    risk_free_rate = NULL,
    #' @field volatility The numeric annual volatility of the underlying, such as 0.12 for 12 per cent.
    volatility = NULL,
    #' @field is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    is_call = NULL,

    #' @description
    #' Keeps the option's inputs after checking that the model can use them.
    #' @param underlying_price The numeric price of the underlying, above zero.
    #' @param strike_price The numeric strike price of the option, above zero.
    #' @param years_to_expiry The numeric time left until expiry in years, above zero.
    #' @param risk_free_rate The numeric annual risk-free interest rate, continuously compounded.
    #' @param volatility The numeric annual volatility of the underlying, above zero.
    #' @param is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    #' @return A new `BlackScholes` object.
    #' @details Errors: signals `ValueError` when the underlying price, strike price, years to expiry or volatility is not above zero.
    initialize = function(
      underlying_price,
      strike_price,
      years_to_expiry,
      risk_free_rate,
      volatility,
      is_call
    ) {
      private$require_positive(
        underlying_price,
        "The underlying price",
        "underlying_price"
      )
      private$require_positive(strike_price, "The strike price", "strike_price")
      private$require_positive(
        years_to_expiry,
        "The time to expiry",
        "years_to_expiry"
      )
      private$require_positive(volatility, "The volatility", "volatility")
      self$underlying_price <- underlying_price
      self$strike_price <- strike_price
      self$years_to_expiry <- years_to_expiry
      self$risk_free_rate <- risk_free_rate
      self$volatility <- volatility
      self$is_call <- is_call
    }
  ),
  active = list(
    #' @field price The option's numeric fair price by the model.
    price = function(value) {
      if (!missing(value)) {
        stop("price is read-only", call. = FALSE)
      }
      first_distance <- private$first_distance()
      second_distance <- private$second_distance()
      discounted_strike <- private$discounted_strike()
      if (self$is_call) {
        return(
          self$underlying_price * private$normal_cumulative(first_distance) -
            discounted_strike * private$normal_cumulative(second_distance)
        )
      }
      discounted_strike * private$normal_cumulative(-second_distance) -
        self$underlying_price * private$normal_cumulative(-first_distance)
    },

    #' @field delta How much the option's price moves for a one-unit move in the underlying, as a numeric value.
    delta = function(value) {
      if (!missing(value)) {
        stop("delta is read-only", call. = FALSE)
      }
      cumulative <- private$normal_cumulative(private$first_distance())
      if (self$is_call) {
        return(cumulative)
      }
      cumulative - 1
    },

    #' @field gamma How much the delta moves for a one-unit move in the underlying, the same for a call and a put, as a numeric value.
    gamma = function(value) {
      if (!missing(value)) {
        stop("gamma is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      density / (
        self$underlying_price * self$volatility * sqrt(self$years_to_expiry)
      )
    },

    #' @field theta How much the option's price changes as one calendar day passes, as a numeric value.
    theta = function(value) {
      if (!missing(value)) {
        stop("theta is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      time_decay <- -(self$underlying_price * density * self$volatility) /
        (2 * sqrt(self$years_to_expiry))
      second_distance <- private$second_distance()
      discounted_strike <- private$discounted_strike()
      if (self$is_call) {
        interest <- self$risk_free_rate * discounted_strike *
          private$normal_cumulative(second_distance)
        annual_theta <- time_decay - interest
      } else {
        interest <- self$risk_free_rate * discounted_strike *
          private$normal_cumulative(-second_distance)
        annual_theta <- time_decay + interest
      }
      annual_theta / OPTION_PRICING_DAYS_PER_YEAR
    },

    #' @field vega How much the option's price moves when volatility rises by one percentage point, the same for a call and a put, as a numeric value.
    vega = function(value) {
      if (!missing(value)) {
        stop("vega is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      annual_vega <- self$underlying_price * density *
        sqrt(self$years_to_expiry)
      annual_vega / OPTION_PRICING_PERCENT
    },

    #' @field rho How much the option's price moves when the risk-free rate rises by one percentage point, as a numeric value.
    rho = function(value) {
      if (!missing(value)) {
        stop("rho is read-only", call. = FALSE)
      }
      second_distance <- private$second_distance()
      discounted_strike <- private$discounted_strike()
      if (self$is_call) {
        annual_rho <- self$years_to_expiry * discounted_strike *
          private$normal_cumulative(second_distance)
      } else {
        annual_rho <- -self$years_to_expiry * discounted_strike *
          private$normal_cumulative(-second_distance)
      }
      annual_rho / OPTION_PRICING_PERCENT
    }
  ),
  private = list(
    # Works out the model's d1, the standardised distance of the underlying from the strike.
    # @return The numeric d1.
    first_distance = function() {
      spread <- self$volatility * sqrt(self$years_to_expiry)
      drift <- (self$risk_free_rate + self$volatility * self$volatility / 2) *
        self$years_to_expiry
      (log(self$underlying_price / self$strike_price) + drift) / spread
    },

    # Works out the model's d2, which is d1 less the volatility over the option's life.
    # @return The numeric d2.
    second_distance = function() {
      spread <- self$volatility * sqrt(self$years_to_expiry)
      private$first_distance() - spread
    },

    # Works out the strike price discounted back from expiry to today.
    # @return The numeric discounted strike price.
    discounted_strike = function() {
      discount <- exp(-self$risk_free_rate * self$years_to_expiry)
      self$strike_price * discount
    }
  )
)

BlackScholes$implied_volatility <- function(
  premium,
  reference_price,
  strike_price,
  years_to_expiry,
  risk_free_rate,
  is_call
) {
  if (premium <= 0) {
    return(NULL)
  }
  model <- BlackScholes$new(
    reference_price,
    strike_price,
    years_to_expiry,
    risk_free_rate,
    OPTION_PRICING_LOWEST_VOLATILITY,
    is_call
  )
  model$search_volatility(premium)
}

#' One European option on a forward price, such as an option priced off a future, priced by the Black-76 model
#'
#' @description
#' Black-76 is Black-Scholes with the forward price in place of the underlying price, so the cost of carrying the underlying is already in the price the model starts from and is not counted again. It is the right model when the underlying given to an option is a future, and it is the model UBI's order engine uses.
#'
#' The function `Black76$implied_volatility(premium, reference_price, strike_price, years_to_expiry, risk_free_rate, is_call)` on the class generator finds the volatility at which the model's price equals a premium, with `reference_price` as the forward price, or `NULL` when the premium is not above zero or lies outside the prices the model can give. It signals `ValueError` when the reference price, strike price or years to expiry is not above zero.
#'
#' @examples
#' on_a_future <- Black76$new(
#'   forward_price = 9125,
#'   strike_price = 9100,
#'   years_to_expiry = 20 / 365,
#'   risk_free_rate = 0.065,
#'   volatility = 0.18,
#'   is_call = FALSE
#' )
#' c(
#'   price = on_a_future$price,
#'   delta = on_a_future$delta
#' )
#' @export
Black76 <- R6::R6Class(
  "Black76",
  inherit = OptionPricingModel,
  public = list(
    #' @field forward_price The numeric forward price, such as the last price of the future the option is priced off.
    forward_price = NULL,
    #' @field strike_price The numeric strike price of the option.
    strike_price = NULL,
    #' @field years_to_expiry The numeric time left until expiry, in years.
    years_to_expiry = NULL,
    #' @field risk_free_rate The numeric annual risk-free interest rate, continuously compounded, used only to discount.
    risk_free_rate = NULL,
    #' @field volatility The numeric annual volatility of the forward price, such as 0.12 for 12 per cent.
    volatility = NULL,
    #' @field is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    is_call = NULL,

    #' @description
    #' Keeps the option's inputs after checking that the model can use them.
    #' @param forward_price The numeric forward price, above zero.
    #' @param strike_price The numeric strike price of the option, above zero.
    #' @param years_to_expiry The numeric time left until expiry in years, above zero.
    #' @param risk_free_rate The numeric annual risk-free interest rate, continuously compounded.
    #' @param volatility The numeric annual volatility of the forward price, above zero.
    #' @param is_call A logical that is `TRUE` for a call and `FALSE` for a put.
    #' @return A new `Black76` object.
    #' @details Errors: signals `ValueError` when the forward price, strike price, years to expiry or volatility is not above zero.
    initialize = function(
      forward_price,
      strike_price,
      years_to_expiry,
      risk_free_rate,
      volatility,
      is_call
    ) {
      private$require_positive(
        forward_price,
        "The forward price",
        "forward_price"
      )
      private$require_positive(strike_price, "The strike price", "strike_price")
      private$require_positive(
        years_to_expiry,
        "The time to expiry",
        "years_to_expiry"
      )
      private$require_positive(volatility, "The volatility", "volatility")
      self$forward_price <- forward_price
      self$strike_price <- strike_price
      self$years_to_expiry <- years_to_expiry
      self$risk_free_rate <- risk_free_rate
      self$volatility <- volatility
      self$is_call <- is_call
    }
  ),
  active = list(
    #' @field price The option's numeric fair price by the model.
    price = function(value) {
      if (!missing(value)) {
        stop("price is read-only", call. = FALSE)
      }
      first_distance <- private$first_distance()
      second_distance <- private$second_distance()
      if (self$is_call) {
        undiscounted <- self$forward_price *
          private$normal_cumulative(first_distance) -
          self$strike_price * private$normal_cumulative(second_distance)
      } else {
        undiscounted <- self$strike_price *
          private$normal_cumulative(-second_distance) -
          self$forward_price * private$normal_cumulative(-first_distance)
      }
      private$discount() * undiscounted
    },

    #' @field delta How much the option's price moves for a one-unit move in the forward price, as a numeric value.
    delta = function(value) {
      if (!missing(value)) {
        stop("delta is read-only", call. = FALSE)
      }
      first_distance <- private$first_distance()
      if (self$is_call) {
        return(private$discount() * private$normal_cumulative(first_distance))
      }
      -private$discount() * private$normal_cumulative(-first_distance)
    },

    #' @field gamma How much the delta moves for a one-unit move in the forward price, the same for a call and a put, as a numeric value.
    gamma = function(value) {
      if (!missing(value)) {
        stop("gamma is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      spread <- self$forward_price * self$volatility * sqrt(self$years_to_expiry)
      private$discount() * density / spread
    },

    #' @field theta How much the option's price changes as one calendar day passes, with the forward price held still, as a numeric value.
    theta = function(value) {
      if (!missing(value)) {
        stop("theta is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      time_decay <- -(
        self$forward_price * private$discount() * density * self$volatility
      ) / (2 * sqrt(self$years_to_expiry))
      annual_theta <- time_decay + self$risk_free_rate * self$price
      annual_theta / OPTION_PRICING_DAYS_PER_YEAR
    },

    #' @field vega How much the option's price moves when volatility rises by one percentage point, the same for a call and a put, as a numeric value.
    vega = function(value) {
      if (!missing(value)) {
        stop("vega is read-only", call. = FALSE)
      }
      density <- private$normal_density(private$first_distance())
      annual_vega <- self$forward_price * private$discount() * density *
        sqrt(self$years_to_expiry)
      annual_vega / OPTION_PRICING_PERCENT
    },

    #' @field rho How much the option's price moves when the rate rises by one percentage point, with the forward price held still, as a numeric value.
    rho = function(value) {
      if (!missing(value)) {
        stop("rho is read-only", call. = FALSE)
      }
      -self$years_to_expiry * self$price / OPTION_PRICING_PERCENT
    }
  ),
  private = list(
    # Works out the model's d1, the standardised distance of the forward from the strike.
    # @return The numeric d1.
    first_distance = function() {
      spread <- self$volatility * sqrt(self$years_to_expiry)
      drift <- self$volatility * self$volatility / 2 * self$years_to_expiry
      (log(self$forward_price / self$strike_price) + drift) / spread
    },

    # Works out the model's d2, which is d1 less the volatility over the option's life.
    # @return The numeric d2.
    second_distance = function() {
      spread <- self$volatility * sqrt(self$years_to_expiry)
      private$first_distance() - spread
    },

    # Works out the factor that brings a payment at expiry back to today.
    # @return The numeric discount factor.
    discount = function() {
      exp(-self$risk_free_rate * self$years_to_expiry)
    }
  )
)

Black76$implied_volatility <- function(
  premium,
  reference_price,
  strike_price,
  years_to_expiry,
  risk_free_rate,
  is_call
) {
  if (premium <= 0) {
    return(NULL)
  }
  model <- Black76$new(
    reference_price,
    strike_price,
    years_to_expiry,
    risk_free_rate,
    OPTION_PRICING_LOWEST_VOLATILITY,
    is_call
  )
  model$search_volatility(premium)
}
