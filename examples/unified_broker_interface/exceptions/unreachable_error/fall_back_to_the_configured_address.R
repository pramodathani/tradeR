#' Try a list of UBI addresses in turn, catching UnifiedBrokerInterfaceError until one answers.
#'
#' A program might be given an old address for UBI. The program tries a port nothing listens on first, catches the UnreachableError through the base class UnifiedBrokerInterfaceError, recognises it by its missing status code, and falls back to the address configured in `TRADINGMACHINE_UBI_BASE_URL`, printing the session status from the first address that answers.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/unreachable_error/fall_back_to_the_configured_address.R

library(tradeR)

#' A connection that tries several addresses for UBI.
#'
#' @field base_urls A list of the character addresses to try, where `NULL` means the configured one.
AddressFallback <- R6::R6Class(
  "AddressFallback",
  public = list(
    base_urls = NULL,

    #' @description
    #' Creates the connection with the addresses to try.
    #' @return A new `AddressFallback` object.
    initialize = function() {
      self$base_urls <- list(
        "http://127.0.0.1:9",
        NULL
      )
    },

    #' @description
    #' Asks each address for the session status until one answers.
    #' @return The named list session status from the first address that answers, or `NULL` when none does.
    #' @details Errors: signals a plain error when the configured address or the MongoDB credentials are not set, and a `UnifiedBrokerInterfaceError` subclass when an address answered with a failure rather than not answering at all.
    first_answer = function() {
      for (base_url in self$base_urls) {
        unified_broker_interface <- UnifiedBrokerInterface$new(
          base_url = base_url,
          timeout_seconds = 5
        )
        status <- tryCatch(
          unified_broker_interface$status(),
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (!inherits(status, "UnifiedBrokerInterfaceError")) {
          return(status)
        }
        if (!is.null(status$status_code)) {
          stop(status)
        }
        base_url_text <- "NULL"
        if (!is.null(base_url)) {
          base_url_text <- base_url
        }
        cat(
          sprintf(
            "%s did not answer: %s\n",
            base_url_text,
            ErrorCatalogue$name_of(status)
          )
        )
      }
      NULL
    },

    #' @description
    #' Finds an address that answers and prints the session status.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the configured address or the MongoDB credentials are not set, and a `UnifiedBrokerInterfaceError` subclass when an address answered with a failure.
    run = function() {
      status <- self$first_answer()
      if (is.null(status)) {
        cat("No address answered.\n")
        return(invisible(NULL))
      }
      cat(
        "Session status: ",
        jsonlite::toJSON(status, auto_unbox = TRUE, null = "null"),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  AddressFallback$new()$run()
}
