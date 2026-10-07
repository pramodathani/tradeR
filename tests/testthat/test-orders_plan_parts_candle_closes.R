test_that("candle closes bare builds the document Python builds", {
  part <- CandleCloses$new(level = 100.0)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"candle_closes": {"level": 100.0}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("candle closes full builds the document Python builds", {
  part <- CandleCloses$new(level = 100.0, direction = "at_or_above", bar_minutes = 15)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"candle_closes": {"level": 100.0, "direction": "at_or_above", "bar_minutes": 15}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
