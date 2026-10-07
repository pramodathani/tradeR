test_that("daily bare builds the document Python builds", {
  part <- DailyExecution$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"daily": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("daily full builds the document Python builds", {
  part <- DailyExecution$new(arm_at = "09:20")
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"daily": {"arm_at": "09:20"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
