test_that("a market order fills at the next open and closes at a later open", {
  candles <- ParityTinyCandles$new()$frame()
  statistics <- Backtest$new(candles, ParityBuyOnce, cash = 10000)$run()
  expect_equal(statistics[["Equity Final [$]"]], 10030)
  expect_equal(
    statistics[["_equity_curve"]]$Equity,
    c(
      10000,
      10000,
      9990,
      9995,
      10030,
      10030
    )
  )
  trades <- statistics[["_trades"]]
  expect_equal(trades$EntryBar, 3)
  expect_equal(trades$ExitBar, 5)
  expect_equal(trades$EntryPrice, 104)
  expect_equal(trades$ExitPrice, 107)
  expect_equal(statistics[["Exposure Time [%]"]], 50)
  expect_equal(statistics[["Return (Ann.) [%]"]], 13.406823692628178, tolerance = 1e-12)
  expect_equal(statistics[["Max. Drawdown [%]"]], -0.10000000000000009, tolerance = 1e-12)
  expect_true(is.nan(statistics[["SQN"]]))
  expect_equal(as.numeric(statistics[["Avg. Trade Duration"]], units = "days"), 2)
})

test_that("commission is charged on entry and exit", {
  candles <- ParityTinyCandles$new()$frame()
  statistics <- Backtest$new(
    candles,
    ParityBuyOnce,
    cash = 10000,
    commission = 0.01
  )$run()
  expect_equal(statistics[["Equity Final [$]"]], 10008.9, tolerance = 1e-12)
  expect_equal(statistics[["_trades"]]$Commission, 21.1, tolerance = 1e-12)
  expect_equal(statistics[["Return (Ann.) [%]"]], 3.8070161849122597, tolerance = 1e-12)
})

test_that("a strategy that is not a BacktestStrategy is refused", {
  candles <- ParityTinyCandles$new()$frame()
  expect_error(Backtest$new(candles, list()), class = "TypeError")
  expect_error(Backtest$new(candles, ParityTinyCandles), class = "TypeError")
})

test_that("bad candles signal ValueError", {
  candles <- ParityTinyCandles$new()$frame()
  candles$Close[[2]] <- NA
  expect_error(Backtest$new(candles, ParityBuyOnce), class = "ValueError")
  expect_error(
    Backtest$new(candles[0, ], ParityBuyOnce),
    class = "ValueError"
  )
})

test_that("bad cash or margin signals ValueError when run", {
  candles <- ParityTinyCandles$new()$frame()
  expect_error(
    Backtest$new(candles, ParityBuyOnce, margin = 2)$run(),
    class = "ValueError"
  )
  expect_error(
    Backtest$new(candles, ParityBuyOnce, commission = 0.5)$run(),
    class = "ValueError"
  )
})
