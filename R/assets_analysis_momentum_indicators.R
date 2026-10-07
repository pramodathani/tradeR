#' Oscillators and directional indicators an instrument calculates from its candles
#'
#' @description
#' Momentum indicators measure how fast prices move and in which direction. Each method fetches the instrument's candles through `prices()`, adds one or more TA-Lib columns and returns the candles. This class is a link in the analysis chain: it inherits `OverlapStudies`, and `VolumeIndicators` inherits it, so `Instrument`, which supplies the real `prices()`, has every method.
#'
#' Arguments named `..._moving_average_type` take TA-Lib's moving average codes: 0 simple, 1 exponential, 2 weighted, 3 double exponential, 4 triple exponential, 5 triangular, 6 Kaufman adaptive, 7 MESA adaptive and 8 Tillson T3.
#'
#' @examples
#' \dontrun{
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' frame <- infosys$relative_strength_index(window = 14, days = 365)
#' }
#' @export
MomentumIndicators <- R6::R6Class(
  "MomentumIndicators",
  inherit = OverlapStudies,
  public = list(
    #' @description
    #' Adds the moving average convergence divergence line, its signal line and their difference.
    #' @param fast_period The integer number of candles in the fast moving average.
    #' @param slow_period The integer number of candles in the slow moving average.
    #' @param signal_period The integer number of candles in the signal line's moving average.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `macd_<fast>_<slow>_<signal>` columns, with `_signal` and `_hist` variants added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$moving_average_convergence_divergence(days = 180)
    #' columns <- c(
    #'   "datetime",
    #'   "macd_12_26_9",
    #'   "macd_12_26_9_signal",
    #'   "macd_12_26_9_hist"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$moving_average_convergence_divergence(
    #'   fast_period = 8,
    #'   slow_period = 21,
    #'   signal_period = 5,
    #'   days = 365
    #' )
    #' histogram <- frame$macd_8_21_5_hist
    #' previous <- c(NA, histogram[-length(histogram)])
    #' crossed_above <- which(histogram > 0 & previous <= 0)
    #' print(as.Date(frame$datetime[crossed_above], tz = "Asia/Kolkata"))
    #' }
    moving_average_convergence_divergence = function(
      fast_period = 12,
      slow_period = 26,
      signal_period = 9,
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
      label <- paste0(
        "macd_",
        fast_period,
        "_",
        slow_period,
        "_",
        signal_period
      )
      lines <- talib::MACD(
        prices[[column]],
        fastPeriod = fast_period,
        slowPeriod = slow_period,
        signalPeriod = signal_period
      )
      prices[[label]] <- as.numeric(lines[, "MACD"])
      prices[[paste0(label, "_signal")]] <- as.numeric(lines[, "MACDSignal"])
      prices[[paste0(label, "_hist")]] <- as.numeric(lines[, "MACDHist"])
      prices
    },

    #' @description
    #' Adds the average directional movement index.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `adx_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$average_directional_movement_index(days = 180)
    #' print(tail(frame[, c("datetime", "adx_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$average_directional_movement_index(
    #'   window = 14,
    #'   days = 180
    #' )
    #' latest <- frame$adx_14[nrow(frame)]
    #' if (latest > 25) {
    #'   cat(sprintf("NIFTY is trending, ADX %.1f\n", latest))
    #' } else {
    #'   cat(sprintf("NIFTY is moving sideways, ADX %.1f\n", latest))
    #' }
    #' }
    average_directional_movement_index = function(
      window = 14,
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
      index <- talib::ADX(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("adx_", window)]] <- as.numeric(index[["ADX"]])
      prices
    },

    #' @description
    #' Adds the momentum of one candle column, its change over each window.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `momentum_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' frame <- reliance$momentum(window = 10, days = 120)
    #' print(tail(frame[, c("datetime", "momentum_10")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$momentum(window = 20, column = "high", days = 120)
    #'   print(paste(symbol, round(frame$momentum_20[nrow(frame)], 2)))
    #' }
    #' }
    momentum = function(
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
      change <- talib::MOM(prices[[column]], timePeriod = window)
      prices[[paste0("momentum_", window)]] <- as.numeric(change)
      prices
    },

    #' @description
    #' Adds the commodity channel index.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `cci_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$commodity_channel_index(window = 20, days = 180)
    #' print(tail(frame[, c("datetime", "cci_20")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$commodity_channel_index(window = 20, days = 365)
    #' above <- sum(frame$cci_20 > 100, na.rm = TRUE)
    #' below <- sum(frame$cci_20 < -100, na.rm = TRUE)
    #' cat(sprintf(
    #'   "Above 100 on %d days, below -100 on %d days\n",
    #'   above,
    #'   below
    #' ))
    #' }
    commodity_channel_index = function(
      window = 14,
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
      index <- talib::CCI(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("cci_", window)]] <- as.numeric(index[["CCI"]])
      prices
    },

    #' @description
    #' Adds the average directional movement index rating.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `adxr_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' frame <- hdfc_bank$average_directional_movement_index_rating(
    #'   window = 14,
    #'   days = 180
    #' )
    #' print(tail(frame[, c("datetime", "adxr_14")]))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' rating_frame <- infosys$average_directional_movement_index_rating(
    #'   window = 14,
    #'   days = 180
    #' )
    #' index_frame <- infosys$average_directional_movement_index(
    #'   window = 14,
    #'   days = 180
    #' )
    #' print(paste("ADXR", round(rating_frame$adxr_14[nrow(rating_frame)], 2)))
    #' print(paste("ADX", round(index_frame$adx_14[nrow(index_frame)], 2)))
    #' }
    average_directional_movement_index_rating = function(
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
      rating <- talib::ADXR(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("adxr_", window)]] <- as.numeric(rating[["ADXR"]])
      prices
    },

    #' @description
    #' Adds the absolute price oscillator, the difference between a fast and a slow moving average.
    #' @param fast_period The integer number of candles in the fast moving average.
    #' @param slow_period The integer number of candles in the slow moving average.
    #' @param moving_average_type The integer TA-Lib moving average type, where 0 is a simple moving average.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `apo_<fast>_<slow>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$absolute_price_oscillator(days = 180)
    #' print(tail(frame[, c("datetime", "apo_12_26")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$absolute_price_oscillator(
    #'   fast_period = 5,
    #'   slow_period = 20,
    #'   moving_average_type = 1,
    #'   days = 120
    #' )
    #' gap <- round(frame$apo_5_20[nrow(frame)], 2)
    #' if (gap > 0) {
    #'   cat(sprintf(
    #'     "The fast average is %s points above the slow one\n",
    #'     gap
    #'   ))
    #' } else {
    #'   cat(sprintf(
    #'     "The fast average is %s points below the slow one\n",
    #'     -gap
    #'   ))
    #' }
    #' }
    absolute_price_oscillator = function(
      fast_period = 12,
      slow_period = 26,
      moving_average_type = 0,
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
      oscillator <- talib::APO(
        prices[[column]],
        fastPeriod = fast_period,
        slowPeriod = slow_period,
        maType = moving_average_type
      )
      label <- paste0("apo_", fast_period, "_", slow_period)
      prices[[label]] <- as.numeric(oscillator)
      prices
    },

    #' @description
    #' Adds the Aroon down and Aroon up lines.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `aroon_down_<window>` and `aroon_up_<window>` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$aroon(window = 25, days = 180)
    #' columns <- c(
    #'   "datetime",
    #'   "aroon_down_25",
    #'   "aroon_up_25"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$aroon(window = 25, days = 180)
    #' aroon_up <- as.integer(frame$aroon_up_25[nrow(frame)])
    #' aroon_down <- as.integer(frame$aroon_down_25[nrow(frame)])
    #' if (aroon_up > aroon_down) {
    #'   cat(sprintf("New highs lead: up %d, down %d\n", aroon_up, aroon_down))
    #' } else {
    #'   cat(sprintf("New lows lead: up %d, down %d\n", aroon_up, aroon_down))
    #' }
    #' }
    aroon = function(
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
      lines <- talib::AROON(
        prices,
        cols = ~ high + low,
        timePeriod = window
      )
      prices[[paste0("aroon_down_", window)]] <- as.numeric(
        lines[["AroonDown"]]
      )
      prices[[paste0("aroon_up_", window)]] <- as.numeric(lines[["AroonUp"]])
      prices
    },

    #' @description
    #' Adds the Aroon oscillator, Aroon up minus Aroon down.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `aroon_osc_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' frame <- tcs$aroon_oscillator(window = 14, days = 180)
    #' print(tail(frame[, c("datetime", "aroon_osc_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$aroon_oscillator(window = 14, days = 180)
    #' last_sixty <- tail(frame$aroon_osc_14, 60)
    #' positive_days <- sum(last_sixty > 0, na.rm = TRUE)
    #' cat(sprintf(
    #'   "Positive on %d of %d days\n",
    #'   positive_days,
    #'   length(last_sixty)
    #' ))
    #' }
    aroon_oscillator = function(
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
      oscillator <- talib::AROONOSC(
        prices,
        cols = ~ high + low,
        timePeriod = window
      )
      prices[[paste0("aroon_osc_", window)]] <- as.numeric(
        oscillator[["AROONOSC"]]
      )
      prices
    },

    #' @description
    #' Adds the balance of power.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `bop` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$balance_of_power(days = 60)
    #' print(tail(frame[, c("datetime", "bop")]))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' frame <- reliance$balance_of_power(days = 120)
    #' smoothed <- mean(tail(frame$bop, 10))
    #' if (smoothed > 0) {
    #'   cat(sprintf("Buyers have been in control: %.3f\n", smoothed))
    #' } else {
    #'   cat(sprintf("Sellers have been in control: %.3f\n", smoothed))
    #' }
    #' }
    balance_of_power = function(
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
      balance <- talib::BOP(
        prices,
        cols = ~ open + high + low + close
      )
      prices[["bop"]] <- as.numeric(balance[["BOP"]])
      prices
    },

    #' @description
    #' Adds the Chande momentum oscillator of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `cmo_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$chande_momentum_oscillator(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "cmo_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$chande_momentum_oscillator(window = 14, days = 120)
    #' latest <- frame$cmo_14[nrow(frame)]
    #' if (latest > 50) {
    #'   label <- "overbought"
    #' } else if (latest < -50) {
    #'   label <- "oversold"
    #' } else {
    #'   label <- "neutral"
    #' }
    #' cat(sprintf("NIFTY CMO %.1f: %s\n", latest, label))
    #' }
    chande_momentum_oscillator = function(
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
      oscillator <- talib::CMO(prices[[column]], timePeriod = window)
      prices[[paste0("cmo_", window)]] <- as.numeric(oscillator)
      prices
    },

    #' @description
    #' Adds the directional movement index.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `dx_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$directional_movement_index(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "dx_14")]))
    #'
    #' bank_nifty <- EquityIndex$new(
    #'   exchange = "nse",
    #'   symbol = "BANKNIFTY"
    #' )
    #' frame <- bank_nifty$directional_movement_index(
    #'   window = 14,
    #'   from_date = "2026-01-01",
    #'   to_date = "2026-03-31"
    #' )
    #' cat(sprintf("Average DX: %.2f\n", mean(frame$dx_14, na.rm = TRUE)))
    #' }
    directional_movement_index = function(
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
      index <- talib::DX(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("dx_", window)]] <- as.numeric(index[["DX"]])
      prices
    },

    #' @description
    #' Adds the moving average convergence divergence with a chosen moving average type for each of its three averages.
    #' @param fast_period The integer number of candles in the fast moving average.
    #' @param fast_moving_average_type The integer TA-Lib moving average type of the fast average, where 0 is a simple moving average.
    #' @param slow_period The integer number of candles in the slow moving average.
    #' @param slow_moving_average_type The integer TA-Lib moving average type of the slow average, where 0 is a simple moving average.
    #' @param signal_period The integer number of candles in the signal line's moving average.
    #' @param signal_moving_average_type The integer TA-Lib moving average type of the signal line, where 0 is a simple moving average.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `macd_<fast>_<slow>_<signal>`, `macd_signal_...` and `macd_hist_...` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$moving_average_convergence_divergence_extended(
    #'   fast_moving_average_type = 1,
    #'   slow_moving_average_type = 1,
    #'   signal_moving_average_type = 1,
    #'   days = 180
    #' )
    #' columns <- c(
    #'   "datetime",
    #'   "macd_12_26_9",
    #'   "macd_signal_12_26_9",
    #'   "macd_hist_12_26_9"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$moving_average_convergence_divergence_extended(
    #'   fast_period = 10,
    #'   fast_moving_average_type = 2,
    #'   slow_period = 30,
    #'   slow_moving_average_type = 2,
    #'   signal_period = 7,
    #'   signal_moving_average_type = 0,
    #'   days = 240
    #' )
    #' print(round(frame$macd_hist_10_30_7[nrow(frame)], 2))
    #' }
    moving_average_convergence_divergence_extended = function(
      fast_period = 12,
      fast_moving_average_type = 0,
      slow_period = 26,
      slow_moving_average_type = 0,
      signal_period = 9,
      signal_moving_average_type = 0,
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
      suffix <- paste0(fast_period, "_", slow_period, "_", signal_period)
      lines <- talib::MACDEXT(
        prices[[column]],
        fastPeriod = fast_period,
        fastMa = fast_moving_average_type,
        slowPeriod = slow_period,
        slowMa = slow_moving_average_type,
        signalPeriod = signal_period,
        signalMa = signal_moving_average_type
      )
      prices[[paste0("macd_", suffix)]] <- as.numeric(lines[, "MACD"])
      prices[[paste0("macd_signal_", suffix)]] <- as.numeric(
        lines[, "MACDSignal"]
      )
      prices[[paste0("macd_hist_", suffix)]] <- as.numeric(lines[, "MACDHist"])
      prices
    },

    #' @description
    #' Adds the money flow index, a relative strength index weighted by volume.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `mfi_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$money_flow_index(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "mfi_14")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$money_flow_index(window = 14, days = 120)
    #'   latest <- frame$mfi_14[nrow(frame)]
    #'   if (latest > 80) {
    #'     label <- "overbought"
    #'   } else if (latest < 20) {
    #'     label <- "oversold"
    #'   } else {
    #'     label <- "neutral"
    #'   }
    #'   cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
    #' }
    #' }
    money_flow_index = function(
      window = 14,
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
      index <- talib::MFI(
        prices,
        cols = ~ high + low + close + volume,
        timePeriod = window
      )
      prices[[paste0("mfi_", window)]] <- as.numeric(index[["MFI"]])
      prices
    },

    #' @description
    #' Adds the minus directional indicator.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `minus_di_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$minus_directional_indicator(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "minus_di_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' minus_frame <- nifty$minus_directional_indicator(window = 14, days = 120)
    #' plus_frame <- nifty$plus_directional_indicator(window = 14, days = 120)
    #' minus_value <- round(minus_frame$minus_di_14[nrow(minus_frame)], 1)
    #' plus_value <- round(plus_frame$plus_di_14[nrow(plus_frame)], 1)
    #' if (minus_value > plus_value) {
    #'   cat(sprintf(
    #'     "Sellers dominate: -DI %s, +DI %s\n",
    #'     minus_value,
    #'     plus_value
    #'   ))
    #' } else {
    #'   cat(sprintf(
    #'     "Buyers dominate: -DI %s, +DI %s\n",
    #'     minus_value,
    #'     plus_value
    #'   ))
    #' }
    #' }
    minus_directional_indicator = function(
      window = 14,
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
      indicator <- talib::MINUS_DI(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("minus_di_", window)]] <- as.numeric(
        indicator[["MINUS_DI"]]
      )
      prices
    },

    #' @description
    #' Adds the minus directional movement.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `minus_dm_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' frame <- tcs$minus_directional_movement(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "minus_dm_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$minus_directional_movement(
    #'   window = 7,
    #'   from_date = "2026-01-01",
    #'   to_date = "2026-09-28"
    #' )
    #' peak_row <- which.max(frame$minus_dm_7)
    #' peak_day <- as.Date(frame$datetime[peak_row], tz = "Asia/Kolkata")
    #' print(paste(peak_day, round(frame$minus_dm_7[peak_row], 2)))
    #' }
    minus_directional_movement = function(
      window = 14,
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
      movement <- talib::MINUS_DM(
        prices,
        cols = ~ high + low,
        timePeriod = window
      )
      prices[[paste0("minus_dm_", window)]] <- as.numeric(
        movement[["MINUS_DM"]]
      )
      prices
    },

    #' @description
    #' Adds the plus directional indicator.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `plus_di_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$plus_directional_indicator(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "plus_di_14")]))
    #'
    #' hdfc_bank <- Equity$new(exchange = "nse", symbol = "HDFCBANK")
    #' frame <- hdfc_bank$plus_directional_indicator(window = 14, days = 180)
    #' days_above <- sum(frame$plus_di_14 > 25, na.rm = TRUE)
    #' cat(sprintf("Above 25 on %d days\n", days_above))
    #' }
    plus_directional_indicator = function(
      window = 14,
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
      indicator <- talib::PLUS_DI(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("plus_di_", window)]] <- as.numeric(
        indicator[["PLUS_DI"]]
      )
      prices
    },

    #' @description
    #' Adds the plus directional movement.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `plus_dm_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$plus_directional_movement(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "plus_dm_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$plus_directional_movement(window = 7, days = 60)
    #' cat(sprintf("%.2f points\n", frame$plus_dm_7[nrow(frame)]))
    #' }
    plus_directional_movement = function(
      window = 14,
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
      movement <- talib::PLUS_DM(
        prices,
        cols = ~ high + low,
        timePeriod = window
      )
      prices[[paste0("plus_dm_", window)]] <- as.numeric(
        movement[["PLUS_DM"]]
      )
      prices
    },

    #' @description
    #' Adds the percentage price oscillator, the gap between a fast and a slow moving average as a percentage.
    #' @param fast_period The integer number of candles in the fast moving average.
    #' @param slow_period The integer number of candles in the slow moving average.
    #' @param moving_average_type The integer TA-Lib moving average type, where 0 is a simple moving average.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ppo<fast>_<slow>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$percentage_price_oscillator(days = 180)
    #' print(tail(frame[, c("datetime", "ppo12_26")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$percentage_price_oscillator(
    #'     moving_average_type = 1,
    #'     days = 180
    #'   )
    #'   cat(sprintf("%s: %.2f%%\n", symbol, frame$ppo12_26[nrow(frame)]))
    #' }
    #' }
    percentage_price_oscillator = function(
      fast_period = 12,
      slow_period = 26,
      moving_average_type = 0,
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
      oscillator <- talib::PPO(
        prices[[column]],
        fastPeriod = fast_period,
        slowPeriod = slow_period,
        maType = moving_average_type
      )
      label <- paste0("ppo", fast_period, "_", slow_period)
      prices[[label]] <- as.numeric(oscillator)
      prices
    },

    #' @description
    #' Adds the rate of change of one candle column as a percentage.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `roc_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals a plain error when `window` is below 1 or above 100000, as TA-Lib does; and `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$rate_of_change(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "roc_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$rate_of_change(
    #'   window = 20,
    #'   from_date = "2026-01-01",
    #'   to_date = "2026-06-30"
    #' )
    #' cat(sprintf("Best 20 days: %.2f%%\n", max(frame$roc_20, na.rm = TRUE)))
    #' cat(sprintf("Worst 20 days: %.2f%%\n", min(frame$roc_20, na.rm = TRUE)))
    #' }
    rate_of_change = function(
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
      values <- as.numeric(prices[[column]])
      previous <- private$values_window_before(values, window, "TA_ROC")
      change <- (values / previous - 1) * 100
      change[which(previous == 0)] <- 0
      prices[[paste0("roc_", window)]] <- change
      prices
    },

    #' @description
    #' Adds the rate of change of one candle column as a fraction.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `rocp_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals a plain error when `window` is below 1 or above 100000, as TA-Lib does; and `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$rate_of_change_percent(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "rocp_14")]))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' frame <- tcs$rate_of_change_percent(
    #'   window = 5,
    #'   column = "high",
    #'   days = 60
    #' )
    #' print(round(frame$rocp_5[nrow(frame)], 4))
    #' }
    rate_of_change_percent = function(
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
      values <- as.numeric(prices[[column]])
      previous <- private$values_window_before(values, window, "TA_ROCP")
      change <- (values - previous) / previous
      change[which(previous == 0)] <- 0
      prices[[paste0("rocp_", window)]] <- change
      prices
    },

    #' @description
    #' Adds the rate of change of one candle column as a ratio.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `rocr_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$rate_of_change_ratio(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "rocr_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$rate_of_change_ratio(window = 10, days = 60)
    #' ratio <- frame$rocr_10[nrow(frame)]
    #' if (ratio > 1) {
    #'   cat(sprintf("Higher than ten days ago, ratio %.4f\n", ratio))
    #' } else {
    #'   cat(sprintf("Lower than ten days ago, ratio %.4f\n", ratio))
    #' }
    #' }
    rate_of_change_ratio = function(
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
      ratio <- talib::ROCR(prices[[column]], timePeriod = window)
      prices[[paste0("rocr_", window)]] <- as.numeric(ratio)
      prices
    },

    #' @description
    #' Adds the relative strength index of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `rsi_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$relative_strength_index(window = 14, days = 120)
    #' print(tail(frame[, c("datetime", "rsi_14")]))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$relative_strength_index(window = 14, days = 120)
    #'   latest <- frame$rsi_14[nrow(frame)]
    #'   if (latest > 70) {
    #'     label <- "overbought"
    #'   } else if (latest < 30) {
    #'     label <- "oversold"
    #'   } else {
    #'     label <- "neutral"
    #'   }
    #'   cat(sprintf("%s: %.1f %s\n", symbol, latest, label))
    #' }
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$relative_strength_index(
    #'   window = 9,
    #'   column = "high",
    #'   from_date = "2026-04-01",
    #'   to_date = "2026-06-30"
    #' )
    #' complete <- frame[!is.na(frame$rsi_9), ]
    #' print(data.frame(
    #'   datetime = complete$datetime,
    #'   rsi_9 = round(complete$rsi_9, 1)
    #' ))
    #' }
    relative_strength_index = function(
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
      index <- talib::RSI(prices[[column]], timePeriod = window)
      prices[[paste0("rsi_", window)]] <- as.numeric(index)
      prices
    },

    #' @description
    #' Adds the slow stochastic oscillator's %K and %D lines.
    #' @param fast_k_period The integer number of candles in the fast %K calculation.
    #' @param slow_k_period The integer number of candles smoothing fast %K into slow %K.
    #' @param slow_k_moving_average_type The integer TA-Lib moving average type for slow %K, where 0 is a simple moving average.
    #' @param slow_d_period The integer number of candles smoothing slow %K into slow %D.
    #' @param slow_d_moving_average_type The integer TA-Lib moving average type for slow %D, where 0 is a simple moving average.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `slowk_<period>` and `slowd_<period>` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$stochastic_oscillator(days = 90)
    #' columns <- c(
    #'   "datetime",
    #'   "slowk_3",
    #'   "slowd_3"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$stochastic_oscillator(
    #'   fast_k_period = 14,
    #'   slow_k_period = 3,
    #'   slow_d_period = 3,
    #'   days = 120
    #' )
    #' difference <- frame$slowk_3 - frame$slowd_3
    #' last <- length(difference)
    #' crossed <- difference[last] > 0 && difference[last - 1] <= 0
    #' cat(sprintf("%%K %.1f\n", frame$slowk_3[nrow(frame)]))
    #' cat(sprintf("Crossed above %%D: %s\n", crossed))
    #' }
    stochastic_oscillator = function(
      fast_k_period = 5,
      slow_k_period = 3,
      slow_k_moving_average_type = 0,
      slow_d_period = 3,
      slow_d_moving_average_type = 0,
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
      lines <- talib::STOCH(
        prices,
        cols = ~ high + low + close,
        fastKPeriod = fast_k_period,
        slowKPeriod = slow_k_period,
        slowKMa = slow_k_moving_average_type,
        slowDPeriod = slow_d_period,
        slowDMa = slow_d_moving_average_type
      )
      prices[[paste0("slowk_", slow_k_period)]] <- as.numeric(lines[["SlowK"]])
      prices[[paste0("slowd_", slow_d_period)]] <- as.numeric(lines[["SlowD"]])
      prices
    },

    #' @description
    #' Adds the fast stochastic oscillator's %K and %D lines.
    #' @param fast_k_period The integer number of candles in the fast %K calculation.
    #' @param fast_d_period The integer number of candles smoothing fast %K into fast %D.
    #' @param fast_d_moving_average_type The integer TA-Lib moving average type for fast %D, where 0 is a simple moving average.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `stochf_fastk<period>` and `stochf_fastd<period>` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$stochastic_fast_oscillator(days = 90)
    #' columns <- c(
    #'   "datetime",
    #'   "stochf_fastk5",
    #'   "stochf_fastd3"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$stochastic_fast_oscillator(
    #'   fast_k_period = 14,
    #'   fast_d_period = 3,
    #'   days = 90
    #' )
    #' fast_k <- round(frame$stochf_fastk14[nrow(frame)], 1)
    #' cat(sprintf("%s%% of the 14-day range\n", fast_k))
    #' }
    stochastic_fast_oscillator = function(
      fast_k_period = 5,
      fast_d_period = 3,
      fast_d_moving_average_type = 0,
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
      lines <- talib::STOCHF(
        prices,
        cols = ~ high + low + close,
        fastKPeriod = fast_k_period,
        fastDPeriod = fast_d_period,
        fastDMa = fast_d_moving_average_type
      )
      prices[[paste0("stochf_fastk", fast_k_period)]] <- as.numeric(
        lines[["FastK"]]
      )
      prices[[paste0("stochf_fastd", fast_d_period)]] <- as.numeric(
        lines[["FastD"]]
      )
      prices
    },

    #' @description
    #' Adds the stochastic relative strength index's %K and %D lines for one candle column.
    #' @param window The integer number of candles in the relative strength index that the stochastic is taken of.
    #' @param fast_k_period The integer number of relative strength index values the stochastic %K looks back over.
    #' @param fast_d_period The integer number of candles smoothing %K into %D.
    #' @param fast_d_moving_average_type The integer TA-Lib moving average type for %D, where 0 is a simple moving average.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with `stochrsi_fastk<period>` and `stochrsi_fastd<period>` columns added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$stochastic_relative_strength_index(days = 120)
    #' columns <- c(
    #'   "datetime",
    #'   "stochrsi_fastk5",
    #'   "stochrsi_fastd3"
    #' )
    #' print(tail(frame[, columns]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$stochastic_relative_strength_index(
    #'   window = 14,
    #'   fast_k_period = 14,
    #'   fast_d_period = 3,
    #'   days = 180
    #' )
    #' cat(sprintf("%%K %.1f\n", frame$stochrsi_fastk14[nrow(frame)]))
    #' cat(sprintf("%%D %.1f\n", frame$stochrsi_fastd3[nrow(frame)]))
    #' }
    stochastic_relative_strength_index = function(
      window = 14,
      fast_k_period = 5,
      fast_d_period = 3,
      fast_d_moving_average_type = 0,
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
      lines <- talib::STOCHRSI(
        prices[[column]],
        timePeriod = window,
        fastKPeriod = fast_k_period,
        fastDPeriod = fast_d_period,
        fastDMa = fast_d_moving_average_type
      )
      prices[[paste0("stochrsi_fastk", fast_k_period)]] <- as.numeric(
        lines[, "FastK"]
      )
      prices[[paste0("stochrsi_fastd", fast_d_period)]] <- as.numeric(
        lines[, "FastD"]
      )
      prices
    },

    #' @description
    #' Adds TRIX, the rate of change of a triple smoothed exponential moving average of one candle column.
    #' @param window The integer number of candles in each calculation window.
    #' @param column The character name of the candle column to use, such as `"close"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `trix_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$trix(days = 180)
    #' print(tail(frame[, c("datetime", "trix_15")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$trix(window = 9, days = 180)
    #' latest <- frame$trix_9[nrow(frame)]
    #' previous <- frame$trix_9[nrow(frame) - 1]
    #' if (latest > previous) {
    #'   cat(sprintf("TRIX is rising: %.4f to %.4f\n", previous, latest))
    #' } else {
    #'   cat(sprintf("TRIX is falling: %.4f to %.4f\n", previous, latest))
    #' }
    #' }
    trix = function(
      window = 15,
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
      rate <- talib::TRIX(prices[[column]], timePeriod = window)
      prices[[paste0("trix_", window)]] <- as.numeric(rate)
      prices
    },

    #' @description
    #' Adds the ultimate oscillator, which blends buying pressure over three windows.
    #' @param fast_period The integer number of candles in the shortest window.
    #' @param slow_period The integer number of candles in the middle window.
    #' @param signal_period The integer number of candles in the longest window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `ultosc_<fast>_<slow>_<signal>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$ultimate_oscillator(days = 120)
    #' print(tail(frame[, c("datetime", "ultosc_7_14_28")]))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' frame <- reliance$ultimate_oscillator(days = 120)
    #' latest <- frame$ultosc_7_14_28[nrow(frame)]
    #' if (latest > 70) {
    #'   label <- "overbought"
    #' } else if (latest < 30) {
    #'   label <- "oversold"
    #' } else {
    #'   label <- "neutral"
    #' }
    #' cat(sprintf("Reliance ultimate oscillator %.1f: %s\n", latest, label))
    #' }
    ultimate_oscillator = function(
      fast_period = 7,
      slow_period = 14,
      signal_period = 28,
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
      oscillator <- talib::ULTOSC(
        prices,
        cols = ~ high + low + close,
        firstPeriod = fast_period,
        secondPeriod = slow_period,
        thirdPeriod = signal_period
      )
      label <- paste0(
        "ultosc_",
        fast_period,
        "_",
        slow_period,
        "_",
        signal_period
      )
      prices[[label]] <- as.numeric(oscillator[["ULTOSC"]])
      prices
    },

    #' @description
    #' Adds Williams %R.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `willr_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$williams_percent_r(window = 14, days = 90)
    #' print(tail(frame[, c("datetime", "willr_14")]))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$williams_percent_r(window = 14, days = 365)
    #' days_below <- sum(frame$willr_14 < -80, na.rm = TRUE)
    #' cat(sprintf("Below -80 on %d days\n", days_below))
    #' }
    williams_percent_r = function(
      window = 14,
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
      percent_r <- talib::WILLR(
        prices,
        cols = ~ high + low + close,
        timePeriod = window
      )
      prices[[paste0("willr_", window)]] <- as.numeric(percent_r[["WILLR"]])
      prices
    }
  ),
  private = list(
    #' Returns each value's counterpart a number of candles earlier, the base TA-Lib's rate of change functions divide by.
    #'
    #' @param values A numeric vector of candle values, oldest first.
    #' @param window The integer number of candles to look back.
    #' @param function_name The character TA-Lib function name, such as `"TA_ROC"`, used in the error message.
    #' @return A numeric vector as long as `values`, holding `NA` for the first `window` positions and the value `window` candles earlier everywhere else.
    #' @details Errors: signals a plain error when `window` is below 1 or above 100000, the range TA-Lib accepts.
    values_window_before = function(values, window, function_name) {
      if (window < 1 || window > 100000) {
        stop(
          sprintf(
            "%s: A parameter is out of range (TA_BAD_PARAM): window = %s",
            function_name,
            window
          ),
          call. = FALSE
        )
      }
      count <- length(values)
      previous <- rep(NA_real_, count)
      if (count > window) {
        previous[seq(window + 1, count)] <- values[seq(1, count - window)]
      }
      previous
    }
  )
)
