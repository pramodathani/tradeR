test_that("preset bare builds the document Python builds", {
  part <- Preset$new("simple")
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"simple": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("preset settings builds the document Python builds", {
  part <- Preset$new(
    "bracket",
    stop_price = 990.0,
    stop_limit_price = 988.0,
    target_price = 1010.0
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"bracket": {"stop_price": 990.0, "stop_limit_price": 988.0, "target_price": 1010.0}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("preset list setting builds the document Python builds", {
  part <- Preset$new("ladder", prices = list(100.0), note = NULL, enabled = TRUE)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"ladder": {"prices": [100.0], "note": null, "enabled": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("a preset with no settings is an empty object, not an empty array", {
  actual <- jsonlite::toJSON(
    Preset$new("simple")$document(),
    auto_unbox = TRUE
  )
  expect_equal(
    as.character(actual),
    r"({"simple":{}})"
  )
})
