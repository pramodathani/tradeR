#' Print the greeks of the Nifty options nearest the money.
#'
#' The program finds the at-the-money strike of the next Nifty option expiry, builds the call and the put at that strike and two strikes either side of it, and prints each option's premium, moneyness, implied volatility, delta, theta and vega.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/option/option_chain_greeks.R

library(tradeR)

#' A table of greeks for the strikes around the money on one expiry.
#'
#' @field underlying_symbol The character symbol of the index.
#' @field strikes_each_side The integer number of strikes to show on each side of the money.
#' @field expiry_date The `Date` of the expiry shown, chosen when the program runs.
OptionChainGreeks <- R6::R6Class(
  "OptionChainGreeks",
  public = list(
    underlying_symbol = NULL,
    strikes_each_side = NULL,
    expiry_date = NULL,

    #' @description
    #' Stores what to show.
    #' @param underlying_symbol The character symbol of an NSE index with options.
    #' @param strikes_each_side The integer number of strikes to show on each side of the money.
    #' @return A new `OptionChainGreeks` object.
    initialize = function(underlying_symbol = "NIFTY", strikes_each_side = 2) {
      self$underlying_symbol <- underlying_symbol
      self$strikes_each_side <- strikes_each_side
      self$expiry_date <- NULL
    },

    #' @description
    #' Chooses the first expiry after today, so the options still have time left.
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
    #' Picks the strikes nearest the index level.
    #' @param level The numeric level of the index.
    #' @return A numeric vector of strikes, lowest first.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    strikes_around_the_money = function(level) {
      strikes <- EquityIndexOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = self$expiry_date
      )
      nearest_index <- 1
      for (index in seq_along(strikes)) {
        distance <- abs(strikes[[index]] - level)
        if (distance < abs(strikes[[nearest_index]] - level)) {
          nearest_index <- index
        }
      }
      first <- max(nearest_index - self$strikes_each_side, 1)
      last <- min(nearest_index + self$strikes_each_side, length(strikes))
      strikes[first:last]
    },

    #' @description
    #' Prints one line of the table for one option.
    #' @param option The `EquityIndexOption` to describe.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    print_option = function(option) {
      greeks <- option$greeks()
      if (is.null(greeks)) {
        cat(sprintf(
          "%9.0f %s  no greeks\n",
          option$strike_price,
          option$option_type
        ))
        return(invisible(NULL))
      }
      cat(sprintf(
        "%9.0f %s %9.2f %+8.2f%% %7.2f%% %7.3f %8.2f %7.2f\n",
        option$strike_price,
        option$option_type,
        option$last_price,
        option$moneyness_percent,
        greeks[["volatility"]] * 100,
        greeks[["delta"]],
        greeks[["theta"]],
        greeks[["vega"]]
      ))
      invisible(NULL)
    },

    #' @description
    #' Prints the table.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no expiry after today is listed, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$expiry_date <- self$choose_expiry()
      index <- EquityIndex$new(
        exchange = "nse",
        symbol = self$underlying_symbol
      )
      level <- index$last_price
      cat(sprintf(
        "%s at %s, expiry %s\n",
        self$underlying_symbol,
        format(level),
        format(self$expiry_date)
      ))
      cat(sprintf(
        "%9s %-3s %8s %9s %8s %7s %8s %7s\n",
        "Strike",
        "Type",
        "Premium",
        "Money",
        "IV",
        "Delta",
        "Theta",
        "Vega"
      ))
      option_types <- c(
        "CE",
        "PE"
      )
      for (strike in self$strikes_around_the_money(level)) {
        for (option_type in option_types) {
          option <- EquityIndexOption$new(
            exchange = "nse",
            underlying_symbol = self$underlying_symbol,
            expiry_date = self$expiry_date,
            strike_price = strike,
            option_type = option_type,
            underlying = index
          )
          self$print_option(option)
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OptionChainGreeks$new()$run()
}
