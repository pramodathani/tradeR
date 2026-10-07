#' Indicators an instrument calculates from its candles' prices and volumes
#'
#' @description
#' Measures that combine price with traded volume. Each method fetches the instrument's candles through `prices()`, adds one TA-Lib column, computed by the `talib` package, and returns the candles. The class is a link in the chain of analysis classes, inheriting `MomentumIndicators`, and `Instrument` inherits it through that chain and supplies `prices()`.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$on_balance_volume(days = 365)
#' }
#' @export
VolumeIndicators <- R6::R6Class(
  "VolumeIndicators",
  inherit = MomentumIndicators,
  public = list(
    #' @description
    #' Adds the Chaikin accumulation distribution line.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `chaikin_ad` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$chaikin_accumulation_distribution_line(days = 90)
    #' print(tail(candles[, c("datetime", "close", "chaikin_ad")], 5))
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$chaikin_accumulation_distribution_line(days = 45)
    #'   line <- candles$chaikin_ad
    #'   change <- line[[length(line)]] - line[[length(line) - 20]]
    #'   if (change > 0) {
    #'     amount <- formatC(change, format = "f", digits = 0, big.mark = ",")
    #'     cat(sprintf("%s: accumulation of %s\n", symbol, amount))
    #'   } else {
    #'     amount <- formatC(-change, format = "f", digits = 0, big.mark = ",")
    #'     cat(sprintf("%s: distribution of %s\n", symbol, amount))
    #'   }
    #' }
    #' }
    chaikin_accumulation_distribution_line = function(
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
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close),
        volume = as.numeric(prices$volume)
      )
      indicator <- talib::AD(inputs)
      prices[["chaikin_ad"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the Chaikin accumulation distribution oscillator.
    #' @param fast_period The integer number of candles in the fast exponential moving average.
    #' @param slow_period The integer number of candles in the slow exponential moving average.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `chaikin_adosc<fast>_<slow>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$chaikin_accumulation_distribution_oscillator(
    #'   days = 90
    #' )
    #' print(tail(candles[, c("datetime", "close", "chaikin_adosc3_10")], 5))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "WIPRO"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$chaikin_accumulation_distribution_oscillator(
    #'     fast_period = 5,
    #'     slow_period = 20,
    #'     days = 120
    #'   )
    #'   value <- candles$chaikin_adosc5_20[[nrow(candles)]]
    #'   amount <- formatC(value, format = "f", digits = 0, big.mark = ",")
    #'   if (value > 0) {
    #'     cat(sprintf("%s: buying pressure %s\n", symbol, amount))
    #'   } else {
    #'     cat(sprintf("%s: selling pressure %s\n", symbol, amount))
    #'   }
    #' }
    #' }
    chaikin_accumulation_distribution_oscillator = function(
      fast_period = 3,
      slow_period = 10,
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
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close),
        volume = as.numeric(prices$volume)
      )
      indicator <- talib::ADOSC(
        inputs,
        fastPeriod = fast_period,
        slowPeriod = slow_period
      )
      column_name <- paste0("chaikin_adosc", fast_period, "_", slow_period)
      prices[[column_name]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the on balance volume, measured against one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `obv` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' candles <- infosys$on_balance_volume(days = 90)
    #' print(tail(candles[, c("datetime", "close", "volume", "obv")], 5))
    #'
    #' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
    #' candles <- reliance$on_balance_volume(days = 45)
    #' closes <- candles$close
    #' volume_line <- candles$obv
    #' last <- nrow(candles)
    #' price_change <- closes[[last]] - closes[[last - 20]]
    #' volume_change <- volume_line[[last]] - volume_line[[last - 20]]
    #' if ((price_change > 0) == (volume_change > 0)) {
    #'   cat("Volume confirms the price move\n")
    #' } else {
    #'   cat("Volume diverges from the price move\n")
    #' }
    #'
    #' symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "SBIN"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   candles <- share$on_balance_volume(column = "open", days = 60)
    #'   latest <- candles$obv[[nrow(candles)]]
    #'   amount <- formatC(latest, format = "f", digits = 0, big.mark = ",")
    #'   cat(sprintf("%s: %s\n", symbol, amount))
    #' }
    #' }
    on_balance_volume = function(
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
        close = as.numeric(prices[[column]]),
        volume = as.numeric(prices$volume)
      )
      indicator <- talib::OBV(inputs)
      prices[["obv"]] <- as.numeric(indicator[[1]])
      prices
    }
  )
)
