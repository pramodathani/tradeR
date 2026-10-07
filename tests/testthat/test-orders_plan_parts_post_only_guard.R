test_that("post only bare builds the document Python builds", {
  part <- PostOnlyGuard$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"post_only": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("post only full builds the document Python builds", {
  part <- PostOnlyGuard$new(on_crossing = "refuse")
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"post_only": {"on_crossing": "refuse"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
