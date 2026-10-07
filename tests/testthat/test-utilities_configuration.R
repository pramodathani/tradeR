test_that("the environment file fills unset variables without replacing set ones", {
  environment_file <- withr::local_tempfile(
    lines = c(
      "TRADINGMACHINE_UBI_BASE_URL=http://from-file:8080",
      "TRADINGMACHINE_MONGODB_HOST=mongo-from-file",
      "TRADINGMACHINE_MONGODB_PORT=2003",
      "TRADINGMACHINE_MONGODB_USERNAME=user name",
      "TRADINGMACHINE_MONGODB_PASSWORD=p@ss:word"
    )
  )
  withr::local_envvar(
    c(
      TRADINGMACHINE_UBI_BASE_URL = "http://from-environment:8080",
      TRADINGMACHINE_MONGODB_HOST = NA,
      TRADINGMACHINE_MONGODB_PORT = NA,
      TRADINGMACHINE_MONGODB_USERNAME = NA,
      TRADINGMACHINE_MONGODB_PASSWORD = NA
    )
  )
  configuration <- Configuration$new(environment_file = environment_file)

  expect_equal(configuration$ubi_base_url, "http://from-environment:8080")
  expect_equal(configuration$mongodb_host, "mongo-from-file")
  expect_equal(
    configuration$mongodb_connection_string,
    "mongodb://user%20name:p%40ss%3Aword@mongo-from-file:2003/?authSource=admin"
  )
})

test_that("a missing variable reads as NULL and properties refuse assignment", {
  withr::local_envvar(
    c(
      TRADINGMACHINE_MONGODB_DB = NA
    )
  )
  configuration <- Configuration$new(load_environment_file = FALSE)

  expect_null(configuration$mongodb_database_name)
  expect_error(configuration$ubi_base_url <- "x", "read-only")
})
