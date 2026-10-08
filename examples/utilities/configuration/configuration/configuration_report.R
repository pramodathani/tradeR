#' Report the project's settings and check that MongoDB answers with them.
#'
#' The program reads every setting `Configuration` knows from the environment and the `.env` file, prints each one with the password hidden, and then connects to MongoDB with the connection string to confirm that the settings work.
#'
#' Typical usage example:
#'
#'   Rscript examples/utilities/configuration/configuration/configuration_report.R

library(tradeR)

#' A report of the settings one process would use.
#'
#' @field project_configuration The `Configuration` being reported.
ConfigurationReport <- R6::R6Class(
  "ConfigurationReport",
  public = list(
    project_configuration = NULL,

    #' @description
    #' Creates the configuration, which reads nothing until the first setting is asked for.
    #' @return A new `ConfigurationReport` object.
    initialize = function() {
      self$project_configuration <- Configuration$new()
    },

    #' @description
    #' Collects every setting, with the password replaced by a note of whether it is set.
    #' @return A named list mapping each setting name to its character value, or to `NULL` when it is not set.
    settings = function() {
      password_note <- "not set"
      password <- self$project_configuration$mongodb_password
      if (!is.null(password) && nzchar(password)) {
        password_note <- "set, hidden"
      }
      list(
        "UBI base url" = self$project_configuration$ubi_base_url,
        "MongoDB host" = self$project_configuration$mongodb_host,
        "MongoDB port" = self$project_configuration$mongodb_port,
        "MongoDB database" = self$project_configuration$mongodb_database_name,
        "MongoDB user" = self$project_configuration$mongodb_username,
        "MongoDB password" = password_note
      )
    },

    #' @description
    #' Connects to MongoDB and prints its answer to a ping and the project's collections, sorted by name.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error from `mongolite` when MongoDB could not be reached or refused the credentials.
    check_mongodb = function() {
      connection_string <- self$project_configuration$mongodb_connection_string
      address <- strsplit(connection_string, "@", fixed = TRUE)[[1]][[2]]
      cat(sprintf("Connecting to %s\n", address))
      database_name <- self$project_configuration$mongodb_database_name
      connection <- mongolite::mongo(
        db = database_name,
        url = connection_string
      )
      on.exit(connection$disconnect(), add = TRUE)
      ping <- connection$run("{\"ping\": 1}")
      cat(
        sprintf(
          "Ping: %s\n",
          jsonlite::toJSON(ping, auto_unbox = TRUE, null = "null")
        )
      )
      listing <- connection$run("{\"listCollections\": 1, \"nameOnly\": true}")
      collection_names <- sort(listing$cursor$firstBatch$name)
      cat(
        sprintf(
          "Collections in %s: %s\n",
          database_name,
          paste(collection_names, collapse = ", ")
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Prints the settings, then checks MongoDB.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error from `mongolite` when MongoDB could not be reached or refused the credentials.
    run = function() {
      settings <- self$settings()
      for (name in names(settings)) {
        value <- settings[[name]]
        if (is.null(value)) {
          value <- "NULL"
        }
        cat(sprintf("%-18s %s\n", name, value))
      }
      self$check_mongodb()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ConfigurationReport$new()$run()
}
