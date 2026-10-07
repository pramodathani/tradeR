test_that("chase bare builds the document Python builds", {
  part <- ChasePricing$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"chase": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("chase full builds the document Python builds", {
  part <- ChasePricing$new(step_ticks = 2, step_seconds = 1.5, cross_after_seconds = 30)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"chase": {"step_ticks": 2, "step_seconds": 1.5, "cross_after_seconds": 30}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
