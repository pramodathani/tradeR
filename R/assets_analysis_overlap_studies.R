#' Moving averages, Bollinger bands and other indicators an instrument draws over its candles
#'
#' @description
#' Overlap studies are indicators drawn on the price scale. Each method fetches the instrument's candles through `prices()`, adds one or more TA-Lib columns and returns the candles. This class is a link in the analysis chain: it inherits `PriceStatistics`, and `MomentumIndicators` inherits it, so `Instrument`, which supplies the real `prices()`, has every method.
#'
#' @examples
#' \dontrun{
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' frame <- infosys$simple_moving_average(window = 20, days = 365)
#' }
#' @export
OverlapStudies <- R6::R6Class(
  "OverlapStudies",
  inherit = PriceStatistics,
  public = list(
    #' @description
    #' Adds the simple moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `sma_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$simple_moving_average(window = 20, days = 90)
    #' print(tail(candles[, c("datetime", "close", "sma_20")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' fast <- nifty$simple_moving_average(window = 50, days = 400)
    #' slow <- nifty$simple_moving_average(window = 200, days = 400)
    #' fast_average <- fast$sma_50[nrow(fast)]
    #' slow_average <- slow$sma_200[nrow(slow)]
    #' if (fast_average > slow_average) {
    #'   cat(sprintf("Golden cross: %.0f > %.0f\n", fast_average, slow_average))
    #' } else {
    #'   cat(sprintf("Death cross: %.0f < %.0f\n", fast_average, slow_average))
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
    #' candles <- information_technology$simple_moving_average(days = 60)
    #' print(tail(candles[, c("datetime", "close", "sma_10")]))
    #' }
    simple_moving_average = function(
      window = 10,
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
      average <- talib::SMA(prices[[column]], timePeriod = window)
      prices[[paste0("sma_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the exponential moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `ema_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$exponential_moving_average(window = 20, days = 120)
    #' print(tail(candles[, c("datetime", "close", "ema_20")]))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   fast <- share$exponential_moving_average(window = 12, days = 180)
    #'   slow <- share$exponential_moving_average(window = 26, days = 180)
    #'   gap <- fast$ema_12[nrow(fast)] - slow$ema_26[nrow(slow)]
    #'   cat(sprintf("%s: %.2f\n", symbol, gap))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$exponential_moving_average(window = 50, days = 250)
    #' last_row <- candles[nrow(candles), ]
    #' distance <- (last_row$close / last_row$ema_50 - 1) * 100
    #' cat(sprintf("%.2f%% from the average\n", distance))
    #' }
    exponential_moving_average = function(
      window = 10,
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
      average <- talib::EMA(prices[[column]], timePeriod = window)
      prices[[paste0("ema_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the upper, middle and lower Bollinger bands of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param standard_deviations_up The numeric number of standard deviations from the middle band to the upper band.
    #' @param standard_deviations_down The numeric number of standard deviations from the middle band to the lower band.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `bb_upper_<window>`, `bb_middle_<window>` and `bb_lower_<window>` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$bollinger_bands(window = 20, days = 120)
    #' columns <- c(
    #'   "datetime",
    #'   "close",
    #'   "bb_lower_20",
    #'   "bb_middle_20",
    #'   "bb_upper_20"
    #' )
    #' print(tail(candles[, columns]))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$bollinger_bands(window = 20, days = 120)
    #'   last_row <- candles[nrow(candles), ]
    #'   width <- last_row$bb_upper_20 - last_row$bb_lower_20
    #'   position <- (last_row$close - last_row$bb_lower_20) / width
    #'   cat(sprintf("%s: %.2f\n", symbol, position))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$bollinger_bands(
    #'   window = 20,
    #'   standard_deviations_up = 3,
    #'   standard_deviations_down = 3,
    #'   days = 120
    #' )
    #' last_row <- candles[nrow(candles), ]
    #' width <- last_row$bb_upper_20 - last_row$bb_lower_20
    #' cat(sprintf("%.2f%%\n", width / last_row$bb_middle_20 * 100))
    #' }
    bollinger_bands = function(
      window = 10,
      standard_deviations_up = 2,
      standard_deviations_down = 2,
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
      bands <- talib::BBANDS(
        prices[[column]],
        timePeriod = window,
        deviationsUp = standard_deviations_up,
        deviationsDown = standard_deviations_down,
        maType = 0
      )
      prices[[paste0("bb_upper_", window)]] <- as.numeric(bands[, "UpperBand"])
      prices[[paste0("bb_middle_", window)]] <- as.numeric(
        bands[, "MiddleBand"]
      )
      prices[[paste0("bb_lower_", window)]] <- as.numeric(bands[, "LowerBand"])
      prices
    },

    #' @description
    #' Adds the weighted moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `wma_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$weighted_moving_average(window = 20, days = 90)
    #' print(tail(candles[, c("datetime", "close", "wma_20")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' weighted <- nifty$weighted_moving_average(window = 10, days = 60)
    #' simple <- nifty$simple_moving_average(window = 10, days = 60)
    #' cat(sprintf("Weighted %.2f\n", weighted$wma_10[nrow(weighted)]))
    #' cat(sprintf("Simple %.2f\n", simple$sma_10[nrow(simple)]))
    #' }
    weighted_moving_average = function(
      window = 10,
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
      average <- talib::WMA(prices[[column]], timePeriod = window)
      prices[[paste0("wma_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the double exponential moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `dema_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$double_exponential_moving_average(
    #'   window = 20,
    #'   days = 180
    #' )
    #' print(tail(candles[, c("datetime", "close", "dema_20")]))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$double_exponential_moving_average(days = 120)
    #'   last_row <- candles[nrow(candles), ]
    #'   if (last_row$close > last_row$dema_10) {
    #'     cat(sprintf("%s: above\n", symbol))
    #'   } else {
    #'     cat(sprintf("%s: below\n", symbol))
    #'   }
    #' }
    #' }
    double_exponential_moving_average = function(
      window = 10,
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
      average <- talib::DEMA(prices[[column]], timePeriod = window)
      prices[[paste0("dema_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds Tillson's T3 triple exponential moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param volume_factor The numeric volume factor that sets how strongly T3 smooths, between 0 and 1.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `t3_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$triple_exponential_moving_average(
    #'   window = 10,
    #'   days = 180
    #' )
    #' print(tail(candles[, c("datetime", "close", "t3_10")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' smooth <- nifty$triple_exponential_moving_average(
    #'   window = 10,
    #'   volume_factor = 0.9,
    #'   days = 250
    #' )
    #' responsive <- nifty$triple_exponential_moving_average(
    #'   window = 10,
    #'   volume_factor = 0.3,
    #'   days = 250
    #' )
    #' cat(sprintf("Factor 0.9: %.2f\n", smooth$t3_10[nrow(smooth)]))
    #' cat(sprintf("Factor 0.3: %.2f\n", responsive$t3_10[nrow(responsive)]))
    #' }
    triple_exponential_moving_average = function(
      window = 10,
      volume_factor = 0.7,
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
      average <- talib::T3(
        prices[[column]],
        timePeriod = window,
        volumeFactor = volume_factor
      )
      prices[[paste0("t3_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the Kaufman adaptive moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `kama_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$kaufman_adaptive_moving_average(days = 120)
    #' print(tail(candles[, c("datetime", "close", "kama_10")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$kaufman_adaptive_moving_average(
    #'     window = 20,
    #'     days = 180
    #'   )
    #'   average <- candles$kama_20
    #'   change <- average[length(average)] - average[length(average) - 5]
    #'   if (change > 0) {
    #'     cat(sprintf("%s: rising by %.2f\n", symbol, change))
    #'   } else {
    #'     cat(sprintf("%s: falling by %.2f\n", symbol, -change))
    #'   }
    #' }
    #' }
    kaufman_adaptive_moving_average = function(
      window = 10,
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
      average <- talib::KAMA(prices[[column]], timePeriod = window)
      prices[[paste0("kama_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the MESA adaptive moving average and its following average of one candle column.
    #' @param fast_limit The numeric upper limit of the adaptive smoothing factor.
    #' @param slow_limit The numeric lower limit of the adaptive smoothing factor.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `mama` and `fama` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$mesa_adaptive_moving_average(days = 365)
    #' print(tail(candles[, c("datetime", "close", "mama", "fama")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$mesa_adaptive_moving_average(days = 365)
    #' last_cross <- NULL
    #' mama <- candles$mama
    #' fama <- candles$fama
    #' for (position in seq(2, nrow(candles))) {
    #'   before <- isTRUE(mama[position - 1] > fama[position - 1])
    #'   after <- isTRUE(mama[position] > fama[position])
    #'   if (before != after) {
    #'     last_cross <- candles$datetime[position]
    #'   }
    #' }
    #' print(last_cross)
    #' }
    mesa_adaptive_moving_average = function(
      fast_limit = 0.5,
      slow_limit = 0.05,
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
      averages <- talib::MAMA(
        prices[[column]],
        fastLimit = fast_limit,
        slowLimit = slow_limit
      )
      prices[["mama"]] <- as.numeric(averages[, "MAMA"])
      prices[["fama"]] <- as.numeric(averages[, "FAMA"])
      prices
    },

    #' @description
    #' Adds the triangular moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `trima_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$triangular_moving_average(window = 20, days = 120)
    #' print(tail(candles[, c("datetime", "close", "trima_20")]))
    #'
    #' symbols <- c(
    #'   "RELIANCE",
    #'   "INFY",
    #'   "HDFCBANK"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$triangular_moving_average(days = 90)
    #'   last_row <- candles[nrow(candles), ]
    #'   distance <- (last_row$close / last_row$trima_10 - 1) * 100
    #'   cat(sprintf("%s: %.2f%%\n", symbol, distance))
    #' }
    #' }
    triangular_moving_average = function(
      window = 10,
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
      average <- talib::TRIMA(prices[[column]], timePeriod = window)
      prices[[paste0("trima_", window)]] <- as.numeric(average)
      prices
    },

    #' @description
    #' Adds the parabolic stop and reverse from the high and low columns.
    #' @param acceleration The numeric acceleration factor added at each new extreme.
    #' @param maximum The numeric largest acceleration factor allowed.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `psar` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$parabolic_sar(days = 120)
    #' print(tail(candles[, c("datetime", "close", "psar")]))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$parabolic_sar(days = 120)
    #'   last_row <- candles[nrow(candles), ]
    #'   if (last_row$close > last_row$psar) {
    #'     cat(sprintf("%s: uptrend, stop %.2f\n", symbol, last_row$psar))
    #'   } else {
    #'     cat(sprintf("%s: downtrend, stop %.2f\n", symbol, last_row$psar))
    #'   }
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$parabolic_sar(
    #'   acceleration = 0.01,
    #'   maximum = 0.1,
    #'   days = 180
    #' )
    #' print(tail(candles[, c("datetime", "close", "psar")]))
    #' }
    parabolic_sar = function(
      acceleration = 0.02,
      maximum = 0.2,
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
      stop_and_reverse <- talib::SAR(
        prices,
        cols = ~ high + low,
        accelerationFactor = acceleration,
        afMaximum = maximum
      )
      prices[["psar"]] <- as.numeric(stop_and_reverse[["SAR"]])
      prices
    },

    #' @description
    #' Adds the midpoint of the highest and lowest value of one candle column over each window.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `mid_point_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$mid_point(days = 60)
    #' print(tail(candles[, c("datetime", "close", "mid_point_10")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$mid_point(window = 20, days = 90)
    #' last_row <- candles[nrow(candles), ]
    #' if (last_row$close > last_row$mid_point_20) {
    #'   print("In the upper half of the recent range")
    #' } else {
    #'   print("In the lower half of the recent range")
    #' }
    #' }
    mid_point = function(
      window = 10,
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
      midpoint <- talib::MIDPOINT(prices[[column]], timePeriod = window)
      prices[[paste0("mid_point_", window)]] <- as.numeric(midpoint)
      prices
    },

    #' @description
    #' Adds the midpoint of the highest high and lowest low over each window.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `middle_price_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$middle_price(days = 60)
    #' print(tail(candles[, c("datetime", "close", "middle_price_10")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$middle_price(window = 20, days = 90)
    #'   last_row <- candles[nrow(candles), ]
    #'   middle <- last_row$middle_price_20
    #'   cat(sprintf(
    #'     "%s: close %s, middle %s\n",
    #'     symbol,
    #'     last_row$close,
    #'     middle
    #'   ))
    #' }
    #' }
    middle_price = function(
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
      middle <- talib::MIDPRICE(
        prices,
        cols = ~ high + low,
        timePeriod = window
      )
      prices[[paste0("middle_price_", window)]] <- as.numeric(
        middle[["MIDPRICE"]]
      )
      prices
    }
  )
)
