test_that("peg bare builds the document Python builds", {
  part <- PegPricing$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"peg": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("peg full builds the document Python builds", {
  part <- PegPricing$new(
    reference = "own_touch",
    offset_ticks = -1,
    follows = FALSE,
    within_body_price = TRUE,
    on_empty_book = "wait"
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"peg": {"reference": "own_touch", "offset_ticks": -1, "follows": false, "within_body_price": true, "on_empty_book": "wait"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("peg follows true builds the document Python builds", {
  part <- PegPricing$new(follows = TRUE)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"peg": {"follows": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
