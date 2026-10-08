#' Connect to an address where UBI is not running and handle the UnreachableError.
#'
#' When no response arrives at all, such as when UBI is stopped or the address is wrong, the client signals UnreachableError, whose status code is `NULL`. The program points a client at a port nothing listens on, asks for the session status, catches UnreachableError and prints it.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/unreachable_error/connect_to_the_wrong_port.R

library(tradeR)

#' A connection attempt to a port where UBI does not listen.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` pointed at the wrong port.
WrongPortConnection <- R6::R6Class(
  "WrongPortConnection",
  public = list(
    unified_broker_interface = NULL,

    #' @description
    #' Creates the client with the wrong address and a short timeout.
    #' @return A new `WrongPortConnection` object.
    #' @details Errors: signals a plain error when the MongoDB credentials are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new(
        base_url = "http://127.0.0.1:9",
        timeout_seconds = 2
      )
    },

    #' @description
    #' Asks for the session status and prints the error.
    #' @return `NULL`, invisibly.
    run = function() {
      status <- tryCatch(
        self$unified_broker_interface$status(),
        UnreachableError = function(error) error
      )
      if (inherits(status, "UnreachableError")) {
        status_code_text <- "NULL"
        if (!is.null(status$status_code)) {
          status_code_text <- as.character(status$status_code)
        }
        cat(sprintf("UnreachableError, status code %s\n", status_code_text))
        cat(conditionMessage(status), "\n", sep = "")
        return(invisible(NULL))
      }
      cat(
        "Unexpectedly connected: ",
        jsonlite::toJSON(status, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WrongPortConnection$new()$run()
}
