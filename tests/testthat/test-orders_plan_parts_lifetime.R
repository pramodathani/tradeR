test_that("lifetime bare builds the document Python builds", {
  part <- Lifetime$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("lifetime full builds the document Python builds", {
  part <- Lifetime$new(
    at_time = "15:00",
    after_minutes = 30,
    after_days = 2,
    when = PriceCrosses$new(level = 90.0),
    applies_to = "exits",
    on_end = "close_filled"
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"at_time": "15:00", "after_minutes": 30, "after_days": 2, "when": {"price_crosses": {"level": 90.0}}, "applies_to": "exits", "on_end": "close_filled"})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
