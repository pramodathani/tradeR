#' Arithmetic and rolling extremes an instrument calculates from its candle columns
#'
#' @description
#' Each method fetches the instrument's candles through `prices()`, adds one or more columns and returns the candles. The class is a link in the chain of analysis classes that `Instrument` inherits, and `Instrument` supplies `prices()`.
#'
#' The `talib` package has no arithmetic operators, no `MINMAX` and no index functions, and its `MAX` and `MIN` treat a missing value inside the data differently from Python's `talib`, so this class computes all of them in R. The arithmetic uses R's operators, which match TA-Lib's C code, and the rolling extremes and their positions follow TA-Lib 0.6.4's loops step by step.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$subtract(
#'   first_column = "high",
#'   second_column = "low",
#'   days = 30
#' )
#' }
#' @export
MathOperators <- R6::R6Class(
  "MathOperators",
  inherit = MathTransforms,
  public = list(
    #' @description
    #' Adds the sum of two candle columns.
    #' @param first_column The character name of the first candle column.
    #' @param second_column The character name of the second candle column.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `sum` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$add(days = 30)
    #' midpoint <- frame$sum / 2
    #' print(tail(midpoint, 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$add(
    #'   first_column = "open",
    #'   second_column = "close",
    #'   days = 30
    #' )
    #' print(tail(frame[, c("datetime", "sum")], 5))
    #' }
    add = function(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      first_values <- as.numeric(prices[[first_column]])
      second_values <- as.numeric(prices[[second_column]])
      prices[["sum"]] <- first_values + second_values
      prices
    },

    #' @description
    #' Adds the second candle column subtracted from the first.
    #' @param first_column The character name of the first candle column.
    #' @param second_column The character name of the second candle column.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `difference` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$subtract(days = 30)
    #' print(tail(frame[, c("datetime", "difference")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$subtract(
    #'   first_column = "close",
    #'   second_column = "open",
    #'   days = 90
    #' )
    #' up_days <- sum(frame$difference > 0)
    #' print(sprintf("Closed above its open on %d of %d days", up_days, nrow(frame)))
    #' }
    subtract = function(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      first_values <- as.numeric(prices[[first_column]])
      second_values <- as.numeric(prices[[second_column]])
      prices[["difference"]] <- first_values - second_values
      prices
    },

    #' @description
    #' Adds the product of two candle columns.
    #' @param first_column The character name of the first candle column.
    #' @param second_column The character name of the second candle column.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `product` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$multiply(days = 30)
    #' print(tail(frame[, c("datetime", "product")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$multiply(
    #'   first_column = "close",
    #'   second_column = "volume",
    #'   days = 30
    #' )
    #' crores <- round(frame$product / 10000000, 1)
    #' print(tail(data.frame(datetime = frame$datetime, crores = crores), 5))
    #' }
    multiply = function(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      first_values <- as.numeric(prices[[first_column]])
      second_values <- as.numeric(prices[[second_column]])
      prices[["product"]] <- first_values * second_values
      prices
    },

    #' @description
    #' Adds the first candle column divided by the second.
    #' @param first_column The character name of the first candle column.
    #' @param second_column The character name of the second candle column.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `quotient` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$divide(days = 30)
    #' range_percent <- (frame$quotient - 1) * 100
    #' print(tail(round(range_percent, 2), 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$divide(
    #'   first_column = "close",
    #'   second_column = "open",
    #'   days = 30
    #' )
    #' print(tail(frame[, c("datetime", "quotient")], 5))
    #' }
    divide = function(
      first_column = "high",
      second_column = "low",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      first_values <- as.numeric(prices[[first_column]])
      second_values <- as.numeric(prices[[second_column]])
      prices[["quotient"]] <- first_values / second_values
      prices
    },

    #' @description
    #' Adds the highest value of one candle column over each window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `max` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$maximum(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "max")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$maximum(column = "high", window = 50, days = 365)
    #' new_highs <- sum(frame$high == frame$max, na.rm = TRUE)
    #' print(sprintf("New 50-day highs on %d days", new_highs))
    #' }
    maximum = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      prices[["max"]] <- private$rolling_maximum(
        values = prices[[column]],
        window = window
      )
      prices
    },

    #' @description
    #' Adds the lowest value of one candle column over each window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `min` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$minimum(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "min")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$minimum(column = "low", window = 50, days = 365)
    #' new_lows <- sum(frame$low == frame$min, na.rm = TRUE)
    #' print(sprintf("New 50-day lows on %d days", new_lows))
    #' }
    minimum = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      prices[["min"]] <- private$rolling_minimum(
        values = prices[[column]],
        window = window
      )
      prices
    },

    #' @description
    #' Adds the row position of the highest value of one candle column over each window.
    #'
    #' Positions are counted from 0 for the first candle, as Python's are, so the row in R is the position plus 1. The first `window - 1` rows, which have no full window, get 0, as Python's `talib` gives them.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an integer `maxindex` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$maximum_index(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "maxindex")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$maximum_index(window = 20, days = 90)
    #' position <- frame$maxindex[[nrow(frame)]]
    #' highest_row <- position + 1
    #' highest_day <- format(frame$datetime[[highest_row]], "%Y-%m-%d")
    #' print(paste(highest_day, frame$close[[highest_row]]))
    #' }
    maximum_index = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      prices[["maxindex"]] <- private$highest_positions(
        values = prices[[column]],
        window = window,
        function_name = "TA_MAXINDEX"
      )
      prices
    },

    #' @description
    #' Adds the row position of the lowest value of one candle column over each window.
    #'
    #' Positions are counted from 0 for the first candle, as Python's are, so the row in R is the position plus 1. The first `window - 1` rows, which have no full window, get 0, as Python's `talib` gives them.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an integer `minindex` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$minimum_index(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "minindex")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$minimum_index(window = 20, days = 90)
    #' position <- frame$minindex[[nrow(frame)]]
    #' print(sprintf("%d trading days ago", nrow(frame) - 1L - position))
    #' }
    minimum_index = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      prices[["minindex"]] <- private$lowest_positions(
        values = prices[[column]],
        window = window,
        function_name = "TA_MININDEX"
      )
      prices
    },

    #' @description
    #' Adds the lowest and highest values of one candle column over each window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `min` and `max` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$minimum_maximum(window = 20, days = 90)
    #' columns <- c(
    #'   "datetime",
    #'   "min",
    #'   "max"
    #' )
    #' print(tail(frame[, columns], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$minimum_maximum(window = 20, days = 90)
    #' latest <- frame[nrow(frame), ]
    #' distance_from_low <- latest$close - latest$min
    #' width <- latest$max - latest$min
    #' position <- distance_from_low / width
    #' print(sprintf("%.0f%% of the way from the low to the high", position * 100))
    #' }
    minimum_maximum = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      private$check_window(window, "TA_MINMAX")
      prices[["min"]] <- private$rolling_minimum(
        values = prices[[column]],
        window = window
      )
      prices[["max"]] <- private$rolling_maximum(
        values = prices[[column]],
        window = window
      )
      prices
    },

    #' @description
    #' Adds the row positions of the lowest and highest values of one candle column over each window.
    #'
    #' Positions are counted from 0 for the first candle, as Python's are, so the row in R is the position plus 1. The first `window - 1` rows, which have no full window, get 0, as Python's `talib` gives them.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with integer `minindex` and `maxindex` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$minimum_maximum_index(window = 20, days = 90)
    #' columns <- c(
    #'   "datetime",
    #'   "minindex",
    #'   "maxindex"
    #' )
    #' print(tail(frame[, columns], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$minimum_maximum_index(window = 20, days = 90)
    #' low_position <- frame$minindex[[nrow(frame)]]
    #' high_position <- frame$maxindex[[nrow(frame)]]
    #' if (high_position > low_position) {
    #'   print("The high came after the low, so the swing is upward")
    #' } else {
    #'   print("The low came after the high, so the swing is downward")
    #' }
    #' }
    minimum_maximum_index = function(
      column = "close",
      window = 10,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- self$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      prices[["minindex"]] <- private$lowest_positions(
        values = prices[[column]],
        window = window,
        function_name = "TA_MINMAXINDEX"
      )
      prices[["maxindex"]] <- private$highest_positions(
        values = prices[[column]],
        window = window,
        function_name = "TA_MINMAXINDEX"
      )
      prices
    }
  ),
  private = list(
    #' @description
    #' Signals TA-Lib's error for a window it does not accept.
    #' @param window The integer number of candles in each calculation window.
    #' @param function_name The character name of the TA-Lib function being imitated, such as `"TA_MAXINDEX"`.
    #' @return `NULL`, invisibly, when `window` is between 2 and 100000.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    check_window = function(window, function_name) {
      if (window < 2 || window > 100000) {
        stop(
          sprintf(
            "%s function failed with error code 2: Bad Parameter (TA_BAD_PARAM)",
            function_name
          ),
          call. = FALSE
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Finds the first position of a vector that holds a value.
    #'
    #' Python's `talib` skips missing values at the start of its input before calling TA-Lib and reports them as missing, and this position is where that skipping stops.
    #' @param values A numeric vector.
    #' @return The integer position of the first value that is not `NA`, or one more than the length when there is none.
    first_present_position = function(values) {
      position <- 1
      while (position <= length(values) && is.na(values[[position]])) {
        position <- position + 1
      }
      position
    },

    #' @description
    #' Calculates TA-Lib's rolling maximum.
    #'
    #' The value is read at the position `scan_highest()` finds, which is what TA-Lib 0.6.4's `TA_MAX` returns. The `talib` package's `MAX` is not used, because it treats a missing value inside the data differently from Python's `talib`.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @return A numeric vector the length of `values`, `NA` until the first full window.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    rolling_maximum = function(values, window) {
      values <- as.numeric(values)
      positions <- private$scan_highest(values, window, "TA_MAX")
      values[positions]
    },

    #' @description
    #' Calculates TA-Lib's rolling minimum.
    #'
    #' The value is read at the position `scan_lowest()` finds, which is what TA-Lib 0.6.4's `TA_MIN` returns. The `talib` package's `MIN` is not used, because it treats a missing value inside the data differently from Python's `talib`.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @return A numeric vector the length of `values`, `NA` until the first full window.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    rolling_minimum = function(values, window) {
      values <- as.numeric(values)
      positions <- private$scan_lowest(values, window, "TA_MIN")
      values[positions]
    },

    #' @description
    #' Gives the position of the highest value in each window counted from 0, as TA-Lib's `TA_MAXINDEX` reports it.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @param function_name The character name of the TA-Lib function being imitated, used in the error message.
    #' @return An integer vector the length of `values` of positions counted from 0, with 0 where there is no full window, as Python's `talib` gives.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    highest_positions = function(values, window, function_name) {
      positions <- private$scan_highest(
        as.numeric(values),
        window,
        function_name
      )
      positions <- positions - 1L
      positions[is.na(positions)] <- 0L
      positions
    },

    #' @description
    #' Gives the position of the lowest value in each window counted from 0, as TA-Lib's `TA_MININDEX` reports it.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @param function_name The character name of the TA-Lib function being imitated, used in the error message.
    #' @return An integer vector the length of `values` of positions counted from 0, with 0 where there is no full window, as Python's `talib` gives.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    lowest_positions = function(values, window, function_name) {
      positions <- private$scan_lowest(
        as.numeric(values),
        window,
        function_name
      )
      positions <- positions - 1L
      positions[is.na(positions)] <- 0L
      positions
    },

    #' @description
    #' Finds the position of the highest value in each window, following TA-Lib 0.6.4's loop for `TA_MAX` and `TA_MAXINDEX` step by step.
    #'
    #' Ties and missing values therefore resolve as they do in TA-Lib: a rescan of the window keeps the earliest of equal values, a new value equal to the current highest takes its place, and a comparison with a missing value is false. As the Python wrapper does, missing values at the start are skipped.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @param function_name The character name of the TA-Lib function being imitated, used in the error message.
    #' @return An integer vector the length of `values` of positions counted from 1, with `NA` where there is no full window.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    scan_highest = function(values, window, function_name) {
      private$check_window(window, function_name)
      count <- length(values)
      positions <- rep(NA_integer_, count)
      first <- private$first_present_position(values)
      today <- first + window - 1
      if (today > count) {
        return(positions)
      }
      highest_position <- 0
      highest <- 0
      while (today <= count) {
        trailing <- today - window + 1
        if (highest_position < trailing) {
          highest_position <- trailing
          highest <- values[[highest_position]]
          candidate <- highest_position + 1
          while (candidate <= today) {
            if (isTRUE(values[[candidate]] > highest)) {
              highest_position <- candidate
              highest <- values[[candidate]]
            }
            candidate <- candidate + 1
          }
        } else if (isTRUE(values[[today]] >= highest)) {
          highest_position <- today
          highest <- values[[today]]
        }
        positions[[today]] <- as.integer(highest_position)
        today <- today + 1
      }
      positions
    },

    #' @description
    #' Finds the position of the lowest value in each window, following TA-Lib 0.6.4's loop for `TA_MIN` and `TA_MININDEX` step by step.
    #'
    #' Ties and missing values therefore resolve as they do in TA-Lib: a rescan of the window keeps the earliest of equal values, a new value equal to the current lowest takes its place, and a comparison with a missing value is false. As the Python wrapper does, missing values at the start are skipped.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each window.
    #' @param function_name The character name of the TA-Lib function being imitated, used in the error message.
    #' @return An integer vector the length of `values` of positions counted from 1, with `NA` where there is no full window.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    scan_lowest = function(values, window, function_name) {
      private$check_window(window, function_name)
      count <- length(values)
      positions <- rep(NA_integer_, count)
      first <- private$first_present_position(values)
      today <- first + window - 1
      if (today > count) {
        return(positions)
      }
      lowest_position <- 0
      lowest <- 0
      while (today <= count) {
        trailing <- today - window + 1
        if (lowest_position < trailing) {
          lowest_position <- trailing
          lowest <- values[[lowest_position]]
          candidate <- lowest_position + 1
          while (candidate <= today) {
            if (isTRUE(values[[candidate]] < lowest)) {
              lowest_position <- candidate
              lowest <- values[[candidate]]
            }
            candidate <- candidate + 1
          }
        } else if (isTRUE(values[[today]] <= lowest)) {
          lowest_position <- today
          lowest <- values[[today]]
        }
        positions[[today]] <- as.integer(lowest_position)
        today <- today + 1
      }
      positions
    }
  )
)
