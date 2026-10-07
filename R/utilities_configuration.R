CONFIGURATION_UBI_BASE_URL_VARIABLE <- "TRADINGMACHINE_UBI_BASE_URL"
CONFIGURATION_MONGODB_HOST_VARIABLE <- "TRADINGMACHINE_MONGODB_HOST"
CONFIGURATION_MONGODB_PORT_VARIABLE <- "TRADINGMACHINE_MONGODB_PORT"
CONFIGURATION_MONGODB_DATABASE_NAME_VARIABLE <- "TRADINGMACHINE_MONGODB_DB"
CONFIGURATION_MONGODB_USERNAME_VARIABLE <- "TRADINGMACHINE_MONGODB_USERNAME"
CONFIGURATION_MONGODB_PASSWORD_VARIABLE <- "TRADINGMACHINE_MONGODB_PASSWORD"
CONFIGURATION_DEFAULT_ENVIRONMENT_FILE <- ".env"

#' The settings for one R session, read from the environment on first use
#'
#' @description
#' Reads the address of the Unified Broker Interface and the MongoDB connection details from environment variables. The first read loads an environment file, `.env` in the working directory unless another is named, so that a variable already set in the environment is kept and one set only in the file is added. Nothing is read when the object is created.
#'
#' The variable names are the ones the Python library `tradingmachine` uses, so both projects can share one `.env` file and one MongoDB.
#'
#' @examples
#' \dontrun{
#' configuration <- Configuration$new()
#' configuration$ubi_base_url
#' configuration$mongodb_connection_string
#' }
#' @export
Configuration <- R6::R6Class(
  "Configuration",
  public = list(
    #' @field environment_file The character path of the environment file to load, or `NULL` for `.env` in the working directory.
    environment_file = NULL,

    #' @description
    #' Prepares the configuration without reading anything yet.
    #' @param environment_file A character path of the environment file to load, or `NULL` for `.env` in the working directory.
    #' @param load_environment_file A logical that is `TRUE` to load the environment file on the first read, or `FALSE` to read only the environment.
    #' @return A new `Configuration` object.
    initialize = function(
      environment_file = NULL,
      load_environment_file = TRUE
    ) {
      self$environment_file <- environment_file
      private$load_environment_file <- load_environment_file
      private$environment_file_loaded <- FALSE
    },

    #' @description
    #' Forgets that the environment file was loaded, so the next read loads it again.
    #' @return `NULL`, invisibly.
    reload = function() {
      private$environment_file_loaded <- FALSE
      invisible(NULL)
    }
  ),
  active = list(
    #' @field ubi_base_url The character address of the Unified Broker Interface, or `NULL` if it is not set.
    ubi_base_url = function(value) {
      if (!missing(value)) {
        stop("ubi_base_url is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_UBI_BASE_URL_VARIABLE)
    },

    #' @field mongodb_host The character host MongoDB is reachable on, or `NULL` if it is not set.
    mongodb_host = function(value) {
      if (!missing(value)) {
        stop("mongodb_host is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_MONGODB_HOST_VARIABLE)
    },

    #' @field mongodb_port The character port MongoDB listens on, or `NULL` if it is not set.
    mongodb_port = function(value) {
      if (!missing(value)) {
        stop("mongodb_port is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_MONGODB_PORT_VARIABLE)
    },

    #' @field mongodb_database_name The character name of the project's MongoDB database, or `NULL` if it is not set.
    mongodb_database_name = function(value) {
      if (!missing(value)) {
        stop("mongodb_database_name is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_MONGODB_DATABASE_NAME_VARIABLE)
    },

    #' @field mongodb_username The character MongoDB user to authenticate as, or `NULL` if it is not set.
    mongodb_username = function(value) {
      if (!missing(value)) {
        stop("mongodb_username is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_MONGODB_USERNAME_VARIABLE)
    },

    #' @field mongodb_password The character password for the MongoDB user, or `NULL` if it is not set.
    mongodb_password = function(value) {
      if (!missing(value)) {
        stop("mongodb_password is read-only", call. = FALSE)
      }
      private$read(CONFIGURATION_MONGODB_PASSWORD_VARIABLE)
    },

    #' @field mongodb_connection_string The character MongoDB URI built from the host, port, username and password, authenticating against the `admin` database.
    mongodb_connection_string = function(value) {
      if (!missing(value)) {
        stop("mongodb_connection_string is read-only", call. = FALSE)
      }
      username <- self$mongodb_username
      if (is.null(username)) {
        username <- ""
      }
      password <- self$mongodb_password
      if (is.null(password)) {
        password <- ""
      }
      sprintf(
        "mongodb://%s:%s@%s:%s/?authSource=admin",
        utils::URLencode(username, reserved = TRUE),
        utils::URLencode(password, reserved = TRUE),
        private$text_or_none(self$mongodb_host),
        private$text_or_none(self$mongodb_port)
      )
    }
  ),
  private = list(
    load_environment_file = TRUE,
    environment_file_loaded = FALSE,

    # Reads one environment variable, loading the environment file first if needed.
    # @param variable_name A character name of the environment variable.
    # @return The character value of the variable, or `NULL` if it is not set.
    read = function(variable_name) {
      private$ensure_environment_file_loaded()
      value <- Sys.getenv(variable_name, unset = NA)
      if (is.na(value)) {
        return(NULL)
      }
      value
    },

    # Loads the environment file once, if loading it was asked for, without replacing a variable already set.
    # @return `NULL`, invisibly.
    ensure_environment_file_loaded = function() {
      if (private$environment_file_loaded) {
        return(invisible(NULL))
      }
      private$environment_file_loaded <- TRUE
      if (!private$load_environment_file) {
        return(invisible(NULL))
      }
      file <- self$environment_file
      if (is.null(file)) {
        file <- CONFIGURATION_DEFAULT_ENVIRONMENT_FILE
      }
      if (!file.exists(file)) {
        return(invisible(NULL))
      }
      environment_before <- as.list(Sys.getenv())
      dotenv::load_dot_env(file)
      do.call(Sys.setenv, environment_before)
      invisible(NULL)
    },

    # Writes a missing value the way Python formats None inside the connection string.
    # @param value A character value, or `NULL`.
    # @return The character value, or `"None"` when it is `NULL`.
    text_or_none = function(value) {
      if (is.null(value)) {
        return("None")
      }
      value
    }
  )
)
