test_that("trail points builds the document Python builds", {
  part <- TrailPricing$new(points = 5.0, limit_offset = 1.0)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"trail": {"points": 5.0, "limit_offset": 1.0}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("trail full builds the document Python builds", {
  part <- TrailPricing$new(
    limit_offset = 1.0,
    points = 5.0,
    step_ticks = 2,
    average_true_range = TRUE,
    bar_minutes = 10,
    periods = 20,
    average_true_range_multiple = 2.5
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"trail": {"points": 5.0, "limit_offset": 1.0, "step_ticks": 2, "atr": {"bar_minutes": 10, "periods": 20, "multiple": 2.5}}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("trail atr bare builds the document Python builds", {
  part <- TrailPricing$new(limit_offset = 1.0, points = 5.0, average_true_range = TRUE)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"trail": {"points": 5.0, "limit_offset": 1.0, "atr": {}}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
