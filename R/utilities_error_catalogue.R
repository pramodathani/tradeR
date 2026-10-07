#' The errors that stand in for Python's built-in exceptions
#'
#' @description
#' The Python library raises some of Python's own exception classes, such as `ValueError` for an argument outside its allowed range. The R port signals conditions with the same names, so the documentation and the handlers read the same in both languages.
#'
#' @format A named character vector, one entry per error class:
#' \describe{
#'   \item{`ValueError`}{An argument has the right type but a value the method cannot use, such as a price that is not above zero.}
#'   \item{`TypeError`}{An argument has the wrong type, such as an underlying that is not an `Instrument`.}
#' }
#' @keywords internal
UTILITIES_LANGUAGE_ERROR_PARENTS <- c(
  ValueError = "error",
  TypeError = "error"
)

#' The catalogue of every error class the package signals
#'
#' @description
#' Builds R conditions that behave like the Python library's exception classes. A condition's class vector is the error's own name followed by each of its parents in turn, then `error` and `condition`, so a handler for any ancestor catches it:
#'
#' ```r
#' tryCatch(
#'   Equity$new(exchange = "nse", symbol = "NOSUCHSHARE"),
#'   InstrumentError = function(error) conditionMessage(error)
#' )
#' ```
#'
#' The parent of every error comes from `UTILITIES_LANGUAGE_ERROR_PARENTS`, `UNIFIED_BROKER_INTERFACE_ERROR_PARENTS`, `ASSETS_ERROR_PARENTS` and `ASSET_BASKETS_ERROR_PARENTS`. The functions `ErrorCatalogue$raise()` and `ErrorCatalogue$name_of()` on the class generator are the usual way in, so code never needs to create the object itself.
#'
#' @export
ErrorCatalogue <- R6::R6Class(
  "ErrorCatalogue",
  public = list(
    #' @field parents A named character vector mapping every error class name to its parent class name, with `error` as the parent of each root.
    parents = NULL,

    #' @description
    #' Collects the parent of every error class the package defines.
    #' @return A new `ErrorCatalogue` object.
    initialize = function() {
      self$parents <- c(
        UTILITIES_LANGUAGE_ERROR_PARENTS,
        UNIFIED_BROKER_INTERFACE_ERROR_PARENTS,
        ASSETS_ERROR_PARENTS,
        ASSET_BASKETS_ERROR_PARENTS
      )
    },

    #' @description
    #' Lists an error class with each of its ancestors, most specific first.
    #' @param class_name A character name of an error class, such as `"NotFoundError"`.
    #' @return A character vector starting with `class_name` and ending with `"error"` and `"condition"`.
    #' @details Errors: signals a plain error when `class_name` is not in the catalogue.
    class_vector = function(class_name) {
      if (!(class_name %in% names(self$parents))) {
        stop(
          sprintf("Not an error class the package defines: %s", class_name),
          call. = FALSE
        )
      }
      classes <- class_name
      current <- class_name
      while (current %in% names(self$parents)) {
        current <- self$parents[[current]]
        classes <- c(
          classes,
          current
        )
      }
      c(
        classes,
        "condition"
      )
    },

    #' @description
    #' Builds one error condition without signalling it.
    #' @param class_name A character name of an error class, such as `"NotFoundError"`.
    #' @param message A character message describing the failure.
    #' @param status_code An integer HTTP status code, or `NULL` when no response arrived or none applies.
    #' @param detail A named list holding the parsed body of UBI's answer, or `NULL` for an empty list.
    #' @param parent A condition that caused this one, the R counterpart of Python's `raise ... from error`, or `NULL`.
    #' @return An R condition of class `class_vector(class_name)` with the fields `message`, `call`, `status_code`, `detail` and `parent`.
    #' @details Errors: signals a plain error when `class_name` is not in the catalogue.
    build = function(
      class_name,
      message,
      status_code = NULL,
      detail = NULL,
      parent = NULL
    ) {
      if (is.null(detail)) {
        detail <- list()
      }
      structure(
        class = self$class_vector(class_name),
        list(
          message = message,
          call = NULL,
          status_code = status_code,
          detail = detail,
          parent = parent
        )
      )
    },

    #' @description
    #' Builds an error condition and signals it with `stop()`.
    #' @param class_name A character name of an error class, such as `"NotFoundError"`.
    #' @param message A character message describing the failure.
    #' @param status_code An integer HTTP status code, or `NULL`.
    #' @param detail A named list holding the parsed body of UBI's answer, or `NULL` for an empty list.
    #' @param parent A condition that caused this one, or `NULL`.
    #' @return Never returns.
    #' @details Errors: always signals the condition of class `class_name`.
    raise = function(
      class_name,
      message,
      status_code = NULL,
      detail = NULL,
      parent = NULL
    ) {
      stop(
        self$build(
          class_name,
          message,
          status_code = status_code,
          detail = detail,
          parent = parent
        )
      )
    }
  )
)

ErrorCatalogue$raise <- function(
  class_name,
  message,
  status_code = NULL,
  detail = NULL,
  parent = NULL
) {
  ErrorCatalogue$new()$raise(
    class_name,
    message,
    status_code = status_code,
    detail = detail,
    parent = parent
  )
}

ErrorCatalogue$name_of <- function(error) {
  class(error)[[1]]
}
