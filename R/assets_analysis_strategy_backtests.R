#' Backtests of trading strategies over an instrument's candles
#'
#' @description
#' A link in the chain of analysis classes, inherited in the end by `Instrument`, which supplies `prices()`. Its one method, `run_backtest()`, runs a strategy written as a subclass of `BacktestStrategy` through the package's own backtesting engine, `Backtest`, which follows the rules of the Python `backtesting` package (version 0.6.5) that the Python library uses.
#'
#' @examples
#' \dontrun{
#' SmaCross <- R6::R6Class(
#'   "SmaCross",
#'   inherit = BacktestStrategy,
#'   public = list(
#'     initialize_strategy = function() {
#'       self$indicator("fast", talib::SMA(self$data$Close, timePeriod = 10))
#'       self$indicator("slow", talib::SMA(self$data$Close, timePeriod = 30))
#'     },
#'     next_candle = function() {
#'       if (self$crossover(self$indicators$fast, self$indicators$slow)) {
#'         self$buy()
#'       }
#'     }
#'   )
#' )
#' infosys <- Instrument$new(exchange = "nse", segment = "equities", symbol = "INFY")
#' statistics <- infosys$run_backtest(
#'   SmaCross,
#'   cash = 100000,
#'   days = 730,
#'   plot_filename = "sma_cross.html"
#' )
#' }
#' @export
StrategyBacktests <- R6::R6Class(
  "StrategyBacktests",
  inherit = Signals,
  public = list(
    #' @description
    #' Runs a strategy over the candles in a range, optionally saving a plot of the result.
    #' @param strategy The R6 class generator of the strategy to run, a subclass of `BacktestStrategy`.
    #' @param cash The numeric starting cash.
    #' @param commission The numeric commission charged on each trade, as a fraction of its value.
    #' @param margin The numeric margin required, as a fraction, where 1.0 means no leverage.
    #' @param trade_on_close A logical that is `TRUE` to fill market orders at the current candle's close rather than the next candle's open.
    #' @param hedging A logical that is `TRUE` to allow long and short trades at the same time.
    #' @param exclusive_orders A logical that is `TRUE` to close the open trade whenever a new order is placed.
    #' @param plot_filename The character path of an HTML file to write the plot to, or `NULL` to skip the plot. The file is not opened. The plot is a plain HTML page of line charts and tables rather than backtesting.py's interactive Bokeh chart.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A named list of the backtest's statistics, with the same names and order as the pandas Series backtesting.py returns, such as `"Return [%]"`, `"Sharpe Ratio"` and `"# Trades"`, plus `"_strategy"`, `"_equity_curve"` and `"_trades"`; or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the request or could not be reached; `TypeError` when `strategy` does not inherit `BacktestStrategy`; `ValueError` when the cash, commission or margin is outside its allowed range.
    #' @examples
    #' \dontrun{
    #' MovingAverageCross <- R6::R6Class(
    #'   "MovingAverageCross",
    #'   inherit = BacktestStrategy,
    #'   public = list(
    #'     initialize_strategy = function() {
    #'       self$indicator(
    #'         "fast_average",
    #'         talib::SMA(self$data$Close, timePeriod = 10)
    #'       )
    #'       self$indicator(
    #'         "slow_average",
    #'         talib::SMA(self$data$Close, timePeriod = 30)
    #'       )
    #'     },
    #'     next_candle = function() {
    #'       fast <- self$indicators$fast_average
    #'       slow <- self$indicators$slow_average
    #'       if (self$crossover(fast, slow)) {
    #'         self$position$close()
    #'         self$buy()
    #'       } else if (self$crossover(slow, fast)) {
    #'         self$position$close()
    #'         self$sell()
    #'       }
    #'     }
    #'   )
    #' )
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' statistics <- infosys$run_backtest(
    #'   MovingAverageCross,
    #'   cash = 100000,
    #'   days = 730
    #' )
    #' return_percent <- statistics[["Return [%]"]]
    #' trade_count <- statistics[["# Trades"]]
    #' cat(sprintf("Return: %.2f%% from %d trades\n", return_percent, trade_count))
    #'
    #' BuyAndHold <- R6::R6Class(
    #'   "BuyAndHold",
    #'   inherit = BacktestStrategy,
    #'   public = list(
    #'     initialize_strategy = function() {
    #'       invisible(NULL)
    #'     },
    #'     next_candle = function() {
    #'       if (self$position$size == 0) {
    #'         self$buy()
    #'       }
    #'     }
    #'   )
    #' )
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' commissions <- c(
    #'   0.0,
    #'   0.001
    #' )
    #' for (commission in commissions) {
    #'   statistics <- nifty$run_backtest(
    #'     BuyAndHold,
    #'     cash = 10000000,
    #'     commission = commission,
    #'     days = 365
    #'   )
    #'   final_equity <- statistics[["Equity Final [$]"]]
    #'   cat(
    #'     sprintf(
    #'       "Commission %s: ends at %s\n",
    #'       commission,
    #'       format(round(final_equity, 2), big.mark = ",", nsmall = 2)
    #'     )
    #'   )
    #' }
    #'
    #' RelativeStrengthReversal <- R6::R6Class(
    #'   "RelativeStrengthReversal",
    #'   inherit = BacktestStrategy,
    #'   public = list(
    #'     initialize_strategy = function() {
    #'       self$indicator(
    #'         "strength",
    #'         talib::RSI(self$data$Close, timePeriod = 14)
    #'       )
    #'     },
    #'     next_candle = function() {
    #'       strength <- tail(self$indicators$strength, 1)
    #'       if (strength < 30 && self$position$size == 0) {
    #'         self$buy()
    #'       } else if (strength > 70 && self$position$size != 0) {
    #'         self$position$close()
    #'       }
    #'     }
    #'   )
    #' )
    #' plot_path <- file.path(tempdir(), "tcs_rsi_backtest.html")
    #' tcs <- Equity$new(exchange = "nse", symbol = "TCS")
    #' statistics <- tcs$run_backtest(
    #'   RelativeStrengthReversal,
    #'   cash = 100000,
    #'   from_date = "2025-01-01",
    #'   to_date = "2025-12-31",
    #'   plot_filename = plot_path
    #' )
    #' measures <- c(
    #'   "Return [%]",
    #'   "Win Rate [%]",
    #'   "Max. Drawdown [%]"
    #' )
    #' str(statistics[measures])
    #' cat(sprintf("Plot written: %s\n", file.exists(plot_path)))
    #' }
    run_backtest = function(
      strategy,
      cash = 10000,
      commission = 0.0,
      margin = 1.0,
      trade_on_close = FALSE,
      hedging = FALSE,
      exclusive_orders = FALSE,
      plot_filename = NULL,
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
      candles <- data.frame(
        datetime = prices$datetime,
        Open = as.numeric(prices$open),
        High = as.numeric(prices$high),
        Low = as.numeric(prices$low),
        Close = as.numeric(prices$close),
        Volume = as.numeric(prices$volume)
      )
      backtest <- Backtest$new(
        data = candles,
        strategy = strategy,
        cash = cash,
        commission = commission,
        margin = margin,
        trade_on_close = trade_on_close,
        hedging = hedging,
        exclusive_orders = exclusive_orders
      )
      statistics <- backtest$run()
      if (!is.null(plot_filename)) {
        backtest$plot(results = statistics, filename = plot_filename)
      }
      statistics
    }
  )
)
