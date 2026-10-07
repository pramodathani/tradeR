test_that("ladder builds the document Python builds", {
  part <- LadderExecution$new(from_price = 100.0, to_price = 95.0, steps = 5)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"ladder": {"from_price": 100.0, "to_price": 95.0, "steps": 5}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
