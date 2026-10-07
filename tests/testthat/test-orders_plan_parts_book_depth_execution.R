test_that("book depth builds the document Python builds", {
  part <- BookDepthExecution$new(limit_price = 100.5, minimum_quantity = 500)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"book_depth": {"limit_price": 100.5, "minimum_quantity": 500}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
