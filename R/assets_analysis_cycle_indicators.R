#' Hilbert transform cycle indicators an instrument calculates from its candles
#'
#' @description
#' The Hilbert transform family, which looks for repeating cycles in prices. Each method fetches the instrument's candles through `prices()`, adds one or more TA-Lib columns, computed by the `talib` package, and returns the candles. The class is a link in the chain of analysis classes, inheriting `VolumeIndicators`, and `Instrument` inherits it through that chain and supplies `prices()`.
#'
#' The Hilbert transform functions need a long warm-up before their first value: TA-Lib's lookback is 32 candles for the dominant cycle period and the phasor components, and 63 for the other four, so a short range returns columns that are mostly or entirely empty.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$hilbert_transform_sine_wave(days = 365)
#' }
#' @export
CycleIndicators <- R6::R6Class(
  "CycleIndicators",
  inherit = VolumeIndicators,
  public = list(
    #' @description
    #' Adds the Hilbert transform dominant cycle period of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ht_dcperiod` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_dominant_cycle_period(days = 365)
    #' print(tail(candles[, c("datetime", "close", "ht_dcperiod")], 5))
    #'
    #' instruments <- list(
    #'   EquityIndex$new(exchange = "nse", symbol = "NIFTY"),
    #'   Equity$new(exchange = "nse", symbol = "HDFCBANK"),
    #'   Equity$new(exchange = "nse", symbol = "ICICIBANK"),
    #'   Equity$new(exchange = "nse", symbol = "SBIN")
    #' )
    #' for (instrument in instruments) {
    #'   candles <- instrument$hilbert_transform_dominant_cycle_period(
    #'     days = 365
    #'   )
    #'   period <- candles$ht_dcperiod[[nrow(candles)]]
    #'   cat(sprintf("%s: %.1f days\n", instrument$symbol, period))
    #' }
    #' }
    hilbert_transform_dominant_cycle_period = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_DCPERIOD(inputs)
      prices[["ht_dcperiod"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the Hilbert transform dominant cycle phase of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ht_dcphase` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_dominant_cycle_phase(days = 365)
    #' print(tail(candles[, c("datetime", "close", "ht_dcphase")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$hilbert_transform_dominant_cycle_phase(
    #'   column = "high",
    #'   days = 365
    #' )
    #' phase <- candles$ht_dcphase[[nrow(candles)]]
    #' cat(sprintf("%.0f degrees\n", phase))
    #' }
    hilbert_transform_dominant_cycle_phase = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_DCPHASE(inputs)
      prices[["ht_dcphase"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the Hilbert transform in-phase and quadrature phasor components of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `inphase` and `quadrature` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_phasor_components(days = 365)
    #' columns <- c(
    #'   "datetime",
    #'   "close",
    #'   "inphase",
    #'   "quadrature"
    #' )
    #' print(tail(candles[, columns], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$hilbert_transform_phasor_components(days = 365)
    #' last_row <- candles[nrow(candles), ]
    #' radians <- atan2(last_row$quadrature, last_row$inphase)
    #' cat(sprintf("%.0f degrees\n", radians * 180 / pi))
    #' }
    hilbert_transform_phasor_components = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_PHASOR(inputs)
      prices[["inphase"]] <- as.numeric(indicator[[1]])
      prices[["quadrature"]] <- as.numeric(indicator[[2]])
      prices
    },

    #' @description
    #' Adds the Hilbert transform sine wave and lead sine wave of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `sine` and `lead_sine` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_sine_wave(days = 365)
    #' print(tail(candles[, c("datetime", "close", "sine", "lead_sine")], 5))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$hilbert_transform_sine_wave(days = 365)
    #'   last_row <- candles[nrow(candles), ]
    #'   if (last_row$lead_sine > last_row$sine) {
    #'     cat(sprintf("%s: lead sine above, cycle turning up\n", symbol))
    #'   } else {
    #'     cat(sprintf("%s: lead sine below, cycle turning down\n", symbol))
    #'   }
    #' }
    #' }
    hilbert_transform_sine_wave = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_SINE(inputs)
      prices[["sine"]] <- as.numeric(indicator[[1]])
      prices[["lead_sine"]] <- as.numeric(indicator[[2]])
      prices
    },

    #' @description
    #' Adds the Hilbert transform trend mode of one candle column, 1 in a trend and 0 in a cycle.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ht_trendmode` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_trend_mode(days = 365)
    #' print(tail(candles[, c("datetime", "close", "ht_trendmode")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' candles <- nifty$hilbert_transform_trend_mode(days = 365)
    #' trending_days <- sum(candles$ht_trendmode)
    #' cat(sprintf("%d of %d days trending\n", trending_days, nrow(candles)))
    #'
    #' information_technology <- Watchlist$new(
    #'   name = "information technology",
    #'   instruments = list(
    #'     Equity$new(exchange = "nse", symbol = "INFY"),
    #'     Equity$new(exchange = "nse", symbol = "TCS"),
    #'     Equity$new(exchange = "nse", symbol = "WIPRO")
    #'   )
    #' )
    #' candles <- information_technology$hilbert_transform_trend_mode(
    #'   days = 365
    #' )
    #' if (candles$ht_trendmode[[nrow(candles)]] == 1) {
    #'   cat("Trending\n")
    #' } else {
    #'   cat("Cycling\n")
    #' }
    #' }
    hilbert_transform_trend_mode = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_TRENDMODE(inputs)
      trend_mode <- as.integer(indicator[[1]])
      trend_mode[is.na(trend_mode)] <- 0L
      prices[["ht_trendmode"]] <- trend_mode
      prices
    },

    #' @description
    #' Adds the Hilbert transform instantaneous trend line of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ht_trendline` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$hilbert_transform_trend_line(days = 365)
    #' print(tail(candles[, c("datetime", "close", "ht_trendline")], 5))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$hilbert_transform_trend_line(days = 365)
    #'   last_row <- candles[nrow(candles), ]
    #'   ratio <- last_row$close / last_row$ht_trendline
    #'   distance <- (ratio - 1) * 100
    #'   cat(sprintf("%s: %.2f%%\n", symbol, distance))
    #' }
    #' }
    hilbert_transform_trend_line = function(
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
      inputs <- data.frame(
        close = as.numeric(prices[[column]])
      )
      indicator <- talib::HT_TRENDLINE(inputs)
      prices[["ht_trendline"]] <- as.numeric(indicator[[1]])
      prices
    }
  )
)
