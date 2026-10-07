#' The default order size, all of the available margin, which is the largest fraction below 1
#' @keywords internal
BACKTESTING_FULL_EQUITY <- 1 - .Machine$double.eps

#' A trading strategy to run through a backtest
#'
#' @description
#' The R counterpart of `backtesting.Strategy` from the Python `backtesting` package (version 0.6.5). Write a strategy as an R6 class that inherits `BacktestStrategy` and defines two methods:
#'
#' - `initialize_strategy()`, Python's `init()`, runs once before the first candle. It declares indicators with `self$indicator(name, values)`, where `values` is a numeric vector with one value per candle, such as `talib::SMA(self$data$Close, timePeriod = 10)`.
#' - `next_candle()`, Python's `next()`, runs once for each candle. It reads `self$data` and `self$indicators`, which reveal only the candles up to the current one, and places orders with `self$buy()` and `self$sell()` or closes them with `self$position$close()`.
#'
#' The methods were renamed because `next` is a reserved word in R and `initialize` is the R6 constructor.
#'
#' Python strategies store an indicator in an attribute, as in `self.fast_average = self.I(...)`. An R6 object cannot gain fields after it is created, so the R strategy names each indicator instead and reads it back as `self$indicators$fast_average`.
#'
#' The backtest starts on the first candle at which every indicator has a value, plus one, exactly as backtesting.py does, so a 30-candle moving average delays the first `next_candle()` call to candle 31.
#'
#' Python's `backtesting.lib.crossover(series1, series2)` is the method `self$crossover(series1, series2)`.
#'
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
#' statistics <- infosys$run_backtest(MovingAverageCross, cash = 100000, days = 730)
#' }
#' @export
BacktestStrategy <- R6::R6Class(
  "BacktestStrategy",
  public = list(
    #' @description
    #' Creates the strategy for one run; `Backtest$run()` does this, so a strategy class rarely needs its own `initialize()`.
    #' @param broker The `BacktestBroker` of the run.
    #' @return A new strategy object.
    initialize = function(broker) {
      private$broker <- broker
      private$indicator_values <- list()
    },

    #' @description
    #' Declares indicators and does any other work needed before the first candle. A strategy class must define it, even as an empty method.
    #' @return Ignored.
    #' @details Errors: always signals a plain error, because only a subclass knows its indicators.
    initialize_strategy = function() {
      stop(
        sprintf(
          "%s must define initialize_strategy to be backtested",
          class(self)[[1]]
        ),
        call. = FALSE
      )
    },

    #' @description
    #' Makes the trading decision for the current candle. A strategy class must define it.
    #' @return Ignored.
    #' @details Errors: always signals a plain error, because only a subclass knows its rules.
    next_candle = function() {
      stop(
        sprintf(
          "%s must define next_candle to be backtested",
          class(self)[[1]]
        ),
        call. = FALSE
      )
    },

    #' @description
    #' Declares an indicator, the R counterpart of Python's `Strategy.I()`. Call it from `initialize_strategy()`.
    #' @param name A character name to read the indicator back by, as `self$indicators[[name]]`.
    #' @param values A numeric vector with one value per candle, `NA` where the indicator is still warming up.
    #' @return The numeric `values`, invisibly.
    #' @details Errors: signals `ValueError` when `values` is not as long as the candles.
    indicator = function(name, values) {
      values <- as.numeric(values)
      candle_count <- nrow(private$broker$candles)
      if (length(values) != candle_count) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "Indicators must be as long as the candles: %d candles, indicator \"%s\" has %d values",
            candle_count,
            name,
            length(values)
          )
        )
      }
      private$indicator_values[[name]] <- values
      invisible(values)
    },

    #' @description
    #' Gives the number of candles before every indicator has a value, which delays the start of the backtest.
    #' @return The integer number of leading candles in which some indicator is still `NA`, or 0 when there are no indicators.
    warmup_candles = function() {
      warmup <- 0
      for (values in private$indicator_values) {
        first_value <- which(!is.na(values))
        if (length(first_value) == 0) {
          next
        }
        warmup <- max(warmup, first_value[[1]] - 1)
      }
      warmup
    },

    #' @description
    #' Gives every indicator with all its values, not only those up to the current candle, for the statistics and the trade list.
    #' @return A named list of numeric vectors.
    all_indicators = function() {
      private$indicator_values
    },

    #' @description
    #' Places a buy order. Without `limit` or `stop` it is a market order, filled at the next candle's open, or at the current close when the backtest runs with `trade_on_close = TRUE`.
    #' @param size The numeric size: a fraction between 0 and 1 of the available margin, or a whole number of units of at least 1. The default is all the available margin.
    #' @param limit The numeric limit price, or `NULL`.
    #' @param stop The numeric stop price, or `NULL`.
    #' @param sl The numeric stop-loss price for the trade, or `NULL`.
    #' @param tp The numeric take-profit price for the trade, or `NULL`.
    #' @param tag Any value to recognise the order and its trade by, or `NULL`.
    #' @return The new `BacktestOrder`.
    #' @details Errors: signals `ValueError` when `size` is neither a fraction between 0 and 1 nor a whole number of at least 1, or the stop-loss, price and take-profit are not in rising order.
    buy = function(
      size = BACKTESTING_FULL_EQUITY,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL
    ) {
      private$check_size(size)
      private$broker$new_order(size, limit, stop, sl, tp, tag)
    },

    #' @description
    #' Places a sell order, which opens a short trade or, without hedging, closes long trades first. Use `self$position$close()` to close a long position without going short.
    #' @param size The numeric size: a fraction between 0 and 1 of the available margin, or a whole number of units of at least 1. The default is all the available margin.
    #' @param limit The numeric limit price, or `NULL`.
    #' @param stop The numeric stop price, or `NULL`.
    #' @param sl The numeric stop-loss price for the trade, or `NULL`.
    #' @param tp The numeric take-profit price for the trade, or `NULL`.
    #' @param tag Any value to recognise the order and its trade by, or `NULL`.
    #' @return The new `BacktestOrder`.
    #' @details Errors: signals `ValueError` when `size` is neither a fraction between 0 and 1 nor a whole number of at least 1, or the take-profit, price and stop-loss are not in rising order.
    sell = function(
      size = BACKTESTING_FULL_EQUITY,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL
    ) {
      private$check_size(size)
      private$broker$new_order(-size, limit, stop, sl, tp, tag)
    },

    #' @description
    #' Tells whether the first series has just crossed above the second, the R counterpart of `backtesting.lib.crossover`.
    #' @param series1 A numeric vector, or one number standing for a flat line.
    #' @param series2 A numeric vector, or one number standing for a flat line.
    #' @return A logical that is `TRUE` when `series1` was below `series2` on the previous value and is above it on the latest, and `FALSE` otherwise, including when either series has fewer than two values or a missing value.
    crossover = function(series1, series2) {
      if (length(series1) == 1) {
        series1 <- c(
          series1,
          series1
        )
      }
      if (length(series2) == 1) {
        series2 <- c(
          series2,
          series2
        )
      }
      if (length(series1) < 2 || length(series2) < 2) {
        return(FALSE)
      }
      previous1 <- series1[[length(series1) - 1]]
      latest1 <- series1[[length(series1)]]
      previous2 <- series2[[length(series2) - 1]]
      latest2 <- series2[[length(series2)]]
      crossed <- previous1 < previous2 && latest1 > latest2
      isTRUE(crossed)
    },

    #' @description
    #' Describes the strategy by its class name, as Python's `str` does.
    #' @param ... Ignored; present for compatibility with `format()`.
    #' @return A character value such as `"MovingAverageCross"`.
    format = function(...) {
      class(self)[[1]]
    },

    #' @description
    #' Prints the strategy's class name.
    #' @param ... Ignored; present for compatibility with `print()`.
    #' @return The strategy, invisibly.
    print = function(...) {
      cat(sprintf("<Strategy %s>\n", self$format()))
      invisible(self)
    }
  ),
  active = list(
    #' @field data A `data.frame` of the candles up to and including the current one, with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns; inside `initialize_strategy()` it holds every candle.
    data = function(value) {
      if (!missing(value)) {
        stop("data is read-only", call. = FALSE)
      }
      candles <- private$broker$candles
      current_bar <- private$broker$current_bar
      if (current_bar >= nrow(candles)) {
        return(candles)
      }
      candles[seq_len(current_bar), , drop = FALSE]
    },

    #' @field indicators A named list of the declared indicators, each a numeric vector cut off at the current candle.
    indicators = function(value) {
      if (!missing(value)) {
        stop("indicators is read-only", call. = FALSE)
      }
      current_bar <- private$broker$current_bar
      visible <- list()
      for (name in names(private$indicator_values)) {
        values <- private$indicator_values[[name]]
        if (current_bar < length(values)) {
          values <- values[seq_len(current_bar)]
        }
        visible[[name]] <- values
      }
      visible
    },

    #' @field equity The numeric account equity: cash plus the profit or loss of the open trades.
    equity = function(value) {
      if (!missing(value)) {
        stop("equity is read-only", call. = FALSE)
      }
      private$broker$equity
    },

    #' @field position The `BacktestPosition` summing the open trades.
    position = function(value) {
      if (!missing(value)) {
        stop("position is read-only", call. = FALSE)
      }
      private$broker$position
    },

    #' @field orders A list of the waiting `BacktestOrder` objects.
    orders = function(value) {
      if (!missing(value)) {
        stop("orders is read-only", call. = FALSE)
      }
      private$broker$orders
    },

    #' @field trades A list of the open `BacktestTrade` objects.
    trades = function(value) {
      if (!missing(value)) {
        stop("trades is read-only", call. = FALSE)
      }
      private$broker$trades
    },

    #' @field closed_trades A list of the closed `BacktestTrade` objects.
    closed_trades = function(value) {
      if (!missing(value)) {
        stop("closed_trades is read-only", call. = FALSE)
      }
      private$broker$closed_trades
    }
  ),
  private = list(
    broker = NULL,
    indicator_values = NULL,

    # Checks an order size.
    # @param size The numeric size given to `buy()` or `sell()`.
    # @return `NULL`, invisibly.
    # @details Errors: signals `ValueError` when `size` is neither a fraction between 0 and 1 nor a whole number of at least 1.
    check_size = function(size) {
      is_fraction <- size > 0 && size < 1
      is_whole_units <- round(size) == size && size >= 1
      if (!(is_fraction || is_whole_units)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "size must be a positive fraction of equity, or a positive whole number of units: size=%s",
            format(size)
          )
        )
      }
      invisible(NULL)
    }
  )
)
