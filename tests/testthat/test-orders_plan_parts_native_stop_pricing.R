test_that("native stop bare builds the document Python builds", {
  part <- NativeStopPricing$new(trigger_price = 95.0, limit_price = 94.5)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"native_stop": {"trigger_price": 95.0, "limit_price": 94.5}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("native stop full builds the document Python builds", {
  part <- NativeStopPricing$new(
    trigger_price = 95.0,
    limit_price = 94.5,
    exit_if_gapped = TRUE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"native_stop": {"trigger_price": 95.0, "limit_price": 94.5, "exit_if_gapped": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
