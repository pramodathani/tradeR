#' Send several requests UBI refuses and tabulate the error class chosen for each status code.
#'
#' The client turns each failed response into the subclass of UnifiedBrokerInterfaceError that matches its HTTP status code. The program sends a request with a missing parameter, one for an instrument that does not exist, one with a method the route does not allow and one to an address nothing listens on, catches the base class each time, and prints a small table.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/unified_broker_interface_error/tabulate_failures_by_status_code.R

library(tradeR)

#' A table of the errors several refused requests signal.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` for the configured UBI.
#' @field unreachable_client A `UnifiedBrokerInterface` pointed at a port nothing listens on.
#' @field rows A list of the rows collected, each a named list with the character `description`, the character `class_name` and the integer `status_code`, which is `NA` when no response arrived.
FailureTable <- R6::R6Class(
  "FailureTable",
  public = list(
    unified_broker_interface = NULL,
    unreachable_client = NULL,
    rows = NULL,

    #' @description
    #' Creates the table with its two clients.
    #' @return A new `FailureTable` object.
    #' @details Errors: signals a plain error when the clients' base url or MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
      self$unreachable_client <- UnifiedBrokerInterface$new(
        base_url = "http://127.0.0.1:9",
        timeout_seconds = 2
      )
      self$rows <- list()
    },

    #' @description
    #' Asks for instrument details without naming an instrument.
    #' @return `NULL`, invisibly.
    #' @details Errors: always signals `BadRequestError`, a `UnifiedBrokerInterfaceError` subclass.
    missing_parameter = function() {
      self$unified_broker_interface$get("/api/instruments/details")
      invisible(NULL)
    },

    #' @description
    #' Asks for the details of a share that does not exist.
    #' @return `NULL`, invisibly.
    #' @details Errors: always signals `NotFoundError`, a `UnifiedBrokerInterfaceError` subclass.
    unknown_instrument = function() {
      self$unified_broker_interface$get(
        "/api/instruments/details",
        params = list(
          exchange = "nse",
          segment = "equities",
          symbol = "NOSUCHSHARE"
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Sends DELETE to a route that only answers GET.
    #' @return `NULL`, invisibly.
    #' @details Errors: always signals `ServerError`, a `UnifiedBrokerInterfaceError` subclass.
    wrong_method = function() {
      self$unified_broker_interface$delete("/api/instruments/details")
      invisible(NULL)
    },

    #' @description
    #' Asks for the session status at an address nothing listens on.
    #' @return `NULL`, invisibly.
    #' @details Errors: always signals `UnreachableError`, a `UnifiedBrokerInterfaceError` subclass.
    nothing_listening = function() {
      self$unreachable_client$status()
      invisible(NULL)
    },

    #' @description
    #' Sends one request and records the error it signals.
    #' @param description The character description of the request, for the table.
    #' @param request A function with no arguments that sends the request.
    #' @return `NULL`, invisibly.
    record = function(description, request) {
      outcome <- tryCatch(
        request(),
        UnifiedBrokerInterfaceError = function(error) error
      )
      class_name <- "no error"
      status_code <- NA_integer_
      if (inherits(outcome, "UnifiedBrokerInterfaceError")) {
        class_name <- ErrorCatalogue$name_of(outcome)
        if (!is.null(outcome$status_code)) {
          status_code <- outcome$status_code
        }
      }
      self$rows[[length(self$rows) + 1]] <- list(
        description = description,
        class_name = class_name,
        status_code = status_code
      )
      invisible(NULL)
    },

    #' @description
    #' Sends the four requests and prints the table.
    #' @return `NULL`, invisibly.
    run = function() {
      self$record("missing parameter", self$missing_parameter)
      self$record("unknown instrument", self$unknown_instrument)
      self$record("wrong method", self$wrong_method)
      self$record("nothing listening", self$nothing_listening)
      cat(sprintf("%-20s %-24s Status\n", "Request", "Error class"))
      for (row in self$rows) {
        cat(
          sprintf(
            "%-20s %-24s %s\n",
            row[["description"]],
            row[["class_name"]],
            row[["status_code"]]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FailureTable$new()$run()
}
