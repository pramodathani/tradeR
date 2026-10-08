#' Read settings from an environment file other than the project's `.env`.
#'
#' The program writes a temporary environment file for a second machine, builds a `Configuration` that reads it, prints the settings it finds, then adds the MongoDB port to the file and calls `reload()` so that the new variable is picked up. The temporary file is removed when the program ends.
#'
#' A variable already set in the process environment is not replaced when a file is loaded or reloaded, which is why the program adds a variable rather than changing one.
#'
#' Typical usage example:
#'
#'   Rscript examples/utilities/configuration/configuration/alternate_environment_file.R

library(tradeR)

#' Settings read from a temporary environment file.
#'
#' @field path The character path of the environment file, or `NULL` until the program runs.
AlternateEnvironmentFile <- R6::R6Class(
  "AlternateEnvironmentFile",
  public = list(
    path = NULL,

    #' @description
    #' Starts without a file, which `run()` writes in a temporary directory.
    #' @return A new `AlternateEnvironmentFile` object.
    initialize = function() {
      self$path <- NULL
    },

    #' @description
    #' Appends one `NAME=value` line to the environment file.
    #' @param line The character line to append, without a line ending.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the file could not be written.
    write_line = function(line) {
      cat(line, "\n", file = self$path, append = TRUE, sep = "")
      invisible(NULL)
    },

    #' @description
    #' Describes a setting's value for printing, writing `NULL` for one that is not set.
    #' @param value The character value of a setting, or `NULL`.
    #' @return A character value.
    setting_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      value
    },

    #' @description
    #' Prints the UBI address and the MongoDB host and port the configuration sees.
    #' @param project_configuration The `Configuration` to read.
    #' @return `NULL`, invisibly.
    print_settings = function(project_configuration) {
      cat(
        sprintf(
          "  UBI base url: %s\n",
          self$setting_text(project_configuration$ubi_base_url)
        )
      )
      cat(
        sprintf(
          "  MongoDB host: %s\n",
          self$setting_text(project_configuration$mongodb_host)
        )
      )
      cat(
        sprintf(
          "  MongoDB port: %s\n",
          self$setting_text(project_configuration$mongodb_port)
        )
      )
      invisible(NULL)
    },

    #' @description
    #' Writes the file in a temporary directory, reads it, extends it and reloads it, and removes the directory at the end whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the file could not be written.
    run = function() {
      directory <- tempfile("alternate_environment_file_")
      dir.create(directory)
      tryCatch(
        {
          self$path <- file.path(directory, "second_machine.env")
          self$write_line(
            "TRADINGMACHINE_UBI_BASE_URL=http://192.168.1.20:8080"
          )
          self$write_line("TRADINGMACHINE_MONGODB_HOST=192.168.1.20")
          project_configuration <- Configuration$new(
            environment_file = self$path
          )
          cat("First read:\n")
          self$print_settings(project_configuration)
          self$write_line("TRADINGMACHINE_MONGODB_PORT=2003")
          project_configuration$reload()
          cat("After adding the port and reloading:\n")
          self$print_settings(project_configuration)
        },
        finally = {
          unlink(directory, recursive = TRUE)
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  AlternateEnvironmentFile$new()$run()
}
