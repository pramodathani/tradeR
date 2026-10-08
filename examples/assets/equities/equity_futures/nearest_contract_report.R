#' Report on the soonest futures contract on a share that still has a day to run.
#'
#' The program lists the expiries of the RELIANCE futures on the nse, builds the first contract that expires after today, and prints its price, its size and how far it trades above the share.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_futures/nearest_contract_report.R

library(tradeR)

#' A report on the soonest futures contract on one share.
#'
#' @field underlying_symbol The character symbol of the share, such as `"RELIANCE"`.
NearestShareFuturesReport <- R6::R6Class(
  "NearestShareFuturesReport",
  public = list(
    underlying_symbol = NULL,

    #' @description
    #' Stores the share to report on.
    #' @param underlying_symbol The character nse symbol of the share.
    #' @return A new `NearestShareFuturesReport` object.
    initialize = function(underlying_symbol = "RELIANCE") {
      self$underlying_symbol <- underlying_symbol
    },

    #' @description
    #' Chooses the soonest expiry after today, so the contract still has time to run, or the soonest listed when none is later than today.
    #' @return The `Date` of the expiry.
    #' @details Errors: signals `ValueError` when no futures are listed on the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    next_expiry = function() {
      expiries <- EquityFutures$expiries(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", self$underlying_symbol)
        )
      }
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          return(expiry)
        }
      }
      expiries[[1]]
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
    #' Builds the contract and prints the report.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no futures are listed on the share; `EquityFuturesError` when UBI has no such contract; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- EquityFutures$new(
        exchange = "nse",
        underlying_symbol = self$underlying_symbol,
        expiry_date = self$next_expiry()
      )
      cat(
        sprintf(
          "%s futures expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Days to expiry: %s\n", contract$days_to_expiry))
      cat(
        sprintf("Lot size: %s shares\n", self$display_text(contract$lot_size))
      )
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      cat(
        sprintf(
          "Contract value: %s\n",
          self$display_text(contract$contract_value)
        )
      )
      cat(
        sprintf(
          "Share price: %s\n",
          self$display_text(contract$underlying_price)
        )
      )
      cat(sprintf("Basis: %.2f\n", contract$basis))
      cat(sprintf("Basis in per cent: %.2f\n", contract$basis_percent))
      cat(sprintf("Annual cost of carry: %.2f%%\n", contract$cost_of_carry))
      cat(
        sprintf(
          "Open interest: %s\n",
          self$display_text(contract$open_interest)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NearestShareFuturesReport$new()$run()
}
