#' Ask the Option base class for an option chain, catch InstrumentError and use a family class instead.
#'
#' The option discovery class methods read the segment a family class such as EquityIndexOption names. Called on the Option base class, which names none, `chain` raises OptionError. The program catches it through its base class InstrumentError, reads the chain through EquityIndexOption instead, and prints the strikes around the middle of it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/option_error/read_a_chain_through_a_family_class.R

library(tradeR)

#' A reader of the NIFTY option chain for the soonest expiry.
#'
#' @field exchange The character exchange the options trade on.
#' @field underlying_symbol The character symbol of the index.
OptionChainReader <- R6::R6Class(
  "OptionChainReader",
  public = list(
    exchange = NULL,
    underlying_symbol = NULL,

    #' @description
    #' Creates the reader for NIFTY options.
    #' @return A new `OptionChainReader` object.
    initialize = function() {
      self$exchange <- "nse"
      self$underlying_symbol <- "NIFTY"
    },

    #' @description
    #' Reads the chain through the Option base class, falling back to EquityIndexOption.
    #' @param expiry_date The `Date` whose chain to read.
    #' @return A `data.frame` of the chain, or `NULL` when nothing is listed.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    read_chain = function(expiry_date) {
      tryCatch(
        Option$chain(
          exchange = self$exchange,
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date
        ),
        InstrumentError = function(error) {
          cat(
            sprintf("%s: %s\n", class(error)[[1]], conditionMessage(error))
          )
          EquityIndexOption$chain(
            exchange = self$exchange,
            underlying_symbol = self$underlying_symbol,
            expiry_date = expiry_date
          )
        }
      )
    },

    #' @description
    #' Reads the soonest chain and prints six rows from its middle.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      expiry_date <- EquityIndexOption$expiries(
        exchange = self$exchange,
        underlying_symbol = self$underlying_symbol
      )[1]
      chain <- self$read_chain(expiry_date)
      if (is.null(chain)) {
        cat(
          sprintf(
            "No %s option expires on %s.\n",
            self$underlying_symbol,
            format(expiry_date)
          )
        )
        return(invisible(NULL))
      }
      middle <- nrow(chain) %/% 2
      columns <- c(
        "strike_price",
        "option_type",
        "instrument_id"
      )
      first_row <- max(middle - 2, 1)
      last_row <- min(middle + 3, nrow(chain))
      cat(
        sprintf(
          "%d options expire on %s; six from the middle:\n",
          nrow(chain),
          format(expiry_date)
        )
      )
      print(chain[first_row:last_row, columns], row.names = FALSE)
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OptionChainReader$new()$run()
}
