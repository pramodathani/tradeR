#' Ask for a RELIANCE option through the IndexOption class and handle the IndexOptionError.
#'
#' IndexOption accepts only an option on an index. The program looks a RELIANCE share option up through it, catches IndexOptionError, and builds the same option through the general Option class instead.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/index_option_error/ask_for_a_share_option_as_an_index_option.R

library(tradeR)

#' A lookup of a share option through the IndexOption class.
#'
#' @field exchange The character exchange the option trades on.
#' @field segment The character UBI segment of share options.
#' @field underlying_symbol The character symbol of the share.
ShareOptionAsIndexOption <- R6::R6Class(
  "ShareOptionAsIndexOption",
  public = list(
    exchange = NULL,
    segment = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the lookup for a RELIANCE option.
    #' @return A new `ShareOptionAsIndexOption` object.
    initialize = function() {
      self$exchange <- "nse"
      self$segment <- "equity_options"
      self$underlying_symbol <- "RELIANCE"
    },

    #' @description
    #' Looks the option up as an index option, catches the error and builds it as a plain option.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know the option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      listed_expiries <- EquityOption$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )
      expiry_date <- listed_expiries[length(listed_expiries)]
      strike_prices <- EquityOption$strikes(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiry_date
      )
      strike_price <- strike_prices[length(strike_prices) %/% 2 + 1]
      option <- tryCatch(
        IndexOption$new(
          exchange = self$exchange,
          segment = self$segment,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = "PE"
        ),
        IndexOptionError = function(error) {
          cat(sprintf("IndexOptionError: %s\n", conditionMessage(error)))
          Option$new(
            exchange = self$exchange,
            segment = self$segment,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date,
            strike_price = strike_price,
            option_type = "PE"
          )
        }
      )
      cat(sprintf("Built %s\n", option$format()))
      cat(sprintf("Lot size: %s\n", format(option$lot_size)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareOptionAsIndexOption$new()$run()
}
