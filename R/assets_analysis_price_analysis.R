#' A source of candles that analysis methods can be written against
#'
#' @description
#' The root of the chain of analysis classes. Each analysis class inherits the one before it, ending with `PerformanceMeasures`, which `Instrument` and `AssetBasket` inherit, and every analysis method calls `prices()` to fetch the candles it works on. This class only declares `prices()`; the instrument or basket that inherits the chain supplies the real one.
#'
#' The chain, from this root to the last link, is `PriceAnalysis`, `PriceStatistics`, `OverlapStudies`, `MomentumIndicators`, `VolumeIndicators`, `CycleIndicators`, `PriceTransforms`, `VolatilityIndicators`, `StatisticFunctions`, `MathTransforms`, `MathOperators`, `CandlestickPatterns`, `Signals`, `StrategyBacktests` and `PerformanceMeasures`.
#'
#' @examples
#' \dontrun{
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' candles <- infosys$prices(days = 30)
#' tail(candles[, c("datetime", "open", "high", "low", "close")])
#'
#' tryCatch(
#'   PriceAnalysis$new()$prices(days = 30),
#'   error = function(error) conditionMessage(error)
#' )
#' }
#' @export
PriceAnalysis <- R6::R6Class(
  "PriceAnalysis",
  public = list(
    #' @description
    #' Fetches candles for a range, which a subclass must provide.
    #' @param interval A character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days An integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` of candles with `exchange`, `segment`, `interval`, `datetime`, `open`, `high`, `low`, `close`, `volume` and `oi` columns, or `NULL` when there are no candles.
    #' @details Errors: always signals a plain error, because only a subclass knows where candles come from.
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      stop(
        sprintf(
          "%s must define prices to use PriceAnalysis",
          class(self)[[1]]
        ),
        call. = FALSE
      )
    }
  )
)
