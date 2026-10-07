test_that("account condition builds the document Python builds", {
  part <- AccountCondition$new(
    field = "day_pnl",
    level = -5000.0,
    direction = "at_or_below"
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"account": {"field": "day_pnl", "level": -5000.0, "direction": "at_or_below"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
