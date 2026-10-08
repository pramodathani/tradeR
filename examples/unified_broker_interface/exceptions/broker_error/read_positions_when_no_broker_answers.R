#' Read the IDEA positions with handling for the BrokerError UBI signals when no broker's data can be read.
#'
#' When UBI cannot read a single broker's positions it answers HTTP 502 and the client signals BrokerError. A program that reports positions should then say the figures are unavailable rather than report no position. The program reads the net positions in IDEA, handles a BrokerError if there is one, and prints what it found. Nothing is placed.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/broker_error/read_positions_when_no_broker_answers.R

library(tradeR)

#' A report of the IDEA positions that tells unavailable figures apart from none.
#'
#' @field share The `Equity` reported on.
PositionReport <- R6::R6Class(
  "PositionReport",
  public = list(
    share = NULL,

    #' @description
    #' Creates the report for the IDEA share.
    #' @return A new `PositionReport` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Reads the positions and prints them, or says they are unavailable.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than every broker failing.
    run = function() {
      positions <- tryCatch(
        self$share$net_positions,
        BrokerError = function(error) error
      )
      if (inherits(positions, "BrokerError")) {
        cat(
          sprintf(
            "BrokerError (%s): %s\n",
            positions$status_code,
            conditionMessage(positions)
          )
        )
        cat(
          "No broker's positions could be read, so the figures are unavailable rather than zero.\n"
        )
        return(invisible(NULL))
      }
      if (is.null(positions)) {
        cat("Every broker answered, and none holds an IDEA position.\n")
        return(invisible(NULL))
      }
      print(positions, row.names = FALSE)
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  PositionReport$new()$run()
}
