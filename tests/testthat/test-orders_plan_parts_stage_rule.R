test_that("stage rule bare builds the document Python builds", {
  part <- StageRule$new(gain = 5.0)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"gain": 5.0})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("stage rule full builds the document Python builds", {
  part <- StageRule$new(gain = 5.0, stop_at_gain = 1.0, trail_points = 2.0)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"gain": 5.0, "stop_at_gain": 1.0, "trail_points": 2.0})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
