TIME_CONVERTER_INDIA_TIME_ZONE <- "Asia/Kolkata"

#' A converter between UBI's date and time text and R's date and time types
#'
#' @description
#' UBI writes dates as `YYYY-MM-DD` text and moments as ISO 8601 text with an offset, such as `2026-09-29T09:15:00+05:30` or `2026-09-29T03:45:00.123Z`, and some moments as seconds since 1970. This class turns them into `Date` and `POSIXct` values in India time, the R counterparts of the Python library's `datetime.date` and timezone-aware `datetime` values, and gives today's date and the current moment in India time.
#'
#' @examples
#' converter <- TimeConverter$new()
#' converter$date("2026-09-29")
#' converter$moments(c("2026-09-29T09:15:00+05:30", "2026-09-29T03:45:00Z"))
#' converter$today()
#' @export
TimeConverter <- R6::R6Class(
  "TimeConverter",
  public = list(
    #' @description
    #' Turns one ISO date into a `Date`.
    #' @param value A `"YYYY-MM-DD"` character value, a `Date`, or `NULL`.
    #' @return The `Date`, or `NULL` when `value` is `NULL` or empty.
    #' @details Errors: signals a plain error when `value` is text that is not a valid ISO date.
    date = function(value) {
      if (is.null(value) || length(value) == 0) {
        return(NULL)
      }
      if (inherits(value, "Date")) {
        return(value)
      }
      if (is.na(value) || identical(value, "")) {
        return(NULL)
      }
      parsed <- as.Date(substr(value, 1, 10), format = "%Y-%m-%d")
      if (is.na(parsed)) {
        stop(sprintf("Invalid isoformat string: '%s'", value), call. = FALSE)
      }
      parsed
    },

    #' @description
    #' Turns ISO dates into a `Date` vector, keeping missing values missing.
    #' @param values A character vector of `"YYYY-MM-DD"` values, with `NA` or `""` for missing ones.
    #' @return A `Date` vector the same length as `values`.
    dates = function(values) {
      result <- rep(as.Date(NA), length(values))
      for (index in seq_along(values)) {
        value <- values[[index]]
        if (!is.na(value) && !identical(value, "")) {
          result[[index]] <- self$date(value)
        }
      }
      result
    },

    #' @description
    #' Turns ISO 8601 moments with an offset into `POSIXct` values in India time.
    #' @param values A character vector such as `"2026-09-29T09:15:00+05:30"` or `"2026-09-29T03:45:00.5Z"`, with `NA` for missing values. A value without an offset is read as India time.
    #' @return A `POSIXct` vector in the `Asia/Kolkata` time zone, the same length as `values`.
    moments = function(values) {
      seconds <- rep(NA_real_, length(values))
      for (index in seq_along(values)) {
        value <- values[[index]]
        if (is.null(value) || is.na(value) || identical(value, "")) {
          next
        }
        seconds[[index]] <- private$epoch_seconds(as.character(value))
      }
      self$from_epoch(seconds)
    },

    #' @description
    #' Turns seconds since 1970 into `POSIXct` values in India time.
    #' @param seconds A numeric vector of seconds since 1970-01-01 UTC, with `NA` for missing values.
    #' @return A `POSIXct` vector in the `Asia/Kolkata` time zone.
    from_epoch = function(seconds) {
      as.POSIXct(
        as.numeric(seconds),
        origin = "1970-01-01",
        tz = TIME_CONVERTER_INDIA_TIME_ZONE
      )
    },

    #' @description
    #' Gives today's date in India time.
    #' @return A `Date`.
    today = function() {
      as.Date(format(self$now(), "%Y-%m-%d"))
    },

    #' @description
    #' Gives the current moment in India time.
    #' @return A `POSIXct` in the `Asia/Kolkata` time zone.
    now = function() {
      moment <- Sys.time()
      attr(moment, "tzone") <- TIME_CONVERTER_INDIA_TIME_ZONE
      moment
    },

    #' @description
    #' Builds one moment from a date and a time of day in India time.
    #' @param date A `Date`.
    #' @param time_of_day A `"HH:MM"` character value, such as `"15:30"`.
    #' @return A `POSIXct` in the `Asia/Kolkata` time zone.
    moment_on = function(date, time_of_day) {
      as.POSIXct(
        paste(format(date, "%Y-%m-%d"), time_of_day),
        format = "%Y-%m-%d %H:%M",
        tz = TIME_CONVERTER_INDIA_TIME_ZONE
      )
    },

    #' @description
    #' Writes a date the way UBI and the Python library write it.
    #' @param value A `Date`, or `NULL`.
    #' @return A `"YYYY-MM-DD"` character value, or `NULL` when `value` is `NULL`.
    iso_date = function(value) {
      if (is.null(value)) {
        return(NULL)
      }
      format(value, "%Y-%m-%d")
    }
  ),
  private = list(
    # Reads one ISO 8601 moment as seconds since 1970.
    # @param value A character moment such as `"2026-09-29T09:15:00.25+05:30"`.
    # @return The numeric seconds since 1970-01-01 UTC, or `NA` when the text cannot be read.
    epoch_seconds = function(value) {
      text <- sub(" ", "T", value, fixed = TRUE)
      offset_seconds <- NA_real_
      if (grepl("Z$", text)) {
        offset_seconds <- 0
        text <- sub("Z$", "", text)
      } else if (grepl("[+-][0-9]{2}:?[0-9]{2}$", text)) {
        offset <- regmatches(text, regexpr("[+-][0-9]{2}:?[0-9]{2}$", text))
        text <- sub("[+-][0-9]{2}:?[0-9]{2}$", "", text)
        digits <- gsub(":", "", offset, fixed = TRUE)
        sign <- 1
        if (substr(digits, 1, 1) == "-") {
          sign <- -1
        }
        hours <- as.numeric(substr(digits, 2, 3))
        minutes <- as.numeric(substr(digits, 4, 5))
        offset_seconds <- sign * (hours * 3600 + minutes * 60)
      }
      if (grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", text)) {
        text <- paste0(text, "T00:00:00")
      }
      if (grepl("T[0-9]{2}:[0-9]{2}$", text)) {
        text <- paste0(text, ":00")
      }
      if (is.na(offset_seconds)) {
        local <- as.POSIXct(
          text,
          format = "%Y-%m-%dT%H:%M:%OS",
          tz = TIME_CONVERTER_INDIA_TIME_ZONE
        )
        return(as.numeric(local))
      }
      as_utc <- as.POSIXct(text, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
      as.numeric(as_utc) - offset_seconds
    }
  )
)
