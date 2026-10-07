#' Range-based volatility indicators an instrument calculates from its candles
#'
#' @description
#' Measures of how far prices range. Each method fetches the instrument's candles through `prices()`, adds one TA-Lib column, computed by the `talib` package, and returns the candles. The class is a link in the chain of analysis classes, inheriting `PriceTransforms`, and `Instrument` inherits it through that chain and supplies `prices()`.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$average_true_range(window = 14, days = 365)
#' }
#' @export
VolatilityIndicators <- R6::R6Class(
  "VolatilityIndicators",
  inherit = PriceTransforms,
  public = list(
    #' @description
    #' Adds the average true range.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `atr_<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$average_true_range(days = 90)
    #' print(tail(frame[, c("datetime", "atr_14")], 5))
    #'
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$average_true_range(window = 14, days = 90)
    #' close <- frame$close[[nrow(frame)]]
    #' average_true_range <- frame$atr_14[[nrow(frame)]]
    #' stop_level <- round(close - 2 * average_true_range, 2)
    #' cat(sprintf("Close %s, ATR %.2f\n", close, average_true_range))
    #' cat(sprintf("Stop level %s\n", stop_level))
    #' }
    average_true_range = function(
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
      inputs <- data.frame(
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close)
      )
      indicator <- talib::ATR(inputs, timePeriod = window)
      prices[[paste0("atr_", window)]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the average true range as a percentage of the close.
    #' @param window The integer number of candles in each calculation window.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `natr<window>` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$normalized_average_true_range(days = 90)
    #' print(tail(frame[, c("datetime", "natr14")], 5))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' latest_values <- numeric(0)
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$normalized_average_true_range(window = 14, days = 90)
    #'   latest_values[[symbol]] <- frame$natr14[[nrow(frame)]]
    #' }
    #' ranked <- names(sort(latest_values, decreasing = TRUE))
    #' for (symbol in ranked) {
    #'   cat(sprintf("%s: %.2f%%\n", symbol, latest_values[[symbol]]))
    #' }
    #' }
    normalized_average_true_range = function(
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
      inputs <- data.frame(
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close)
      )
      indicator <- talib::NATR(inputs, timePeriod = window)
      prices[[paste0("natr", window)]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds each candle's true range.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `tr` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$true_range(days = 30)
    #' print(tail(frame[, c("datetime", "tr")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$true_range(days = 180)
    #' widest_row <- which.max(frame$tr)
    #' widest_day <- as.Date(frame$datetime[[widest_row]], tz = "Asia/Kolkata")
    #' cat(sprintf("%s: %.2f points\n", widest_day, frame$tr[[widest_row]]))
    #' }
    true_range = function(
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
        close = as.numeric(prices$close)
      )
      indicator <- talib::TRANGE(inputs)
      prices[["tr"]] <- as.numeric(indicator[[1]])
      prices
    }
  )
)
