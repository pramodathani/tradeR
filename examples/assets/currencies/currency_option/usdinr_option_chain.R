#' Print the dollar-rupee option chain around the money.
#'
#' The program reads the USDINR option chain on the nse for the soonest expiry after today, finds the future the options are priced off, and prints the calls and puts at the five strikes nearest that future's rate with their last prices.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_option/usdinr_option_chain.R

library(tradeR)

#' A slice of one currency pair's option chain around the money.
#'
#' @field underlying_symbol The character symbol of the pair, such as `"USDINR"`.
#' @field strike_count The integer number of strikes nearest the money to show.
DollarRupeeOptionChain <- R6::R6Class(
  "DollarRupeeOptionChain",
  public = list(
    underlying_symbol = NULL,
    strike_count = NULL,

    #' @description
    #' Stores the pair and how many strikes to show.
    #' @param underlying_symbol The character symbol of the pair.
    #' @param strike_count The integer number of strikes to show.
    #' @return A new `DollarRupeeOptionChain` object.
    initialize = function(underlying_symbol = "USDINR", strike_count = 5) {
      self$underlying_symbol <- underlying_symbol
      self$strike_count <- strike_count
    },

    #' @description
    #' Chooses the soonest option expiry after today, or the soonest listed when none is later than today.
    #' @return The `Date` of the expiry, or `NULL` when no option is listed.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    next_expiry = function() {
      expiries <- CurrencyOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        return(NULL)
      }
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          return(expiry)
        }
      }
      expiries[[1]]
    },

    #' @description
    #' Reads the chain and prints the options nearest the money.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CurrencyOptionError` when a listed option could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- self$next_expiry()
      if (is.null(expiry_date)) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      strikes <- CurrencyOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      probe <- CurrencyOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strikes[[1]],
        option_type = "CE"
      )
      future_rate <- probe$underlying_price
      cat(
        sprintf(
          "%s options expiring %s\n",
          self$underlying_symbol,
          format(expiry_date)
        )
      )
      cat(sprintf("%d strikes, future at %s\n", length(strikes), future_rate))
      by_distance <- strikes[order(abs(strikes - future_rate))]
      nearest_strikes <- sort(head(by_distance, self$strike_count))
      option_types <- c(
        "CE",
        "PE"
      )
      for (strike_price in nearest_strikes) {
        prices <- character(0)
        for (option_type in option_types) {
          option <- CurrencyOption$new(
            exchange = "nse",
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date,
            strike_price = strike_price,
            option_type = option_type
          )
          price_text <- tryCatch(
            {
              last_price <- option$last_price
              if (is.null(last_price)) {
                last_price <- "NULL"
              }
              sprintf("%s %s", option_type, last_price)
            },
            ServiceUnavailableError = function(error) {
              sprintf("%s no quote", option_type)
            }
          )
          prices <- c(
            prices,
            price_text
          )
        }
        cat(sprintf("%s: %s\n", strike_price, paste(prices, collapse = ", ")))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DollarRupeeOptionChain$new()$run()
}
