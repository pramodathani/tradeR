test_that("stages bare builds the document Python builds", {
  part <- StagesPricing$new(
    entry_price = 100.0,
    stop_price = 95.0,
    limit_offset = 0.5,
    rules = list(StageRule$new(gain = 5.0))
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"stages": {"entry_price": 100.0, "stop_price": 95.0, "limit_offset": 0.5, "rules": [{"gain": 5.0}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("stages full builds the document Python builds", {
  part <- StagesPricing$new(
    entry_price = 100.0,
    stop_price = 95.0,
    limit_offset = 0.5,
    rules = list(
      StageRule$new(gain = 5.0, stop_at_gain = 0.0),
      StageRule$new(gain = 10.0, trail_points = 3.0)
    ),
    step_ticks = 2
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"stages": {"entry_price": 100.0, "stop_price": 95.0, "limit_offset": 0.5, "step_ticks": 2, "rules": [{"gain": 5.0, "stop_at_gain": 0.0}, {"gain": 10.0, "trail_points": 3.0}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("stages no rules builds the document Python builds", {
  part <- StagesPricing$new(
    entry_price = 100.0,
    stop_price = 95.0,
    limit_offset = 0.5,
    rules = list()
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"stages": {"entry_price": 100.0, "stop_price": 95.0, "limit_offset": 0.5, "rules": []}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
