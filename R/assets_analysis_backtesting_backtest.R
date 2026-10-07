#' One backtest of a strategy over a table of candles
#'
#' @description
#' The R counterpart of `backtesting.Backtest` from the Python `backtesting` package (version 0.6.5), kept to the features `StrategyBacktests$run_backtest()` uses: starting cash, a commission as a fraction of each fill, margin, filling market orders at the close, hedging and exclusive orders. The bid-ask spread, commission functions, strategy parameters, `finalize_trades` and optimisation are left out.
#'
#' `run()` creates the strategy, calls its `initialize_strategy()`, then walks the candles from the first one on which every indicator has a value, plus one. On each candle the broker first fills the waiting orders and records the equity, and then the strategy's `next_candle()` decides what to do. Trades still open after the last candle are not closed, so they count in the equity but not in the trade statistics, as in backtesting.py.
#'
#' @examples
#' \dontrun{
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
#' prices <- nifty$prices(days = 365)
#' candles <- data.frame(
#'   datetime = prices$datetime,
#'   Open = prices$open,
#'   High = prices$high,
#'   Low = prices$low,
#'   Close = prices$close,
#'   Volume = prices$volume
#' )
#' backtest <- Backtest$new(candles, BuyAndHold, cash = 10000000)
#' statistics <- backtest$run()
#' statistics[["Return [%]"]]
#' backtest$plot(results = statistics, filename = file.path(tempdir(), "nifty.html"))
#' }
#' @export
Backtest <- R6::R6Class(
  "Backtest",
  public = list(
    #' @field candles The `data.frame` of candles with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns, oldest first.
    candles = NULL,

    #' @field strategy The R6 class generator of the strategy, a subclass of `BacktestStrategy`.
    strategy = NULL,

    #' @field cash The numeric starting cash.
    cash = NULL,

    #' @field commission The numeric commission as a fraction of each fill's value.
    commission = NULL,

    #' @field margin The numeric margin as a fraction, where 1 means no leverage.
    margin = NULL,

    #' @field trade_on_close A logical that is `TRUE` to fill market orders at the current candle's close.
    trade_on_close = NULL,

    #' @field hedging A logical that is `TRUE` to allow long and short trades at the same time.
    hedging = NULL,

    #' @field exclusive_orders A logical that is `TRUE` to close the open trades whenever a new order is placed.
    exclusive_orders = NULL,

    #' @field results The named list of statistics from the latest `run()`, or `NULL` before the first run.
    results = NULL,

    #' @description
    #' Checks the candles and the strategy and stores the settings.
    #' @param data A `data.frame` with `datetime`, `Open`, `High`, `Low` and `Close` columns, and optionally `Volume`.
    #' @param strategy The R6 class generator of a strategy that inherits `BacktestStrategy`.
    #' @param cash The numeric starting cash.
    #' @param commission The numeric commission charged on each fill, as a fraction of its value.
    #' @param margin The numeric margin required, as a fraction, where 1.0 means no leverage.
    #' @param trade_on_close A logical that is `TRUE` to fill market orders at the current candle's close rather than the next candle's open.
    #' @param hedging A logical that is `TRUE` to allow long and short trades at the same time.
    #' @param exclusive_orders A logical that is `TRUE` to close the open trade whenever a new order is placed.
    #' @return A new `Backtest` object.
    #' @details Errors: signals `TypeError` when `strategy` is not a class generator inheriting `BacktestStrategy` or `data` is not a `data.frame`; `ValueError` when `data` is empty, lacks a column or has a missing price. Warns when a close is above the starting cash or the candles were not in time order.
    initialize = function(
      data,
      strategy,
      cash = 10000,
      commission = 0.0,
      margin = 1.0,
      trade_on_close = FALSE,
      hedging = FALSE,
      exclusive_orders = FALSE
    ) {
      private$check_strategy(strategy)
      self$candles <- private$checked_candles(data, cash)
      self$strategy <- strategy
      self$cash <- cash
      self$commission <- commission
      self$margin <- margin
      self$trade_on_close <- trade_on_close
      self$hedging <- hedging
      self$exclusive_orders <- exclusive_orders
    },

    #' @description
    #' Runs the strategy over the candles.
    #' @return A named list of statistics, as `BacktestStatistics$compute()` describes, from `Start` to `Kelly Criterion` followed by `_strategy`, `_equity_curve` and `_trades`.
    #' @details Errors: signals `ValueError` when the cash, commission or margin is outside its allowed range, and passes on any error the strategy signals. Warns when trades remain open at the end.
    run = function() {
      broker <- BacktestBroker$new(
        candles = self$candles,
        cash = self$cash,
        commission = self$commission,
        margin = self$margin,
        trade_on_close = self$trade_on_close,
        hedging = self$hedging,
        exclusive_orders = self$exclusive_orders
      )
      strategy <- self$strategy$new(broker)
      strategy$initialize_strategy()
      candle_count <- nrow(self$candles)
      start <- strategy$warmup_candles() + 2
      out_of_money <- FALSE
      bar <- start
      while (bar <= candle_count) {
        out_of_money <- broker$next_bar(bar)
        if (out_of_money) {
          break
        }
        strategy$next_candle()
        bar <- bar + 1
      }
      if (!out_of_money && length(broker$trades) > 0) {
        warning(
          "Some trades remain open at the end of the backtest. They count in the equity but not in the trade statistics.",
          call. = FALSE
        )
      }
      broker$current_bar <- candle_count
      equity <- private$filled_equity(broker$equity_curve, broker$cash)
      statistics <- BacktestStatistics$new(
        trades = broker$closed_trades,
        equity = equity,
        candles = self$candles,
        strategy = strategy,
        risk_free_rate = 0
      )
      self$results <- statistics$compute()
      self$results
    },

    #' @description
    #' Writes a standalone HTML page with the price, the trades, the equity curve and the statistics of a run.
    #' @param results The named list of statistics from `run()`, or `NULL` to use the latest run, running the backtest first when there is none.
    #' @param filename The character path of the HTML file to write.
    #' @return The character `filename`, invisibly.
    #' @details Errors: signals `ValueError` when `filename` is `NULL`.
    plot = function(results = NULL, filename = NULL) {
      if (is.null(filename)) {
        ErrorCatalogue$raise("ValueError", "plot needs a filename to write to")
      }
      if (is.null(results)) {
        results <- self$results
      }
      if (is.null(results)) {
        results <- self$run()
      }
      BacktestPlot$new(self$candles, results)$write(filename)
      invisible(filename)
    }
  ),
  private = list(
    # Checks that a strategy is a class generator inheriting `BacktestStrategy`.
    # @param strategy The value given as the strategy.
    # @return `NULL`, invisibly.
    # @details Errors: signals `TypeError` when it is not.
    check_strategy = function(strategy) {
      generator <- NULL
      if (inherits(strategy, "R6ClassGenerator")) {
        generator <- strategy
      }
      while (!is.null(generator)) {
        if (identical(generator$classname, "BacktestStrategy")) {
          return(invisible(NULL))
        }
        generator <- generator$get_inherit()
      }
      ErrorCatalogue$raise(
        "TypeError",
        "`strategy` must be a BacktestStrategy sub-type"
      )
    },

    # Checks the candles and puts them in time order.
    # @param data The `data.frame` of candles.
    # @param cash The numeric starting cash, for the warning about prices above it.
    # @return The `data.frame` with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns, sorted by `datetime`.
    # @details Errors: signals `TypeError` when `data` is not a `data.frame`; `ValueError` when it is empty, lacks a column or has a missing price.
    checked_candles = function(data, cash) {
      if (!is.data.frame(data)) {
        ErrorCatalogue$raise(
          "TypeError",
          "`data` must be a data.frame with columns"
        )
      }
      if (!("Volume" %in% names(data))) {
        data$Volume <- rep(NA_real_, nrow(data))
      }
      if (nrow(data) == 0) {
        ErrorCatalogue$raise("ValueError", "OHLC `data` is empty")
      }
      columns <- c(
        "datetime",
        "Open",
        "High",
        "Low",
        "Close",
        "Volume"
      )
      if (!all(columns %in% names(data))) {
        ErrorCatalogue$raise(
          "ValueError",
          "`data` must be a data.frame with columns 'datetime', 'Open', 'High', 'Low', 'Close', and (optionally) 'Volume'"
        )
      }
      candles <- data[, columns]
      prices <- candles[, c(
        "Open",
        "High",
        "Low",
        "Close"
      )]
      if (anyNA(prices)) {
        ErrorCatalogue$raise(
          "ValueError",
          "Some OHLC values are missing (NA). Please strip those rows or fill them in."
        )
      }
      if (any(candles$Close > cash)) {
        warning(
          "Some prices are larger than initial cash value. Note that fractional trading is not supported by this class.",
          call. = FALSE
        )
      }
      if (is.unsorted(candles$datetime)) {
        warning(
          "Data index is not sorted in ascending order. Sorting.",
          call. = FALSE
        )
        candles <- candles[order(candles$datetime), ]
      }
      rownames(candles) <- NULL
      candles
    },

    # Fills the equity of the candles before the strategy started with the first recorded equity, and any candle without one with the final cash.
    # @param equity_curve A numeric vector with `NA` for candles without a recorded equity.
    # @param cash The numeric cash at the end of the run.
    # @return A numeric vector without missing values.
    filled_equity = function(equity_curve, cash) {
      filled <- equity_curve
      next_value <- NA_real_
      for (index in rev(seq_along(filled))) {
        if (is.na(filled[[index]])) {
          filled[[index]] <- next_value
        } else {
          next_value <- filled[[index]]
        }
      }
      filled[is.na(filled)] <- cash
      filled
    }
  )
)
