test_that("follow bare builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- FollowInstrumentPricing$new(instrument = index, delta = 0.5)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"follow_instrument": {"instrument_id": "index-instrument-id", "delta": 0.5}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("follow full builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- FollowInstrumentPricing$new(
    instrument = index,
    delta = -0.25,
    lowest = 90.0,
    highest = 110.0,
    step_ticks = 3
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"follow_instrument": {"instrument_id": "index-instrument-id", "delta": -0.25, "lowest": 90.0, "highest": 110.0, "step_ticks": 3}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
