test_that("a run without trades gives missing trade statistics", {
  candles <- ParityTinyCandles$new()$frame()
  statistics <- BacktestStatistics$new(
    trades = list(),
    equity = rep(10000, 6),
    candles = candles
  )$compute()
  expect_equal(statistics[["# Trades"]], 0)
  expect_true(is.nan(statistics[["Win Rate [%]"]]))
  expect_true(is.nan(statistics[["Best Trade [%]"]]))
  expect_equal(statistics[["Return [%]"]], 0)
  expect_equal(statistics[["Max. Drawdown [%]"]], 0)
  expect_true(is.na(statistics[["Max. Drawdown Duration"]]))
  expect_false("Commissions [$]" %in% names(statistics))
  expect_equal(nrow(statistics[["_trades"]]), 0)
})

test_that("the statistic names follow backtesting.py's order", {
  candles <- ParityTinyCandles$new()$frame()
  statistics <- BacktestStatistics$new(list(), rep(10000, 6), candles)$compute()
  expect_equal(
    names(statistics)[1:8],
    c(
      "Start",
      "End",
      "Duration",
      "Exposure Time [%]",
      "Equity Final [$]",
      "Equity Peak [$]",
      "Return [%]",
      "Buy & Hold Return [%]"
    )
  )
  expect_equal(utils::tail(names(statistics), 3), c("_strategy", "_equity_curve", "_trades"))
  expect_error(
    BacktestStatistics$new(list(), rep(10000, 6), candles, risk_free_rate = 2),
    class = "ValueError"
  )
})
