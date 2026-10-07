#' A converter between UBI's rows and R data frames
#'
#' @description
#' UBI answers with lists of JSON objects, which `jsonlite` parses into lists of named lists. This class turns such a list into a base `data.frame` the way `pandas.DataFrame(rows)` does in the Python library: every field any row has becomes a column, in the order the fields are first seen, a missing or null value becomes `NA`, a field whose values are all single numbers, strings or logicals becomes an ordinary column, and any other field, such as a position's `pnl` object or an order book's levels, becomes a list column whose elements are the original values.
#'
#' It also turns one row of a data frame back into a named list, which is how the Python code's `frame.to_dict("records")` loops are written in R.
#'
#' @examples
#' builder <- FrameBuilder$new()
#' frame <- builder$frame(
#'   list(
#'     list(symbol = "INFY", quantity = 10, pnl = list(realized = 5)),
#'     list(symbol = "TCS", quantity = NULL, pnl = list(realized = 7))
#'   )
#' )
#' frame$quantity
#' frame$pnl[[2]]$realized
#' @export
FrameBuilder <- R6::R6Class(
  "FrameBuilder",
  public = list(
    #' @description
    #' Builds a data frame from a list of rows.
    #' @param rows A list of named lists, one per row.
    #' @return A `data.frame` with one row per element of `rows`, or `NULL` when `rows` is `NULL` or empty.
    frame = function(rows) {
      if (is.null(rows) || length(rows) == 0) {
        return(NULL)
      }
      column_names <- character(0)
      for (row in rows) {
        for (name in names(row)) {
          if (!(name %in% column_names)) {
            column_names <- c(
              column_names,
              name
            )
          }
        }
      }
      columns <- list()
      for (name in column_names) {
        values <- list()
        for (row_index in seq_along(rows)) {
          value <- rows[[row_index]][[name]]
          if (is.null(value)) {
            values[row_index] <- list(NULL)
          } else {
            values[[row_index]] <- value
          }
        }
        columns[[name]] <- self$column(values)
      }
      frame <- data.frame(
        row.names = seq_along(rows)
      )
      for (name in column_names) {
        frame[[name]] <- columns[[name]]
      }
      rownames(frame) <- NULL
      frame
    },

    #' @description
    #' Builds one column from the values of one field, one value per row.
    #' @param values A list with one element per row, where `NULL` marks a missing value.
    #' @return An atomic vector with `NA` for missing values when every present value is a single number, string or logical, otherwise a list with `NULL` for missing values.
    column = function(values) {
      all_scalar <- TRUE
      any_character <- FALSE
      any_numeric <- FALSE
      any_logical <- FALSE
      for (value in values) {
        if (is.null(value)) {
          next
        }
        is_scalar <- is.atomic(value) && length(value) == 1
        if (!is_scalar) {
          all_scalar <- FALSE
          break
        }
        if (is.character(value)) {
          any_character <- TRUE
        } else if (is.numeric(value)) {
          any_numeric <- TRUE
        } else if (is.logical(value)) {
          any_logical <- TRUE
        }
      }
      if (!all_scalar) {
        return(values)
      }
      kinds <- sum(
        c(
          any_character,
          any_numeric,
          any_logical
        )
      )
      if (kinds > 1) {
        return(values)
      }
      if (any_character) {
        column <- rep(NA_character_, length(values))
      } else if (any_numeric) {
        column <- rep(NA_real_, length(values))
      } else {
        column <- rep(NA, length(values))
      }
      for (index in seq_along(values)) {
        if (!is.null(values[[index]])) {
          column[[index]] <- values[[index]]
        }
      }
      column
    },

    #' @description
    #' Turns one row of a data frame back into a named list, the R counterpart of one record from `frame.to_dict("records")`.
    #' @param frame A `data.frame`.
    #' @param row_index An integer row number.
    #' @return A named list with one element per column, where a list column gives its element for that row and an atomic column gives its value, `NA` included.
    row = function(frame, row_index) {
      row <- list()
      for (name in names(frame)) {
        column <- frame[[name]]
        if (is.list(column)) {
          value <- column[[row_index]]
          if (is.null(value)) {
            row[name] <- list(NULL)
          } else {
            row[[name]] <- value
          }
        } else {
          row[[name]] <- column[[row_index]]
        }
      }
      row
    },

    #' @description
    #' Turns every row of a data frame into a named list.
    #' @param frame A `data.frame`, or `NULL`.
    #' @return A list of named lists, one per row, or an empty list when `frame` is `NULL`.
    rows = function(frame) {
      if (is.null(frame)) {
        return(list())
      }
      rows <- list()
      for (row_index in seq_len(nrow(frame))) {
        rows[[row_index]] <- self$row(frame, row_index)
      }
      rows
    }
  )
)
