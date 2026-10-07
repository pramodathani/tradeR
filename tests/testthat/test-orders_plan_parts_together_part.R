test_that("together bare builds the document Python builds", {
  other <- list(
    instrument_id = "other-instrument-id"
  )
  part <- TogetherPart$new(
    children = list(OrderPart$new(), OrderPart$new(instrument = other))
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"together": {"children": [{"order": {}}, {"order": {"instrument_id": "other-instrument-id"}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("together full builds the document Python builds", {
  part <- TogetherPart$new(
    children = list(OrderPart$new()),
    group_margin = FALSE,
    hedge_benefit = TRUE,
    done_when = "all_filled"
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"together": {"children": [{"order": {}}], "group_margin": false, "hedge_benefit": true, "done_when": "all_filled"}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
