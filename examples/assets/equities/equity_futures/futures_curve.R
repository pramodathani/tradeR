#' Print the futures curve of a share, one line per live expiry.
#'
#' The program lists every live RELIANCE futures contract on the nse, builds each one from its row, and prints its last price next to its premium over the share, so the premium can be seen growing with time to expiry.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_futures/futures_curve.R

library(tradeR)

#' The live futures contracts on one share, from the soonest expiry to the latest.
#'
#' @field underlying_symbol The character symbol of the share, such as `"RELIANCE"`.
ShareFuturesCurve <- R6::R6Class(
  "ShareFuturesCurve",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the share whose curve to print.
    #' @param underlying_symbol The character nse symbol of the share.
    #' @return A new `ShareFuturesCurve` object.
    initialize = function(underlying_symbol = "RELIANCE") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      as.character(value)
    },

    #' @description
    #' Lists the contracts and prints one line for each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityFuturesError` when a listed contract could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      rows <- EquityFutures$contracts(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (is.null(rows)) {
        cat(sprintf("No live futures on %s.\n", self$underlying_symbol))
        return(invisible(NULL))
      }
      share <- Equity$new(exchange = "nse", symbol = self$underlying_symbol)
      cat(
        sprintf(
          "%s share: %s\n",
          self$underlying_symbol,
          self$display_text(share$last_price)
        )
      )
      for (row_index in seq_len(nrow(rows))) {
        expiry_date <- rows$expiry_date[[row_index]]
        contract <- EquityFutures$new(
          exchange = "nse",
          underlying_symbol = self$underlying_symbol,
          expiry_date = expiry_date,
          underlying = share
        )
        basis_percent <- contract$basis_percent
        if (is.null(basis_percent)) {
          premium <- "unknown"
        } else {
          premium <- sprintf("%.2f%%", basis_percent)
        }
        cat(
          sprintf(
            "%s: %s, premium %s\n",
            format(expiry_date),
            self$display_text(contract$last_price),
            premium
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ShareFuturesCurve$new()$run()
}
