#' Print the crude oil option chain around the price of the future it settles into.
#'
#' The program lists the CRUDEOIL option expiries on the mcx, reads the chain for the soonest one, finds the future the options are priced off, and prints the calls and puts at the five strikes nearest that future's price with their last prices.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/commodities/commodity_option/crude_option_chain.R

library(tradeR)

#' A slice of one commodity's option chain around the money.
#'
#' @field underlying_symbol The character mcx symbol of the commodity, such as `"CRUDEOIL"`.
#' @field strike_count The integer number of strikes nearest the money to show.
CrudeOptionChain <- R6::R6Class(
  "CrudeOptionChain",
  public = list(
    underlying_symbol = NULL,
    strike_count = NULL,

    #' @description
    #' Stores the commodity and how many strikes to show.
    #' @param underlying_symbol The character mcx symbol of the commodity.
    #' @param strike_count The integer number of strikes to show.
    #' @return A new `CrudeOptionChain` object.
    initialize = function(underlying_symbol = "CRUDEOIL", strike_count = 5) {
      self$underlying_symbol <- underlying_symbol
      self$strike_count <- strike_count
    },

    #' @description
    #' Reads the chain and prints the options nearest the money.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `CommodityOptionError` when a listed option could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- CommodityOption$expiries(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      expiry_date <- expiries[[1]]
      strikes <- CommodityOption$strikes(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      probe <- CommodityOption$new(
        exchange = "mcx",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strikes[[1]],
        option_type = "CE"
      )
      future_price <- probe$underlying_price
      cat(
        sprintf(
          "%s options expiring %s\n",
          self$underlying_symbol,
          format(expiry_date)
        )
      )
      cat(sprintf("%d strikes, future at %s\n", length(strikes), future_price))
      by_distance <- strikes[order(abs(strikes - future_price))]
      nearest_strikes <- sort(head(by_distance, self$strike_count))
      option_types <- c(
        "CE",
        "PE"
      )
      for (strike_price in nearest_strikes) {
        prices <- character(0)
        for (option_type in option_types) {
          option <- CommodityOption$new(
            exchange = "mcx",
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
  CrudeOptionChain$new()$run()
}
