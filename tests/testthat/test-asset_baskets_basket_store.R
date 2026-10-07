saved_watchlist_store <- function() {
  fake <- FakeDetailsClient$new()
  collection <- FakeMongoCollection$new()
  store <- BasketStore$new(
    project_configuration = Configuration$new(load_environment_file = FALSE),
    unified_broker_interface = fake,
    collection = collection
  )
  members <- MemberResolver$new(fake)$resolve(
    list(
      list(instrument_id = "infy-id", weight = 0.5),
      list(instrument_id = "tcs-id", weight = 0.5)
    )
  )
  basket <- AssetBasket$new("pair", members, unified_broker_interface = fake)
  list(
    store = store,
    collection = collection,
    basket = basket,
    fake = fake
  )
}

test_that("save writes the Python document shape with a MongoDB date", {
  setup <- saved_watchlist_store()
  document <- setup$store$save(
    setup$basket,
    effective_date = as.Date("2026-09-30"),
    source = "test"
  )

  expect_equal(document$effective_date, "2026-09-30")
  expect_equal(document$source, "test")
  expect_s3_class(document$updated_at, "POSIXct")

  run_call <- setup$collection$calls_named("run")[[1]]
  command <- jsonlite::fromJSON(run_call$command, simplifyVector = FALSE)
  expect_equal(command$createIndexes, "asset_baskets")
  expect_equal(command$indexes[[1]]$name, "name_1_effective_date_1")
  expect_true(command$indexes[[1]]$unique)
  expect_equal(command$indexes[[2]]$name, "linked_instrument_id_1")

  replace_call <- setup$collection$calls_named("replace")[[1]]
  expect_true(replace_call$upsert)
  expect_equal(
    jsonlite::fromJSON(replace_call$query, simplifyVector = FALSE),
    list(name = "pair", effective_date = "2026-09-30")
  )
  expect_match(replace_call$update, "\"updated_at\":\\{\"\\$date\":[0-9]+\\}")
  expect_match(replace_call$update, "\"weight\":0.5")
  expect_match(replace_call$update, "\"base_value\":100.0")
  expect_match(replace_call$update, "\"linked_instrument_id\":null")
})

test_that("load finds the latest version on or before a day", {
  setup <- saved_watchlist_store()
  setup$store$save(setup$basket, effective_date = "2026-01-01")
  setup$basket$remove_member(setup$basket$instruments[[2]])
  setup$store$save(setup$basket, effective_date = "2026-06-01")

  early <- setup$store$load("pair", as_of = "2026-03-01")
  late <- setup$store$load("pair", as_of = as.Date("2026-07-01"))

  expect_s3_class(early, "AssetBasket")
  expect_equal(early$size, 2)
  expect_equal(late$size, 1)
  iterate_call <- setup$collection$calls_named("iterate")[[1]]
  expect_equal(iterate_call$sort, "{\"effective_date\":-1}")
  expect_equal(iterate_call$limit, 1)
  expect_equal(
    jsonlite::fromJSON(iterate_call$query, simplifyVector = FALSE),
    list(name = "pair", effective_date = list("$lte" = "2026-03-01"))
  )
  expect_error(
    setup$store$load("pair", as_of = "2025-01-01"),
    "No basket named 'pair' is in effect on 2025-01-01",
    class = "BasketNotFoundError"
  )
})

test_that("names, history and delete read the collection", {
  setup <- saved_watchlist_store()
  setup$store$save(setup$basket, effective_date = "2026-06-01", source = "b")
  setup$store$save(setup$basket, effective_date = "2026-01-01", source = "a")

  expect_equal(setup$store$names(), "pair")
  expect_equal(setup$store$names(kind = "index"), character(0))
  history <- setup$store$history("pair")
  expect_equal(names(history), ASSET_BASKETS_HISTORY_COLUMNS)
  expect_equal(history$effective_date, c("2026-01-01", "2026-06-01"))
  expect_equal(history$source, c("a", "b"))
  expect_equal(history$size, c(2L, 2L))
  expect_s3_class(history$updated_at, "POSIXct")
  expect_null(setup$store$history("other"))

  expect_true(setup$store$delete("pair", as.Date("2026-01-01")))
  expect_false(setup$store$delete("pair", "2026-01-01"))
  expect_length(setup$collection$documents, 1)
})

test_that("load_for_instrument links the given instrument", {
  setup <- saved_watchlist_store()
  nifty <- MemberResolver$new(setup$fake)$resolve_one(
    list(instrument_id = "nifty-id")
  )
  setup$basket$linked_instrument <- nifty
  setup$store$save(setup$basket, effective_date = "2026-01-01")

  found <- setup$store$load_for_instrument(nifty, as_of = "2026-02-01")
  expect_identical(found$linked_instrument, nifty)
  other <- MemberResolver$new(setup$fake)$resolve_one(
    list(instrument_id = "tcs-id")
  )
  expect_null(setup$store$load_for_instrument(other))
})

test_that("build picks the class the kind names", {
  setup <- saved_watchlist_store()
  rows <- list(
    list(instrument_id = "infy-id"),
    list(instrument_id = "tcs-id")
  )
  index <- setup$store$build(
    list(
      name = "two",
      kind = "index",
      weighting = "equal",
      linked_instrument_id = "nifty-id",
      members = rows
    )
  )
  expect_s3_class(index, "Index")
  expect_equal(index$linked_instrument$symbol, "NIFTY")
  watchlist <- setup$store$build(
    list(name = "two", kind = "watchlist", members = rows)
  )
  expect_s3_class(watchlist, "Watchlist")
  expect_error(
    setup$store$build(list(name = "mystery", kind = "hedge_fund", members = rows)),
    "The basket 'mystery' is stored with a kind this store does not know: kind='hedge_fund'",
    class = "AssetBasketError"
  )
})

test_that("a store without a configured database refuses to connect", {
  withr::local_envvar(TRADINGMACHINE_MONGODB_DB = NA)
  store <- BasketStore$new(
    project_configuration = Configuration$new(load_environment_file = FALSE),
    unified_broker_interface = FakeClient$new()
  )
  expect_error(store$names(), class = "ValueError")
})
