#' Try to build a currency index option and handle the error UBI gives today.
#'
#' UBI holds no rows in its currency index options segment, so every lookup fails with `CurrencyIndexOptionError`. The program borrows a real expiry and strike from the USDINR option chain, asks for a currency index option with them, catches the error, and prints it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/currencies/currency_index_option/lookup_error_handled.R

library(tradeR)

#' An attempt to build one currency index option.
#'
#' @field underlying_symbol The character symbol of the index, such as `"USDINR"`.
CurrencyIndexOptionLookup <- R6::R6Class(
  "CurrencyIndexOptionLookup",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the index whose option to look for.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `CurrencyIndexOptionLookup` object.
    initialize = function(underlying_symbol = "USDINR") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Tries to build the option at the middle strike of the soonest USDINR expiry and prints either the option or the error.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      pair_expiries <- CurrencyOption$expiries(
        exchange = "nse",
        underlying_symbol = "USDINR"
      )
      if (length(pair_expiries) == 0) {
        cat("No USDINR options are listed to borrow an expiry from.\n")
        return(invisible(NULL))
      }
      strikes <- CurrencyOption$strikes(
        exchange = "nse",
        underlying_symbol = "USDINR",
        expiry_date = pair_expiries[[1]]
      )
      strike_price <- strikes[[length(strikes) %/% 2 + 1]]
      option <- tryCatch(
        CurrencyIndexOption$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = pair_expiries[[1]],
          strike_price = strike_price,
          option_type = "CE"
        ),
        CurrencyIndexOptionError = function(error) {
          cat(sprintf("Not available today: %s\n", conditionMessage(error)))
          NULL
        }
      )
      if (is.null(option)) {
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "Found %s %s CE\n",
          option$underlying_symbol,
          option$strike_price
        )
      )
      premium <- option$last_price
      if (is.null(premium)) {
        premium <- "NULL"
      }
      cat(sprintf("Premium: %s\n", premium))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CurrencyIndexOptionLookup$new()$run()
}
