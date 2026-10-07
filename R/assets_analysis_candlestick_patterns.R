#' Candlestick pattern recognisers an instrument runs over its candles
#'
#' @description
#' TA-Lib's recognisers for named one to five candle formations. Each method fetches the instrument's candles through `prices()`, adds one column and returns the candles. The class is a link in the chain of analysis classes that `Instrument` inherits, and `Instrument` supplies `prices()`.
#'
#' The recognisers come from the `talib` package, which wraps the same TA-Lib C library as Python's `talib`. Its signals are read as 100 and -100, not 1 and -1, and the candles at the start that TA-Lib cannot judge get 0, as in Python.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$candle_hammer(days = 365)
#' }
#' @export
CandlestickPatterns <- R6::R6Class(
  "CandlestickPatterns",
  inherit = MathOperators,
  public = list(
    #' @description
    #' Marks where the two crows candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_two_crows` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_two_crows(days = 365)
    #' pattern_column <- "candle_two_crows"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_two_crows"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_two_crows(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_two_crows = function(
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
      prices[["candle_two_crows"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL2CROWS
      )
      prices
    },

    #' @description
    #' Marks where the three black crows candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_black_crows` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_three_black_crows(days = 730)
    #' pattern_column <- "candle_three_black_crows"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_three_black_crows(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_three_black_crows"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_three_black_crows = function(
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
      prices[["candle_three_black_crows"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3BLACKCROWS
      )
      prices
    },

    #' @description
    #' Marks where the three inside up or down candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_inside_up_down` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_three_inside_up_down(days = 1095)
    #' pattern_column <- "candle_three_inside_up_down"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_three_inside_up_down(days = 1825)
    #' pattern_column <- "candle_three_inside_up_down"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_three_inside_up_down = function(
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
      prices[["candle_three_inside_up_down"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3INSIDE
      )
      prices
    },

    #' @description
    #' Marks where the three line strike candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_line_strike` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_three_line_strike"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_three_line_strike(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_three_line_strike(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_three_line_strike"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_three_line_strike = function(
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
      prices[["candle_three_line_strike"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3LINESTRIKE
      )
      prices
    },

    #' @description
    #' Marks where the three outside up or down candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_outside_up_down` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_three_outside_up_down(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_three_outside_up_down"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_three_outside_up_down(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_three_outside_up_down"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_three_outside_up_down = function(
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
      prices[["candle_three_outside_up_down"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3OUTSIDE
      )
      prices
    },

    #' @description
    #' Marks where the three stars in the south candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_stars_in_the_south` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_three_stars_in_the_south(days = 1825)
    #' pattern_column <- "candle_three_stars_in_the_south"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_three_stars_in_the_south(days = 365)
    #' pattern_column <- "candle_three_stars_in_the_south"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_three_stars_in_the_south = function(
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
      prices[["candle_three_stars_in_the_south"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3STARSINSOUTH
      )
      prices
    },

    #' @description
    #' Marks where the three white soldiers candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_three_white_soldiers` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_three_white_soldiers(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_three_white_soldiers"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_three_white_soldiers(days = 730)
    #' pattern_column <- "candle_three_white_soldiers"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_three_white_soldiers = function(
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
      prices[["candle_three_white_soldiers"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDL3WHITESOLDIERS
      )
      prices
    },

    #' @description
    #' Marks where the abandoned baby candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_abandoned_baby` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_abandoned_baby(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_abandoned_baby"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_abandoned_baby(days = 1095)
    #' pattern_column <- "candle_abandoned_baby"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_abandoned_baby = function(
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
      prices[["candle_abandoned_baby"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLABANDONEDBABY
      )
      prices
    },

    #' @description
    #' Marks where the advance block candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_advance_block` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_advance_block(days = 365)
    #' pattern_column <- "candle_advance_block"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_advance_block"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_advance_block(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_advance_block = function(
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
      prices[["candle_advance_block"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLADVANCEBLOCK
      )
      prices
    },

    #' @description
    #' Marks where the belt hold candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_belt_hold` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_belt_hold(days = 730)
    #' pattern_column <- "candle_belt_hold"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_belt_hold(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_belt_hold"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_belt_hold = function(
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
      prices[["candle_belt_hold"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLBELTHOLD
      )
      prices
    },

    #' @description
    #' Marks where the breakaway candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_breakaway` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_breakaway(days = 1095)
    #' pattern_column <- "candle_breakaway"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_breakaway(days = 1825)
    #' pattern_column <- "candle_breakaway"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_breakaway = function(
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
      prices[["candle_breakaway"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLBREAKAWAY
      )
      prices
    },

    #' @description
    #' Marks where the closing marubozu candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_closing_marubozu` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_closing_marubozu"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_closing_marubozu(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_closing_marubozu(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_closing_marubozu"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_closing_marubozu = function(
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
      prices[["candle_closing_marubozu"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLCLOSINGMARUBOZU
      )
      prices
    },

    #' @description
    #' Marks where the concealing baby swallow candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_concealing_baby_swallow` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_concealing_baby_swallow(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_concealing_baby_swallow"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_concealing_baby_swallow(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_concealing_baby_swallow"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_concealing_baby_swallow = function(
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
      prices[["candle_concealing_baby_swallow"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLCONCEALBABYSWALL
      )
      prices
    },

    #' @description
    #' Marks where the counterattack candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_counter_attack` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_counter_attack(days = 1825)
    #' pattern_column <- "candle_counter_attack"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_counter_attack(days = 365)
    #' pattern_column <- "candle_counter_attack"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_counter_attack = function(
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
      prices[["candle_counter_attack"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLCOUNTERATTACK
      )
      prices
    },

    #' @description
    #' Marks where the dark cloud cover candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_dark_cloud_cover` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_dark_cloud_cover(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_dark_cloud_cover"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_dark_cloud_cover(days = 730)
    #' pattern_column <- "candle_dark_cloud_cover"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_dark_cloud_cover = function(
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
      prices[["candle_dark_cloud_cover"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLDARKCLOUDCOVER
      )
      prices
    },

    #' @description
    #' Marks where the doji candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_doji` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_doji(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_doji"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_doji(days = 1095)
    #' pattern_column <- "candle_doji"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_doji = function(
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
      prices[["candle_doji"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLDOJI
      )
      prices
    },

    #' @description
    #' Marks where the doji star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_doji_star` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_doji_star(days = 365)
    #' pattern_column <- "candle_doji_star"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_doji_star"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_doji_star(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_doji_star = function(
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
      prices[["candle_doji_star"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLDOJISTAR
      )
      prices
    },

    #' @description
    #' Marks where the dragonfly doji candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_dragonfly_doji` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_dragonfly_doji(days = 730)
    #' pattern_column <- "candle_dragonfly_doji"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_dragonfly_doji(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_dragonfly_doji"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_dragonfly_doji = function(
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
      prices[["candle_dragonfly_doji"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLDRAGONFLYDOJI
      )
      prices
    },

    #' @description
    #' Marks where the engulfing candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_engulfing` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_engulfing(days = 1095)
    #' pattern_column <- "candle_engulfing"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_engulfing(days = 1825)
    #' pattern_column <- "candle_engulfing"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_engulfing = function(
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
      prices[["candle_engulfing"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLENGULFING
      )
      prices
    },

    #' @description
    #' Marks where the evening doji star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_evening_dojistar` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_evening_dojistar"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_evening_doji_star(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_evening_doji_star(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_evening_dojistar"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_evening_doji_star = function(
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
      prices[["candle_evening_dojistar"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLEVENINGDOJISTAR
      )
      prices
    },

    #' @description
    #' Marks where the evening star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_evening_star` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_evening_star(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_evening_star"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_evening_star(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_evening_star"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_evening_star = function(
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
      prices[["candle_evening_star"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLEVENINGSTAR
      )
      prices
    },

    #' @description
    #' Marks where the up or down gap side by side white lines candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_side_by_side_white_lines` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_side_by_side_white_lines(days = 1825)
    #' pattern_column <- "candle_side_by_side_white_lines"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_side_by_side_white_lines(days = 365)
    #' pattern_column <- "candle_side_by_side_white_lines"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_side_by_side_white_lines = function(
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
      prices[["candle_side_by_side_white_lines"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLGAPSIDESIDEWHITE
      )
      prices
    },

    #' @description
    #' Marks where the gravestone doji candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_gravestone_doji` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_gravestone_doji(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_gravestone_doji"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_gravestone_doji(days = 730)
    #' pattern_column <- "candle_gravestone_doji"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_gravestone_doji = function(
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
      prices[["candle_gravestone_doji"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLGRAVESTONEDOJI
      )
      prices
    },

    #' @description
    #' Marks where the hammer candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_hammer` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_hammer(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_hammer"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_hammer(days = 1095)
    #' pattern_column <- "candle_hammer"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_hammer = function(
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
      prices[["candle_hammer"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHAMMER
      )
      prices
    },

    #' @description
    #' Marks where the hanging man candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_hangingman` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_hanging_man(days = 365)
    #' pattern_column <- "candle_hangingman"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_hangingman"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_hanging_man(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_hanging_man = function(
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
      prices[["candle_hangingman"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHANGINGMAN
      )
      prices
    },

    #' @description
    #' Marks where the harami candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_harami` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_harami(days = 730)
    #' pattern_column <- "candle_harami"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_harami(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_harami"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_harami = function(
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
      prices[["candle_harami"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHARAMI
      )
      prices
    },

    #' @description
    #' Marks where the harami cross candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_harami_cross` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_harami_cross(days = 1095)
    #' pattern_column <- "candle_harami_cross"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_harami_cross(days = 1825)
    #' pattern_column <- "candle_harami_cross"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_harami_cross = function(
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
      prices[["candle_harami_cross"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHARAMICROSS
      )
      prices
    },

    #' @description
    #' Marks where the high wave candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_high_wave` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_high_wave"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_high_wave(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_high_wave(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_high_wave"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_high_wave = function(
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
      prices[["candle_high_wave"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHIGHWAVE
      )
      prices
    },

    #' @description
    #' Marks where the hikkake candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_hikkake` column added, which is 100 for a bullish match, -100 for a bearish match, 200 or -200 when the match is confirmed and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_hikkake(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_hikkake"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_hikkake(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_hikkake"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_hikkake = function(
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
      prices[["candle_hikkake"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHIKKAKE
      )
      prices
    },

    #' @description
    #' Marks where the modified hikkake candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_modified_hikkake` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_modified_hikkake(days = 1825)
    #' pattern_column <- "candle_modified_hikkake"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_modified_hikkake(days = 365)
    #' pattern_column <- "candle_modified_hikkake"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_modified_hikkake = function(
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
      prices[["candle_modified_hikkake"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHIKKAKEMOD
      )
      prices
    },

    #' @description
    #' Marks where the homing pigeon candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_homing_pigeon` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_homing_pigeon(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_homing_pigeon"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_homing_pigeon(days = 730)
    #' pattern_column <- "candle_homing_pigeon"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_homing_pigeon = function(
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
      prices[["candle_homing_pigeon"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLHOMINGPIGEON
      )
      prices
    },

    #' @description
    #' Marks where the identical three crows candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_identical_three_crows` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_identical_three_crows(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_identical_three_crows"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_identical_three_crows(days = 1095)
    #' pattern_column <- "candle_identical_three_crows"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_identical_three_crows = function(
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
      prices[["candle_identical_three_crows"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLIDENTICAL3CROWS
      )
      prices
    },

    #' @description
    #' Marks where the in-neck candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_in_neck` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_in_neck(days = 365)
    #' pattern_column <- "candle_in_neck"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_in_neck"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_in_neck(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_in_neck = function(
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
      prices[["candle_in_neck"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLINNECK
      )
      prices
    },

    #' @description
    #' Marks where the inverted hammer candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_inverted_hammer` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_inverted_hammer(days = 730)
    #' pattern_column <- "candle_inverted_hammer"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_inverted_hammer(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_inverted_hammer"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_inverted_hammer = function(
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
      prices[["candle_inverted_hammer"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLINVERTEDHAMMER
      )
      prices
    },

    #' @description
    #' Marks where the kicking candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_kicking` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_kicking(days = 1095)
    #' pattern_column <- "candle_kicking"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_kicking(days = 1825)
    #' pattern_column <- "candle_kicking"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_kicking = function(
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
      prices[["candle_kicking"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLKICKING
      )
      prices
    },

    #' @description
    #' Marks where the kicking, bull or bear decided by the longer marubozu, candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_kicking_by_length` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_kicking_by_length"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_kicking_by_length(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_kicking_by_length(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_kicking_by_length"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_kicking_by_length = function(
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
      prices[["candle_kicking_by_length"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLKICKINGBYLENGTH
      )
      prices
    },

    #' @description
    #' Marks where the ladder bottom candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_ladder_bottom` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_ladder_bottom(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_ladder_bottom"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_ladder_bottom(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_ladder_bottom"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_ladder_bottom = function(
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
      prices[["candle_ladder_bottom"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLLADDERBOTTOM
      )
      prices
    },

    #' @description
    #' Marks where the long legged doji candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_long_legged_doji` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_long_legged_doji(days = 1825)
    #' pattern_column <- "candle_long_legged_doji"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_long_legged_doji(days = 365)
    #' pattern_column <- "candle_long_legged_doji"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_long_legged_doji = function(
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
      prices[["candle_long_legged_doji"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLLONGLEGGEDDOJI
      )
      prices
    },

    #' @description
    #' Marks where the long line candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_long_line` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_long_line(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_long_line"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_long_line(days = 730)
    #' pattern_column <- "candle_long_line"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_long_line = function(
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
      prices[["candle_long_line"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLLONGLINE
      )
      prices
    },

    #' @description
    #' Marks where the marubozu candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_marubozu` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_marubozu(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_marubozu"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_marubozu(days = 1095)
    #' pattern_column <- "candle_marubozu"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_marubozu = function(
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
      prices[["candle_marubozu"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLMARUBOZU
      )
      prices
    },

    #' @description
    #' Marks where the matching low candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_matching_low` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_matching_low(days = 365)
    #' pattern_column <- "candle_matching_low"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_matching_low"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_matching_low(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_matching_low = function(
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
      prices[["candle_matching_low"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLMATCHINGLOW
      )
      prices
    },

    #' @description
    #' Marks where the mat hold candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_mat_hold` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_mat_hold(days = 730)
    #' pattern_column <- "candle_mat_hold"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_mat_hold(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_mat_hold"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_mat_hold = function(
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
      prices[["candle_mat_hold"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLMATHOLD
      )
      prices
    },

    #' @description
    #' Marks where the morning star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_morning_star` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_morning_star(days = 1095)
    #' pattern_column <- "candle_morning_star"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_morning_star(days = 1825)
    #' pattern_column <- "candle_morning_star"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_morning_star = function(
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
      prices[["candle_morning_star"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLMORNINGSTAR
      )
      prices
    },

    #' @description
    #' Marks where the morning doji star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_morning_star_doji` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_morning_star_doji"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_morning_star_doji(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_morning_star_doji(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_morning_star_doji"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_morning_star_doji = function(
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
      prices[["candle_morning_star_doji"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLMORNINGDOJISTAR
      )
      prices
    },

    #' @description
    #' Marks where the on-neck candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_on_neck` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_on_neck(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_on_neck"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_on_neck(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_on_neck"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_on_neck = function(
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
      prices[["candle_on_neck"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLONNECK
      )
      prices
    },

    #' @description
    #' Marks where the piercing candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_piercing` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_piercing(days = 1825)
    #' pattern_column <- "candle_piercing"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_piercing(days = 365)
    #' pattern_column <- "candle_piercing"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_piercing = function(
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
      prices[["candle_piercing"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLPIERCING
      )
      prices
    },

    #' @description
    #' Marks where the rickshaw man candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_rickshaw_man` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_rickshaw_man(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_rickshaw_man"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_rickshaw_man(days = 730)
    #' pattern_column <- "candle_rickshaw_man"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_rickshaw_man = function(
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
      prices[["candle_rickshaw_man"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLRICKSHAWMAN
      )
      prices
    },

    #' @description
    #' Marks where the rising or falling three methods candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_rise_fall_three_methods` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_rise_fall_three_methods(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_rise_fall_three_methods"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_rise_fall_three_methods(days = 1095)
    #' pattern_column <- "candle_rise_fall_three_methods"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_rise_fall_three_methods = function(
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
      prices[["candle_rise_fall_three_methods"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLRISEFALL3METHODS
      )
      prices
    },

    #' @description
    #' Marks where the separating lines candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_separating_lines` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_separating_lines(days = 365)
    #' pattern_column <- "candle_separating_lines"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_separating_lines"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_separating_lines(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_separating_lines = function(
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
      prices[["candle_separating_lines"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSEPARATINGLINES
      )
      prices
    },

    #' @description
    #' Marks where the shooting star candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_shooting_star` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_shooting_star(days = 730)
    #' pattern_column <- "candle_shooting_star"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_shooting_star(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_shooting_star"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_shooting_star = function(
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
      prices[["candle_shooting_star"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSHOOTINGSTAR
      )
      prices
    },

    #' @description
    #' Marks where the short line candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_short_line` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_short_line(days = 1095)
    #' pattern_column <- "candle_short_line"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_short_line(days = 1825)
    #' pattern_column <- "candle_short_line"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_short_line = function(
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
      prices[["candle_short_line"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSHORTLINE
      )
      prices
    },

    #' @description
    #' Marks where the spinning top candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_spinning_top` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_spinning_top"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_spinning_top(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_spinning_top(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_spinning_top"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_spinning_top = function(
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
      prices[["candle_spinning_top"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSPINNINGTOP
      )
      prices
    },

    #' @description
    #' Marks where the stalled candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_stalled_pattern` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_stalled_pattern(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_stalled_pattern"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_stalled_pattern(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_stalled_pattern"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_stalled_pattern = function(
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
      prices[["candle_stalled_pattern"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSTALLEDPATTERN
      )
      prices
    },

    #' @description
    #' Marks where the stick sandwich candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_stick_sandwich` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_stick_sandwich(days = 1825)
    #' pattern_column <- "candle_stick_sandwich"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_stick_sandwich(days = 365)
    #' pattern_column <- "candle_stick_sandwich"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #' }
    candle_stick_sandwich = function(
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
      prices[["candle_stick_sandwich"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLSTICKSANDWICH
      )
      prices
    },

    #' @description
    #' Marks where the takuri, a dragonfly doji with a very long lower shadow, candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_takuri` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_takuri(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_takuri"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_takuri(days = 730)
    #' pattern_column <- "candle_takuri"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #' }
    candle_takuri = function(
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
      prices[["candle_takuri"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLTAKURI
      )
      prices
    },

    #' @description
    #' Marks where the tasuki gap candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_tasuki_gap` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_tasuki_gap(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_tasuki_gap"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_tasuki_gap(days = 1095)
    #' pattern_column <- "candle_tasuki_gap"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #' }
    candle_tasuki_gap = function(
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
      prices[["candle_tasuki_gap"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLTASUKIGAP
      )
      prices
    },

    #' @description
    #' Marks where the thrusting candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_thrusting_pattern` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' pattern_frame <- infosys$candle_thrusting_pattern(days = 365)
    #' pattern_column <- "candle_thrusting_pattern"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last year.")
    #' }
    #' for (position in seq_len(nrow(matches))) {
    #'   row <- matches[position, ]
    #'   print(paste(format(row$datetime, "%Y-%m-%d"), row[[pattern_column]]))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_thrusting_pattern"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_thrusting_pattern(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #' }
    candle_thrusting_pattern = function(
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
      prices[["candle_thrusting_pattern"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLTHRUSTING
      )
      prices
    },

    #' @description
    #' Marks where the tristar candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_tristar` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_tristar(days = 730)
    #' pattern_column <- "candle_tristar"
    #' bullish_count <- sum(pattern_frame[[pattern_column]] > 0)
    #' bearish_count <- sum(pattern_frame[[pattern_column]] < 0)
    #' print(sprintf("Bullish: %d, bearish: %d", bullish_count, bearish_count))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_tristar(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_tristar"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #' }
    candle_tristar = function(
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
      prices[["candle_tristar"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLTRISTAR
      )
      prices
    },

    #' @description
    #' Marks where the unique three river candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_unique_three_river` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' pattern_frame <- reliance$candle_unique_three_river(days = 1095)
    #' pattern_column <- "candle_unique_three_river"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match on Reliance in three years.")
    #' } else {
    #'   latest <- matches[nrow(matches), ]
    #'   latest_date <- format(latest$datetime, "%Y-%m-%d")
    #'   close_price <- latest$close
    #'   print(sprintf("Last seen on %s, closing at %s.", latest_date, close_price))
    #' }
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' pattern_frame <- hdfc_bank$candle_unique_three_river(days = 1825)
    #' pattern_column <- "candle_unique_three_river"
    #' closes <- pattern_frame$close
    #' next_closes <- c(closes[-1], NA)
    #' next_day_return <- next_closes / closes - 1
    #' after_pattern <- next_day_return[pattern_frame[[pattern_column]] != 0]
    #' after_pattern <- after_pattern[!is.na(after_pattern)]
    #' if (length(after_pattern) == 0) {
    #'   print("No match with a following day to measure.")
    #' } else {
    #'   average <- mean(after_pattern)
    #'   match_count <- length(after_pattern)
    #'   print(
    #'     sprintf("%d matches, %.3f%% on the next day", match_count, average * 100)
    #'   )
    #' }
    #' }
    candle_unique_three_river = function(
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
      prices[["candle_unique_three_river"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLUNIQUE3RIVER
      )
      prices
    },

    #' @description
    #' Marks where the upside gap two crows candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_up_side_gap_two_crows` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK"
    #' )
    #' pattern_column <- "candle_up_side_gap_two_crows"
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   pattern_frame <- share$candle_up_side_gap_two_crows(days = 1825)
    #'   match_count <- sum(pattern_frame[[pattern_column]] != 0)
    #'   print(sprintf("%s: %d matches in five years", symbol, match_count))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' pattern_frame <- nifty$candle_up_side_gap_two_crows(days = 30)
    #' latest <- pattern_frame[nrow(pattern_frame), ]
    #' latest_date <- format(latest$datetime, "%Y-%m-%d")
    #' signal <- latest[["candle_up_side_gap_two_crows"]]
    #' if (signal > 0) {
    #'   print(sprintf("Bullish match on %s.", latest_date))
    #' } else if (signal < 0) {
    #'   print(sprintf("Bearish match on %s.", latest_date))
    #' } else {
    #'   print(sprintf("No match on the latest candle, %s.", latest_date))
    #' }
    #' }
    candle_up_side_gap_two_crows = function(
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
      prices[["candle_up_side_gap_two_crows"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLUPSIDEGAP2CROWS
      )
      prices
    },

    #' @description
    #' Marks where the upside or downside gap three methods candlestick pattern appears.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `candle_up_side_gap_three_methods` column added, which is 100 for a bullish match, -100 for a bearish match and 0 otherwise, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' pattern_frame <- tcs$candle_up_side_down_side_gap_three_methods(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' pattern_column <- "candle_up_side_gap_three_methods"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' if (nrow(matches) == 0) {
    #'   print("No match in 2025.")
    #' } else {
    #'   months <- format(matches$datetime, "%Y-%m")
    #'   print(table(months))
    #' }
    #'
    #' state_bank <- Equity$new(exchange = "nse", symbol = "SBIN")
    #' pattern_frame <- state_bank$candle_up_side_down_side_gap_three_methods(
    #'   days = 180,
    #'   adjusted = FALSE
    #' )
    #' pattern_column <- "candle_up_side_gap_three_methods"
    #' matches <- pattern_frame[pattern_frame[[pattern_column]] != 0, ]
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   pattern_column
    #' )
    #' if (nrow(matches) == 0) {
    #'   print("No match in the last six months.")
    #' } else {
    #'   print(matches[, columns], row.names = FALSE)
    #' }
    #' }
    candle_up_side_down_side_gap_three_methods = function(
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
      prices[["candle_up_side_gap_three_methods"]] <- private$pattern_signals(
        prices = prices,
        recogniser = talib::CDLXSIDEGAP3METHODS
      )
      prices
    }
  ),
  private = list(
    # @description
    # Runs one of the `talib` package's candlestick recognisers over the candles and returns its signals as Python's `talib` gives them.
    #
    # The `talib` package reports a match as 1 or -1 unless its `talib.normalize` option is `FALSE`, so the option is set to `FALSE` for the call and restored afterwards. Candles at the start with a missing price are skipped, as Python's `talib` skips them, and every row without a signal, including the first candles that TA-Lib cannot judge, gets 0.
    # @param prices The `data.frame` of candles, with `open`, `high`, `low` and `close` columns.
    # @param recogniser The `talib` function to run, such as `talib::CDLDOJI`.
    # @return An integer vector with one signal per candle: 100 or -100 for a match, 200 or -200 for a confirmed hikkake, and 0 otherwise.
    pattern_signals = function(prices, recogniser) {
      candles <- data.frame(
        open = as.numeric(prices$open),
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close)
      )
      count <- nrow(candles)
      signals <- rep(0L, count)
      first <- 1
      while (first <= count && anyNA(candles[first, ])) {
        first <- first + 1
      }
      if (first > count) {
        return(signals)
      }
      previous_options <- options(talib.normalize = FALSE)
      on.exit(options(previous_options), add = TRUE)
      recognised <- recogniser(candles[first:count, , drop = FALSE])
      values <- as.integer(recognised[[1]])
      values[is.na(values)] <- 0L
      signals[first:count] <- values
      signals
    }
  )
)
