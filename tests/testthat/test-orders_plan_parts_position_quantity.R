test_that("position bare builds the document Python builds", {
  part <- PositionQuantity$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"position": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("position one instrument builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- PositionQuantity$new(held_instruments = list(index))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"position": {"instrument_ids": ["index-instrument-id"]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("position full builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  other <- list(
    instrument_id = "other-instrument-id"
  )
  part <- PositionQuantity$new(
    product = "nrml",
    held_instruments = list(index, other),
    every_instrument = TRUE,
    ratio = 2,
    cancel_resting_first = FALSE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"position": {"product": "nrml", "instrument_ids": ["index-instrument-id", "other-instrument-id"], "every_instrument": true, "ratio": 2, "cancel_resting_first": false}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("position empty instruments builds the document Python builds", {
  part <- PositionQuantity$new(held_instruments = list())
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"position": {"instrument_ids": []}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
