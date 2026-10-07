test_that("twap builds the document Python builds", {
  part <- TwapExecution$new(slices = 6, over_minutes = 60)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"twap": {"slices": 6, "over_minutes": 60}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
