test_that("run_backtest matches backtesting.py for a moving average cross", {
  statistics <- PerformanceFixtureCandles$new()$run_backtest(
    ParityMovingAverageCross,
    cash = 100000
  ) |> suppressWarnings()
  tolerance <- 1e-12
  expect_equal(statistics[["# Trades"]], 13)
  expect_equal(statistics[["Exposure Time [%]"]], 76)
  expect_equal(statistics[["Equity Final [$]"]], 68393.45999999996, tolerance = tolerance)
  expect_equal(statistics[["Equity Peak [$]"]], 102006.01, tolerance = tolerance)
  expect_equal(statistics[["Return [%]"]], -31.606540000000038, tolerance = tolerance)
  expect_equal(statistics[["Buy & Hold Return [%]"]], 9.445664276720395, tolerance = tolerance)
  expect_equal(statistics[["Return (Ann.) [%]"]], -21.28469504624824, tolerance = tolerance)
  expect_equal(statistics[["Volatility (Ann.) [%]"]], 16.10006385996202, tolerance = tolerance)
  expect_equal(statistics[["CAGR [%]"]], -15.791354089299736, tolerance = tolerance)
  expect_equal(statistics[["Sharpe Ratio"]], -1.3220255044565052, tolerance = tolerance)
  expect_equal(statistics[["Sortino Ratio"]], -1.4084672251129413, tolerance = tolerance)
  expect_equal(statistics[["Calmar Ratio"]], -0.6284786386463376, tolerance = tolerance)
  expect_equal(statistics[["Alpha [%]"]], -31.61078253927034, tolerance = tolerance)
  expect_equal(statistics[["Beta"]], 0.00044915202848746307, tolerance = 1e-9)
  expect_equal(statistics[["Max. Drawdown [%]"]], -33.86701430631396, tolerance = tolerance)
  expect_equal(statistics[["Avg. Drawdown [%]"]], -17.85002215315698, tolerance = tolerance)
  expect_equal(as.numeric(statistics[["Max. Drawdown Duration"]], units = "secs"), 36374400)
  expect_equal(as.numeric(statistics[["Avg. Drawdown Duration"]], units = "secs"), 18489600)
  expect_equal(statistics[["Win Rate [%]"]], 30.76923076923077, tolerance = tolerance)
  expect_equal(statistics[["Best Trade [%]"]], 1.7046367252832262, tolerance = tolerance)
  expect_equal(statistics[["Worst Trade [%]"]], -8.537958590628413, tolerance = tolerance)
  expect_equal(statistics[["Avg. Trade [%]"]], -2.6699594561102824, tolerance = tolerance)
  expect_equal(as.numeric(statistics[["Max. Trade Duration"]], units = "secs"), 5270400)
  expect_equal(as.numeric(statistics[["Avg. Trade Duration"]], units = "secs"), 2851200)
  expect_equal(statistics[["Profit Factor"]], 0.11280895214657093, tolerance = tolerance)
  expect_equal(statistics[["Expectancy [%]"]], -2.616351401589435, tolerance = tolerance)
  expect_equal(statistics[["SQN"]], -2.859841889320439, tolerance = tolerance)
  expect_equal(statistics[["Kelly Criterion"]], -3.0494170666835902, tolerance = tolerance)
  trades <- statistics[["_trades"]]
  expect_equal(trades$Size[1:2], c(-93, 88))
  expect_equal(trades$EntryBar[1:2], c(94, 110))
  expect_equal(trades$ExitBar[1:2], c(110, 118))
  expect_equal(trades$PnL[1:2], c(-3037.3800000000074, -8273.76000000001), tolerance = tolerance)
})

test_that("commission adds the Commissions entry in the same place as Python", {
  statistics <- PerformanceFixtureCandles$new()$run_backtest(
    ParityMovingAverageCross,
    cash = 100000,
    commission = 0.002
  ) |> suppressWarnings()
  expect_equal(names(statistics)[[7]], "Commissions [$]")
  expect_equal(statistics[["Commissions [$]"]], 4058.63876, tolerance = 1e-12)
  expect_equal(statistics[["Equity Final [$]"]], 64796.21131999996, tolerance = 1e-12)
  expect_equal(statistics[["SQN"]], -3.2360647981768804, tolerance = 1e-12)
})

test_that("stop-loss and take-profit brackets match Python", {
  statistics <- PerformanceFixtureCandles$new()$run_backtest(
    ParityBracket,
    cash = 100000,
    commission = 0.001
  ) |> suppressWarnings()
  expect_equal(statistics[["# Trades"]], 21)
  expect_equal(statistics[["Equity Final [$]"]], 106360.35013680004, tolerance = 1e-12)
  expect_equal(statistics[["Kelly Criterion"]], 0.16653975119618825, tolerance = 1e-12)
  trades <- statistics[["_trades"]]
  expect_equal(trades$TP[[1]], 905.4431999999999, tolerance = 1e-12)
  expect_equal(trades$SL[[2]], 961.7841, tolerance = 1e-12)
  expect_equal(trades$Tag[[2]], "bracket")
})

test_that("stop, limit and partial closes match Python", {
  statistics <- PerformanceFixtureCandles$new()$run_backtest(
    ParityStopAndLimit,
    cash = 100000
  ) |> suppressWarnings()
  trades <- statistics[["_trades"]]
  expect_equal(nrow(trades), 34)
  expect_equal(trades$EntryPrice[[1]], 979.0738, tolerance = 1e-12)
  expect_equal(trades$SL[[1]], 872.028, tolerance = 1e-12)
  expect_equal(trades$Size[[2]], 4)
})

test_that("run_backtest returns NULL without candles", {
  empty <- R6::R6Class(
    "EmptyBacktestCandles",
    inherit = StrategyBacktests,
    public = list(
      prices = function(
        interval = "day",
        from_date = NULL,
        to_date = NULL,
        days = NULL,
        adjusted = TRUE
      ) {
        NULL
      }
    )
  )$new()
  expect_null(empty$run_backtest(ParityMovingAverageCross))
})

test_that("plot_filename writes an HTML page", {
  plot_path <- withr::local_tempfile(fileext = ".html")
  PerformanceFixtureCandles$new()$run_backtest(
    ParityMovingAverageCross,
    cash = 100000,
    plot_filename = plot_path
  ) |> suppressWarnings()
  expect_true(file.exists(plot_path))
  page <- paste(readLines(plot_path), collapse = "\n")
  expect_match(page, "ParityMovingAverageCross", fixed = TRUE)
  expect_match(page, "<svg", fixed = TRUE)
})
