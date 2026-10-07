test_that("parent fill delta bare builds the document Python builds", {
  part <- ParentFillDeltaQuantity$new(volatility = 0.2)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"parent_fill_delta": {"volatility": 0.2}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("parent fill delta full builds the document Python builds", {
  part <- ParentFillDeltaQuantity$new(volatility = 0.2, whole_lots = TRUE)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"parent_fill_delta": {"volatility": 0.2, "whole_lots": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
