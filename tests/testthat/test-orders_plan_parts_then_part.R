test_that("then bare builds the document Python builds", {
  part <- ThenPart$new(first = OrderPart$new())
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"then": {"first": {"order": {}}}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("then full builds the document Python builds", {
  part <- ThenPart$new(
    first = OrderPart$new(),
    each_fill = OrderPart$new(side = "protect"),
    on_complete = OrderPart$new(side = "close"),
    cancel_first_on_child_fill = TRUE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"then": {"first": {"order": {}}, "each_fill": {"order": {"side": "protect"}}, "on_complete": {"order": {"side": "close"}}, "cancel_first_on_child_fill": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
