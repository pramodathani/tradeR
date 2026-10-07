test_that("using builds the document Python builds", {
  part <- UsingPart$new(
    order = OrderPart$new(
      execution = LadderExecution$new(from_price = 100.0, to_price = 96.0, steps = 4)
    ),
    each_piece = OrderPart$new(
      presets = list(Preset$new("bracket", stop_price = 94.0, stop_limit_price = 93.5))
    )
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"using": {"order": {"execution": [{"ladder": {"from_price": 100.0, "to_price": 96.0, "steps": 4}}]}, "each_piece": {"presets": [{"bracket": {"stop_price": 94.0, "stop_limit_price": 93.5}}]}}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
