test_that("prices out of order for a bracket signal ValueError", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 2
  expect_error(broker$new_order(5, sl = 110), class = "ValueError")
  expect_error(broker$new_order(-5, tp = 110), class = "ValueError")
})

test_that("a limit buy fills at the limit when the low reaches it", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(5, limit = 100.5)
  broker$next_bar(2)
  expect_equal(length(broker$trades), 0)
  broker$next_bar(4)
  expect_equal(broker$trades[[1]]$entry_price, 100.5)
  expect_equal(broker$trades[[1]]$entry_bar, 4)
})

test_that("a stop buy fills at the stop once the high reaches it", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(5, stop = 104.5)
  broker$next_bar(2)
  expect_equal(broker$trades[[1]]$entry_price, 104.5)
})

test_that("an order the cash cannot pay for is dropped", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 1000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(50)
  broker$next_bar(2)
  expect_equal(length(broker$trades), 0)
  expect_equal(length(broker$orders), 0)
})

test_that("without hedging a sell closes the long trade first", {
  candles <- ParityTinyCandles$new()$frame()
  broker <- BacktestBroker$new(candles, 10000, 0, 1, FALSE, FALSE, FALSE)
  broker$current_bar <- 1
  broker$new_order(5)
  broker$next_bar(2)
  broker$new_order(-3)
  broker$next_bar(3)
  expect_equal(broker$position$size, 2)
  expect_equal(length(broker$closed_trades), 1)
  expect_equal(broker$closed_trades[[1]]$size, 3)
  expect_equal(broker$closed_trades[[1]]$exit_price, 104)
})
