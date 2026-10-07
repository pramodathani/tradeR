test_that("Black-Scholes matches the Python library to ten places", {
  model <- BlackScholes$new(24000, 24100, 7 / 365, 0.065, 0.12, TRUE)

  expect_equal(model$price, 126.7939124695, tolerance = 1e-10)
  expect_equal(model$delta, 0.4337296702, tolerance = 1e-9)
  expect_equal(model$gamma, 0.0009864321, tolerance = 1e-8)
  expect_equal(model$theta, -13.0391997424, tolerance = 1e-10)
  expect_equal(model$vega, 13.0760358784, tolerance = 1e-10)
  expect_equal(model$rho, 1.9720281425, tolerance = 1e-10)
  expect_equal(
    BlackScholes$implied_volatility(150, 24000, 24100, 7 / 365, 0.065, TRUE),
    0.1377121249,
    tolerance = 1e-9
  )
})

test_that("Black-76 matches the Python library to ten places", {
  model <- Black76$new(9125, 9100, 20 / 365, 0.065, 0.18, FALSE)

  expect_equal(model$price, 140.4872035581, tolerance = 1e-10)
  expect_equal(model$delta, -0.4640062911, tolerance = 1e-9)
  expect_equal(model$theta, -3.7818205023, tolerance = 1e-10)
  expect_equal(model$rho, -0.0769792896, tolerance = 1e-9)
  expect_equal(
    Black76$implied_volatility(120, 9125, 9100, 20 / 365, 0.065, FALSE),
    0.1557751285,
    tolerance = 1e-9
  )
})

test_that("bad inputs signal ValueError and a worthless premium has no volatility", {
  expect_error(
    BlackScholes$new(0, 1, 1, 0, 1, TRUE),
    class = "ValueError"
  )
  expect_null(BlackScholes$implied_volatility(0, 24000, 24100, 0.1, 0.065, TRUE))
  expect_null(BlackScholes$implied_volatility(1, 24000, 20000, 0.1, 0.065, TRUE))
})
