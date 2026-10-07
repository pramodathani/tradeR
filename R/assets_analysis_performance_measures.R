#' The number of trading days in a year, used to annualise `day` candles
#' @keywords internal
PERFORMANCE_MEASURES_TRADING_DAYS_PER_YEAR <- 252

#' The number of minutes in one NSE session, from 09:15 to 15:30
#' @keywords internal
PERFORMANCE_MEASURES_TRADING_MINUTES_PER_DAY <- 375

#' The interval name of daily candles
#' @keywords internal
PERFORMANCE_MEASURES_DAY_INTERVAL <- "day"

#' The pattern a minute interval such as `5minute` matches
#' @keywords internal
PERFORMANCE_MEASURES_MINUTE_INTERVAL_PATTERN <- "^([0-9]+)minute$"

#' The value at risk method that reads the loss from past returns
#' @keywords internal
PERFORMANCE_MEASURES_HISTORICAL_METHOD <- "historical"

#' The value at risk method that assumes normally distributed returns
#' @keywords internal
PERFORMANCE_MEASURES_PARAMETRIC_METHOD <- "parametric"

#' Return, risk and benchmark-relative measures calculated from closing prices
#'
#' @description
#' The last link of the chain of analysis classes, which `Instrument` and `AssetBasket` inherit, so the same Sharpe ratio or drawdown can be asked of one share, an index, a fund or a whole basket.
#'
#' Each public method fetches candles through `prices()`, works on the closing prices, and returns one number, or a `data.frame` for `drawdowns()`, or a named list for `performance_summary()`.
#'
#' Returns are the fractional change of the close from one candle to the next. Annual figures scale by the number of candles in a trading year, 252 for `day` candles and the number of candles in 252 sessions of 375 minutes for an intraday interval such as `5minute`. A `risk_free_rate` is an annual fraction, so 6.5 percent is 0.065.
#'
#' @examples
#' \dontrun{
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY 50")
#' ratio <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
#' worst <- infosys$maximum_drawdown(days = 730)
#' summary <- infosys$performance_summary(
#'   benchmark = nifty,
#'   risk_free_rate = 0.065,
#'   days = 365
#' )
#' }
#' @export
PerformanceMeasures <- R6::R6Class(
  "PerformanceMeasures",
  inherit = StrategyBacktests,
  public = list(
    #' @description
    #' Calculates the total growth of the close from the first candle to the last.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric fractional growth, such as 0.12 for 12 percent, or `NULL` when there are fewer than two candles.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' growth <- infosys$cumulative_return(days = 365)
    #' cat(sprintf("Infosys over one year: %.2f%%\n", growth * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' returns <- numeric(0)
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   returns[[symbol]] <- share$cumulative_return(
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #' }
    #' for (symbol in names(sort(returns, decreasing = TRUE))) {
    #'   cat(sprintf("%s: %.2f%%\n", symbol, returns[[symbol]] * 100))
    #' }
    #' }
    cumulative_return = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$cumulative_return_of(closes)
    },

    #' @description
    #' Calculates the compound annual growth rate of the close over the range.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric annual growth rate, such as 0.15 for 15 percent a year, or `NULL` when there are fewer than two candles or the first or last close is not above zero.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' growth_rate <- nifty$annualised_return(days = 1825)
    #' cat(sprintf("Nifty over five years: %.2f%% a year\n", growth_rate * 100))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' periods <- c(
    #'   365,
    #'   1095,
    #'   1825
    #' )
    #' for (period in periods) {
    #'   growth_rate <- infosys$annualised_return(days = period)
    #'   cat(sprintf("%d days: %.2f%% a year\n", period, growth_rate * 100))
    #' }
    #' }
    annualised_return = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$annualised_return_of(closes, periods_per_year)
    },

    #' @description
    #' Calculates the standard deviation of returns, scaled to a year.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric annual volatility, such as 0.22 for 22 percent, or `NULL` when there are fewer than three candles.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' volatility <- infosys$annualised_volatility(days = 365)
    #' cat(sprintf("Infosys volatility: %.2f%%\n", volatility * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' index_volatility <- nifty$annualised_volatility(days = 730)
    #' cat(sprintf("Nifty: %.2f%%\n", index_volatility * 100))
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   volatility <- share$annualised_volatility(days = 730)
    #'   if (volatility > index_volatility) {
    #'     cat(sprintf("%s: %.2f%%, more than the index\n", symbol, volatility * 100))
    #'   } else {
    #'     cat(sprintf("%s: %.2f%%, less than the index\n", symbol, volatility * 100))
    #'   }
    #' }
    #' }
    annualised_volatility = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$annualised_volatility_of(
        private$returns_of(closes),
        periods_per_year
      )
    },

    #' @description
    #' Calculates the Sharpe ratio: the annual return above the risk-free rate for each unit of annual volatility.
    #'
    #' A ratio above 1 is usually thought good. The annual return here is the mean return scaled to a year, which is the textbook form, rather than the compound growth rate `annualised_return()` gives.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction, such as 0.065 for a 6.5 percent treasury bill.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric Sharpe ratio, or `NULL` when there are fewer than three candles or the price never moved.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' ratio <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
    #' cat(sprintf("Sharpe ratio: %.2f\n", ratio))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' best_symbol <- NULL
    #' best_ratio <- NULL
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   ratio <- share$sharpe_ratio(risk_free_rate = 0.065, days = 730)
    #'   cat(sprintf("%s: %.2f\n", symbol, ratio))
    #'   if (is.null(best_ratio) || ratio > best_ratio) {
    #'     best_symbol <- symbol
    #'     best_ratio <- ratio
    #'   }
    #' }
    #' cat(sprintf("Best Sharpe ratio: %s\n", best_symbol))
    #' }
    sharpe_ratio = function(
      risk_free_rate = 0.0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$sharpe_ratio_of(
        private$returns_of(closes),
        risk_free_rate,
        periods_per_year
      )
    },

    #' @description
    #' Calculates the Sortino ratio, which is the Sharpe ratio with only the falls counted as risk.
    #'
    #' The downside deviation is the root mean square of each period's shortfall below the risk-free rate, counting a period that beat it as zero.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction, such as 0.065.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric Sortino ratio, or `NULL` when there are fewer than three candles or no period fell short of the risk-free rate.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' ratio <- nifty$sortino_ratio(risk_free_rate = 0.065, days = 730)
    #' cat(sprintf("Nifty Sortino ratio: %.2f\n", ratio))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' sortino <- infosys$sortino_ratio(risk_free_rate = 0.065, days = 365)
    #' sharpe <- infosys$sharpe_ratio(risk_free_rate = 0.065, days = 365)
    #' cat(sprintf("Sortino %.2f against Sharpe %.2f\n", sortino, sharpe))
    #' if (sortino > sharpe) {
    #'   cat("The rises are larger than the falls.\n")
    #' } else {
    #'   cat("The falls weigh at least as much as the rises.\n")
    #' }
    #' }
    sortino_ratio = function(
      risk_free_rate = 0.0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$sortino_ratio_of(
        private$returns_of(closes),
        risk_free_rate,
        periods_per_year
      )
    },

    #' @description
    #' Calculates how far the close stood below its highest earlier close at every candle.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with `datetime`, `close`, `running_peak` and `drawdown` columns, where `drawdown` is zero at a new peak and negative below one, such as -0.1 for ten percent below, or `NULL` when there are fewer than two candles.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' drawdown_frame <- infosys$drawdowns(days = 365)
    #' latest <- drawdown_frame[nrow(drawdown_frame), ]
    #' cat(sprintf("Close %s, peak %s\n", latest$close, latest$running_peak))
    #' cat(sprintf("Drawdown from the peak: %.2f%%\n", latest$drawdown * 100))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' drawdown_frame <- nifty$drawdowns(days = 1095)
    #' deep_days <- drawdown_frame[drawdown_frame$drawdown < -0.05, ]
    #' day_count <- nrow(drawdown_frame)
    #' cat(sprintf("%d of %d days were 5%% down.\n", nrow(deep_days), day_count))
    #' }
    drawdowns = function(
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
      if (is.null(prices) || nrow(prices) < 2) {
        return(NULL)
      }
      close <- as.numeric(prices$close)
      running_peak <- private$running_peak_of(close)
      frame <- data.frame(
        datetime = prices$datetime,
        close = close,
        running_peak = running_peak,
        drawdown = close / running_peak - 1
      )
      rownames(frame) <- NULL
      frame
    },

    #' @description
    #' Finds the worst fall of the close from an earlier peak in the range.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric worst drawdown as a negative fraction, such as -0.25 for a 25 percent fall, zero when the close never fell, or `NULL` when there are fewer than two candles.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' worst_fall <- infosys$maximum_drawdown(days = 730)
    #' cat(sprintf("Maximum drawdown: %.2f%%\n", worst_fall * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' symbols <- c(
    #'   symbols,
    #'   "NIFTY"
    #' )
    #' for (symbol in symbols) {
    #'   if (symbol == "NIFTY") {
    #'     instrument <- EquityIndex$new(
    #'       exchange = "nse",
    #'       symbol = symbol
    #'     )
    #'   } else {
    #'     instrument <- Equity$new(exchange = "nse", symbol = symbol)
    #'   }
    #'   worst_fall <- instrument$maximum_drawdown(
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: %.2f%%\n", symbol, worst_fall * 100))
    #' }
    #' }
    maximum_drawdown = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$maximum_drawdown_of(closes)
    },

    #' @description
    #' Calculates the Calmar ratio: the compound annual growth rate divided by the size of the worst drawdown.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric Calmar ratio, or `NULL` when there are fewer than two candles or the close never fell.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' ratio <- nifty$calmar_ratio(days = 1095)
    #' cat(sprintf("Nifty Calmar ratio: %.2f\n", ratio))
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' growth_rate <- infosys$annualised_return(days = 730)
    #' worst_fall <- infosys$maximum_drawdown(days = 730)
    #' ratio <- infosys$calmar_ratio(days = 730)
    #' cat(
    #'   sprintf(
    #'     "%.2f%% a year, worst fall %.2f%%\n",
    #'     growth_rate * 100,
    #'     worst_fall * 100
    #'   )
    #' )
    #' if (is.null(ratio)) {
    #'   cat("The close never fell, so there is no Calmar ratio.\n")
    #' } else {
    #'   cat(sprintf("Calmar ratio: %.2f\n", ratio))
    #' }
    #' }
    calmar_ratio = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$calmar_ratio_of(closes, periods_per_year)
    },

    #' @description
    #' Estimates the loss over one candle that is not exceeded with the given confidence.
    #'
    #' The `historical` method reads the loss straight from the returns in the range. The `parametric` method assumes returns follow a normal distribution with the range's mean and standard deviation, which understates the rare large falls real prices have.
    #' @param confidence The numeric confidence level between 0 and 1, such as 0.95 for the loss exceeded on only one candle in twenty.
    #' @param method The character method, `"historical"` or `"parametric"`.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric loss as a positive fraction of the value, such as 0.021 for 2.1 percent, or `NULL` when there are fewer than three candles.
    #' @details Errors: signals `ValueError` when the method is neither `historical` nor `parametric`, or confidence is not between 0 and 1; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' loss <- infosys$value_at_risk(confidence = 0.95, days = 365)
    #' cat(sprintf("One-day value at risk: %.2f%%\n", loss * 100))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' methods <- c(
    #'   "historical",
    #'   "parametric"
    #' )
    #' for (method in methods) {
    #'   loss <- nifty$value_at_risk(
    #'     confidence = 0.99,
    #'     method = method,
    #'     days = 1095
    #'   )
    #'   cat(sprintf("%s: %.2f%%\n", method, loss * 100))
    #' }
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' holding_value <- 500000
    #' loss <- infosys$value_at_risk(confidence = 0.95, days = 730)
    #' loss_in_rupees <- holding_value * loss
    #' cat(
    #'   sprintf(
    #'     "Loss under Rs %s on 19 days in 20\n",
    #'     format(round(loss_in_rupees), big.mark = ",")
    #'   )
    #' )
    #' }
    value_at_risk = function(
      confidence = 0.95,
      method = PERFORMANCE_MEASURES_HISTORICAL_METHOD,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      private$check_value_at_risk_arguments(confidence, method)
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$value_at_risk_of(
        private$returns_of(closes),
        confidence,
        method
      )
    },

    #' @description
    #' Calculates the average loss over one candle on the candles whose loss reached the historical value at risk.
    #'
    #' This is also called the conditional value at risk. It answers how bad the bad days are, where the value at risk only says where they begin.
    #' @param confidence The numeric confidence level between 0 and 1, such as 0.95.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric average loss as a positive fraction, or `NULL` when there are fewer than three candles.
    #' @details Errors: signals `ValueError` when confidence is not between 0 and 1; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' shortfall <- infosys$expected_shortfall(confidence = 0.95, days = 365)
    #' cat(sprintf("Expected shortfall: %.2f%%\n", shortfall * 100))
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' loss <- nifty$value_at_risk(confidence = 0.95, days = 1095)
    #' shortfall <- nifty$expected_shortfall(confidence = 0.95, days = 1095)
    #' cat(sprintf("Bad days begin at a loss of %.2f%%\n", loss * 100))
    #' cat(sprintf("They average a loss of %.2f%%\n", shortfall * 100))
    #' }
    expected_shortfall = function(
      confidence = 0.95,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      private$check_value_at_risk_arguments(
        confidence,
        PERFORMANCE_MEASURES_HISTORICAL_METHOD
      )
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      private$expected_shortfall_of(
        private$returns_of(closes),
        confidence
      )
    },

    #' @description
    #' Calculates one beta against a benchmark over the whole range.
    #'
    #' This is the slope of the returns regressed on the benchmark's returns, so 1.2 means the price tended to move 1.2 percent for each percent the benchmark moved. `beta()` gives the rolling TA-Lib version instead.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric beta, or `NULL` when fewer than three candles match the benchmark's or the benchmark never moved.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' beta <- infosys$benchmark_beta(nifty, days = 730)
    #' cat(sprintf("Infosys beta against the Nifty: %.2f\n", beta))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   beta <- share$benchmark_beta(nifty, days = 365)
    #'   if (beta < 1) {
    #'     cat(sprintf("%s: beta %.2f, defensive\n", symbol, beta))
    #'   } else {
    #'     cat(sprintf("%s: beta %.2f, aggressive\n", symbol, beta))
    #'   }
    #' }
    #' }
    benchmark_beta = function(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$beta_of(matched)
    },

    #' @description
    #' Calculates Jensen's alpha: the annual return beyond what the benchmark's moves and the beta explain.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction, such as 0.065.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric annual alpha as a fraction, such as 0.03 for three percent a year ahead, or `NULL` when fewer than three candles match or the benchmark never moved.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' excess <- infosys$alpha(nifty, risk_free_rate = 0.065, days = 365)
    #' cat(sprintf("Jensen's alpha: %.2f%% a year\n", excess * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   excess <- share$alpha(
    #'     nifty,
    #'     risk_free_rate = 0.065,
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: alpha %.2f%%\n", symbol, excess * 100))
    #' }
    #' }
    alpha = function(
      benchmark,
      risk_free_rate = 0.0,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$alpha_of(matched, risk_free_rate, periods_per_year)
    },

    #' @description
    #' Calculates the annual volatility of the difference between the returns and the benchmark's.
    #'
    #' A fund that follows an index closely has a tracking error near zero.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric annual tracking error as a fraction, or `NULL` when fewer than three candles match the benchmark's.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty_bees <- ExchangeTradedFund$new(
    #'   exchange = "nse",
    #'   symbol = "NIFTYBEES"
    #' )
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' error <- nifty_bees$tracking_error(nifty, days = 365)
    #' cat(sprintf("Tracking error: %.2f%%\n", error * 100))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   error <- share$tracking_error(nifty, days = 730)
    #'   cat(sprintf("%s: %.2f%%\n", symbol, error * 100))
    #' }
    #' }
    tracking_error = function(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$tracking_error_of(matched, periods_per_year)
    },

    #' @description
    #' Calculates the information ratio: the annual return above the benchmark for each unit of tracking error.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric information ratio, or `NULL` when fewer than three candles match the benchmark's or the returns never differed from it.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' ratio <- infosys$information_ratio(nifty, days = 730)
    #' cat(sprintf("Information ratio: %.2f\n", ratio))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   ratio <- share$information_ratio(nifty, days = 365)
    #'   if (ratio > 0.5) {
    #'     cat(sprintf("%s: %.2f, consistently ahead\n", symbol, ratio))
    #'   } else {
    #'     cat(sprintf("%s: %.2f, not consistently ahead\n", symbol, ratio))
    #'   }
    #' }
    #' }
    information_ratio = function(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$information_ratio_of(matched, periods_per_year)
    },

    #' @description
    #' Calculates how much of the benchmark's rises were captured, on the candles where the benchmark rose.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric ratio of the mean return to the benchmark's mean return on those candles, such as 1.1 for rising ten percent more, or `NULL` when fewer than three candles match or the benchmark never rose.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' ratio <- infosys$up_capture_ratio(nifty, days = 365)
    #' cat(sprintf("Up capture: %.2f\n", ratio))
    #'
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' up_ratio <- tcs$up_capture_ratio(nifty, days = 730)
    #' down_ratio <- tcs$down_capture_ratio(nifty, days = 730)
    #' cat(sprintf("Up capture %.2f, down capture %.2f\n", up_ratio, down_ratio))
    #' if (up_ratio > down_ratio) {
    #'   cat("TCS caught more of the rises than of the falls.\n")
    #' } else {
    #'   cat("TCS caught no more of the rises than of the falls.\n")
    #' }
    #' }
    up_capture_ratio = function(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$capture_ratio_of(matched, rising = TRUE)
    },

    #' @description
    #' Calculates how much of the benchmark's falls were suffered, on the candles where the benchmark fell.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or anything else with a `prices()` method.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric ratio of the mean return to the benchmark's mean return on those candles, where below 1 means falling less than the benchmark, or `NULL` when fewer than three candles match or the benchmark never fell.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' ratio <- infosys$down_capture_ratio(nifty, days = 365)
    #' cat(sprintf("Down capture: %.2f\n", ratio))
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' safest_symbol <- NULL
    #' lowest_ratio <- NULL
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   ratio <- share$down_capture_ratio(
    #'     nifty,
    #'     from_date = "2025-01-01",
    #'     to_date = "2025-12-31"
    #'   )
    #'   cat(sprintf("%s: %.2f\n", symbol, ratio))
    #'   if (is.null(lowest_ratio) || ratio < lowest_ratio) {
    #'     safest_symbol <- symbol
    #'     lowest_ratio <- ratio
    #'   }
    #' }
    #' cat(sprintf("Fell least with the index: %s\n", safest_symbol))
    #' }
    down_capture_ratio = function(
      benchmark,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        return(NULL)
      }
      private$capture_ratio_of(matched, rising = FALSE)
    },

    #' @description
    #' Calculates every measure in this class from one fetch of the candles.
    #' @param benchmark The object to measure against, such as an index instrument or a basket, or `NULL` to leave out the benchmark measures.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction, such as 0.065.
    #' @param confidence The numeric confidence level for the value at risk and expected shortfall, such as 0.95.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A named list from `cumulative_return` to `expected_shortfall` and, when a benchmark is given, `benchmark_beta` to `down_capture_ratio`, where a measure that cannot be calculated is `NULL`; or `NULL` when there are fewer than two candles.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`, or confidence is not between 0 and 1; `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' summary <- infosys$performance_summary(
    #'   risk_free_rate = 0.065,
    #'   days = 365
    #' )
    #' str(summary)
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' summary <- infosys$performance_summary(
    #'   benchmark = nifty,
    #'   risk_free_rate = 0.065,
    #'   confidence = 0.99,
    #'   days = 730
    #' )
    #' str(summary)
    #'
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "RELIANCE"
    #' )
    #' measures <- c(
    #'   "annualised_return",
    #'   "sharpe_ratio",
    #'   "maximum_drawdown",
    #'   "benchmark_beta"
    #' )
    #' table <- data.frame(row.names = measures)
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   summary <- share$performance_summary(
    #'     benchmark = nifty,
    #'     risk_free_rate = 0.065,
    #'     days = 365
    #'   )
    #'   column <- numeric(0)
    #'   for (measure in measures) {
    #'     value <- summary[[measure]]
    #'     if (is.null(value)) {
    #'       value <- NA
    #'     }
    #'     column[[measure]] <- value
    #'   }
    #'   table[[symbol]] <- column
    #' }
    #' print(table)
    #' }
    performance_summary = function(
      benchmark = NULL,
      risk_free_rate = 0.0,
      confidence = 0.95,
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      periods_per_year <- private$periods_per_year(interval)
      private$check_value_at_risk_arguments(
        confidence,
        PERFORMANCE_MEASURES_HISTORICAL_METHOD
      )
      closes <- private$closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes)) {
        return(NULL)
      }
      returns <- private$returns_of(closes)
      summary <- list(
        cumulative_return = private$cumulative_return_of(closes),
        annualised_return = private$annualised_return_of(
          closes,
          periods_per_year
        ),
        annualised_volatility = private$annualised_volatility_of(
          returns,
          periods_per_year
        ),
        sharpe_ratio = private$sharpe_ratio_of(
          returns,
          risk_free_rate,
          periods_per_year
        ),
        sortino_ratio = private$sortino_ratio_of(
          returns,
          risk_free_rate,
          periods_per_year
        ),
        maximum_drawdown = private$maximum_drawdown_of(closes),
        calmar_ratio = private$calmar_ratio_of(closes, periods_per_year),
        value_at_risk = private$value_at_risk_of(
          returns,
          confidence,
          PERFORMANCE_MEASURES_HISTORICAL_METHOD
        ),
        expected_shortfall = private$expected_shortfall_of(
          returns,
          confidence
        )
      )
      if (is.null(benchmark)) {
        return(summary)
      }
      matched <- private$matched_returns(
        benchmark,
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(matched)) {
        benchmark_summary <- list(
          benchmark_beta = NULL,
          alpha = NULL,
          tracking_error = NULL,
          information_ratio = NULL,
          up_capture_ratio = NULL,
          down_capture_ratio = NULL
        )
      } else {
        benchmark_summary <- list(
          benchmark_beta = private$beta_of(matched),
          alpha = private$alpha_of(matched, risk_free_rate, periods_per_year),
          tracking_error = private$tracking_error_of(
            matched,
            periods_per_year
          ),
          information_ratio = private$information_ratio_of(
            matched,
            periods_per_year
          ),
          up_capture_ratio = private$capture_ratio_of(matched, rising = TRUE),
          down_capture_ratio = private$capture_ratio_of(
            matched,
            rising = FALSE
          )
        )
      }
      c(
        summary,
        benchmark_summary
      )
    }
  ),
  private = list(
    #' Counts the candles of an interval in one trading year.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @return The numeric number of candles in 252 trading sessions of 375 minutes each.
    #' @details Errors: signals `ValueError` when the interval is neither `day` nor a minute interval such as `5minute`.
    periods_per_year = function(interval) {
      if (identical(interval, PERFORMANCE_MEASURES_DAY_INTERVAL)) {
        return(PERFORMANCE_MEASURES_TRADING_DAYS_PER_YEAR)
      }
      is_minute_interval <- is.character(interval) &&
        length(interval) == 1 &&
        grepl(PERFORMANCE_MEASURES_MINUTE_INTERVAL_PATTERN, interval)
      if (!is_minute_interval) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "Cannot annualise candles of this interval: interval='%s'",
            format(interval)
          )
        )
      }
      minutes <- as.numeric(
        sub(PERFORMANCE_MEASURES_MINUTE_INTERVAL_PATTERN, "\\1", interval)
      )
      PERFORMANCE_MEASURES_TRADING_DAYS_PER_YEAR *
        PERFORMANCE_MEASURES_TRADING_MINUTES_PER_DAY /
        minutes
    },

    #' Checks a confidence level and a value at risk method.
    #' @param confidence The numeric confidence level, which must lie strictly between 0 and 1.
    #' @param method The character method, which must be `"historical"` or `"parametric"`.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when the confidence or the method is not valid.
    check_value_at_risk_arguments = function(confidence, method) {
      if (!(confidence > 0 && confidence < 1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "Not a confidence level between 0 and 1: confidence=%s",
            format(confidence)
          )
        )
      }
      methods <- c(
        PERFORMANCE_MEASURES_HISTORICAL_METHOD,
        PERFORMANCE_MEASURES_PARAMETRIC_METHOD
      )
      if (!(method %in% methods)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("Not a value at risk method: method='%s'", method)
        )
      }
      invisible(NULL)
    },

    #' Fetches the closing prices for a range.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param days The integer number of days to count back from today, or `NULL`.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A numeric vector of closes in time order without missing values, or `NULL` when there are fewer than two.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    closes = function(interval, from_date, to_date, days, adjusted) {
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
      closes <- as.numeric(prices$close)
      closes <- closes[!is.na(closes)]
      if (length(closes) < 2) {
        return(NULL)
      }
      closes
    },

    #' Works out the fractional change from each close to the next.
    #' @param closes A numeric vector of at least two closes in time order.
    #' @return A numeric vector one shorter than `closes`.
    returns_of = function(closes) {
      count <- length(closes)
      closes[-1] / closes[-count] - 1
    },

    #' Fetches the returns and a benchmark's returns on the candles both have.
    #' @param benchmark The object with a `prices()` method to match against.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param days The integer number of days to count back from today, or `NULL`.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with numeric `returns` and `benchmark_returns` columns, one row per matched candle after the first, or `NULL` when fewer than three candles match.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached.
    matched_returns = function(
      benchmark,
      interval,
      from_date,
      to_date,
      days,
      adjusted
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
      own_closes <- data.frame(
        datetime = prices$datetime,
        close = as.numeric(prices$close)
      )
      benchmark_closes <- data.frame(
        datetime = benchmark_prices$datetime,
        benchmark_close = as.numeric(benchmark_prices$close)
      )
      matched <- merge(own_closes, benchmark_closes, by = "datetime")
      matched <- matched[order(matched$datetime), ]
      matched <- matched[stats::complete.cases(matched), ]
      if (nrow(matched) < 3) {
        return(NULL)
      }
      returns <- data.frame(
        returns = private$returns_of(matched$close),
        benchmark_returns = private$returns_of(matched$benchmark_close)
      )
      returns <- returns[stats::complete.cases(returns), ]
      rownames(returns) <- NULL
      returns
    },

    #' Works out the highest value so far at each position, leaving a missing value missing without letting it hide later peaks.
    #' @param values A numeric vector that may hold `NA` values.
    #' @return A numeric vector as long as `values`.
    running_peak_of = function(values) {
      peaks <- rep(NA_real_, length(values))
      peak <- NA_real_
      for (index in seq_along(values)) {
        value <- values[[index]]
        if (is.na(value)) {
          next
        }
        if (is.na(peak) || value > peak) {
          peak <- value
        }
        peaks[[index]] <- peak
      }
      peaks
    },

    #' Calculates the growth from the first close to the last.
    #' @param closes A numeric vector of at least two closes in time order.
    #' @return The numeric fractional growth.
    cumulative_return_of = function(closes) {
      closes[[length(closes)]] / closes[[1]] - 1
    },

    #' Calculates the compound annual growth rate of a run of closes.
    #' @param closes A numeric vector of at least two closes in time order.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric annual growth rate, or `NULL` when the first or last close is not above zero.
    annualised_return_of = function(closes, periods_per_year) {
      first_close <- closes[[1]]
      last_close <- closes[[length(closes)]]
      if (first_close <= 0 || last_close <= 0) {
        return(NULL)
      }
      growth <- last_close / first_close
      years <- (length(closes) - 1) / periods_per_year
      growth^(1 / years) - 1
    },

    #' Scales the standard deviation of returns to a year.
    #' @param returns A numeric vector of returns.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric annual volatility, or `NULL` when there are fewer than two returns.
    annualised_volatility_of = function(returns, periods_per_year) {
      if (length(returns) < 2) {
        return(NULL)
      }
      stats::sd(returns) * sqrt(periods_per_year)
    },

    #' Calculates the Sharpe ratio of a run of returns.
    #' @param returns A numeric vector of returns.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric Sharpe ratio, or `NULL` when there are fewer than two returns or they never varied.
    sharpe_ratio_of = function(returns, risk_free_rate, periods_per_year) {
      if (length(returns) < 2) {
        return(NULL)
      }
      volatility <- stats::sd(returns) * sqrt(periods_per_year)
      if (volatility == 0) {
        return(NULL)
      }
      annual_return <- mean(returns) * periods_per_year
      (annual_return - risk_free_rate) / volatility
    },

    #' Calculates the Sortino ratio of a run of returns.
    #' @param returns A numeric vector of returns.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric Sortino ratio, or `NULL` when there are fewer than two returns or none fell short of the risk-free rate.
    sortino_ratio_of = function(returns, risk_free_rate, periods_per_year) {
      if (length(returns) < 2) {
        return(NULL)
      }
      risk_free_per_period <- risk_free_rate / periods_per_year
      shortfalls <- pmin(returns - risk_free_per_period, 0)
      downside_deviation <- sqrt(mean(shortfalls^2)) * sqrt(periods_per_year)
      if (downside_deviation == 0) {
        return(NULL)
      }
      annual_return <- mean(returns) * periods_per_year
      (annual_return - risk_free_rate) / downside_deviation
    },

    #' Finds the worst fall of a run of closes from an earlier peak.
    #' @param closes A numeric vector of closes in time order.
    #' @return The numeric worst drawdown as a negative fraction, or zero when the closes never fell.
    maximum_drawdown_of = function(closes) {
      drawdown <- closes / cummax(closes) - 1
      min(drawdown)
    },

    #' Calculates the Calmar ratio of a run of closes.
    #' @param closes A numeric vector of at least two closes in time order.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric Calmar ratio, or `NULL` when the closes never fell or the growth rate cannot be calculated.
    calmar_ratio_of = function(closes, periods_per_year) {
      worst <- private$maximum_drawdown_of(closes)
      if (worst == 0) {
        return(NULL)
      }
      annual_return <- private$annualised_return_of(closes, periods_per_year)
      if (is.null(annual_return)) {
        return(NULL)
      }
      annual_return / abs(worst)
    },

    #' Estimates the one-candle value at risk of a run of returns.
    #' @param returns A numeric vector of returns.
    #' @param confidence The numeric confidence level between 0 and 1.
    #' @param method The character method, `"historical"` or `"parametric"`.
    #' @return The numeric loss as a positive fraction, or `NULL` when there are fewer than two returns.
    value_at_risk_of = function(returns, confidence, method) {
      if (length(returns) < 2) {
        return(NULL)
      }
      if (identical(method, PERFORMANCE_MEASURES_HISTORICAL_METHOD)) {
        quantile <- stats::quantile(
          returns,
          probs = 1 - confidence,
          names = FALSE,
          type = 7
        )
        return(-quantile)
      }
      standard_score <- stats::qnorm(1 - confidence)
      -(mean(returns) + standard_score * stats::sd(returns))
    },

    #' Calculates the average loss beyond the historical value at risk of a run of returns.
    #' @param returns A numeric vector of returns.
    #' @param confidence The numeric confidence level between 0 and 1.
    #' @return The numeric average loss as a positive fraction, or `NULL` when there are fewer than two returns.
    expected_shortfall_of = function(returns, confidence) {
      value_at_risk <- private$value_at_risk_of(
        returns,
        confidence,
        PERFORMANCE_MEASURES_HISTORICAL_METHOD
      )
      if (is.null(value_at_risk)) {
        return(NULL)
      }
      tail <- returns[returns <= -value_at_risk]
      -mean(tail)
    },

    #' Calculates the regression beta of matched returns.
    #' @param matched A `data.frame` with numeric `returns` and `benchmark_returns` columns.
    #' @return The numeric beta, or `NULL` when the benchmark's returns never varied.
    beta_of = function(matched) {
      benchmark_variance <- stats::var(matched$benchmark_returns)
      if (benchmark_variance == 0) {
        return(NULL)
      }
      covariance <- stats::cov(matched$returns, matched$benchmark_returns)
      covariance / benchmark_variance
    },

    #' Calculates Jensen's alpha of matched returns.
    #' @param matched A `data.frame` with numeric `returns` and `benchmark_returns` columns.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric annual alpha, or `NULL` when the benchmark's returns never varied.
    alpha_of = function(matched, risk_free_rate, periods_per_year) {
      beta <- private$beta_of(matched)
      if (is.null(beta)) {
        return(NULL)
      }
      annual_return <- mean(matched$returns) * periods_per_year
      benchmark_annual_return <- mean(matched$benchmark_returns) *
        periods_per_year
      expected <- risk_free_rate +
        beta * (benchmark_annual_return - risk_free_rate)
      annual_return - expected
    },

    #' Calculates the annual tracking error of matched returns.
    #' @param matched A `data.frame` with numeric `returns` and `benchmark_returns` columns.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric annual tracking error.
    tracking_error_of = function(matched, periods_per_year) {
      difference <- matched$returns - matched$benchmark_returns
      stats::sd(difference) * sqrt(periods_per_year)
    },

    #' Calculates the information ratio of matched returns.
    #' @param matched A `data.frame` with numeric `returns` and `benchmark_returns` columns.
    #' @param periods_per_year The numeric number of candles in a trading year.
    #' @return The numeric information ratio, or `NULL` when the returns never differed from the benchmark's.
    information_ratio_of = function(matched, periods_per_year) {
      tracking_error <- private$tracking_error_of(matched, periods_per_year)
      if (tracking_error == 0) {
        return(NULL)
      }
      difference <- matched$returns - matched$benchmark_returns
      mean(difference) * periods_per_year / tracking_error
    },

    #' Calculates the up or down capture ratio of matched returns.
    #' @param matched A `data.frame` with numeric `returns` and `benchmark_returns` columns.
    #' @param rising A logical that is `TRUE` for the candles where the benchmark rose and `FALSE` for those where it fell.
    #' @return The numeric capture ratio, or `NULL` when the benchmark had no such candle.
    capture_ratio_of = function(matched, rising) {
      if (rising) {
        chosen <- matched[matched$benchmark_returns > 0, ]
      } else {
        chosen <- matched[matched$benchmark_returns < 0, ]
      }
      if (nrow(chosen) == 0) {
        return(NULL)
      }
      benchmark_mean <- mean(chosen$benchmark_returns)
      mean(chosen$returns) / benchmark_mean
    }
  )
)
