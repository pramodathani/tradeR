test_that("the base class signals NotImplementedError naming the class", {
  expect_error(
    PlanPart$new()$document(),
    "PlanPart does not describe a part of a plan",
    class = "NotImplementedError"
  )
})

test_that("every part is a PlanPart", {
  part <- PriceCrosses$new(level = 995.0)
  expect_true(inherits(part, "PlanPart"))
})
