test_that("either bare builds the document Python builds", {
  part <- EitherPart$new(
    children = list(OrderPart$new(), OrderPart$new(side = "sell")),
    sibling_rule = "cancel"
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"either": {"children": [{"order": {}}, {"order": {"side": "sell"}}], "sibling_rule": "cancel"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("either full builds the document Python builds", {
  part <- EitherPart$new(
    children = list(OrderPart$new()),
    sibling_rule = "reduce",
    cancel_before_send = TRUE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"either": {"children": [{"order": {}}], "sibling_rule": "reduce", "cancel_before_send": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("either false builds the document Python builds", {
  part <- EitherPart$new(
    children = list(OrderPart$new()),
    sibling_rule = "reduce",
    cancel_before_send = FALSE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"either": {"children": [{"order": {}}], "sibling_rule": "reduce"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
