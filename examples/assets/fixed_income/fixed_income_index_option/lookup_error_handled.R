#' Try to build an option on a fixed income index and handle the error UBI gives today.
#'
#' No broker maps anything into UBI's fixed income index options segment, so every lookup fails. The program asks for an overnight MIBOR call at the expiry of the soonest MIBOR future, catches the `FixedIncomeIndexOptionError` that is signalled, and prints it, so the same code will simply start working the day UBI carries these options.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index_option/lookup_error_handled.R

library(tradeR)

#' An attempt to build one option on a fixed income index.
#'
#' @field underlying_symbol The character symbol of the index, such as `"ONMIBOR"`.
RateIndexOptionLookup <- R6::R6Class(
  "RateIndexOptionLookup",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the index to look an option up on.
    #' @param underlying_symbol The character symbol of the index.
    #' @return A new `RateIndexOptionLookup` object.
    initialize = function(underlying_symbol = "ONMIBOR") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Tries to build the option and prints either the option or the error.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      futures_expiries <- FixedIncomeIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(futures_expiries) == 0) {
        cat(
          sprintf(
            "No futures are listed on %s either.\n",
            self$underlying_symbol
          )
        )
        return(invisible(NULL))
      }
      expiry_date <- futures_expiries[[1]]
      option <- tryCatch(
        FixedIncomeIndexOption$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          strike_price = 95,
          option_type = "CE"
        ),
        FixedIncomeIndexOptionError = function(error) {
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
  RateIndexOptionLookup$new()$run()
}
