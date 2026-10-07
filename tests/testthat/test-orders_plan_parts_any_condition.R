test_that("any condition two builds the document Python builds", {
  part <- AnyCondition$new(list(TimeAt$new("10:00"), Trails$new(points = 2.0)))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"any": [{"time_at": "10:00"}, {"trails": {"points": 2.0}}]})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
