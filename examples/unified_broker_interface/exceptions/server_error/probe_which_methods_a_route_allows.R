#' Probe which HTTP methods a route allows, catching UnifiedBrokerInterfaceError.
#'
#' The program sends GET, POST, PUT, PATCH and DELETE to the session status route, which only answers GET. Each refused method signals ServerError for HTTP 405, which is caught through the base class UnifiedBrokerInterfaceError, and the program prints the status of each method. None of the refused requests changes anything.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/server_error/probe_which_methods_a_route_allows.R

library(tradeR)

#' A probe of the methods one route answers.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the requests are sent through.
#' @field path The character route probed.
MethodProbe <- R6::R6Class(
  "MethodProbe",
  public = list(
    unified_broker_interface = NULL,
    path = NULL,

    #' @description
    #' Creates the probe with its client and route.
    #' @return A new `MethodProbe` object.
    #' @details Errors: signals a plain error when the client's base url or MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
      self$path <- "/api/session/status"
    },

    #' @description
    #' Sends one method to the route and prints the outcome.
    #' @param method_name The character HTTP method, for the printed line.
    #' @param send The client method that sends it, a function taking the route.
    #' @return `NULL`, invisibly.
    probe = function(method_name, send) {
      answer <- tryCatch(
        send(self$path),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(answer, "UnifiedBrokerInterfaceError")) {
        cat(
          sprintf(
            "%-7s refused: %s (%s)\n",
            method_name,
            ErrorCatalogue$name_of(answer),
            toString(answer$status_code)
          )
        )
        return(invisible(NULL))
      }
      cat(sprintf("%-7s allowed\n", method_name))
      invisible(NULL)
    },

    #' @description
    #' Probes the five methods.
    #' @return `NULL`, invisibly.
    run = function() {
      self$probe("GET", self$unified_broker_interface$get)
      self$probe("POST", self$unified_broker_interface$post)
      self$probe("PUT", self$unified_broker_interface$put)
      self$probe("PATCH", self$unified_broker_interface$patch)
      self$probe("DELETE", self$unified_broker_interface$delete)
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MethodProbe$new()$run()
}
