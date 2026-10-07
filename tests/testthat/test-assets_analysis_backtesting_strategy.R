test_that("crossover follows backtesting.lib.crossover", {
  strategy <- BacktestStrategy$new(broker = NULL)
  expect_true(strategy$crossover(c(1, 3), c(2, 2)))
  expect_false(strategy$crossover(c(3, 1), c(2, 2)))
  expect_true(strategy$crossover(c(1, 3), 2))
  expect_false(strategy$crossover(3, 2))
  expect_false(strategy$crossover(c(NA, 3), c(2, 2)))
  expect_false(strategy$crossover(c(2, 3), c(2, 2)))
})

test_that("an indicator must be as long as the candles", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  strategy <- BacktestStrategy$new(broker)
  expect_error(strategy$indicator("short", c(1, 2)), class = "ValueError")
  strategy$indicator(
    "average",
    c(
      NA,
      NA,
      1,
      2,
      3,
      4
    )
  )
  expect_equal(strategy$warmup_candles(), 2)
  broker$current_bar <- 4
  expect_equal(strategy$indicators$average, c(NA, NA, 1, 2))
  expect_equal(nrow(strategy$data), 4)
})

test_that("order sizes are checked like backtesting.py", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  strategy <- BacktestStrategy$new(broker)
  expect_error(strategy$buy(size = 1.5), class = "ValueError")
  expect_error(strategy$sell(size = 0), class = "ValueError")
  order <- strategy$buy(size = 3)
  expect_equal(order$size, 3)
  expect_equal(strategy$sell(size = 0.5)$size, -0.5)
})

test_that("a strategy without its two methods cannot run", {
  candles <- ParityTinyCandles$new()$frame()
  expect_error(Backtest$new(candles, BacktestStrategy)$run(), "initialize_strategy")
})
