#' Rolling statistics an instrument calculates from its candles with TA-Lib
#'
#' @description
#' Rolling regressions, correlations and dispersion of candle columns. Each method fetches the instrument's candles through `prices()`, adds one or more columns and returns the candles. The class is a link in the chain of analysis classes that `Instrument` inherits, and `Instrument` supplies `prices()`.
#'
#' Beta, standard deviation and variance come from the `talib` package. Its R interface has no linear regression functions, and its correlation is a newer rewrite that treats a missing value differently from Python's `talib`, so the regression methods and the correlation follow TA-Lib 0.6.4's definitions in R, with the same empty values at the start.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$linear_regression_slope(window = 14, days = 365)
#' nifty <- NonTradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equity_indices",
#'   symbol = "NIFTY"
#' )
#' frame <- infosys$beta(nifty, window = 60, days = 730)
#' }
#' @export
StatisticFunctions <- R6::R6Class(
  "StatisticFunctions",
  inherit = VolatilityIndicators,
  public = list(
    #' @description
    #' Adds the rolling beta of the instrument against a benchmark, such as an index.
    #'
    #' TA-Lib's beta works on the change from each candle to the next, so a beta of 1 means the instrument moved in step with the benchmark. Candles are matched by time, and a candle either side lacks is left out.
    #' @param benchmark The instrument to measure against, such as a `NonTradeableInstrument` for NIFTY, or any other object with a `prices()` method.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use from both, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the matched candles with a `benchmark_<column>` column and a `beta_<window>` column added, or `NULL` when UBI has no candles for either instrument in the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when TA-Lib rejects `window`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- infosys$beta(benchmark = nifty, window = 20, days = 180)
    #' print(tail(frame[, c("datetime", "beta_20")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$beta(benchmark = nifty, window = 60, days = 365)
    #'   latest_beta <- frame$beta_60[[nrow(frame)]]
    #'   print(sprintf("%s: beta %.2f", symbol, latest_beta))
    #' }
    #' }
    beta = function(
      benchmark,
      window = 14,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- private$prices_with_benchmark(
        benchmark = benchmark,
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      benchmark_values <- as.numeric(prices[[paste0("benchmark_", column)]])
      instrument_values <- as.numeric(prices[[column]])
      count <- length(instrument_values)
      beta_values <- rep(NA_real_, count)
      first <- private$first_complete_position(
        list(
          benchmark_values,
          instrument_values
        )
      )
      if (first <= count) {
        beta_values[first:count] <- talib::BETA(
          x = benchmark_values[first:count],
          y = instrument_values[first:count],
          timePeriod = window
        )
      }
      prices[[paste0("beta_", window)]] <- beta_values
      prices
    },

    #' @description
    #' Adds the rolling Pearson correlation of the instrument's returns with a benchmark's returns.
    #'
    #' Returns, the fractional change from each candle to the next, are correlated rather than price levels, because two unrelated prices that both trend upwards would otherwise look strongly correlated. Candles are matched by time, and a candle either side lacks is left out.
    #' @param benchmark The instrument to compare with, such as a `NonTradeableInstrument` for NIFTY, or any other object with a `prices()` method.
    #' @param window The integer number of returns in each calculation window.
    #' @param column The character name of the candle column to use from both, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the matched candles with a `benchmark_<column>` column and a `corr_<window>` column added, which lies between -1 and 1, or `NULL` when UBI has no candles for either instrument in the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 1 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- infosys$correlation_coefficient(
    #'   benchmark = nifty,
    #'   window = 20,
    #'   days = 180
    #' )
    #' print(tail(frame[, c("datetime", "corr_20")], 5))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- tcs$correlation_coefficient(
    #'   benchmark = infosys,
    #'   window = 30,
    #'   days = 365
    #' )
    #' average <- mean(frame$corr_30, na.rm = TRUE)
    #' print(sprintf("Average correlation: %.2f", average))
    #' }
    correlation_coefficient = function(
      benchmark,
      window = 14,
      column = "close",
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      prices <- private$prices_with_benchmark(
        benchmark = benchmark,
        column = column,
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(prices)) {
        return(NULL)
      }
      instrument_returns <- private$fractional_changes(prices[[column]])
      benchmark_returns <- private$fractional_changes(
        prices[[paste0("benchmark_", column)]]
      )
      prices[[paste0("corr_", window)]] <- private$rolling_correlation(
        first_values = instrument_returns,
        second_values = benchmark_returns,
        window = window
      )
      prices
    },

    #' @description
    #' Adds the end value of a rolling linear regression line through one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `lin_regr_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$linear_regression(days = 90)
    #' print(tail(frame[, c("datetime", "lin_regr_14")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$linear_regression(window = 20, days = 120)
    #' last_row <- nrow(frame)
    #' gap <- frame$close[[last_row]] - frame$lin_regr_20[[last_row]]
    #' print(sprintf("The close is %.2f points from the regression line", gap))
    #' }
    linear_regression = function(
      window = 14,
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
      lines <- private$regression_lines(
        values = prices[[column]],
        window = window,
        function_name = "TA_LINEARREG"
      )
      prices[[paste0("lin_regr_", window)]] <- lines$end_value
      prices
    },

    #' @description
    #' Adds the slope of a rolling linear regression line through one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `lin_regr_slope_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$linear_regression_slope(days = 90)
    #' print(tail(frame[, c("datetime", "lin_regr_slope_14")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$linear_regression_slope(window = 50, days = 180)
    #' slope <- frame$lin_regr_slope_50[[nrow(frame)]]
    #' if (slope > 0) {
    #'   print(sprintf("Rising by %.2f points a day", slope))
    #' } else {
    #'   print(sprintf("Falling by %.2f points a day", -slope))
    #' }
    #' }
    linear_regression_slope = function(
      window = 14,
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
      lines <- private$regression_lines(
        values = prices[[column]],
        window = window,
        function_name = "TA_LINEARREG_SLOPE"
      )
      prices[[paste0("lin_regr_slope_", window)]] <- lines$slope
      prices
    },

    #' @description
    #' Adds the intercept of a rolling linear regression line through one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `lin_regr_int_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$linear_regression_intercept(days = 90)
    #' print(tail(frame[, c("datetime", "lin_regr_int_14")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' intercept_frame <- infosys$linear_regression_intercept(days = 90)
    #' slope_frame <- infosys$linear_regression_slope(days = 90)
    #' line_frame <- infosys$linear_regression(days = 90)
    #' last_row <- nrow(line_frame)
    #' intercept <- intercept_frame$lin_regr_int_14[[last_row]]
    #' slope <- slope_frame$lin_regr_slope_14[[last_row]]
    #' print(sprintf("Rebuilt end value %.2f", intercept + 13 * slope))
    #' print(
    #'   sprintf("linear_regression %.2f", line_frame$lin_regr_14[[last_row]])
    #' )
    #' }
    linear_regression_intercept = function(
      window = 14,
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
      lines <- private$regression_lines(
        values = prices[[column]],
        window = window,
        function_name = "TA_LINEARREG_INTERCEPT"
      )
      prices[[paste0("lin_regr_int_", window)]] <- lines$intercept
      prices
    },

    #' @description
    #' Adds the angle in degrees of a rolling linear regression line through one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `lin_regr_angle_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when `window` is below 2 or above 100000, as TA-Lib does.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$linear_regression_angle(days = 90)
    #' print(tail(frame[, c("datetime", "lin_regr_angle_14")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$linear_regression_angle(window = 30, days = 120)
    #' angle <- frame$lin_regr_angle_30[[nrow(frame)]]
    #' print(sprintf("%.2f degrees", angle))
    #' }
    linear_regression_angle = function(
      window = 14,
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
      lines <- private$regression_lines(
        values = prices[[column]],
        window = window,
        function_name = "TA_LINEARREG_ANGLE"
      )
      prices[[paste0("lin_regr_angle_", window)]] <- lines$angle
      prices
    },

    #' @description
    #' Adds the rolling standard deviation of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param standard_deviations The numeric multiple of the standard deviation to report.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `std_dev_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when TA-Lib rejects `window`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$standard_deviation(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "std_dev_20")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$standard_deviation(
    #'   window = 20,
    #'   standard_deviations = 2,
    #'   days = 90
    #' )
    #' last_row <- nrow(frame)
    #' middle <- mean(frame$close[(last_row - 19):last_row])
    #' width <- frame$std_dev_20[[last_row]]
    #' print(sprintf("Upper %.2f, lower %.2f", middle + width, middle - width))
    #' }
    standard_deviation = function(
      window = 14,
      standard_deviations = 1,
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
      count <- length(values)
      deviation_values <- rep(NA_real_, count)
      first <- private$first_complete_position(list(values))
      if (first <= count) {
        deviation_values[first:count] <- talib::STDDEV(
          x = values[first:count],
          timePeriod = window,
          deviations = standard_deviations
        )
      }
      prices[[paste0("std_dev_", window)]] <- deviation_values
      prices
    },

    #' @description
    #' Adds the rolling variance of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param standard_deviations The numeric multiple passed to TA-Lib, which its variance calculation does not use.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `var_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached, and a plain error when TA-Lib rejects `window`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$variance(window = 20, days = 90)
    #' print(tail(frame[, c("datetime", "var_20")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$variance(
    #'   window = 10,
    #'   from_date = "2026-01-01",
    #'   to_date = "2026-06-30"
    #' )
    #' peak_row <- which.max(frame$var_10)
    #' peak_day <- format(frame$datetime[[peak_row]], "%Y-%m-%d")
    #' print(paste(peak_day, round(frame$var_10[[peak_row]], 1)))
    #' }
    variance = function(
      window = 14,
      standard_deviations = 1,
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
      count <- length(values)
      variance_values <- rep(NA_real_, count)
      first <- private$first_complete_position(list(values))
      if (first <= count) {
        variance_values[first:count] <- talib::VAR(
          x = values[first:count],
          timePeriod = window,
          deviations = standard_deviations
        )
      }
      prices[[paste0("var_", window)]] <- variance_values
      prices
    }
  ),
  private = list(
    #' @description
    #' Fetches the instrument's candles with a benchmark's column matched to them by time.
    #'
    #' Each candle of the instrument is kept, in its own order, when the benchmark has a candle at the same moment, as a pandas inner merge on `datetime` does.
    #' @param benchmark The object with a `prices()` method whose column is matched in.
    #' @param column The character name of the candle column taken from the benchmark.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the instrument's candles that have a benchmark candle at the same time, with an added `benchmark_<column>` column, or `NULL` when either has no candles in the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    prices_with_benchmark = function(
      benchmark,
      column,
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
      benchmark_prices <- benchmark$prices(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(benchmark_prices)) {
        return(NULL)
      }
      benchmark_rows <- match(
        as.numeric(prices$datetime),
        as.numeric(benchmark_prices$datetime)
      )
      matched_rows <- !is.na(benchmark_rows)
      if (!any(matched_rows)) {
        return(NULL)
      }
      matched <- prices[matched_rows, , drop = FALSE]
      matched[[paste0("benchmark_", column)]] <- benchmark_prices[[column]][
        benchmark_rows[matched_rows]
      ]
      rownames(matched) <- NULL
      matched
    },

    #' @description
    #' Calculates the fractional change from each value to the next, as pandas `pct_change()` does.
    #' @param values A numeric vector.
    #' @return A numeric vector of the same length, whose first element is `NA` and whose other elements are each value divided by the one before, minus 1.
    fractional_changes = function(values) {
      values <- as.numeric(values)
      count <- length(values)
      changes <- rep(NA_real_, count)
      if (count < 2) {
        return(changes)
      }
      for (position in 2:count) {
        changes[[position]] <- values[[position]] / values[[position - 1]] - 1
      }
      changes
    },

    #' @description
    #' Finds the first row at which every one of several equally long vectors has a value.
    #'
    #' Python's `talib` skips missing values at the start of its inputs before calling TA-Lib and reports them as missing, and this position is where that skipping stops.
    #' @param columns A list of numeric vectors of the same length.
    #' @return The integer position of the first row with no `NA` in any vector, or one more than the length when there is none.
    first_complete_position = function(columns) {
      count <- length(columns[[1]])
      position <- 1
      while (position <= count) {
        complete <- TRUE
        for (column in columns) {
          if (is.na(column[[position]])) {
            complete <- FALSE
          }
        }
        if (complete) {
          return(position)
        }
        position <- position + 1
      }
      position
    },

    #' @description
    #' Calculates TA-Lib's rolling Pearson correlation of two numeric vectors.
    #'
    #' This follows TA-Lib 0.6.4's `TA_CORREL`, the version Python's `talib` uses, with its running sums, so a missing value inside the data makes every later value missing, as in Python. The `talib` package's `CORREL` is a newer rewrite that differs in the last digits and turns such values into 0. As the Python wrapper does, rows at the start where either vector is missing are skipped, and the first `window - 1` values after them are `NA`.
    #' @param first_values A numeric vector.
    #' @param second_values A numeric vector of the same length.
    #' @param window The integer number of values in each window.
    #' @return A numeric vector the length of `first_values`, between -1 and 1, and 0 where either vector does not vary over the window.
    #' @details Errors: signals a plain error when `window` is below 1 or above 100000.
    rolling_correlation = function(first_values, second_values, window) {
      if (window < 1 || window > 100000) {
        stop(
          "TA_CORREL function failed with error code 2: Bad Parameter (TA_BAD_PARAM)",
          call. = FALSE
        )
      }
      first_values <- as.numeric(first_values)
      second_values <- as.numeric(second_values)
      count <- length(first_values)
      correlations <- rep(NA_real_, count)
      first <- private$first_complete_position(
        list(
          first_values,
          second_values
        )
      )
      start <- first + window - 1
      if (start > count) {
        return(correlations)
      }
      sum_x <- 0
      sum_y <- 0
      sum_x_squared <- 0
      sum_y_squared <- 0
      sum_xy <- 0
      for (today in first:start) {
        x <- first_values[[today]]
        y <- second_values[[today]]
        sum_x <- sum_x + x
        sum_x_squared <- sum_x_squared + x * x
        sum_xy <- sum_xy + x * y
        sum_y <- sum_y + y
        sum_y_squared <- sum_y_squared + y * y
      }
      trailing <- first
      for (today in start:count) {
        if (today > start) {
          trailing_x <- first_values[[trailing]]
          trailing_y <- second_values[[trailing]]
          sum_x <- sum_x - trailing_x
          sum_x_squared <- sum_x_squared - trailing_x * trailing_x
          sum_xy <- sum_xy - trailing_x * trailing_y
          sum_y <- sum_y - trailing_y
          sum_y_squared <- sum_y_squared - trailing_y * trailing_y
          trailing <- trailing + 1
          x <- first_values[[today]]
          y <- second_values[[today]]
          sum_x <- sum_x + x
          sum_x_squared <- sum_x_squared + x * x
          sum_xy <- sum_xy + x * y
          sum_y <- sum_y + y
          sum_y_squared <- sum_y_squared + y * y
        }
        spread_x <- sum_x_squared - ((sum_x * sum_x) / window)
        spread_y <- sum_y_squared - ((sum_y * sum_y) / window)
        product <- spread_x * spread_y
        if (!is.na(product) && product < 0.00000000000001) {
          correlations[[today]] <- 0
        } else {
          covariance <- sum_xy - ((sum_x * sum_y) / window)
          correlations[[today]] <- covariance / sqrt(product)
        }
      }
      correlations
    },

    #' @description
    #' Calculates TA-Lib's rolling linear regression lines through a numeric vector.
    #'
    #' This follows TA-Lib 0.6.4's `TA_LINEARREG` family exactly, including the order of its sums, so the values match Python's `talib` to the last bit. As the Python wrapper does, missing values at the start are skipped, and the first `window - 1` values after them are `NA`.
    #' @param values A numeric vector, such as a candle column.
    #' @param window The integer number of values in each regression window.
    #' @param function_name The character name of the TA-Lib function being imitated, such as `"TA_LINEARREG"`, used in the error message.
    #' @return A named list of four numeric vectors the length of `values`: `end_value`, the line's value at the newest point, `slope`, `intercept`, the line's value at the oldest point, and `angle`, the slope's angle in degrees.
    #' @details Errors: signals a plain error when `window` is below 2 or above 100000.
    regression_lines = function(values, window, function_name) {
      if (window < 2 || window > 100000) {
        stop(
          sprintf(
            "%s function failed with error code 2: Bad Parameter (TA_BAD_PARAM)",
            function_name
          ),
          call. = FALSE
        )
      }
      values <- as.numeric(values)
      count <- length(values)
      lines <- list(
        end_value = rep(NA_real_, count),
        slope = rep(NA_real_, count),
        intercept = rep(NA_real_, count),
        angle = rep(NA_real_, count)
      )
      first_present <- private$first_complete_position(list(values))
      first_output <- first_present + window - 1
      if (first_output > count) {
        return(lines)
      }
      sum_x <- window * (window - 1) * 0.5
      sum_x_squared <- window * (window - 1) * (2 * window - 1) / 6
      divisor <- sum_x * sum_x - window * sum_x_squared
      for (today in first_output:count) {
        sum_xy <- 0
        sum_y <- 0
        for (distance in (window - 1):0) {
          value <- values[[today - distance]]
          sum_y <- sum_y + value
          sum_xy <- sum_xy + distance * value
        }
        slope <- (window * sum_xy - sum_x * sum_y) / divisor
        intercept <- (sum_y - slope * sum_x) / window
        lines$end_value[[today]] <- intercept + slope * (window - 1)
        lines$slope[[today]] <- slope
        lines$intercept[[today]] <- intercept
        lines$angle[[today]] <- atan(slope) * (180 / 3.14159265358979323846)
      }
      lines
    }
  )
)
