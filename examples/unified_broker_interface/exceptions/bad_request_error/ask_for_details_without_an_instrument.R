#' Ask UBI for instrument details without naming an instrument and handle the BadRequestError.
#'
#' The details route needs an instrument id, or an exchange, a segment and the fields that identify one instrument. The program sends only an exchange and a segment, catches BadRequestError, and prints UBI's explanation of what was missing.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/bad_request_error/ask_for_details_without_an_instrument.R

library(tradeR)

#' A details request that leaves out the symbol.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the request is sent through.
#' @field parameters The named list of incomplete query parameters.
IncompleteDetailsRequest <- R6::R6Class(
  "IncompleteDetailsRequest",
  public = list(
    unified_broker_interface = NULL,
    parameters = NULL,

    #' @description
    #' Creates the request with its client and parameters.
    #' @return A new `IncompleteDetailsRequest` object.
    #' @details Errors: signals a plain error when the client's base url or MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
      self$parameters <- list(
        exchange = "nse",
        segment = "equities"
      )
    },

    #' @description
    #' Sends the request and prints why it was refused.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than a malformed request.
    run = function() {
      details <- tryCatch(
        self$unified_broker_interface$get(
          "/api/instruments/details",
          params = self$parameters
        ),
        BadRequestError = function(error) error
      )
      if (inherits(details, "BadRequestError")) {
        cat(
          sprintf(
            "BadRequestError (%s): %s\n",
            details$status_code,
            conditionMessage(details)
          )
        )
        return(invisible(NULL))
      }
      cat(
        "Unexpectedly found: ",
        jsonlite::toJSON(details, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IncompleteDetailsRequest$new()$run()
}
