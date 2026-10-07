csv_importer <- function() {
  BasketCsvImporter$new(
    project_configuration = Configuration$new(load_environment_file = FALSE),
    unified_broker_interface = FakeDetailsClient$new(),
    collection = FakeMongoCollection$new()
  )
}

csv_file <- function(lines) {
  path <- tempfile(fileext = ".csv")
  writeLines(lines, path)
  path
}

test_that("a weighted file becomes a stated index and is saved", {
  importer <- csv_importer()
  path <- csv_file(
    c(
      " Symbol , Weight ,Industry",
      "INFY, \"1,500\",IT",
      "TCS,500%,IT",
      ",,"
    )
  )

  basket <- importer$import_file(path, name = "IT", effective_date = "2026-09-01")

  expect_s3_class(basket, "Index")
  expect_equal(basket$weighting, "stated")
  expect_equal(unname(basket$weights), c(0.75, 0.25))
  expect_equal(importer$store$history("IT")$source, "csv")
})

test_that("a file without weights becomes an equal index", {
  importer <- csv_importer()
  path <- csv_file(
    c(
      "symbol,exchange",
      "INFY,NA",
      "TCS,nse"
    )
  )
  basket <- importer$import_file(path, name = "pair")
  expect_equal(basket$weighting, "equal")
  expect_equal(basket$size, 2)
})

test_that("bad files are refused", {
  importer <- csv_importer()
  expect_error(
    importer$import_file(csv_file(c("Company,Weight", "Infosys,100")), name = "x"),
    "The file has no symbol column",
    class = "BasketCsvImportError"
  )
  expect_error(
    importer$import_file(csv_file(c("symbol", "")), name = "x"),
    "The file has no rows",
    class = "BasketCsvImportError"
  )
  expect_error(
    importer$import_file(csv_file(c("symbol,weight", "INFY,1", "TCS,")), name = "x"),
    "Only 1 of 2 rows give a weight",
    class = "BasketCsvImportError"
  )
  expect_error(
    importer$import_file(csv_file(c("symbol,weight", "INFY,abc")), name = "x"),
    "could not convert string to float: 'abc'",
    class = "ValueError"
  )
})
