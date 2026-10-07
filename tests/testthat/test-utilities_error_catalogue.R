test_that("an error's class vector lists every ancestor in order", {
  catalogue <- ErrorCatalogue$new()

  expect_equal(
    catalogue$class_vector("EquityError"),
    c(
      "EquityError",
      "InstrumentError",
      "error",
      "condition"
    )
  )
  expect_equal(
    catalogue$class_vector("NotFoundError"),
    c(
      "NotFoundError",
      "UnifiedBrokerInterfaceError",
      "error",
      "condition"
    )
  )
})

test_that("a raised error is caught by its root class and keeps its fields", {
  caught <- tryCatch(
    ErrorCatalogue$raise(
      "NotFoundError",
      "no such instrument",
      status_code = 404L,
      detail = list(error = "no such instrument")
    ),
    UnifiedBrokerInterfaceError = function(error) error
  )

  expect_s3_class(caught, "NotFoundError")
  expect_equal(conditionMessage(caught), "no such instrument")
  expect_equal(caught$status_code, 404L)
  expect_equal(caught$detail$error, "no such instrument")
  expect_equal(ErrorCatalogue$name_of(caught), "NotFoundError")
})

test_that("an unknown error class is refused", {
  expect_error(ErrorCatalogue$new()$class_vector("NoSuchError"), "Not an error class")
})
