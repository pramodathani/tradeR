#' Check that UBI is reachable, the session is live and every broker's data is fresh.
#'
#' The program connects to UBI, prints when the access token expires and how long it has left, lists the brokers UBI is connected to, and reports how fresh each broker's funds are, flagging any broker whose data UBI marks as anything other than `ok`.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/client/unified_broker_interface/session_health_check.R

library(tradeR)

#' A health check of the UBI session and the brokers behind it.
#'
#' @field unified_broker_interface The `UnifiedBrokerInterface` the checks are sent through.
SessionHealthCheck <- R6::R6Class(
  "SessionHealthCheck",
  public = list(
    unified_broker_interface = NULL,

    #' @description
    #' Creates the client, which reads its api key and secret from MongoDB.
    #' @return A new `SessionHealthCheck` object.
    #' @details Errors: signals a plain error when the base url or the MongoDB settings are not configured.
    initialize = function() {
      self$unified_broker_interface <- UnifiedBrokerInterface$new()
    },

    #' @description
    #' Connects and prints the session's state and the token's remaining life, both counted in India time.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the api key or could not be reached.
    check_session = function() {
      self$unified_broker_interface$connect()
      session <- self$unified_broker_interface$status()
      converter <- TimeConverter$new()
      expires_at <- converter$moments(session[["expires_at"]])
      remaining <- difftime(expires_at, converter$now(), units = "mins")
      cat(sprintf("Session: %s\n", session[["status"]]))
      cat(
        sprintf(
          "Token expires at %s, in %s\n",
          format(expires_at, "%Y-%m-%d %H:%M"),
          format(round(remaining, 1))
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Prints every connected broker and how fresh its funds are.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    check_brokers = function() {
      brokers <- self$unified_broker_interface$get("/api/brokers/details")
      cat(sprintf("Brokers connected: %d\n", length(brokers)))
      funds <- self$unified_broker_interface$get("/api/portfolio/funds")
      for (broker in funds[["brokers"]]) {
        flag <- ""
        if (broker[["status"]] != "ok") {
          flag <- "  <- check this broker"
        }
        cat(
          sprintf(
            "  %-10s %-6s %s%s\n",
            broker[["broker"]],
            broker[["status"]],
            broker[["as_of"]],
            flag
          )
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Runs both checks.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$check_session()
      self$check_brokers()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SessionHealthCheck$new()$run()
}
