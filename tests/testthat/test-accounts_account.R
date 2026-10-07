test_that("flatten sends the confirm word unchecked and a real boolean", {
  fake <- FakeClient$new()
  fake$answers[["POST /api/orders/flatten"]] <- list(flat = TRUE)
  account <- Account$new(fake)

  outcome <- account$flatten(confirm = "flatten", dry_run = 1)

  request <- fake$last_request()
  expect_equal(request$path, "/api/orders/flatten")
  expect_identical(
    request$body,
    list(
      confirm = "flatten",
      dry_run = TRUE
    )
  )
  expect_true(outcome$flat)
})

test_that("parents is a frame, or NULL when none is open", {
  fake <- FakeClient$new()
  account <- Account$new(fake)
  fake$answers[["/api/orders/parents"]] <- list(parents = list())
  expect_null(account$parents)

  fake$answers[["/api/orders/parents"]] <- list(
    parents = list(
      list(parent_order_id = "p1", synthetic_type = "bracket", legs = list()),
      list(parent_order_id = "p2", synthetic_type = "grid", legs = list())
    )
  )
  parents <- account$parents
  expect_equal(parents$parent_order_id, c("p1", "p2"))
  expect_error(account$parents <- NULL, "read-only")
})

test_that("intent reads the intent route", {
  fake <- FakeClient$new()
  fake$answers[["/api/orders/intents/abc"]] <- list(intent_id = "abc", status = 200)
  expect_equal(Account$new(fake)$intent("abc")$status, 200)
  expect_equal(fake$last_request()$path, "/api/orders/intents/abc")
})

test_that("flatten passes its own timeout", {
  TimeoutClient <- R6::R6Class(
    "TimeoutClient",
    inherit = FakeClient,
    public = list(
      timeouts = c(),
      post = function(path, body = NULL, params = NULL, timeout_seconds = NULL) {
        self$timeouts <- c(
          self$timeouts,
          timeout_seconds
        )
        super$post(path, body, params, timeout_seconds)
      }
    )
  )
  fake <- TimeoutClient$new()
  account <- Account$new(fake)
  account$flatten(confirm = "FLATTEN", dry_run = TRUE)
  account$flatten(confirm = "FLATTEN", timeout_seconds = 30)
  expect_equal(fake$timeouts, c(120, 30))
})
