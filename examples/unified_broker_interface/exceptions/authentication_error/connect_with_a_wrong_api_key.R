#' Connect to UBI with a wrong api key and handle the AuthenticationError.
#'
#' The client reads its api key and secret from a settings document in MongoDB. The program writes a settings document with a wrong key and secret into a separate, temporary database, points a client at that database, and connects. UBI answers HTTP 401 without touching the access token other clients are using, the client signals AuthenticationError, and the program prints it. The temporary database is dropped at the end whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/unified_broker_interface/exceptions/authentication_error/connect_with_a_wrong_api_key.R

library(tradeR)

#' A connection attempt with credentials UBI does not accept.
#'
#' @field project_configuration The `Configuration` of the real project, used to reach MongoDB.
#' @field temporary_database_name The character name of the database the wrong credentials are written to.
WrongApiKeyConnection <- R6::R6Class(
  "WrongApiKeyConnection",
  public = list(
    project_configuration = NULL,
    temporary_database_name = NULL,

    #' @description
    #' Creates the attempt with the project's configuration.
    #' @return A new `WrongApiKeyConnection` object.
    initialize = function() {
      self$project_configuration <- Configuration$new()
      self$temporary_database_name <- "tradingmachine_examples_wrong_api_key"
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
          api_key = "not-the-real-api-key",
          api_secret = "not-the-real-api-secret"
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
    #' Connects with the wrong credentials and prints UBI's refusal.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI failed for a reason other than the credentials.
    run = function() {
      self$write_wrong_credentials()
      tryCatch(
        {
          Sys.setenv(TRADINGMACHINE_MONGODB_DB = self$temporary_database_name)
          wrong_client <- UnifiedBrokerInterface$new(
            project_configuration = Configuration$new()
          )
          outcome <- tryCatch(
            wrong_client$connect(),
            AuthenticationError = function(error) error
          )
          if (inherits(outcome, "AuthenticationError")) {
            cat(
              sprintf(
                "AuthenticationError (%s): %s\n",
                outcome$status_code,
                conditionMessage(outcome)
              )
            )
          } else {
            cat("Unexpectedly connected with the wrong credentials.\n")
          }
        },
        finally = {
          self$drop_temporary_database()
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WrongApiKeyConnection$new()$run()
}
