#' Price an at-the-money straddle on Reliance and print where it breaks even.
#'
#' A straddle is one call and one put at the same strike, bought together, which pays off when the share moves far in either direction. The program builds both options at the strike nearest the share price on the nearest expiry, and prints the cost of one lot of each, the intrinsic and time value in each premium, the notional value controlled and the two share prices at which the straddle breaks even at expiry.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/option/straddle_breakevens.R

library(tradeR)

#' An at-the-money straddle on one share.
#'
#' @field underlying_symbol The character symbol of the share.
#' @field share The `Equity` the options are written on.
StraddleBreakevens <- R6::R6Class(
  "StraddleBreakevens",
  public = list(
    underlying_symbol = NULL,
    share = NULL,

    #' @description
    #' Looks the share up in UBI.
    #' @param underlying_symbol The character symbol of an NSE share with options.
    #' @return A new `StraddleBreakevens` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function(underlying_symbol = "RELIANCE") {
      self$underlying_symbol <- underlying_symbol
      self$share <- Equity$new(exchange = "nse", symbol = underlying_symbol)
    },

    #' @description
    #' Builds one option of the straddle.
    #' @param expiry_date The `Date` of the expiry.
    #' @param strike The numeric strike price.
    #' @param option_type The character option type, `"CE"` or `"PE"`.
    #' @return The `EquityOption`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    build_leg = function(expiry_date, strike, option_type) {
      EquityOption$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike,
        option_type = option_type,
        underlying = self$share
      )
    },

    #' @description
    #' Prints the straddle's legs, its total cost and its breakevens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      expiries <- EquityOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      expiry_date <- expiries[[1]]
      strikes <- EquityOption$strikes(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      share_price <- self$share$last_price
      strike <- strikes[[1]]
      for (candidate in strikes) {
        if (abs(candidate - share_price) < abs(strike - share_price)) {
          strike <- candidate
        }
      }
      call <- self$build_leg(expiry_date, strike, "CE")
      put <- self$build_leg(expiry_date, strike, "PE")
      cat(sprintf(
        "%s at %s, strike %s, %s\n",
        self$underlying_symbol,
        format(share_price),
        format(strike),
        format(expiry_date)
      ))
      total_premium <- 0
      legs <- list(
        call,
        put
      )
      for (option in legs) {
        premium <- option$last_price
        total_premium <- total_premium + premium
        cat(sprintf(
          paste0(
            "  %s: premium %s, intrinsic %.2f, time %.2f, ",
            "in the money %s, one lot Rs %s\n"
          ),
          option$option_type,
          format(premium),
          option$intrinsic_value,
          option$time_value,
          format(option$in_the_money),
          formatC(
            option$premium_per_lot,
            format = "f",
            digits = 0,
            big.mark = ","
          )
        ))
      }
      cat(sprintf(
        "  notional per lot Rs %s\n",
        formatC(call$notional_value, format = "f", digits = 0, big.mark = ",")
      ))
      cat(sprintf("  straddle costs %.2f a share\n", total_premium))
      cat(sprintf(
        "  breaks even below %.2f or above %.2f\n",
        strike - total_premium,
        strike + total_premium
      ))
      cat(sprintf(
        "  call breakeven %.2f, put breakeven %.2f\n",
        call$breakeven_price,
        put$breakeven_price
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StraddleBreakevens$new()$run()
}
