test_that("order bare builds the document Python builds", {
  part <- OrderPart$new()
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order full builds the document Python builds", {
  other <- list(
    instrument_id = "other-instrument-id"
  )
  part <- OrderPart$new(
    presets = list(Preset$new("scheduled", at_time = "10:00")),
    trigger = AllConditions$new(
      list(TimeAfter$new("09:30"), PriceCrosses$new(level = 99.0))
    ),
    side = "protect",
    pricing = PegPricing$new(reference = "mid"),
    cap = CapModifier$new(worst_price = 101.0),
    discretion = DiscretionModifier$new(points = 0.2),
    execution = TwapExecution$new(slices = 3, over_minutes = 15),
    inner_execution = IcebergExecution$new(visible_quantity = 5),
    guard = PostOnlyGuard$new(on_crossing = "reprice"),
    lifetime = Lifetime$new(after_minutes = 20),
    venue = PaperVenue$new(),
    quantity = PositionQuantity$new(product = "mis"),
    instrument = other,
    transaction_type = "sell",
    product = "nrml",
    validity = "ioc",
    tag = "planleg1",
    hold_limits = TRUE
  )
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"presets": [{"scheduled": {"at_time": "10:00"}}], "trigger": {"all": [{"time_after": "09:30"}, {"price_crosses": {"level": 99.0}}]}, "side": "protect", "pricing": [{"peg": {"reference": "mid"}}, {"cap": {"worst_price": 101.0}}, {"discretion": {"points": 0.2}}], "execution": [{"twap": {"slices": 3, "over_minutes": 15}}, {"iceberg": {"visible_quantity": 5}}], "guards": [{"post_only": {"on_crossing": "reprice"}}], "lifetime": [{"after_minutes": 20}], "venue": [{"session": "paper"}], "quantity": {"position": {"product": "mis"}}, "instrument_id": "other-instrument-id", "transaction_type": "sell", "product": "nrml", "validity": "ioc", "tag": "planleg1", "hold_limits": true}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order empty presets builds the document Python builds", {
  part <- OrderPart$new(presets = list())
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"presets": []}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order integer quantity builds the document Python builds", {
  part <- OrderPart$new(quantity = 25, hold_limits = FALSE)
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"quantity": 25, "hold_limits": false}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order cap only builds the document Python builds", {
  part <- OrderPart$new(cap = CapModifier$new(worst_price = 101.0))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"pricing": [{"cap": {"worst_price": 101.0}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order inner only builds the document Python builds", {
  part <- OrderPart$new(inner_execution = IcebergExecution$new(visible_quantity = 5))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"execution": [{"iceberg": {"visible_quantity": 5}}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})

test_that("order pre open builds the document Python builds", {
  part <- OrderPart$new(venue = PreOpenVenue$new(at_time = "09:05"))
  actual <- jsonlite::toJSON(
    part$document(),
    auto_unbox = TRUE,
    null = "null",
    digits = NA
  )
  expected <- r"({"order": {"venue": [{"session": "pre_open", "at_time": "09:05"}]}})"
  expect_equal(
    jsonlite::fromJSON(actual, simplifyVector = FALSE),
    jsonlite::fromJSON(expected, simplifyVector = FALSE)
  )
})
