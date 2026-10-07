test_that("front loaded bare builds the document Python builds", {
  part <- FrontLoadedExecution$new(slices = 4, over_minutes = 30)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"front_loaded": {"slices": 4, "over_minutes": 30}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("front loaded full builds the document Python builds", {
  part <- FrontLoadedExecution$new(slices = 4, over_minutes = 30.5, urgency = 0.7)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"front_loaded": {"slices": 4, "over_minutes": 30.5, "urgency": 0.7}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
