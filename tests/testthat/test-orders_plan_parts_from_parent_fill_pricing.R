test_that("from parent fill builds the document Python builds", {
  part <- FromParentFillPricing$new(net_price = 12.5)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"from_parent_fill": {"net_price": 12.5}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
