#' Value the bullion index call nearest the money off the index future.
#'
#' The program builds the soonest MCXBULLDEX future, gives it to the call nearest its price on the matching option expiry as the underlying, and prints the call's premium and, when it has traded, its implied volatility and greeks under Black-76.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_index_option/bullion_index_option_valuation.R

library(tradeR)

#' A valuation of the call nearest the money on one commodity index.
#'
#' @field underlying_symbol The character mcx symbol of the index, such as `"MCXBULLDEX"`.
BullionIndexOptionValuation <- R6::R6Class(
  "BullionIndexOptionValuation",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the index whose option to value.
    #' @param underlying_symbol The character mcx symbol of the index.
    #' @return A new `BullionIndexOptionValuation` object.
    initialize = function(underlying_symbol = "MCXBULLDEX") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Builds the future and the call, and prints the valuation. The future chosen is the first that expires on or after the option, or the last one listed when none does.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityIndexFuturesError` when UBI has no such future; `CommodityIndexOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      option_expiries <- CommodityIndexOption$expiries(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol
      )
      futures_expiries <- CommodityIndexFutures$expiries(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol
      )
      if (length(option_expiries) == 0 || length(futures_expiries) == 0) {
        cat(sprintf("%s lacks options or futures.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      expiry_date <- option_expiries[[1]]
      future_expiry <- futures_expiries[[length(futures_expiries)]]
      for (candidate_index in seq_along(futures_expiries)) {
        candidate <- futures_expiries[[candidate_index]]
        if (candidate >= expiry_date) {
          future_expiry <- candidate
          break
        }
      }
      future <- CommodityIndexFutures$new(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = future_expiry
      )
      future_price <- future$last_price
      strikes <- CommodityIndexOption$strikes(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      strike_price <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - future_price) < abs(strike_price - future_price)) {
          strike_price <- strike
        }
      }
      option <- CommodityIndexOption$new(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = "CE",
        underlying = future
      )
      cat(
        sprintf(
          "Future expiring %s at %s\n",
          format(future_expiry),
          future_price
        )
      )
      cat(
        sprintf(
          "Call at %s expiring %s\n",
          strike_price,
          format(expiry_date)
        )
      )
      premium <- tryCatch(
        option$last_price,
        ServiceUnavailableError = function(error) {
          cat("The call has no quote.\n")
          FALSE
        }
      )
      if (isFALSE(premium)) {
        return(invisible(NULL))
      }
      if (is.null(premium)) {
        cat("Premium: NULL\n")
      } else {
        cat(sprintf("Premium: %s\n", premium))
      }
      greeks <- option$greeks()
      if (is.null(greeks)) {
        cat("No greeks, because the call has not traded.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Model: %s\n", greeks[["model"]]))
      cat(
        sprintf(
          "Implied volatility: %.1f%%\n",
          greeks[["volatility"]] * 100
        )
      )
      cat(sprintf("Delta: %.3f\n", greeks[["delta"]]))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BullionIndexOptionValuation$new()$run()
}
