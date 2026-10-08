#' Send a DELETE to a route that only answers GET and handle the ServerError.
#'
#' HTTP 405 has no more specific class in the client, so it arrives as ServerError, the class for any failure status without its own subclass. The program sends DELETE to the instrument details route, catches ServerError, and prints the status code.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/server_error/send_a_method_the_route_does_not_allow.R

library(tradeR)

#' A request sent with a method the route does not allow.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the request is sent through.
#' @field path The character route the request is sent to.
WrongMethodRequest <- R6::R6Class(
  "WrongMethodRequest",
  public = list(
    unified_broker_interface = NULL,
    path = NULL,

    #' @description
    #' Creates the request with its client and route.
    #' @return A new `WrongMethodRequest` object.
    #' @details Errors: signals a plain error when the client's base url or MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
      self$path <- "/api/instruments/details"
    },

    #' @description
    #' Sends the request and prints the error.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed with a status that has its own subclass.
    run = function() {
      answer <- tryCatch(
        self$unified_broker_interface$delete(self$path),
        ServerError = function(error) error
      )
      if (inherits(answer, "ServerError")) {
        cat(
          sprintf(
            "ServerError (%s): %s\n",
            toString(answer$status_code),
            conditionMessage(answer)
          )
        )
        return(invisible(NULL))
      }
      cat(
        "Unexpectedly answered: ",
        jsonlite::toJSON(answer, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WrongMethodRequest$new()$run()
}
