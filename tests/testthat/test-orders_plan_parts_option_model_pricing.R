test_that("option model bare builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- OptionModelPricing$new(instrument = index, volatility = 0.18)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"option_model": {"instrument_id": "index-instrument-id", "volatility": 0.18}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("option model full builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- OptionModelPricing$new(
    instrument = index,
    volatility = 0.18,
    interest_rate = 0.065,
    lowest = 1.0,
    highest = 500.0,
    step_ticks = 2
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"option_model": {"instrument_id": "index-instrument-id", "volatility": 0.18, "interest_rate": 0.065, "lowest": 1.0, "highest": 500.0, "step_ticks": 2}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
