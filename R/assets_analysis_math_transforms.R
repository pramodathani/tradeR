#' Element-by-element mathematical functions an instrument applies to one candle column
#'
#' @description
#' Each method fetches the instrument's candles through `prices()`, adds one column and returns the candles. The class is a link in the chain of analysis classes that `Instrument` inherits, and `Instrument` supplies `prices()`.
#'
#' The `talib` package has no math transforms, so each is computed with the base R function that TA-Lib's C code calls, such as `acos()` for TA-Lib's `ACOS`. TA-Lib's math transforms need no earlier candles, so every row gets a value.
#'
#' @examples
#' \dontrun{
#' infosys <- Instrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' frame <- infosys$natural_logarithm(days = 365)
#' }
#' @export
MathTransforms <- R6::R6Class(
  "MathTransforms",
  inherit = StatisticFunctions,
  public = list(
    #' @description
    #' Adds the arc cosine of one candle column.
    #'
    #' Values outside -1 to 1 have no arc cosine and give `NaN`, as in TA-Lib.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `acos` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$arc_cosine(column = "price_factor", days = 30)
    #' print(tail(frame[, c("datetime", "acos")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$arc_cosine(days = 30)
    #' missing <- sum(is.na(frame$acos))
    #' print(sprintf("%d of %d values are undefined", missing, nrow(frame)))
    #' }
    arc_cosine = function(
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
      results <- rep(NaN, length(values))
      defined <- !is.na(values) & values >= -1 & values <= 1
      results[defined] <- acos(values[defined])
      prices[["acos"]] <- results
      prices
    },

    #' @description
    #' Adds the arc sine of one candle column.
    #'
    #' Values outside -1 to 1 have no arc sine and give `NaN`, as in TA-Lib.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `asin` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$arc_sine(column = "price_factor", days = 30)
    #' print(tail(frame[, c("datetime", "asin")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$arc_sine(days = 30)
    #' missing <- sum(is.na(frame$asin))
    #' print(sprintf("%d of %d values are undefined", missing, nrow(frame)))
    #' }
    arc_sine = function(
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
      results <- rep(NaN, length(values))
      defined <- !is.na(values) & values >= -1 & values <= 1
      results[defined] <- asin(values[defined])
      prices[["asin"]] <- results
      prices
    },

    #' @description
    #' Adds the arc tangent of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `atan` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$arc_tangent(days = 30)
    #' print(tail(frame[, c("datetime", "atan")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$arc_tangent(column = "low", days = 30)
    #' print(tail(frame[, c("datetime", "atan")], 5))
    #' }
    arc_tangent = function(
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
      prices[["atan"]] <- atan(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the ceiling of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ceil` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$ceiling(days = 30)
    #' columns <- c(
    #'   "datetime",
    #'   "close",
    #'   "ceil"
    #' )
    #' print(tail(frame[, columns], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$ceiling(days = 180)
    #' whole <- sum(frame$ceil == frame$close)
    #' print(sprintf("Closed on a whole rupee on %d of %d days", whole, nrow(frame)))
    #' }
    ceiling = function(
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
      prices[["ceil"]] <- ceiling(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the cosine of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `cos` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$cosine(days = 30)
    #' print(tail(frame[, c("datetime", "cos")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$cosine(column = "price_factor", days = 30)
    #' print(tail(frame[, c("datetime", "cos")], 5))
    #' }
    cosine = function(
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
      prices[["cos"]] <- cos(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the hyperbolic cosine of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `cosh` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$hyperbolic_cosine(days = 30)
    #' print(tail(frame[, c("datetime", "cosh")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$hyperbolic_cosine(days = 30)
    #' infinite <- sum(is.infinite(frame$cosh))
    #' print(sprintf("%d of %d values overflowed to infinity", infinite, nrow(frame)))
    #' }
    hyperbolic_cosine = function(
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
      prices[["cosh"]] <- cosh(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the exponential of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `exp` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$exponential(days = 30)
    #' print(tail(frame[, c("datetime", "exp")], 5))
    #'
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$exponential(days = 30)
    #' error <- max(abs(log(frame$exp) - frame$close))
    #' print(sprintf("Largest round-trip error: %g", error))
    #' }
    exponential = function(
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
      prices[["exp"]] <- exp(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the floor of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `floor` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$floor(days = 30)
    #' columns <- c(
    #'   "datetime",
    #'   "close",
    #'   "floor"
    #' )
    #' print(tail(frame[, columns], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$floor(days = 90)
    #' paise <- (frame$close - frame$floor) * 100
    #' print(sprintf("Average paise part of the close: %.1f", mean(paise)))
    #' }
    floor = function(
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
      prices[["floor"]] <- floor(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the natural logarithm of one candle column.
    #'
    #' Negative values have no logarithm and give `NaN`, as in TA-Lib.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `ln` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$natural_logarithm(days = 30)
    #' print(tail(frame[, c("datetime", "ln")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$natural_logarithm(days = 365)
    #' total_log_return <- sum(diff(frame$ln))
    #' print(sprintf("Total log return %.4f", total_log_return))
    #' print(sprintf("Total return %.2f%%", (exp(total_log_return) - 1) * 100))
    #' }
    natural_logarithm = function(
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
      results <- rep(NaN, length(values))
      defined <- !is.na(values) & values >= 0
      results[defined] <- log(values[defined])
      prices[["ln"]] <- results
      prices
    },

    #' @description
    #' Adds the base 10 logarithm of one candle column.
    #'
    #' Negative values have no logarithm and give `NaN`, as in TA-Lib.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `log10` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$logarithm_base_10(days = 30)
    #' print(tail(frame[, c("datetime", "log10")], 5))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HDFCBANK",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   frame <- share$logarithm_base_10(days = 10)
    #'   digits <- floor(frame$log10[[nrow(frame)]]) + 1
    #'   print(sprintf("%s: %d digits", symbol, as.integer(digits)))
    #' }
    #' }
    logarithm_base_10 = function(
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
      results <- rep(NaN, length(values))
      defined <- !is.na(values) & values >= 0
      results[defined] <- log10(values[defined])
      prices[["log10"]] <- results
      prices
    },

    #' @description
    #' Adds the sine of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `sin` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$sine(days = 30)
    #' print(tail(frame[, c("datetime", "sin")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$sine(column = "price_factor", days = 30)
    #' print(tail(frame[, c("datetime", "sin")], 5))
    #' }
    sine = function(
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
      prices[["sin"]] <- sin(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the hyperbolic sine of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `sinh` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$hyperbolic_sine(days = 30)
    #' print(tail(frame[, c("datetime", "sinh")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$hyperbolic_sine(column = "price_factor", days = 30)
    #' print(tail(frame[, c("datetime", "sinh")], 5))
    #' }
    hyperbolic_sine = function(
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
      prices[["sinh"]] <- sinh(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the square root of one candle column.
    #'
    #' Negative values have no square root and give `NaN`, as in TA-Lib.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `sqrt` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$square_root(days = 30)
    #' print(tail(frame[, c("datetime", "sqrt")], 5))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' frame <- nifty$square_root(
    #'   column = "high",
    #'   from_date = "2026-09-21",
    #'   to_date = "2026-09-25"
    #' )
    #' print(frame[, c("datetime", "sqrt")])
    #' }
    square_root = function(
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
      results <- rep(NaN, length(values))
      defined <- !is.na(values) & values >= 0
      results[defined] <- sqrt(values[defined])
      prices[["sqrt"]] <- results
      prices
    },

    #' @description
    #' Adds the tangent of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `tan` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$tangent(days = 30)
    #' print(tail(frame[, c("datetime", "tan")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' tangent_frame <- infosys$tangent(days = 30)
    #' sine_frame <- infosys$sine(days = 30)
    #' cosine_frame <- infosys$cosine(days = 30)
    #' tangent <- tangent_frame$tan[[nrow(tangent_frame)]]
    #' sine <- sine_frame$sin[[nrow(sine_frame)]]
    #' cosine <- cosine_frame$cos[[nrow(cosine_frame)]]
    #' print(sprintf("tan %.6f, sin / cos %.6f", tangent, sine / cosine))
    #' }
    tangent = function(
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
      prices[["tan"]] <- tan(as.numeric(prices[[column]]))
      prices
    },

    #' @description
    #' Adds the hyperbolic tangent of one candle column.
    #' @param column The character name of the candle column to use, such as `close`.
    #' @param interval The character candle interval, such as `day` or `5minute`.
    #' @param from_date The first day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param to_date The last day of the range as a `Date` or a `YYYY-MM-DD` character, or `NULL` when days is given.
    #' @param days The integer number of days to count back from today, or `NULL` when from_date and to_date are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of the candles with a `tanh` column added, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' frame <- vodafone_idea$hyperbolic_tangent(days = 30)
    #' print(tail(frame[, c("datetime", "tanh")], 5))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' frame <- infosys$hyperbolic_tangent(
    #'   column = "price_factor",
    #'   days = 30
    #' )
    #' print(tail(frame[, c("datetime", "tanh")], 5))
    #' }
    hyperbolic_tangent = function(
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
      prices[["tanh"]] <- tanh(as.numeric(prices[[column]]))
      prices
    }
  )
)
