#' Summarise positions and holdings for IDEA, catching UnifiedBrokerInterfaceError for each part separately.
#'
#' A summary built from several reads should still show the parts that worked when one fails. The program reads the IDEA positions and holding, catching the base class UnifiedBrokerInterfaceError around each, so a BrokerError (HTTP 502, no broker's data could be read) or a ServiceUnavailableError (HTTP 503, UBI's document is stale) in one part is reported by status code while the other part is still shown. Nothing is placed.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/broker_error/summarise_the_account_when_brokers_fail.R

library(tradeR)

#' A summary of what the account has in IDEA, part by part.
#'
#' @field share The `Equity` summarised.
IdeaSummary <- R6::R6Class(
  "IdeaSummary",
  public = list(
    share = NULL,

    #' @description
    #' Creates the summary for the IDEA share.
    #' @return A new `IdeaSummary` object.
    #' @details Errors: signals `EquityError` when UBI does not know the share, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Reads the net positions and describes them.
    #' @return A character line with the number of positions, or why they could not be read.
    describe_positions = function() {
      positions <- tryCatch(
        self$share$net_positions,
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(positions, "UnifiedBrokerInterfaceError")) {
        return(
          sprintf(
            "Positions unavailable: %s (%s)",
            ErrorCatalogue$name_of(positions),
            toString(positions$status_code)
          )
        )
      }
      if (is.null(positions)) {
        return("Positions: none")
      }
      sprintf("Positions: %d row(s)", nrow(positions))
    },

    #' @description
    #' Reads the holding and describes it.
    #' @return A character line with the quantity held, or why it could not be read.
    describe_holding = function() {
      holding <- tryCatch(
        self$share$holdings,
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(holding, "UnifiedBrokerInterfaceError")) {
        return(
          sprintf(
            "Holding unavailable: %s (%s)",
            ErrorCatalogue$name_of(holding),
            toString(holding$status_code)
          )
        )
      }
      if (is.null(holding)) {
        return("Holding: none")
      }
      sprintf("Holding: %s shares", holding[["quantity"]])
    },

    #' @description
    #' Prints both parts of the summary.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(self$describe_positions(), "\n", sep = "")
      cat(self$describe_holding(), "\n", sep = "")
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IdeaSummary$new()$run()
}
