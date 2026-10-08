#' Compare the call and the put at one strike on a share.
#'
#' The program takes the soonest RELIANCE option expiry after today and the strike closest to the share's price, builds the call and the put there, and prints what each premium is made of and where each breaks even.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_option/put_call_pair.R

library(tradeR)

#' The call and the put at the same strike and expiry on one share.
#'
#' @field share The `Equity` the options are written on.
SharePutCallPair <- R6::R6Class(
  "SharePutCallPair",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up in UBI.
    #' @param underlying_symbol The character nse symbol of the share.
    #' @return A new `SharePutCallPair` object.
    #' @details Errors: signals `EquityError` when UBI has no nse share with that symbol.
    initialize = function(underlying_symbol = "RELIANCE") {
      self$share <- Equity$new(exchange = "nse", symbol = underlying_symbol)
    },

    #' @description
    #' Chooses the soonest expiry after today and the strike nearest the share's price.
    #' @return A named list with `expiry_date`, a `Date`, and `strike_price`, a numeric price in rupees.
    #' @details Errors: signals `ValueError` when no options are listed on the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    expiry_and_strike = function() {
      expiries <- EquityOption$expiries(
        exchange = "nse",
        underlying_symbol = self$share$symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No options are listed on %s", self$share$symbol)
        )
      }
      expiry_date <- expiries[[1]]
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          expiry_date <- expiry
          break
        }
      }
      strikes <- EquityOption$strikes(
        exchange = "nse",
        underlying_symbol = self$share$symbol,
        expiry_date = expiry_date
      )
      share_price <- self$share$last_price
      strike_price <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - share_price) < abs(strike_price - share_price)) {
          strike_price <- strike
        }
      }
      list(
        expiry_date = expiry_date,
        strike_price = strike_price
      )
    },

    #' @description
    #' Builds both options and prints them side by side.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no options are listed on the share; `EquityOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      choice <- self$expiry_and_strike()
      expiry_date <- choice[["expiry_date"]]
      strike_price <- choice[["strike_price"]]
      cat(sprintf("%s at %s\n", self$share$symbol, self$share$last_price))
      cat(
        sprintf(
          "Strike %s, expiring %s\n",
          strike_price,
          format(expiry_date)
        )
      )
      option_types <- c(
        "CE",
        "PE"
      )
      for (option_type in option_types) {
        option <- EquityOption$new(
          exchange = "nse",
          underlying_symbol = self$share$symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = self$share
        )
        cat(
          sprintf(
            "%s: premium %s, intrinsic %.2f, time value %.2f, in the money %s, breakeven %s\n",
            option_type,
            option$last_price,
            option$intrinsic_value,
            option$time_value,
            option$in_the_money,
            option$breakeven_price
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SharePutCallPair$new()$run()
}
