#' Send a request UBI refuses and report the UnifiedBrokerInterfaceError it signals.
#'
#' Every failure the client reports is a UnifiedBrokerInterfaceError, which carries the message, the HTTP status code and the body UBI answered with. The program asks UBI for the details of a share that does not exist, catches the base class, and prints all three.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/unified_broker_interface_error/report_a_failed_request.R

library(tradeR)

#' A report of one request UBI refuses.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the request is sent through.
#' @field parameters The named list of query parameters naming a share that does not exist.
FailedRequestReport <- R6::R6Class(
  "FailedRequestReport",
  public = list(
    unified_broker_interface = NULL,
    parameters = NULL,

    #' @description
    #' Creates the report with its client and the request to send.
    #' @return A new `FailedRequestReport` object.
    #' @details Errors: signals a plain error when the client's base url or MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
      self$parameters <- list(
        exchange = "nse",
        segment = "equities",
        symbol = "NOSUCHSHARE"
      )
    },

    #' @description
    #' Sends the request and prints what the error carries.
    #' @return `NULL`, invisibly.
    run = function() {
      details <- tryCatch(
        self$unified_broker_interface$get(
          "/api/instruments/details",
          params = self$parameters
        ),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(details, "UnifiedBrokerInterfaceError")) {
        cat(sprintf("Class: %s\n", ErrorCatalogue$name_of(details)))
        cat(sprintf("Message: %s\n", conditionMessage(details)))
        cat(sprintf("HTTP status code: %s\n", toString(details$status_code)))
        cat(
          "Body: ",
          jsonlite::toJSON(details$detail, auto_unbox = TRUE, null = "null"),
          "\n",
          sep = ""
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
  FailedRequestReport$new()$run()
}
