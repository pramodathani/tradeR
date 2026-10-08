#' Recover from a strike price that is not listed by catching CommodityIndexOptionError.
#'
#' The program asks for an MCXBULLDEX call option at a strike price that is not listed, catches CommodityIndexOptionError, then reads the strikes that are listed for the expiry and builds the option at the one nearest the strike asked for.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/commodity_index_option_error/recover_from_an_unlisted_strike.R

library(tradeR)

#' A lookup of an option that falls back to the nearest listed strike.
#'
#' @field exchange The character exchange the option trades on.
#' @field underlying_symbol The character symbol the option is written on.
#' @field fallback_expiry_date The `Date` to ask for when no expiry is listed at all.
#' @field wanted_strike_price The numeric strike price the person asked for, which is not listed.
#' @field option_type The character option type, `CE` for a call.
UnlistedStrikeRecovery <- R6::R6Class(
  "UnlistedStrikeRecovery",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,
    fallback_expiry_date = NULL,
    wanted_strike_price = NULL,
    option_type = NULL,

    #' @description
    #' Creates the lookup with the option the person asked for.
    #' @return A new `UnlistedStrikeRecovery` object.
    initialize = function() {
      self$exchange <- "mcx"
      self$underlying_symbol <- "MCXBULLDEX"
      self$fallback_expiry_date <- as.Date("2026-10-28")
      self$wanted_strike_price <- 33050.0
      self$option_type <- "CE"
    },

    #' @description
    #' Picks the soonest listed expiry.
    #' @return The first listed `Date`, or fallback_expiry_date when nothing is listed.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    nearest_expiry = function() {
      listed_expiries <- CommodityIndexOption$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      if (length(listed_expiries) > 0) {
        return(listed_expiries[1])
      }
      self$fallback_expiry_date
    },

    #' @description
    #' Picks the listed strike closest to the one asked for.
    #' @param expiry_date The `Date` whose strikes to read.
    #' @return The numeric listed strike nearest wanted_strike_price, or `NULL` when no strike is listed.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    nearest_listed_strike = function(expiry_date) {
      listed_strikes <- CommodityIndexOption$strikes(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      nearest_strike <- NULL
      for (strike_price in listed_strikes) {
        if (is.null(nearest_strike)) {
          nearest_strike <- strike_price
          next
        }
        distance <- abs(strike_price - self$wanted_strike_price)
        if (distance < abs(nearest_strike - self$wanted_strike_price)) {
          nearest_strike <- strike_price
        }
      }
      nearest_strike
    },

    #' @description
    #' Looks one option up in UBI.
    #' @param expiry_date The `Date` the option expires on.
    #' @param strike_price The numeric strike price of the option.
    #' @return The `CommodityIndexOption` UBI knows for that expiry and strike.
    #' @details Errors: signals `CommodityIndexOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    build_option = function(expiry_date, strike_price) {
      CommodityIndexOption$new(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = self$option_type
      )
    },

    #' @description
    #' Asks for the unlisted strike, recovers from the error and prints the option found.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- self$nearest_expiry()
      option <- tryCatch(
        self$build_option(expiry_date, self$wanted_strike_price),
        CommodityIndexOptionError = function(error) {
          cat(
            sprintf(
              "CommodityIndexOptionError: %s\n",
              conditionMessage(error)
            )
          )
          NULL
        }
      )
      if (is.null(option)) {
        strike_price <- self$nearest_listed_strike(expiry_date)
        if (is.null(strike_price)) {
          cat(
            sprintf(
              "No strike is listed for %s, which is expected for a mistyped name.\n",
              format(expiry_date)
            )
          )
          return(invisible(NULL))
        }
        cat(
          sprintf(
            "Using the listed strike %s instead.\n",
            format(strike_price)
          )
        )
        option <- self$build_option(expiry_date, strike_price)
      }
      cat(sprintf("Option: %s\n", option$format()))
      cat(
        sprintf(
          "Strike %s %s, expiring %s\n",
          format(option$strike_price),
          option$option_type,
          format(option$expiry_date)
        )
      )
      cat(sprintf("Lot size: %s\n", format(option$lot_size)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  UnlistedStrikeRecovery$new()$run()
}
