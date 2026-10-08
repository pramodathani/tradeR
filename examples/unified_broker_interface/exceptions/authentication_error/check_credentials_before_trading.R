#' Check two sets of credentials before trading, catching UnifiedBrokerInterfaceError.
#'
#' A program that trades should find out at the start whether its credentials work, rather than on its first order. The program checks the real credentials and a wrong set written to a temporary database, by sending one request through a client built on each. The wrong set signals AuthenticationError, which is caught through the base class UnifiedBrokerInterfaceError and recognised by its status code 401. The temporary database is dropped at the end whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/authentication_error/check_credentials_before_trading.R

library(tradeR)

#' A check of whether each of two sets of credentials is accepted by UBI.
#'
#' @field project_configuration The `Configuration` of the real project.
#' @field real_database_name The character name of the project's own MongoDB database.
#' @field temporary_database_name The character name of the database the wrong credentials are written to.
CredentialCheck <- R6::R6Class(
  "CredentialCheck",
  public = list(
    project_configuration = NULL,
    real_database_name = NULL,
    temporary_database_name = NULL,

    #' @description
    #' Creates the check with the project's configuration.
    #' @return A new `CredentialCheck` object.
    initialize = function() {
      self$project_configuration <- Configuration$new()
      self$real_database_name <-
        self$project_configuration$mongodb_database_name
      self$temporary_database_name <-
        "tradingmachine_examples_wrong_credentials"
    },

    #' @description
    #' Writes a settings document with a wrong api key and secret to the temporary database.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached or refused the write.
    write_wrong_credentials = function() {
      settings_collection <- mongolite::mongo(
        collection = "settings",
        db = self$temporary_database_name,
        url = self$project_configuration$mongodb_connection_string
      )
      on.exit(settings_collection$disconnect(), add = TRUE)
      settings_document <- jsonlite::toJSON(
        list(
          broker_name = "unified_broker_interface",
          api_key = "a-key-that-was-rotated",
          api_secret = "a-secret-that-was-rotated"
        ),
        auto_unbox = TRUE
      )
      settings_collection$insert(settings_document)
      invisible(NULL)
    },

    #' @description
    #' Drops the temporary database.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached.
    drop_temporary_database = function() {
      settings_collection <- mongolite::mongo(
        collection = "settings",
        db = self$temporary_database_name,
        url = self$project_configuration$mongodb_connection_string
      )
      on.exit(settings_collection$disconnect(), add = TRUE)
      settings_collection$run("{\"dropDatabase\": 1}")
      invisible(NULL)
    },

    #' @description
    #' Sends one request through a client whose credentials come from a database.
    #' @param database_name The character name of the MongoDB database holding the settings document.
    #' @return `TRUE` when UBI accepted the credentials, `FALSE` when it refused them with HTTP 401.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than the credentials.
    credentials_work = function(database_name) {
      Sys.setenv(TRADINGMACHINE_MONGODB_DB = database_name)
      checked_client <- UnifiedBrokerInterface$new(
        project_configuration = Configuration$new()
      )
      outcome <- tryCatch(
        checked_client$status(),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(outcome, "UnifiedBrokerInterfaceError")) {
        status_code <- outcome$status_code
        if (is.null(status_code) || status_code != 401) {
          stop(outcome)
        }
        cat(
          sprintf(
            "%s: refused with %s: %s\n",
            database_name,
            ErrorCatalogue$name_of(outcome),
            conditionMessage(outcome)
          )
        )
        return(FALSE)
      }
      cat(sprintf("%s: accepted\n", database_name))
      TRUE
    },

    #' @description
    #' Checks both sets of credentials and prints whether trading can start.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than the credentials.
    run = function() {
      self$write_wrong_credentials()
      tryCatch(
        {
          real_works <- self$credentials_work(self$real_database_name)
          wrong_works <- self$credentials_work(self$temporary_database_name)
        },
        finally = {
          Sys.setenv(TRADINGMACHINE_MONGODB_DB = self$real_database_name)
          self$drop_temporary_database()
        }
      )
      cat(sprintf("Real credentials can trade: %s\n", real_works))
      cat(sprintf("Rotated credentials can trade: %s\n", wrong_works))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CredentialCheck$new()$run()
}
