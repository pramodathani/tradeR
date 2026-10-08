#' Report the cost of rolling the nearest index futures into the next expiry.
#'
#' The program builds the nearest and the next future on each of two indices through the base IndexFutures class, from the instrument ids that the discovery call lists, and prints the spread between them, which is what a trader pays or receives to roll a position forward.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/index_futures/index_futures_roll_report.R

library(tradeR)

#' The roll spread of the nearest index futures.
#'
#' @field symbols A character vector of index symbols to report on.
IndexFuturesRollReport <- R6::R6Class(
  "IndexFuturesRollReport",
  public = list(
    symbols = NULL,

    #' @description
    #' Stores the indices to report on.
    #' @return A new `IndexFuturesRollReport` object.
    initialize = function() {
      self$symbols <- c(
        "NIFTY",
        "BANKNIFTY"
      )
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
    #' Prints the roll of one index's nearest future.
    #' @param symbol The character symbol of the index.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    report = function(symbol) {
      contracts <- EquityIndexFutures$contracts(
        exchange = "nse",
        underlying_symbol = symbol
      )
      if (is.null(contracts) || nrow(contracts) < 2) {
        cat(sprintf("%s: fewer than two live futures\n", symbol))
        return(invisible(NULL))
      }
      near <- IndexFutures$new(instrument_id = contracts$instrument_id[[1]])
      far <- IndexFutures$new(instrument_id = contracts$instrument_id[[2]])
      near_price <- near$last_price
      far_price <- far$last_price
      cat(sprintf(
        "%s: %s at %s, %s at %s\n",
        symbol,
        format(near$expiry_date),
        self$display_text(near_price),
        format(far$expiry_date),
        self$display_text(far_price)
      ))
      if (is.null(near_price) || is.null(far_price)) {
        cat("  a last price is missing\n")
        return(invisible(NULL))
      }
      spread <- far_price - near_price
      lot_spread <- spread * near$lot_size
      cat(sprintf(
        "  roll spread %.2f points, Rs %s a lot\n",
        spread,
        formatC(lot_spread, format = "f", digits = 0, big.mark = ",")
      ))
      invisible(NULL)
    },

    #' @description
    #' Prints the roll of every index.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      for (symbol in self$symbols) {
        self$report(symbol)
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexFuturesRollReport$new()$run()
}
