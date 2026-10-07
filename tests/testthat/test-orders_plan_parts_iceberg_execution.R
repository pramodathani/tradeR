test_that("iceberg bare builds the document Python builds", {
  part <- IcebergExecution$new(visible_quantity = 10)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"iceberg": {"visible_quantity": 10}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("iceberg full builds the document Python builds", {
  part <- IcebergExecution$new(visible_quantity = 10, randomise_percent = 20)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"iceberg": {"visible_quantity": 10, "randomise_percent": 20}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
