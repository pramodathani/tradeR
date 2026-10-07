test_that("sequence builds the document Python builds", {
  part <- SequencePart$new(
    children = list(OrderPart$new(), OrderPart$new(side = "sell"))
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"sequence": {"children": [{"order": {}}, {"order": {"side": "sell"}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("sequence one builds the document Python builds", {
  part <- SequencePart$new(children = list(OrderPart$new()))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"sequence": {"children": [{"order": {}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("nested tree builds the document Python builds", {
  part <- SequencePart$new(
    children = list(
      ThenPart$new(
        first = OrderPart$new(
          trigger = AnyCondition$new(
            list(TimeFrom$new("10:00"), CandleCloses$new(level = 101.0))
          )
        ),
        each_fill = EitherPart$new(
          children = list(
            OrderPart$new(
              side = "protect",
              pricing = NativeStopPricing$new(trigger_price = 95.0, limit_price = 94.0)
            ),
            OrderPart$new(
              side = "protect",
              pricing = FixedPricing$new(price = 110.0)
            )
          ),
          sibling_rule = "reduce"
        )
      ),
      RepeatPart$new(
        child = OrderPart$new(quantity = ParentFillQuantity$new(ratio = 1.0)),
        times = 2,
        every_minutes = 5
      )
    )
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"sequence": {"children": [{"then": {"first": {"order": {"trigger": {"any": [{"time_from": "10:00"}, {"candle_closes": {"level": 101.0}}]}}}, "each_fill": {"either": {"children": [{"order": {"side": "protect", "pricing": [{"native_stop": {"trigger_price": 95.0, "limit_price": 94.0}}]}}, {"order": {"side": "protect", "pricing": [{"fixed": {"price": 110.0}}]}}], "sibling_rule": "reduce"}}}}, {"repeat": {"child": {"order": {"quantity": {"parent_fill": {"ratio": 1.0}}}}, "times": 2, "every_minutes": 5}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
