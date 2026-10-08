#' Print the implied volatility smile of Bank Nifty options.
#'
#' The implied volatility of an option is the volatility at which the pricing model reproduces its market price, and plotted across strikes it usually forms a smile or a skew, with out-of-the-money puts dearer than calls. The program builds the out-of-the-money option at each of nine strikes around the money on the next expiry, a put below the index and a call above it, and prints each strike's implied volatility.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/index_option/volatility_smile.R

library(tradeR)

#' The implied volatility across strikes of one index's options.
#'
#' @field underlying_symbol The character symbol of the index.
#' @field strikes_each_side The integer number of strikes to show on each side of the money.
VolatilitySmile <- R6::R6Class(
  "VolatilitySmile",
  public = list(
    underlying_symbol = NULL,
    strikes_each_side = NULL,

    #' @description
    #' Stores what to show.
    #' @param underlying_symbol The character symbol of an NSE index with options.
    #' @param strikes_each_side The integer number of strikes on each side of the money.
    #' @return A new `VolatilitySmile` object.
    initialize = function(
      underlying_symbol = "BANKNIFTY",
      strikes_each_side = 4
    ) {
      self$underlying_symbol <- underlying_symbol
      self$strikes_each_side <- strikes_each_side
    },

    #' @description
    #' Chooses the first expiry after today.
    #' @return The `Date` of the expiry.
    #' @details Errors: signals `ValueError` when no expiry after today is listed, and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    choose_expiry = function() {
      today <- TimeConverter$new()$today()
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        if (expiry_date > today) {
          return(expiry_date)
        }
      }
      ErrorCatalogue$raise(
        "ValueError",
        sprintf(
          "No expiry after today is listed: self$underlying_symbol='%s'",
          self$underlying_symbol
        )
      )
    },

    #' @description
    #' Prints one line per strike, lowest first.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no expiry after today is listed, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      expiry_date <- self$choose_expiry()
      index <- EquityIndex$new(
        exchange = "nse",
        symbol = self$underlying_symbol
      )
      level <- index$last_price
      strikes <- EquityIndexOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      nearest_index <- 1
      for (position in seq_along(strikes)) {
        distance <- abs(strikes[[position]] - level)
        if (distance < abs(strikes[[nearest_index]] - level)) {
          nearest_index <- position
        }
      }
      first <- max(nearest_index - self$strikes_each_side, 1)
      last <- min(nearest_index + self$strikes_each_side, length(strikes))
      cat(sprintf(
        "%s at %s, expiry %s\n",
        self$underlying_symbol,
        format(level),
        format(expiry_date)
      ))
      for (strike in strikes[first:last]) {
        option_type <- "CE"
        if (strike < level) {
          option_type <- "PE"
        }
        option <- EquityIndexOption$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike,
          option_type = option_type,
          underlying = index
        )
        volatility <- option$implied_volatility()
        if (is.null(volatility)) {
          cat(sprintf(
            "  %9.0f %s  no implied volatility\n",
            strike,
            option_type
          ))
        } else {
          cat(sprintf(
            "  %9.0f %s  %6.2f%%\n",
            strike,
            option_type,
            volatility * 100
          ))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  VolatilitySmile$new()$run()
}
