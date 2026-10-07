#' Summary statistics of the prices, volumes and returns in an instrument's candles
#'
#' @description
#' Summaries of an instrument's prices, volumes and returns over a range. Each method fetches the instrument's candles through `prices()` and reduces one column to a number, a summary or a histogram. The class is the first link after `PriceAnalysis` in the chain of analysis classes, and `Instrument` inherits it through that chain and supplies `prices()`.
#'
#' The methods form three families, each built on the one before: the `price_` methods read `prices()`, the `volume_` methods read `volumes()`, and the `returns_` methods read `returns()`, the fractional change of one column from each candle to the next, whose first row is always `NA`. Every statistic leaves out missing values, as pandas does, and the skewness, kurtosis, quantile, summary and histogram follow pandas' and NumPy's definitions exactly, so the figures match the Python library's.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' infosys$price_mean(column = "close", days = 365)
#' }
#' @export
PriceStatistics <- R6::R6Class(
  "PriceStatistics",
  inherit = PriceAnalysis,
  public = list(
    #' @description
    #' Finds the highest high in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The highest high as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_high(days = 365))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' year_high <- nifty$price_high(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' print(year_high)
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   year_high <- share$price_high(days = 365)
    #'   closes <- share$prices(days = 10)$close
    #'   last_close <- closes[[length(closes)]]
    #'   distance <- (year_high - last_close) / year_high * 100
    #'   cat(sprintf("%s: %.1f%% below %s\n", symbol, distance, year_high))
    #' }
    #' }
    price_high = function(
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
      private$price_statistics_largest(prices$high)
    },

    #' @description
    #' Finds the lowest low in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The lowest low as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_low(days = 365))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' year_low <- nifty$price_low(days = 365)
    #' year_high <- nifty$price_high(days = 365)
    #' cat(sprintf("Range: %.1f%%\n", (year_high - year_low) / year_low * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   year_low <- share$price_low(days = 365)
    #'   closes <- share$prices(days = 10)$close
    #'   last_close <- closes[[length(closes)]]
    #'   distance <- (last_close - year_low) / year_low * 100
    #'   cat(sprintf("%s: %.1f%% above %s\n", symbol, distance, year_low))
    #' }
    #' }
    price_low = function(
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
      private$price_statistics_smallest(prices$low)
    },

    #' @description
    #' Finds the mean of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_mean(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   average <- share$price_mean(
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: %.2f\n", symbol, average))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(nifty$price_mean(column = "high", days = 90))
    #' }
    price_mean = function(
      column = "close",
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
      mean(as.numeric(prices[[column]]), na.rm = TRUE)
    },

    #' @description
    #' Finds the median of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The median as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_median(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   mean <- share$price_mean(days = 365)
    #'   median <- share$price_median(days = 365)
    #'   if (mean > median) {
    #'     cat(sprintf("%s: mean %.2f > median %.2f\n", symbol, mean, median))
    #'   } else {
    #'     cat(sprintf("%s: mean %.2f < median %.2f\n", symbol, mean, median))
    #'   }
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(
    #'   nifty$price_median(
    #'     column = "open",
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #' )
    #' }
    price_median = function(
      column = "close",
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
      stats::median(as.numeric(prices[[column]]), na.rm = TRUE)
    },

    #' @description
    #' Finds the standard deviation of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The standard deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_standard_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   spread <- share$price_standard_deviation(days = 365)
    #'   mean <- share$price_mean(days = 365)
    #'   cat(sprintf("%s: %.1f%% of the mean\n", symbol, spread / mean * 100))
    #' }
    #'
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     Equity$new(exchange = "nse", symbol = "INFY"),
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' print(information_technology$price_standard_deviation(days = 365))
    #' }
    price_standard_deviation = function(
      column = "close",
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
      stats::sd(as.numeric(prices[[column]]), na.rm = TRUE)
    },

    #' @description
    #' Finds the variance of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The variance as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_variance(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   cat(sprintf("%s: %.2f\n", symbol, share$price_variance(days = 182)))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' years <- c(
    #'   "2024",
    #'   "2025"
    #' )
    #' for (year in years) {
    #'   variance <- nifty$price_variance(
    #'     from_date = paste0(year, "-01-01"),
    #'     to_date = paste0(year, "-12-31")
    #'   )
    #'   cat(sprintf("%s: %.0f\n", year, variance))
    #' }
    #' }
    price_variance = function(
      column = "close",
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
      stats::var(as.numeric(prices[[column]]), na.rm = TRUE)
    },

    #' @description
    #' Finds the mean absolute deviation of one candle column from its mean in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean absolute deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_mean_absolute_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   absolute <- share$price_mean_absolute_deviation(days = 365)
    #'   standard <- share$price_standard_deviation(days = 365)
    #'   cat(sprintf("%s: %.2f against %.2f\n", symbol, absolute, standard))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(nifty$price_mean_absolute_deviation(column = "low", days = 90))
    #' }
    price_mean_absolute_deviation = function(
      column = "close",
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
      private$price_statistics_mean_absolute_deviation(prices[[column]])
    },

    #' @description
    #' Finds the skewness of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The skewness as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_skewness(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   skewness <- share$price_skewness(days = 365)
    #'   if (skewness > 0) {
    #'     cat(sprintf("%s: %.2f, a tail of high prices\n", symbol, skewness))
    #'   } else {
    #'     cat(sprintf("%s: %.2f, a tail of low prices\n", symbol, skewness))
    #'   }
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' skewness <- nifty$price_skewness(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' print(skewness)
    #' }
    price_skewness = function(
      column = "close",
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
      private$price_statistics_skewness(prices[[column]])
    },

    #' @description
    #' Finds the kurtosis of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The kurtosis as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_kurtosis(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   cat(sprintf("%s: %.2f\n", symbol, share$price_kurtosis(days = 365)))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(nifty$price_kurtosis(column = "high", days = 730))
    #' }
    price_kurtosis = function(
      column = "close",
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
      private$price_statistics_kurtosis(prices[[column]])
    },

    #' @description
    #' Finds a quantile of one candle column in the range.
    #' @param quantile The numeric quantile to find, between 0 and 1, where 0.5 is the median.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The quantile as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_quantile(quantile = 0.9, days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   lower <- share$price_quantile(quantile = 0.25, days = 365)
    #'   upper <- share$price_quantile(quantile = 0.75, days = 365)
    #'   cat(sprintf("%s: %.2f to %.2f\n", symbol, lower, upper))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(
    #'   nifty$price_quantile(
    #'     quantile = 0.1,
    #'     column = "low",
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #' )
    #' }
    price_quantile = function(
      quantile = 0.5,
      column = "close",
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
      private$price_statistics_quantile(prices[[column]], quantile)
    },

    #' @description
    #' Summarises one candle column in the range with count, mean, spread and quartiles.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A named numeric vector of summary statistics, `count`, `mean`, `std`, `min`, `25%`, `50%`, `75%` and `max`, the same names and figures as pandas' `describe()`, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$price_summary(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   summary <- share$price_summary(days = 365)
    #'   cat(
    #'     sprintf(
    #'       "%s: mean %.2f, from %s to %s\n",
    #'       symbol,
    #'       summary[["mean"]],
    #'       summary[["min"]],
    #'       summary[["max"]]
    #'     )
    #'   )
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(
    #'   nifty$price_summary(
    #'     column = "high",
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #' )
    #' }
    price_summary = function(
      column = "close",
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
      private$price_statistics_summary(prices[[column]])
    },

    #' @description
    #' Draws a histogram of one candle column in the range on the current graphics device.
    #' @param bins The integer number of histogram bins.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The `histogram` object from `graphics::hist()`, whose `breaks` are the bin edges and whose `counts` are the bar heights, after drawing the histogram on the current graphics device, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' path <- file.path(tempdir(), "infosys_closes.png")
    #' grDevices::png(path)
    #' histogram <- infosys$price_histogram(bins = 30, days = 365)
    #' grDevices::dev.off()
    #' cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' histogram <- nifty$price_histogram(bins = 20, days = 365)
    #' tallest_bar <- which.max(histogram$counts)
    #' lower <- histogram$breaks[[tallest_bar]]
    #' upper <- histogram$breaks[[tallest_bar + 1]]
    #' count <- histogram$counts[[tallest_bar]]
    #' cat(sprintf("%.0f closes from %.0f to %.0f\n", count, lower, upper))
    #' }
    price_histogram = function(
      bins = 50,
      column = "close",
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
      private$price_statistics_histogram(prices[[column]], bins, column)
    },

    #' @description
    #' Fetches the traded volume of each candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with `exchange`, `segment`, `datetime`, `interval` and `volume` columns, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volumes(days = 10))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' volumes <- reliance$volumes(days = 365)
    #' busiest_row <- volumes[which.max(volumes$volume), ]
    #' busiest_date <- format(busiest_row$datetime, "%Y-%m-%d")
    #' cat(sprintf("%s: %s\n", busiest_date, busiest_row$volume))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   volumes <- share$volumes(days = 45)$volume
    #'   last <- length(volumes)
    #'   average <- mean(volumes[(last - 20):(last - 1)])
    #'   ratio <- volumes[[last]] / average
    #'   cat(sprintf("%s: %.2f times the average\n", symbol, ratio))
    #' }
    #' }
    volumes = function(
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
      columns <- c(
        "exchange",
        "segment",
        "datetime",
        "interval",
        "volume"
      )
      prices[, columns, drop = FALSE]
    },

    #' @description
    #' Finds the total volume traded in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The total volume as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_total(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   total <- share$volume_total(
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: %s\n", symbol, format(total, big.mark = ",")))
    #' }
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' totals <- numeric(0)
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   totals[[symbol]] <- share$volume_total(days = 30)
    #' }
    #' combined <- sum(totals)
    #' share_of_total <- totals[["INFY"]] / combined * 100
    #' cat(
    #'   sprintf(
    #'     "INFY: %.1f%% of %s\n",
    #'     share_of_total,
    #'     format(combined, big.mark = ",")
    #'   )
    #' )
    #' }
    volume_total = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      sum(as.numeric(volumes$volume), na.rm = TRUE)
    },

    #' @description
    #' Finds the highest volume of any candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The highest volume as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_high(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   busiest <- share$volume_high(days = 365)
    #'   average <- share$volume_mean(days = 365)
    #'   cat(sprintf("%s: %.1f times the average\n", symbol, busiest / average))
    #' }
    #' }
    volume_high = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_largest(volumes$volume)
    },

    #' @description
    #' Finds the lowest volume of any candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The lowest volume as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_low(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   quietest <- share$volume_low(days = 90)
    #'   busiest <- share$volume_high(days = 90)
    #'   cat(
    #'     sprintf(
    #'       "%s: from %s to %s\n",
    #'       symbol,
    #'       format(quietest, big.mark = ","),
    #'       format(busiest, big.mark = ",")
    #'     )
    #'   )
    #' }
    #' }
    volume_low = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_smallest(volumes$volume)
    },

    #' @description
    #' Finds the mean volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean volume as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_mean(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   month <- share$volume_mean(days = 30)
    #'   year <- share$volume_mean(days = 365)
    #'   ratio <- month / year
    #'   cat(sprintf("%s: %.2f times the yearly average\n", symbol, ratio))
    #' }
    #' }
    volume_mean = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      mean(as.numeric(volumes$volume), na.rm = TRUE)
    },

    #' @description
    #' Finds the median volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The median volume as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_median(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   mean <- share$volume_mean(days = 365)
    #'   median <- share$volume_median(days = 365)
    #'   cat(sprintf("%s: mean %.2f times the median\n", symbol, mean / median))
    #' }
    #' }
    volume_median = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      stats::median(as.numeric(volumes$volume), na.rm = TRUE)
    },

    #' @description
    #' Finds the standard deviation of volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The standard deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_standard_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   spread <- share$volume_standard_deviation(days = 365)
    #'   mean <- share$volume_mean(days = 365)
    #'   cat(sprintf("%s: %.2f\n", symbol, spread / mean))
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' mean <- infosys$volume_mean(days = 365)
    #' spread <- infosys$volume_standard_deviation(days = 365)
    #' volumes <- infosys$volumes(days = 10)$volume
    #' last_volume <- volumes[[length(volumes)]]
    #' volume_text <- format(last_volume, big.mark = ",")
    #' if (last_volume > mean + 2 * spread) {
    #'   cat(sprintf("Unusually busy: %s\n", volume_text))
    #' } else {
    #'   cat(sprintf("Ordinary: %s\n", volume_text))
    #' }
    #' }
    volume_standard_deviation = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      stats::sd(as.numeric(volumes$volume), na.rm = TRUE)
    },

    #' @description
    #' Finds the variance of volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The variance as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_variance(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   variance <- share$volume_variance(
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: %.3e\n", symbol, variance))
    #' }
    #' }
    volume_variance = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      stats::var(as.numeric(volumes$volume), na.rm = TRUE)
    },

    #' @description
    #' Finds the mean absolute deviation of volume per candle from its mean in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean absolute deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_mean_absolute_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   deviation <- share$volume_mean_absolute_deviation(days = 365)
    #'   mean <- share$volume_mean(days = 365)
    #'   cat(sprintf("%s: %.0f%%\n", symbol, deviation / mean * 100))
    #' }
    #' }
    volume_mean_absolute_deviation = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_mean_absolute_deviation(volumes$volume)
    },

    #' @description
    #' Finds the kurtosis of volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The kurtosis as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_kurtosis(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   cat(sprintf("%s: %.2f\n", symbol, share$volume_kurtosis(days = 365)))
    #' }
    #' }
    volume_kurtosis = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_kurtosis(volumes$volume)
    },

    #' @description
    #' Finds the skewness of volume per candle in the range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The skewness as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_skewness(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   cat(sprintf("%s: %.2f\n", symbol, share$volume_skewness(days = 365)))
    #' }
    #' }
    volume_skewness = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_skewness(volumes$volume)
    },

    #' @description
    #' Finds a quantile of volume per candle in the range.
    #' @param quantile The numeric quantile to find, between 0 and 1, where 0.5 is the median.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The quantile as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_quantile(quantile = 0.9, days = 365))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' threshold <- reliance$volume_quantile(quantile = 0.9, days = 365)
    #' volumes <- reliance$volumes(days = 365)$volume
    #' busy_days <- 0
    #' for (volume in volumes) {
    #'   if (volume > threshold) {
    #'     busy_days <- busy_days + 1
    #'   }
    #' }
    #' threshold_text <- formatC(threshold, format = "f", digits = 0, big.mark = ",")
    #' cat(sprintf("%d days above %s\n", busy_days, threshold_text))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   lower <- share$volume_quantile(quantile = 0.25, days = 365)
    #'   median <- share$volume_quantile(quantile = 0.5, days = 365)
    #'   cat(
    #'     sprintf(
    #'       "%s: %s and %s\n",
    #'       symbol,
    #'       formatC(lower, format = "f", digits = 0, big.mark = ","),
    #'       formatC(median, format = "f", digits = 0, big.mark = ",")
    #'     )
    #'   )
    #' }
    #' }
    volume_quantile = function(
      quantile = 0.5,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_quantile(volumes$volume, quantile)
    },

    #' @description
    #' Summarises volume per candle in the range with count, mean, spread and quartiles.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A named numeric vector of summary statistics, `count`, `mean`, `std`, `min`, `25%`, `50%`, `75%` and `max`, the same names and figures as pandas' `describe()`, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$volume_summary(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   summary <- share$volume_summary(days = 365)
    #'   average <- summary[["mean"]]
    #'   busiest <- summary[["max"]]
    #'   cat(
    #'     sprintf(
    #'       "%s: %s, at most %s\n",
    #'       symbol,
    #'       formatC(average, format = "f", digits = 0, big.mark = ","),
    #'       formatC(busiest, format = "f", digits = 0, big.mark = ",")
    #'     )
    #'   )
    #' }
    #' }
    volume_summary = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_summary(volumes$volume)
    },

    #' @description
    #' Draws a histogram of volume per candle in the range on the current graphics device.
    #' @param bins The integer number of histogram bins.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The `histogram` object from `graphics::hist()`, whose `breaks` are the bin edges and whose `counts` are the bar heights, after drawing the histogram on the current graphics device, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' path <- file.path(tempdir(), "infosys_volumes.png")
    #' grDevices::png(path)
    #' histogram <- infosys$volume_histogram(bins = 40, days = 365)
    #' grDevices::dev.off()
    #' cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' histogram <- reliance$volume_histogram(bins = 20, days = 365)
    #' tallest_bar <- which.max(histogram$counts)
    #' lower <- histogram$breaks[[tallest_bar]]
    #' upper <- histogram$breaks[[tallest_bar + 1]]
    #' count <- histogram$counts[[tallest_bar]]
    #' cat(
    #'   sprintf(
    #'     "%.0f days from %s to %s\n",
    #'     count,
    #'     formatC(lower, format = "f", digits = 0, big.mark = ","),
    #'     formatC(upper, format = "f", digits = 0, big.mark = ",")
    #'   )
    #' )
    #' }
    volume_histogram = function(
      bins = 50,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      volumes <- self$volumes(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(volumes)) {
        return(NULL)
      }
      private$price_statistics_histogram(volumes$volume, bins, "volume")
    },

    #' @description
    #' Calculates the fractional change of one candle column from each candle to the next.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with `exchange`, `segment`, `datetime`, `interval` and `returns` columns, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns(days = 10))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' returns <- nifty$returns(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' growth <- 1
    #' for (daily_return in returns$returns[!is.na(returns$returns)]) {
    #'   growth <- growth * (1 + daily_return)
    #' }
    #' cat(sprintf("%.2f%%\n", (growth - 1) * 100))
    #'
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     Equity$new(exchange = "nse", symbol = "INFY"),
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' print(information_technology$returns(days = 10))
    #' }
    returns = function(
      column = "close",
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
      values <- as.numeric(prices[[column]])
      previous_values <- c(NA_real_, values[-length(values)])
      prices[["returns"]] <- values / previous_values - 1
      columns <- c(
        "exchange",
        "segment",
        "datetime",
        "interval",
        "returns"
      )
      prices[, columns, drop = FALSE]
    },

    #' @description
    #' Finds the highest return of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The highest return as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_high(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   best <- share$returns_high(days = 365) * 100
    #'   cat(sprintf("%s: %.2f%%\n", symbol, best))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' best <- nifty$returns_high(
    #'   column = "high",
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' cat(sprintf("%.2f%%\n", best * 100))
    #' }
    returns_high = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_largest(returns$returns)
    },

    #' @description
    #' Finds the lowest return of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The lowest return as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_low(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   worst <- share$returns_low(days = 365) * 100
    #'   best <- share$returns_high(days = 365) * 100
    #'   cat(sprintf("%s: from %.2f%% to %.2f%%\n", symbol, worst, best))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' worst <- nifty$returns_low(
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31"
    #' )
    #' cat(sprintf("%.2f%%\n", worst * 100))
    #' }
    returns_low = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_smallest(returns$returns)
    },

    #' @description
    #' Finds the mean return of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean return as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_mean(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   annual <- share$returns_mean(days = 365) * 252
    #'   cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
    #' }
    #'
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     Equity$new(exchange = "nse", symbol = "INFY"),
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' print(information_technology$returns_mean(days = 365))
    #' }
    returns_mean = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      mean(as.numeric(returns$returns), na.rm = TRUE)
    },

    #' @description
    #' Finds the median return of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The median return as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_median(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   median <- share$returns_median(days = 365)
    #'   mean <- share$returns_mean(days = 365)
    #'   cat(sprintf("%s: median %.5f, mean %.5f\n", symbol, median, mean))
    #' }
    #' }
    returns_median = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      stats::median(as.numeric(returns$returns), na.rm = TRUE)
    },

    #' @description
    #' Finds the standard deviation of returns of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The standard deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_standard_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   daily <- share$returns_standard_deviation(days = 365)
    #'   annual <- daily * sqrt(252)
    #'   cat(sprintf("%s: %.1f%% a year\n", symbol, annual * 100))
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     infosys,
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' basket <- information_technology$returns_standard_deviation(days = 365)
    #' single <- infosys$returns_standard_deviation(days = 365)
    #' cat(sprintf("Basket %.4f against Infosys %.4f\n", basket, single))
    #' }
    returns_standard_deviation = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      stats::sd(as.numeric(returns$returns), na.rm = TRUE)
    },

    #' @description
    #' Finds the variance of returns of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The variance as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_variance(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   annual <- share$returns_variance(days = 365) * 252
    #'   cat(sprintf("%s: %.4f\n", symbol, annual))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' years <- c(
    #'   "2024",
    #'   "2025"
    #' )
    #' for (year in years) {
    #'   variance <- nifty$returns_variance(
    #'     from_date = paste0(year, "-01-01"),
    #'     to_date = paste0(year, "-12-31")
    #'   )
    #'   cat(sprintf("%s: %.6f\n", year, variance))
    #' }
    #' }
    returns_variance = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      stats::var(as.numeric(returns$returns), na.rm = TRUE)
    },

    #' @description
    #' Finds the mean absolute deviation of returns of one candle column from their mean in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The mean absolute deviation as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_mean_absolute_deviation(days = 365))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   deviation <- share$returns_mean_absolute_deviation(days = 365)
    #'   cat(sprintf("%s: %.2f%%\n", symbol, deviation * 100))
    #' }
    #' }
    returns_mean_absolute_deviation = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_mean_absolute_deviation(returns$returns)
    },

    #' @description
    #' Finds the skewness of returns of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The skewness as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_skewness(days = 365))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   skewness <- share$returns_skewness(days = 365)
    #'   if (skewness > 0) {
    #'     cat(sprintf("%s: %.2f, more large rises\n", symbol, skewness))
    #'   } else {
    #'     cat(sprintf("%s: %.2f, more large falls\n", symbol, skewness))
    #'   }
    #' }
    #' }
    returns_skewness = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_skewness(returns$returns)
    },

    #' @description
    #' Finds the kurtosis of returns of one candle column in the range.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The kurtosis as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_kurtosis(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   cat(sprintf("%s: %.2f\n", symbol, share$returns_kurtosis(days = 365)))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(nifty$returns_kurtosis(days = 730))
    #' }
    returns_kurtosis = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_kurtosis(returns$returns)
    },

    #' @description
    #' Finds a quantile of returns of one candle column in the range.
    #' @param quantile The numeric quantile to find, between 0 and 1, where 0.5 is the median.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The quantile as a numeric, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_quantile(quantile = 0.05, days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   fifth_percentile <- share$returns_quantile(
    #'     quantile = 0.05,
    #'     days = 365
    #'   )
    #'   loss <- -fifth_percentile * 100000
    #'   loss_text <- formatC(loss, format = "f", digits = 0, big.mark = ",")
    #'   cat(sprintf("%s: Rs %s\n", symbol, loss_text))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' print(
    #'   nifty$returns_quantile(
    #'     quantile = 0.95,
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #' )
    #' }
    returns_quantile = function(
      quantile = 0.5,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_quantile(returns$returns, quantile)
    },

    #' @description
    #' Draws a histogram of returns of one candle column in the range on the current graphics device.
    #' @param bins The integer number of histogram bins.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The `histogram` object from `graphics::hist()`, whose `breaks` are the bin edges and whose `counts` are the bar heights, after drawing the histogram on the current graphics device, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' path <- file.path(tempdir(), "infosys_returns.png")
    #' grDevices::png(path)
    #' histogram <- infosys$returns_histogram(bins = 40, days = 365)
    #' grDevices::dev.off()
    #' cat(sprintf("Saved %d bars to %s\n", length(histogram$counts), path))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' histogram <- nifty$returns_histogram(bins = 30, days = 365)
    #' falling_days <- 0
    #' for (bar in seq_along(histogram$counts)) {
    #'   if (histogram$breaks[[bar + 1]] <= 0) {
    #'     falling_days <- falling_days + histogram$counts[[bar]]
    #'   }
    #' }
    #' cat(sprintf("%.0f days in bars wholly below zero\n", falling_days))
    #' }
    returns_histogram = function(
      bins = 50,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_histogram(returns$returns, bins, "returns")
    },

    #' @description
    #' Summarises returns of one candle column in the range with count, mean, spread and quartiles.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A named numeric vector of summary statistics, `count`, `mean`, `std`, `min`, `25%`, `50%`, `75%` and `max`, the same names and figures as pandas' `describe()`, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' print(infosys$returns_summary(days = 365))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   summary <- share$returns_summary(days = 365)
    #'   cat(
    #'     sprintf(
    #'       "%s: mean %.4f, deviation %.4f, worst %.4f\n",
    #'       symbol,
    #'       summary[["mean"]],
    #'       summary[["std"]],
    #'       summary[["min"]]
    #'     )
    #'   )
    #' }
    #'
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     Equity$new(exchange = "nse", symbol = "INFY"),
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' print(information_technology$returns_summary(days = 365))
    #' }
    returns_summary = function(
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$returns(
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(returns)) {
        return(NULL)
      }
      private$price_statistics_summary(returns$returns)
    }
  ),
  private = list(
    #' Keeps the values that are present.
    #' @param values A numeric vector that may hold `NA`.
    #' @return A numeric vector of the values that are not `NA`, in their order.
    price_statistics_present = function(values) {
      values <- as.numeric(values)
      values[!is.na(values)]
    },

    #' Finds the largest value that is present.
    #' @param values A numeric vector that may hold `NA`.
    #' @return The largest value as a numeric, or `NA` when no value is present, as pandas' `max()` gives `NaN`.
    price_statistics_largest = function(values) {
      present <- private$price_statistics_present(values)
      if (length(present) == 0) {
        return(NA_real_)
      }
      max(present)
    },

    #' Finds the smallest value that is present.
    #' @param values A numeric vector that may hold `NA`.
    #' @return The smallest value as a numeric, or `NA` when no value is present, as pandas' `min()` gives `NaN`.
    price_statistics_smallest = function(values) {
      present <- private$price_statistics_present(values)
      if (length(present) == 0) {
        return(NA_real_)
      }
      min(present)
    },

    #' Finds the mean absolute deviation of the values from their mean.
    #' @param values A numeric vector that may hold `NA`, which is left out.
    #' @return The mean absolute deviation as a numeric, or `NaN` when no value is present.
    price_statistics_mean_absolute_deviation = function(values) {
      present <- private$price_statistics_present(values)
      deviations <- present - mean(present)
      mean(abs(deviations))
    },

    #' Finds the bias-corrected skewness of the values, as pandas' `skew()` does.
    #' @param values A numeric vector that may hold `NA`, which is left out.
    #' @return The adjusted Fisher-Pearson skewness as a numeric, `0` when the values are all the same, or `NA` when fewer than three values are present.
    price_statistics_skewness = function(values) {
      present <- private$price_statistics_present(values)
      count <- length(present)
      if (count < 3) {
        return(NA_real_)
      }
      adjusted <- present - sum(present) / count
      second_moment <- sum(adjusted^2)
      third_moment <- sum(adjusted^3)
      rounding_limit <- .Machine$double.eps * max(abs(present))
      if (abs(second_moment) < rounding_limit^2 * count) {
        second_moment <- 0
      }
      if (abs(third_moment) < rounding_limit^3 * count) {
        third_moment <- 0
      }
      if (second_moment == 0) {
        return(0)
      }
      scale <- count * sqrt(count - 1) / (count - 2)
      scale * third_moment / second_moment^1.5
    },

    #' Finds the bias-corrected excess kurtosis of the values, as pandas' `kurtosis()` does.
    #' @param values A numeric vector that may hold `NA`, which is left out.
    #' @return Fisher's excess kurtosis with the sample correction as a numeric, `0` when the values are all the same, or `NA` when fewer than four values are present.
    price_statistics_kurtosis = function(values) {
      present <- private$price_statistics_present(values)
      count <- length(present)
      if (count < 4) {
        return(NA_real_)
      }
      adjusted <- present - sum(present) / count
      second_moment <- sum(adjusted^2)
      fourth_moment <- sum(adjusted^4)
      rounding_limit <- .Machine$double.eps * max(abs(present))
      if (abs(second_moment) < rounding_limit^2 * count) {
        second_moment <- 0
      }
      if (abs(fourth_moment) < rounding_limit^4 * count) {
        fourth_moment <- 0
      }
      correction <- 3 * (count - 1)^2 / ((count - 2) * (count - 3))
      numerator <- count * (count + 1) * (count - 1) * fourth_moment
      denominator <- (count - 2) * (count - 3) * second_moment^2
      if (denominator == 0) {
        return(0)
      }
      numerator / denominator - correction
    },

    #' Finds a quantile of the values by linear interpolation, as pandas' `quantile()` does.
    #' @param values A numeric vector that may hold `NA`, which is left out.
    #' @param quantile The numeric quantile to find, between 0 and 1.
    #' @return The quantile as a numeric, or `NA` when no value is present.
    price_statistics_quantile = function(values, quantile) {
      present <- private$price_statistics_present(values)
      if (length(present) == 0) {
        return(NA_real_)
      }
      stats::quantile(present, probs = quantile, names = FALSE, type = 7)
    },

    #' Summarises the values with the eight figures pandas' `describe()` gives.
    #' @param values A numeric vector that may hold `NA`, which is left out of every figure.
    #' @return A named numeric vector with `count`, `mean`, `std`, `min`, `25%`, `50%`, `75%` and `max`.
    price_statistics_summary = function(values) {
      present <- private$price_statistics_present(values)
      c(
        count = length(present),
        mean = mean(present),
        std = stats::sd(present),
        min = private$price_statistics_smallest(present),
        "25%" = private$price_statistics_quantile(present, 0.25),
        "50%" = private$price_statistics_quantile(present, 0.5),
        "75%" = private$price_statistics_quantile(present, 0.75),
        max = private$price_statistics_largest(present)
      )
    },

    #' Draws a histogram of the values with equal-width bins, as NumPy and matplotlib do.
    #'
    #' The bins run from the smallest to the largest value, or half a unit either side when every value is the same. Each bin holds the values from its lower edge up to but not including its upper edge, except the last, which also holds its upper edge.
    #' @param values A numeric vector that may hold `NA`, which is left out.
    #' @param bins The integer number of bins.
    #' @param label The character name of the column, used for the title and the axis label.
    #' @return The `histogram` object from `graphics::hist()`.
    price_statistics_histogram = function(values, bins, label) {
      present <- private$price_statistics_present(values)
      lower_edge <- min(present)
      upper_edge <- max(present)
      if (lower_edge == upper_edge) {
        lower_edge <- lower_edge - 0.5
        upper_edge <- upper_edge + 0.5
      }
      breaks <- seq(lower_edge, upper_edge, length.out = bins + 1)
      graphics::hist(
        present,
        breaks = breaks,
        right = FALSE,
        include.lowest = TRUE,
        main = paste("Histogram of", label),
        xlab = label
      )
    }
  )
)
