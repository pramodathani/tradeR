#' The statistics table of a finished backtest
#'
#' @description
#' The R counterpart of `compute_stats` in the Python `backtesting` package (version 0.6.5). It turns the closed trades and the equity of every candle into the same named statistics backtesting.py returns, in the same order, from `Start` to `Kelly Criterion`, followed by `_strategy`, `_equity_curve` and `_trades`.
#'
#' Durations are `difftime` values in days, rounded up to the resolution of the candles, so whole days for `day` candles and whole minutes for minute candles, as backtesting.py rounds its `Timedelta` values. Candle numbers in `_trades` count from 1.
#'
#' @examples
#' \dontrun{
#' backtest <- Backtest$new(candles, MovingAverageCross, cash = 100000)
#' statistics <- backtest$run()
#' statistics[["Sharpe Ratio"]]
#' head(statistics[["_trades"]])
#' }
#' @export
BacktestStatistics <- R6::R6Class(
  "BacktestStatistics",
  public = list(
    #' @field trades A list of the closed `BacktestTrade` objects.
    trades = NULL,

    #' @field equity A numeric vector with the equity at the end of every candle.
    equity = NULL,

    #' @field candles The `data.frame` of candles with `datetime` and `Close` columns.
    candles = NULL,

    #' @field strategy The `BacktestStrategy` that ran, or `NULL`.
    strategy = NULL,

    #' @field risk_free_rate The numeric annual risk-free rate as a fraction, above -1 and below 1.
    risk_free_rate = NULL,

    #' @description
    #' Collects what the statistics are calculated from.
    #' @param trades A list of the closed `BacktestTrade` objects.
    #' @param equity A numeric vector with the equity at the end of every candle, without missing values.
    #' @param candles The `data.frame` of candles with `datetime` and `Close` columns.
    #' @param strategy The `BacktestStrategy` that ran, or `NULL`.
    #' @param risk_free_rate The numeric annual risk-free rate as a fraction.
    #' @return A new `BacktestStatistics` object.
    #' @details Errors: signals `ValueError` when `risk_free_rate` is not above -1 and below 1.
    initialize = function(
      trades,
      equity,
      candles,
      strategy = NULL,
      risk_free_rate = 0
    ) {
      if (!(risk_free_rate > -1 && risk_free_rate < 1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "risk_free_rate must be above -1 and below 1: risk_free_rate=%s",
            format(risk_free_rate)
          )
        )
      }
      self$trades <- trades
      self$equity <- equity
      self$candles <- candles
      self$strategy <- strategy
      self$risk_free_rate <- risk_free_rate
    },

    #' @description
    #' Builds the table of closed trades.
    #' @return A `data.frame` with one row per closed trade and the columns `Size`, `EntryBar`, `ExitBar`, `EntryPrice`, `ExitPrice`, `SL`, `TP`, `PnL`, `Commission`, `ReturnPct`, `EntryTime`, `ExitTime`, `Duration` and `Tag`, then `Entry_<name>` and `Exit_<name>` for each indicator when there are trades.
    trade_frame = function() {
      count <- length(self$trades)
      size <- numeric(count)
      entry_bar <- integer(count)
      exit_bar <- integer(count)
      entry_price <- numeric(count)
      exit_price <- numeric(count)
      stop_loss <- rep(NA_real_, count)
      take_profit <- rep(NA_real_, count)
      profit <- numeric(count)
      commission <- numeric(count)
      return_fraction <- numeric(count)
      tag <- rep(NA, count)
      for (index in seq_len(count)) {
        trade <- self$trades[[index]]
        size[[index]] <- trade$size
        entry_bar[[index]] <- trade$entry_bar
        exit_bar[[index]] <- trade$exit_bar
        entry_price[[index]] <- trade$entry_price
        exit_price[[index]] <- trade$exit_price
        if (!is.null(trade$sl)) {
          stop_loss[[index]] <- trade$sl
        }
        if (!is.null(trade$tp)) {
          take_profit[[index]] <- trade$tp
        }
        profit[[index]] <- trade$pl
        commission[[index]] <- trade$commissions
        return_fraction[[index]] <- trade$pl_pct
        if (!is.null(trade$tag)) {
          tag[[index]] <- trade$tag
        }
      }
      datetimes <- self$candles$datetime
      entry_time <- datetimes[entry_bar]
      exit_time <- datetimes[exit_bar]
      frame <- data.frame(
        Size = size,
        EntryBar = entry_bar,
        ExitBar = exit_bar,
        EntryPrice = entry_price,
        ExitPrice = exit_price,
        SL = stop_loss,
        TP = take_profit,
        PnL = profit,
        Commission = commission,
        ReturnPct = return_fraction,
        EntryTime = entry_time,
        ExitTime = exit_time,
        Duration = difftime(exit_time, entry_time, units = "days"),
        Tag = tag
      )
      if (count > 0 && !is.null(self$strategy)) {
        indicators <- self$strategy$all_indicators()
        for (name in names(indicators)) {
          values <- indicators[[name]]
          frame[[paste0("Entry_", name)]] <- values[entry_bar]
          frame[[paste0("Exit_", name)]] <- values[exit_bar]
        }
      }
      frame
    },

    #' @description
    #' Calculates every statistic.
    #' @return A named list with the entries `Start`, `End`, `Duration`, `Exposure Time [%]`, `Equity Final [$]`, `Equity Peak [$]`, `Commissions [$]` when any commission was paid, `Return [%]`, `Buy & Hold Return [%]`, `Return (Ann.) [%]`, `Volatility (Ann.) [%]`, `CAGR [%]`, `Sharpe Ratio`, `Sortino Ratio`, `Calmar Ratio`, `Alpha [%]`, `Beta`, `Max. Drawdown [%]`, `Avg. Drawdown [%]`, `Max. Drawdown Duration`, `Avg. Drawdown Duration`, `# Trades`, `Win Rate [%]`, `Best Trade [%]`, `Worst Trade [%]`, `Avg. Trade [%]`, `Max. Trade Duration`, `Avg. Trade Duration`, `Profit Factor`, `Expectancy [%]`, `SQN`, `Kelly Criterion`, `_strategy` (the strategy object), `_equity_curve` (a `data.frame` with `datetime`, `Equity`, `DrawdownPct` and `DrawdownDuration`) and `_trades` (from `trade_frame()`). A value that cannot be calculated is `NaN` or `NA`.
    compute = function() {
      equity <- self$equity
      datetimes <- self$candles$datetime
      closes <- self$candles$Close
      candle_count <- length(equity)
      period_seconds <- private$period_seconds()
      drawdown <- 1 - equity / cummax(equity)
      durations_and_peaks <- private$drawdown_durations_and_peaks(drawdown)
      drawdown_durations <- durations_and_peaks$durations
      drawdown_peaks <- durations_and_peaks$peaks
      trade_frame <- self$trade_frame()
      profit <- trade_frame$PnL
      returns <- trade_frame$ReturnPct
      trade_count <- nrow(trade_frame)
      statistics <- list()
      statistics[["Start"]] <- datetimes[[1]]
      statistics[["End"]] <- datetimes[[candle_count]]
      duration <- difftime(
        datetimes[[candle_count]],
        datetimes[[1]],
        units = "days"
      )
      statistics[["Duration"]] <- duration
      have_position <- rep(0, candle_count)
      for (index in seq_len(trade_count)) {
        entry_bar <- trade_frame$EntryBar[[index]]
        exit_bar <- trade_frame$ExitBar[[index]]
        have_position[entry_bar:exit_bar] <- 1
      }
      statistics[["Exposure Time [%]"]] <- mean(have_position) * 100
      statistics[["Equity Final [$]"]] <- equity[[candle_count]]
      statistics[["Equity Peak [$]"]] <- max(equity)
      commissions <- sum(trade_frame$Commission)
      if (commissions != 0) {
        statistics[["Commissions [$]"]] <- commissions
      }
      statistics[["Return [%]"]] <- (equity[[candle_count]] - equity[[1]]) /
        equity[[1]] * 100
      first_trading_bar <- 1
      if (!is.null(self$strategy)) {
        first_trading_bar <- self$strategy$warmup_candles() + 1
      }
      first_close <- closes[[first_trading_bar]]
      buy_and_hold <- (closes[[candle_count]] - first_close) / first_close * 100
      statistics[["Buy & Hold Return [%]"]] <- buy_and_hold
      annual_trading_days <- private$annual_trading_days(period_seconds)
      day_returns <- private$period_returns(period_seconds)
      mean_day_return <- private$geometric_mean(day_returns)
      annualised_return <- (1 + mean_day_return)^annual_trading_days - 1
      statistics[["Return (Ann.) [%]"]] <- annualised_return * 100
      known_day_returns <- day_returns[!is.na(day_returns)]
      day_variance <- NaN
      if (length(known_day_returns) > 1) {
        day_variance <- stats::var(known_day_returns)
      }
      growth <- 1 + mean_day_return
      volatility <- sqrt(
        (day_variance + growth^2)^annual_trading_days -
          growth^(2 * annual_trading_days)
      ) * 100
      statistics[["Volatility (Ann.) [%]"]] <- volatility
      duration_seconds <- as.numeric(duration, units = "secs")
      duration_days <- duration_seconds %/% 86400 +
        (duration_seconds %% 86400) / 86400
      time_in_years <- duration_days / annual_trading_days
      if (time_in_years != 0) {
        equity_growth <- equity[[candle_count]] / equity[[1]]
        cagr <- (equity_growth^(1 / time_in_years) - 1) * 100
      } else {
        cagr <- NaN
      }
      statistics[["CAGR [%]"]] <- cagr
      excess_percent <- annualised_return * 100 - self$risk_free_rate * 100
      statistics[["Sharpe Ratio"]] <- excess_percent /
        private$or_nan(volatility)
      downside <- pmin(known_day_returns, 0)
      downside_deviation <- sqrt(mean(downside^2)) * sqrt(annual_trading_days)
      excess_return <- annualised_return - self$risk_free_rate
      statistics[["Sortino Ratio"]] <- excess_return / downside_deviation
      worst_drawdown <- max(drawdown)
      if (is.na(worst_drawdown)) {
        worst_drawdown <- 0
      }
      statistics[["Calmar Ratio"]] <- annualised_return /
        private$or_nan(worst_drawdown)
      beta <- private$beta(equity, closes)
      statistics[["Alpha [%]"]] <- statistics[["Return [%]"]] -
        self$risk_free_rate * 100 -
        beta * (buy_and_hold - self$risk_free_rate * 100)
      statistics[["Beta"]] <- beta
      statistics[["Max. Drawdown [%]"]] <- -worst_drawdown * 100
      statistics[["Avg. Drawdown [%]"]] <- -private$mean_or_nan(
        drawdown_peaks
      ) * 100
      statistics[["Max. Drawdown Duration"]] <- private$round_duration(
        private$max_or_nan(drawdown_durations),
        period_seconds,
        durations_and_peaks$are_durations
      )
      statistics[["Avg. Drawdown Duration"]] <- private$round_duration(
        private$mean_or_nan(drawdown_durations),
        period_seconds,
        durations_and_peaks$are_durations
      )
      statistics[["# Trades"]] <- trade_count
      win_rate <- NaN
      if (trade_count > 0) {
        win_rate <- mean(profit > 0)
      }
      statistics[["Win Rate [%]"]] <- win_rate * 100
      statistics[["Best Trade [%]"]] <- private$max_or_nan(returns) * 100
      statistics[["Worst Trade [%]"]] <- -private$max_or_nan(-returns) * 100
      statistics[["Avg. Trade [%]"]] <- private$geometric_mean(returns) * 100
      trade_seconds <- as.numeric(trade_frame$Duration, units = "secs")
      statistics[["Max. Trade Duration"]] <- private$round_duration(
        private$max_or_nan(trade_seconds),
        period_seconds,
        TRUE
      )
      statistics[["Avg. Trade Duration"]] <- private$round_duration(
        private$mean_or_nan(trade_seconds),
        period_seconds,
        TRUE
      )
      gains <- sum(returns[returns > 0])
      losses <- abs(sum(returns[returns < 0]))
      statistics[["Profit Factor"]] <- gains / private$or_nan(losses)
      statistics[["Expectancy [%]"]] <- private$mean_or_nan(returns) * 100
      profit_spread <- NaN
      if (trade_count > 1) {
        profit_spread <- stats::sd(profit)
      }
      statistics[["SQN"]] <- sqrt(trade_count) * private$mean_or_nan(profit) /
        private$or_nan(profit_spread)
      average_win <- private$mean_or_nan(profit[profit > 0])
      average_loss <- private$mean_or_nan(profit[profit < 0])
      statistics[["Kelly Criterion"]] <- win_rate -
        (1 - win_rate) / (average_win / -average_loss)
      statistics["_strategy"] <- list(self$strategy)
      if (durations_and_peaks$are_durations) {
        drawdown_durations <- as.difftime(
          drawdown_durations / 86400,
          units = "days"
        )
      }
      statistics[["_equity_curve"]] <- data.frame(
        datetime = datetimes,
        Equity = equity,
        DrawdownPct = drawdown,
        DrawdownDuration = drawdown_durations
      )
      statistics[["_trades"]] <- trade_frame
      statistics
    }
  ),
  private = list(
    # Stands in for Python's `value or nan`, which turns a zero into `NaN`.
    # @param value A numeric value.
    # @return `value`, or `NaN` when it is zero.
    or_nan = function(value) {
      if (!is.na(value) && value == 0) {
        return(NaN)
      }
      value
    },

    # Takes the mean of the known values, as pandas does.
    # @param values A numeric vector that may hold `NA` values.
    # @return The numeric mean of the values that are not `NA`, or `NaN` when there are none.
    mean_or_nan = function(values) {
      known <- values[!is.na(values)]
      if (length(known) == 0) {
        return(NaN)
      }
      mean(known)
    },

    # Takes the largest of the known values, as pandas does.
    # @param values A numeric vector that may hold `NA` values.
    # @return The numeric largest value that is not `NA`, or `NaN` when there are none.
    max_or_nan = function(values) {
      known <- values[!is.na(values)]
      if (length(known) == 0) {
        return(NaN)
      }
      max(known)
    },

    # Works out the typical gap between candles, as the median gap among the last 100 candles.
    # @return The numeric number of seconds between candles.
    period_seconds = function() {
      datetimes <- utils::tail(self$candles$datetime, 100)
      gaps <- diff(as.numeric(datetimes))
      if (length(gaps) == 0) {
        return(NaN)
      }
      stats::median(gaps)
    },

    # Chooses how many periods make a year from the gap between candles, as backtesting.py does.
    # @param period_seconds The numeric number of seconds between candles.
    # @return The numeric number of periods in a year: 52 for weekly candles, 12 for monthly, 1 for yearly, and otherwise 365 when weekends trade or 252 when they do not.
    annual_trading_days = function(period_seconds) {
      period_days <- floor(period_seconds / 86400)
      if (!is.na(period_days) && period_days == 7) {
        return(52)
      }
      if (!is.na(period_days) && period_days == 31) {
        return(12)
      }
      if (!is.na(period_days) && period_days == 365) {
        return(1)
      }
      weekdays <- as.POSIXlt(
        self$candles$datetime,
        tz = TIME_CONVERTER_INDIA_TIME_ZONE
      )$wday
      weekend_share <- mean(weekdays == 0 | weekdays == 6)
      if (weekend_share > 2 / 7 * 0.6) {
        return(365)
      }
      252
    },

    # Gives the return of the equity from one calendar period to the next, taking the last equity of each day, or of each week, month or year for such candles.
    # @param period_seconds The numeric number of seconds between candles.
    # @return A numeric vector of returns whose first value is `NA`.
    period_returns = function(period_seconds) {
      local_times <- as.POSIXlt(
        self$candles$datetime,
        tz = TIME_CONVERTER_INDIA_TIME_ZONE
      )
      local_dates <- as.Date(format(local_times, "%Y-%m-%d"))
      period_days <- floor(period_seconds / 86400)
      if (!is.na(period_days) && period_days == 7) {
        keys <- format(local_dates + (7 - local_times$wday) %% 7)
      } else if (!is.na(period_days) && period_days == 31) {
        keys <- format(local_dates, "%Y-%m")
      } else if (!is.na(period_days) && period_days == 365) {
        keys <- format(local_dates, "%Y")
      } else {
        keys <- format(local_dates)
      }
      last_equity <- numeric(0)
      for (index in seq_along(keys)) {
        last_equity[[keys[[index]]]] <- self$equity[[index]]
      }
      last_equity <- last_equity[order(names(last_equity))]
      last_equity <- unname(last_equity)
      count <- length(last_equity)
      if (count < 2) {
        return(rep(NA_real_, count))
      }
      c(
        NA_real_,
        last_equity[-1] / last_equity[-count] - 1
      )
    },

    # Takes the geometric mean of returns, counting a missing return as zero, as backtesting.py does.
    # @param returns A numeric vector of fractional returns.
    # @return The numeric geometric mean return, 0 when any return is -1 or below, or `NaN` when there are no returns.
    geometric_mean = function(returns) {
      returns[is.na(returns)] <- 0
      growth <- returns + 1
      if (any(growth <= 0)) {
        return(0)
      }
      if (length(growth) == 0) {
        return(NaN)
      }
      exp(sum(log(growth)) / length(growth)) - 1
    },

    # Calculates the beta of the equity's log returns against the closes' log returns.
    # @param equity A numeric vector of equity values.
    # @param closes A numeric vector of closes.
    # @return The numeric beta, or `NaN` when there are fewer than three candles.
    beta = function(equity, closes) {
      count <- length(equity)
      if (count < 3) {
        return(NaN)
      }
      equity_log_returns <- log(equity[-1] / equity[-count])
      market_log_returns <- log(closes[-1] / closes[-count])
      stats::cov(equity_log_returns, market_log_returns) /
        stats::var(market_log_returns)
    },

    # Finds each drawdown's length and depth, the way backtesting.py's `compute_drawdown_duration_peaks` does.
    # @param drawdown A numeric vector of drawdowns as positive fractions, zero at a new peak.
    # @return A named list with `durations`, a numeric vector of seconds holding the length of each drawdown at the candle where it ended and `NA` elsewhere; `peaks`, a numeric vector with the depth of each drawdown at the same candles; and `are_durations`, a logical that is `FALSE` when no drawdown ended, in which case both vectors hold the drawdowns with zeros made `NA`, as pandas returns them.
    drawdown_durations_and_peaks = function(drawdown) {
      count <- length(drawdown)
      seconds <- as.numeric(self$candles$datetime)
      ends <- sort(unique(c(
        which(drawdown == 0),
        count
      )))
      durations <- rep(NA_real_, count)
      peaks <- rep(NA_real_, count)
      found <- FALSE
      for (position in seq_along(ends)) {
        if (position == 1) {
          next
        }
        previous <- ends[[position - 1]]
        current <- ends[[position]]
        if (current <= previous + 1) {
          next
        }
        found <- TRUE
        durations[[current]] <- seconds[[current]] - seconds[[previous]]
        peaks[[current]] <- max(drawdown[previous:current])
      }
      if (!found) {
        zero_free <- drawdown
        zero_free[!is.na(zero_free) & zero_free == 0] <- NA
        return(list(
          durations = zero_free,
          peaks = zero_free,
          are_durations = FALSE
        ))
      }
      list(
        durations = durations,
        peaks = peaks,
        are_durations = TRUE
      )
    },

    # Rounds a duration up to the resolution of the candles and makes it a `difftime` in days.
    # @param seconds A numeric number of seconds, or `NaN`.
    # @param period_seconds The numeric number of seconds between candles.
    # @param is_duration A logical that is `FALSE` when `seconds` is not a duration but a drawdown fraction, which is returned unchanged as backtesting.py does.
    # @return A `difftime` in days, `NA` when `seconds` is `NaN`, or `seconds` itself when `is_duration` is `FALSE`.
    round_duration = function(seconds, period_seconds, is_duration) {
      if (!is_duration) {
        return(seconds)
      }
      if (is.na(seconds)) {
        return(as.difftime(NA_real_, units = "days"))
      }
      resolution <- 1
      if (!is.na(period_seconds)) {
        if (period_seconds %% 86400 == 0) {
          resolution <- 86400
        } else if (period_seconds %% 3600 == 0) {
          resolution <- 3600
        } else if (period_seconds %% 60 == 0) {
          resolution <- 60
        }
      }
      rounded <- ceiling(seconds / resolution) * resolution
      as.difftime(rounded / 86400, units = "days")
    }
  )
)
