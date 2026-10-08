#' Report the open interest and contract value of the nearest index futures.
#'
#' The program builds the nearest future on each of three indices and prints its underlying's level, its open interest now and its range today in lots, and what one lot is worth at the last price.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/derivative/open_interest_report.R

library(tradeR)

#' A report of open interest across the nearest index futures.
#'
#' @field futures A list of `Derivative` objects, the nearest future on each index.
OpenInterestReport <- R6::R6Class(
  "OpenInterestReport",
  public = list(
    futures = NULL,

    #' @description
    #' Builds the nearest future on each index.
    #' @return A new `OpenInterestReport` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      symbols <- c(
        "NIFTY",
        "BANKNIFTY",
        "FINNIFTY"
      )
      self$futures <- list()
      for (symbol in symbols) {
        expiries <- EquityIndexFutures$expiries(
          exchange = "nse",
          underlying_symbol = symbol
        )
        future <- EquityIndexFutures$new(
          exchange = "nse",
          underlying_symbol = symbol,
          expiry_date = expiries[[1]]
        )
        self$futures[[length(self$futures) + 1]] <- future
      }
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      format(value)
    },

    #' @description
    #' Turns a count of underlying units into lots for printing.
    #' @param units The integer number of underlying units, or `NULL` when unknown.
    #' @param contract The `Derivative` whose lot size to divide by.
    #' @return The character number of lots, or a dash when either figure is unknown.
    in_lots = function(units, contract) {
      lot_size <- contract$lot_size
      if (is.null(units) || is.null(lot_size) || lot_size == 0) {
        return("-")
      }
      formatC(units %/% lot_size, format = "d", big.mark = ",")
    },

    #' @description
    #' Prints one block per future.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      for (future in self$futures) {
        cat(sprintf(
          "%s %s:\n",
          future$underlying_symbol,
          format(future$expiry_date)
        ))
        cat(sprintf(
          "  underlying at %s\n",
          self$display_text(future$underlying_price)
        ))
        cat(sprintf(
          "  open interest %s lots\n",
          self$in_lots(future$open_interest, future)
        ))
        low <- self$in_lots(future$open_interest_day_low, future)
        high <- self$in_lots(future$open_interest_day_high, future)
        cat(sprintf("  today's range %s to %s lots\n", low, high))
        contract_value <- future$contract_value
        if (is.null(contract_value)) {
          cat("  one lot: unknown\n")
        } else {
          cat(sprintf(
            "  one lot of %s worth Rs %s\n",
            format(future$lot_size),
            formatC(contract_value, format = "f", digits = 0, big.mark = ",")
          ))
        }
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OpenInterestReport$new()$run()
}
