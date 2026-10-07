#' Per-candle price summaries an instrument calculates from its candles
#'
#' @description
#' Single prices that summarise each candle. Each method fetches the instrument's candles through `prices()`, adds one TA-Lib column, computed by the `talib` package, and returns the candles. The class is a link in the chain of analysis classes, inheriting `CycleIndicators`, and `Instrument` inherits it through that chain and supplies `prices()`.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$typical_price(days = 30)
#' }
#' @export
PriceTransforms <- R6::R6Class(
  "PriceTransforms",
  inherit = CycleIndicators,
  public = list(
    #' @description
    #' Adds the average of each candle's open, high, low and close.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with an `avg_price` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$average_price(days = 30)
    #' print(tail(frame[, c("datetime", "avg_price")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$average_price(days = 90)
    #' above <- sum(frame$close > frame$avg_price)
    #' total <- nrow(frame)
    #' cat(sprintf("Closed above its average price on %d of %d days\n", above, total))
    #' }
    average_price = function(
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
        open = as.numeric(prices$open),
        high = as.numeric(prices$high),
        low = as.numeric(prices$low),
        close = as.numeric(prices$close)
      )
      indicator <- talib::AVGPRICE(inputs)
      prices[["avg_price"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the midpoint of each candle's high and low.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `med_price` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$median_price(days = 30)
    #' print(tail(frame[, c("datetime", "med_price")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$median_price(
    #'   from_date = "2026-09-21",
    #'   to_date = "2026-09-25"
    #' )
    #' print(frame[, c("datetime", "med_price")])
    #' }
    median_price = function(
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
        low = as.numeric(prices$low)
      )
      indicator <- talib::MEDPRICE(inputs)
      prices[["med_price"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds the average of each candle's high, low and close.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `typ_price` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$typical_price(days = 30)
    #' print(tail(frame[, c("datetime", "typ_price")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$typical_price(days = 30)
    #' traded_value <- sum(frame$typ_price * frame$volume)
    #' weighted_price <- traded_value / sum(frame$volume)
    #' cat(sprintf("Volume-weighted typical price: %.2f\n", weighted_price))
    #' }
    typical_price = function(
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
      indicator <- talib::TYPPRICE(inputs)
      prices[["typ_price"]] <- as.numeric(indicator[[1]])
      prices
    },

    #' @description
    #' Adds each candle's weighted close, which counts the close twice alongside the high and low.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `wght_close` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$weighted_close(days = 30)
    #' print(tail(frame[, c("datetime", "wght_close")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' weighted_frame <- nifty$weighted_close(days = 30)
    #' typical_frame <- nifty$typical_price(days = 30)
    #' weighted_close <- weighted_frame$wght_close[[nrow(weighted_frame)]]
    #' typical_price <- typical_frame$typ_price[[nrow(typical_frame)]]
    #' cat(sprintf("Weighted close %.2f\n", weighted_close))
    #' cat(sprintf("Typical price %.2f\n", typical_price))
    #' }
    weighted_close = function(
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
      indicator <- talib::WCLPRICE(inputs)
      prices[["wght_close"]] <- as.numeric(indicator[[1]])
      prices
    }
  )
)
