CLIENT_DEFAULT_TIMEOUT_SECONDS <- 30
CLIENT_SETTINGS_BROKER_NAME <- "unified_broker_interface"
CLIENT_SETTINGS_COLLECTION <- "settings"

#' A connection to the Unified Broker Interface REST API
#'
#' @description
#' A thin REST client for the Unified Broker Interface (UBI). It reads its api key and secret from the `settings` collection of the project's MongoDB, exchanges them for an access token on the first request, sends that token with every request, reconnects and retries once when UBI answers HTTP 401, and turns every other failing status code into its own error class from `UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE`.
#'
#' UBI holds one access token for the whole application, and every client shares it: `connect()` hands back the token in force, so other clients, such as a running Python script, keep working. `disconnect()` revokes that token and so ends every client's session. Instruments share one client, which `Instrument$shared_unified_broker_interface()` creates on first use.
#'
#' @examples
#' \dontrun{
#' client <- UnifiedBrokerInterface$new()
#' client$status()
#' client$get("/api/instruments/ltp", params = list(instrument_id = "..."))
#' }
#' @export
UnifiedBrokerInterface <- R6::R6Class(
  "UnifiedBrokerInterface",
  public = list(
    #' @field token_expires_at The character expiry time of the access token as UBI reported it, or `NULL` before the first connection.
    token_expires_at = NULL,

    #' @description
    #' Initialises the client and reads its api key and secret from MongoDB.
    #' @param base_url A character address of UBI, such as `"http://127.0.0.1:8080"`, or `NULL` to read `TRADINGMACHINE_UBI_BASE_URL`.
    #' @param timeout_seconds A numeric number of seconds to wait for each response.
    #' @param project_configuration A `Configuration` object, or `NULL` to create one that reads `.env`.
    #' @param credentials A named list with `api_key` and `api_secret` to use instead of reading MongoDB, or `NULL` to read MongoDB.
    #' @return A new `UnifiedBrokerInterface` object, not yet connected.
    #' @details Errors: signals a plain error when no base url is configured, when MongoDB holds no settings document for UBI, or when that document lacks the api key or secret.
    initialize = function(
      base_url = NULL,
      timeout_seconds = CLIENT_DEFAULT_TIMEOUT_SECONDS,
      project_configuration = NULL,
      credentials = NULL
    ) {
      if (is.null(project_configuration)) {
        project_configuration <- Configuration$new()
      }
      private$configuration <- project_configuration
      chosen_base_url <- base_url
      if (is.null(chosen_base_url) || !nzchar(chosen_base_url)) {
        chosen_base_url <- private$configuration$ubi_base_url
      }
      if (is.null(chosen_base_url) || !nzchar(chosen_base_url)) {
        stop(
          "UBI base url is not configured: TRADINGMACHINE_UBI_BASE_URL",
          call. = FALSE
        )
      }
      private$base_url <- sub("/+$", "", chosen_base_url)
      private$timeout_seconds <- timeout_seconds
      if (is.null(credentials)) {
        private$load_credentials()
      } else {
        private$use_credentials(credentials, "the credentials argument")
      }
    },

    #' @description
    #' Exchanges the api key and secret for UBI's access token, which every client shares, so other clients keep working.
    #' @return The character access token.
    #' @details Errors: signals `AuthenticationError` when UBI refuses the key or secret, another `UnifiedBrokerInterfaceError` subclass for any other failing status, and `UnreachableError` when UBI cannot be reached.
    connect = function() {
      headers <- list(
        "api-key" = private$api_key,
        "api-secret" = private$api_secret
      )
      response <- private$send(
        "POST",
        "/api/session/connect",
        headers,
        NULL,
        NULL
      )
      response_body <- private$parse_body(response)
      if (httr2::resp_status(response) >= 400) {
        private$raise_for_failure(response, response_body)
      }
      private$access_token <- response_body[["access-token"]]
      self$token_expires_at <- response_body[["expires_at"]]
      private$access_token
    },

    #' @description
    #' Revokes the access token in force on the server, which ends every client's session, including other R sessions and Python scripts.
    #' @return A named list holding UBI's answer.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    disconnect = function() {
      response_body <- private$request("DELETE", "/api/session/disconnect")
      private$access_token <- NULL
      self$token_expires_at <- NULL
      response_body
    },

    #' @description
    #' Reports whether the session is connected and when its token expires.
    #' @return A named list holding UBI's answer.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    status = function() {
      private$request("GET", "/api/session/status")
    },

    #' @description
    #' Sends a GET request.
    #' @param path A character route, such as `"/api/instruments/ltp"`.
    #' @param params A named list of query parameters, or `NULL`. A `NULL` value inside it is left out.
    #' @return The parsed JSON answer as a list, or `NULL` when the answer was not JSON.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    get = function(path, params = NULL) {
      private$request("GET", path, params = params)
    },

    #' @description
    #' Sends a POST request.
    #' @param path A character route, such as `"/api/orders/place"`.
    #' @param body A list to send as the JSON body, or `NULL` for none.
    #' @param params A named list of query parameters, or `NULL`.
    #' @param timeout_seconds A numeric number of seconds to wait for this response, or `NULL` for the client's default.
    #' @return The parsed JSON answer as a list, or `NULL` when the answer was not JSON.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    post = function(
      path,
      body = NULL,
      params = NULL,
      timeout_seconds = NULL
    ) {
      private$request(
        "POST",
        path,
        params = params,
        body = body,
        timeout_seconds = timeout_seconds
      )
    },

    #' @description
    #' Sends a PUT request.
    #' @param path A character route, such as `"/api/orders/modify"`.
    #' @param body A list to send as the JSON body, or `NULL` for none.
    #' @param params A named list of query parameters, or `NULL`.
    #' @return The parsed JSON answer as a list, or `NULL` when the answer was not JSON.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    put = function(path, body = NULL, params = NULL) {
      private$request("PUT", path, params = params, body = body)
    },

    #' @description
    #' Sends a PATCH request.
    #' @param path A character route.
    #' @param body A list to send as the JSON body, or `NULL` for none.
    #' @param params A named list of query parameters, or `NULL`.
    #' @return The parsed JSON answer as a list, or `NULL` when the answer was not JSON.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    patch = function(path, body = NULL, params = NULL) {
      private$request("PATCH", path, params = params, body = body)
    },

    #' @description
    #' Sends a DELETE request.
    #' @param path A character route, such as `"/api/orders/cancel"`.
    #' @param body A list to send as the JSON body, or `NULL` for none.
    #' @param params A named list of query parameters, or `NULL`.
    #' @return The parsed JSON answer as a list, or `NULL` when the answer was not JSON.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refuses the request or cannot be reached.
    delete = function(path, body = NULL, params = NULL) {
      private$request("DELETE", path, params = params, body = body)
    }
  ),
  private = list(
    configuration = NULL,
    base_url = NULL,
    timeout_seconds = CLIENT_DEFAULT_TIMEOUT_SECONDS,
    access_token = NULL,
    api_key = NULL,
    api_secret = NULL,

    # Reads the api key and secret from the project's MongoDB `settings` collection.
    # @return `NULL`, invisibly.
    # @details Errors: signals a plain error when no settings document for UBI exists or it lacks the key or secret.
    load_credentials = function() {
      database_name <- private$configuration$mongodb_database_name
      collection <- mongolite::mongo(
        collection = CLIENT_SETTINGS_COLLECTION,
        db = database_name,
        url = private$configuration$mongodb_connection_string
      )
      on.exit(collection$disconnect(), add = TRUE)
      query <- jsonlite::toJSON(
        list(broker_name = CLIENT_SETTINGS_BROKER_NAME),
        auto_unbox = TRUE
      )
      settings <- collection$iterate(query = query, limit = 1)$one()
      if (is.null(settings)) {
        stop(
          sprintf(
            "No settings document with broker_name='%s' in MongoDB database '%s'",
            CLIENT_SETTINGS_BROKER_NAME,
            database_name
          ),
          call. = FALSE
        )
      }
      private$use_credentials(
        settings,
        sprintf("Settings document '%s'", CLIENT_SETTINGS_BROKER_NAME)
      )
    },

    # Keeps an api key and secret, refusing a pair with either part missing.
    # @param credentials A named list with `api_key` and `api_secret`.
    # @param source A character description of where the pair came from, used in the error message.
    # @return `NULL`, invisibly.
    # @details Errors: signals a plain error when the key or the secret is missing or empty.
    use_credentials = function(credentials, source) {
      api_key <- credentials[["api_key"]]
      api_secret <- credentials[["api_secret"]]
      key_missing <- is.null(api_key) || !nzchar(api_key)
      secret_missing <- is.null(api_secret) || !nzchar(api_secret)
      if (key_missing || secret_missing) {
        stop(
          sprintf("%s is missing api_key or api_secret", source),
          call. = FALSE
        )
      }
      private$api_key <- api_key
      private$api_secret <- api_secret
      invisible(NULL)
    },

    # Sends an authenticated request, reconnecting once if the token is refused.
    # @param method A character HTTP method, such as `"GET"`.
    # @param path A character route.
    # @param params A named list of query parameters, or `NULL`.
    # @param body A list to send as the JSON body, or `NULL`.
    # @param is_retry A logical that is `TRUE` when this is already the retry after a 401.
    # @param timeout_seconds A numeric timeout for this request, or `NULL` for the default.
    # @return The parsed JSON answer as a list, or `NULL` when it was not JSON.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for a failing status or when UBI cannot be reached.
    request = function(
      method,
      path,
      params = NULL,
      body = NULL,
      is_retry = FALSE,
      timeout_seconds = NULL
    ) {
      if (is.null(private$access_token)) {
        self$connect()
      }
      headers <- list(
        "access-token" = private$access_token
      )
      response <- private$send(
        method,
        path,
        headers,
        params,
        body,
        timeout_seconds = timeout_seconds
      )
      response_body <- private$parse_body(response)
      status_code <- httr2::resp_status(response)
      if (status_code == 401 && !is_retry) {
        private$access_token <- NULL
        return(
          private$request(
            method,
            path,
            params,
            body,
            is_retry = TRUE,
            timeout_seconds = timeout_seconds
          )
        )
      }
      if (status_code >= 400) {
        private$raise_for_failure(response, response_body)
      }
      response_body
    },

    # Sends one HTTP request to the server, whatever status comes back.
    # @param method A character HTTP method.
    # @param path A character route.
    # @param headers A named list of request headers.
    # @param params A named list of query parameters, or `NULL`.
    # @param body A list to send as the JSON body, or `NULL`.
    # @param timeout_seconds A numeric timeout, or `NULL` for the default.
    # @return The `httr2_response` received.
    # @details Errors: signals `UnreachableError` when no response arrives.
    send = function(
      method,
      path,
      headers,
      params,
      body,
      timeout_seconds = NULL
    ) {
      url <- paste0(private$base_url, path)
      if (is.null(timeout_seconds)) {
        timeout_seconds <- private$timeout_seconds
      }
      query <- private$query_text(params)
      request <- httr2::request(paste0(url, query))
      request <- httr2::req_method(request, method)
      header_arguments <- c(
        list(request),
        headers
      )
      request <- do.call(httr2::req_headers, header_arguments)
      if (!is.null(body)) {
        request <- httr2::req_body_raw(
          request,
          private$json_text(body),
          type = "application/json"
        )
      }
      request <- httr2::req_timeout(request, timeout_seconds)
      request <- httr2::req_error(
        request,
        is_error = function(response) FALSE
      )
      tryCatch(
        httr2::req_perform(request),
        httr2_failure = function(error) {
          ErrorCatalogue$raise(
            "UnreachableError",
            sprintf(
              "Could not reach UBI at %s: %s",
              url,
              conditionMessage(error)
            ),
            parent = error
          )
        }
      )
    },

    # Turns query parameters into the text after the route, leaving out every `NULL` value.
    # @param params A named list of query parameters, or `NULL`.
    # @return A character query string starting with `?`, or `""` when there are no parameters.
    query_text = function(params) {
      if (is.null(params)) {
        return("")
      }
      pieces <- character(0)
      for (name in names(params)) {
        value <- params[[name]]
        if (is.null(value)) {
          next
        }
        for (element in as.list(value)) {
          pieces <- c(
            pieces,
            paste0(
              utils::URLencode(name, reserved = TRUE),
              "=",
              utils::URLencode(private$parameter_text(element), reserved = TRUE)
            )
          )
        }
      }
      if (length(pieces) == 0) {
        return("")
      }
      paste0("?", paste(pieces, collapse = "&"))
    },

    # Writes one query parameter value as text, the way the Python library's `requests` call writes it.
    # @param value A single character, numeric, logical or `Date` value.
    # @return A character value.
    parameter_text = function(value) {
      if (inherits(value, "Date")) {
        return(format(value, "%Y-%m-%d"))
      }
      if (is.logical(value)) {
        if (isTRUE(value)) {
          return("True")
        }
        return("False")
      }
      if (is.numeric(value)) {
        return(format(value, scientific = FALSE, digits = 15, trim = TRUE))
      }
      as.character(value)
    },

    # Writes a request body as JSON, with every length-one vector as a scalar and `NULL` as null.
    # @param body A list to send.
    # @return A character JSON document.
    json_text = function(body) {
      as.character(
        jsonlite::toJSON(
          body,
          auto_unbox = TRUE,
          null = "null",
          na = "null",
          digits = NA,
          Date = "ISO8601",
          POSIXt = "ISO8601"
        )
      )
    },

    # Parses a response body as JSON, keeping objects as named lists and arrays as lists.
    # @param response An `httr2_response`.
    # @return The parsed body as a list or scalar, or `NULL` when the body is empty or not JSON.
    parse_body = function(response) {
      if (!httr2::resp_has_body(response)) {
        return(NULL)
      }
      text <- httr2::resp_body_string(response)
      tryCatch(
        jsonlite::fromJSON(text, simplifyVector = FALSE),
        error = function(error) NULL
      )
    },

    # Describes the brokers a refusal says UBI passed over, and why.
    # @param response_body The parsed body of a failed response.
    # @return A character description such as `"zerodha: at order limit"`, or `""` when there is none.
    skipped_text = function(response_body) {
      if (!is.list(response_body)) {
        return("")
      }
      skipped <- response_body[["skipped"]]
      if (!is.list(skipped) || !is.null(names(skipped))) {
        return("")
      }
      parts <- character(0)
      for (entry in skipped) {
        if (!is.list(entry)) {
          next
        }
        parts <- c(
          parts,
          sprintf(
            "%s: %s",
            private$text_of(entry[["broker"]]),
            private$text_of(entry[["reason"]])
          )
        )
      }
      paste(parts, collapse = "; ")
    },

    # Writes a value the way Python's f-string would, with `NULL` as `None`.
    # @param value A scalar or `NULL`.
    # @return A character value.
    text_of = function(value) {
      if (is.null(value)) {
        return("None")
      }
      as.character(value)
    },

    # Signals the error class that matches a failed response's status code.
    # @param response The failed `httr2_response`.
    # @param response_body Its parsed body.
    # @return Never returns.
    # @details Errors: always signals a `UnifiedBrokerInterfaceError` subclass.
    raise_for_failure = function(response, response_body) {
      status_code <- httr2::resp_status(response)
      message <- NULL
      if (is.list(response_body)) {
        message <- response_body[["error"]]
        if (is.null(message) || identical(message, "")) {
          message <- response_body[["status_message"]]
        }
      }
      if (is.null(message) || identical(message, "")) {
        message <- sprintf("UBI returned HTTP %d", status_code)
      }
      skipped_text <- private$skipped_text(response_body)
      if (nzchar(skipped_text)) {
        message <- sprintf("%s (%s)", message, skipped_text)
      }
      class_name <- "ServerError"
      status_key <- as.character(status_code)
      if (status_key %in% names(UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE)) {
        class_name <- UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE[[status_key]]
      }
      ErrorCatalogue$raise(
        class_name,
        message,
        status_code = status_code,
        detail = response_body
      )
    }
  )
)
