test_that("price crosses bare builds the document Python builds", {
  part <- PriceCrosses$new(level = 995.0)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"price_crosses": {"level": 995.0}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("price crosses full builds the document Python builds", {
  index <- list(
    instrument_id = "index-instrument-id"
  )
  part <- PriceCrosses$new(
    level = 995.0,
    direction = "at_or_above",
    field = "bid",
    instrument = index,
    confirm = "held",
    hold_seconds = 10
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"price_crosses": {"level": 995.0, "direction": "at_or_above", "field": "bid", "instrument_id": "index-instrument-id", "confirm": "held", "hold_seconds": 10}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
