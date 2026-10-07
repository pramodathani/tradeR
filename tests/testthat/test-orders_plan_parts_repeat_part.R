test_that("repeat bare builds the document Python builds", {
  part <- RepeatPart$new(child = OrderPart$new(), times = 3)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"repeat": {"child": {"order": {}}, "times": 3}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("repeat full builds the document Python builds", {
  part <- RepeatPart$new(
    child = OrderPart$new(),
    times = 3,
    every_minutes = 10,
    every_trading_day_at = "09:20",
    until = PriceCrosses$new(level = 110.0)
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"repeat": {"child": {"order": {}}, "times": 3, "every_minutes": 10, "every_trading_day_at": "09:20", "until": {"price_crosses": {"level": 110.0}}}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("the repeat key, a reserved word in R, is the document's only key", {
  document <- RepeatPart$new(child = OrderPart$new(), times = 2)$document()
  expect_equal(
    names(document),
    "repeat"
  )
})
