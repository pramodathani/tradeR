test_that("vwap bare builds the document Python builds", {
  part <- VwapExecution$new(slices = 8)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"vwap": {"slices": 8}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("vwap one weight builds the document Python builds", {
  part <- VwapExecution$new(slices = 8, volume_profile = list(1.0))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"vwap": {"slices": 8, "volume_profile": [1.0]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("vwap full builds the document Python builds", {
  part <- VwapExecution$new(
    slices = 8,
    over_minutes = 120,
    until = "15:00",
    volume_profile = list(3.0, 2.0, 1.5)
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"vwap": {"slices": 8, "over_minutes": 120, "until": "15:00", "volume_profile": [3.0, 2.0, 1.5]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("a volume profile given as a numeric vector of one is still an array", {
  part <- VwapExecution$new(slices = 8, volume_profile = c(1.5))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    digits = NA
  )
  expect_equal(
    as.character(actual),
    r"({"vwap":{"slices":8,"volume_profile":[1.5]}})"
  )
})
