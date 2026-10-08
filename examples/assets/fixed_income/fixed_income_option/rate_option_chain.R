#' Print the option chain on an interest rate underlying.
#'
#' The program lists the option expiries on the 6.33 per cent government security of 2035, reads the chain for the soonest one, and prints how many calls and puts are listed and the range of strikes each covers.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_option/rate_option_chain.R

library(tradeR)

#' The option chain on one interest rate underlying for its soonest expiry.
#'
#' @field underlying_symbol The character rate code of the security, such as `"633GS2035"`.
RateOptionChain <- R6::R6Class(
  "RateOptionChain",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the security whose chain to print.
    #' @param underlying_symbol The character rate code of the security.
    #' @return A new `RateOptionChain` object.
    initialize = function(underlying_symbol = "633GS2035") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Reads the chain and prints one line per option type.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiries <- FixedIncomeOption$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        cat(sprintf("No options are listed on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      listed <- character(0)
      for (expiry_index in seq_along(expiries)) {
        listed <- c(
          listed,
          format(expiries[[expiry_index]], "%Y-%m-%d")
        )
      }
      cat(
        sprintf(
          "Option expiries on %s: %s\n",
          self$underlying_symbol,
          paste(listed, collapse = ", ")
        )
      )
      chain <- FixedIncomeOption$chain(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = expiries[[1]]
      )
      if (is.null(chain)) {
        cat("The chain is empty.\n")
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "%d options expiring %s\n",
          nrow(chain),
          format(expiries[[1]])
        )
      )
      option_types <- c(
        "CE",
        "PE"
      )
      for (option_type in option_types) {
        rows <- chain[chain$option_type == option_type, , drop = FALSE]
        if (nrow(rows) == 0) {
          cat(sprintf("%s: none listed\n", option_type))
          next
        }
        lowest <- min(rows$strike_price)
        highest <- max(rows$strike_price)
        cat(
          sprintf(
            "%s: %d strikes from %s to %s\n",
            option_type,
            nrow(rows),
            lowest,
            highest
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RateOptionChain$new()$run()
}
