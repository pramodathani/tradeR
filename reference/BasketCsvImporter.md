# A reader of CSV files into stored baskets

`import_file()` reads a CSV with a `symbol` column and, optionally,
`exchange`, `segment`, `weight`, `quantity` and `instrument_id` columns,
looks every row's instrument up in UBI in one list request, builds the
basket as the class its `kind` names, and saves it through
`BasketStore`. Column names are read without regard to case or
surrounding spaces, so the constituent files the NSE publishes, whose
header has `Symbol`, import as they are. A row without an exchange or a
segment takes the ones given to `import_file()`.

A file without a `weight` column makes an equally weighted index,
recorded with `weighting` set to `"equal"`, because the NSE's free
constituent files carry no weights. Weights may be fractions or
percentages, since every basket normalises them. Scripts that download
constituents and weights are meant to call this same importer.

The file is read the way the Python library reads it with pandas: every
value as text, leading spaces after a comma skipped, and the same words,
such as `NA`, `N/A` and `null`, read as an empty cell.

## Public fields

- `store`:

  The `BasketStore` the imported baskets are saved to.

## Methods

### Public methods

- [`BasketCsvImporter$new()`](#method-BasketCsvImporter-initialize)

- [`BasketCsvImporter$import_file()`](#method-BasketCsvImporter-import_file)

- [`BasketCsvImporter$clone()`](#method-BasketCsvImporter-clone)

------------------------------------------------------------------------

### `BasketCsvImporter$new()`

Initialises the importer with the store it saves to.

#### Usage

    BasketCsvImporter$new(
      project_configuration = NULL,
      unified_broker_interface = NULL,
      collection = NULL
    )

#### Arguments

- `project_configuration`:

  The `Configuration` to read the MongoDB settings from, or `NULL` to
  build one that reads the environment and the `.env` file.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to look instruments up through, or `NULL`
  to share the one every instrument uses.

- `collection`:

  A collection object with the methods of a
  [`mongolite::mongo()`](https://jeroen.r-universe.dev/mongolite/reference/mongo.html)
  connection for the store to use instead of connecting, such as a
  stand-in for tests, or `NULL` to connect on first use.

#### Returns

A new `BasketCsvImporter` object.

------------------------------------------------------------------------

### `BasketCsvImporter$import_file()`

Reads a CSV file, builds the basket it describes and saves it.

#### Usage

    BasketCsvImporter$import_file(
      path,
      name,
      kind = "index",
      exchange = "nse",
      segment = "equities",
      linked_instrument = NULL,
      effective_date = NULL,
      unmapped_weight = 0,
      source = "csv"
    )

#### Arguments

- `path`:

  The character path of the CSV file.

- `name`:

  The character name to store the basket under, such as `"NIFTY"`.

- `kind`:

  The character kind of basket to build, such as `"index"`,
  `"portfolio"` or `"mutual_fund_constituents"`.

- `exchange`:

  The character exchange of any row that does not give one.

- `segment`:

  The character segment of any row that does not give one, such as
  `"equities"`.

- `linked_instrument`:

  The `Instrument` whose contents the file describes, such as the NIFTY
  index, or `NULL`.

- `effective_date`:

  The first day the basket is in effect as a `Date` or a `"YYYY-MM-DD"`
  character value, or `NULL` for today.

- `unmapped_weight`:

  The numeric share of a fund, between 0 and 1, held outside the listed
  instruments.

- `source`:

  The character name of where the file came from, stored with the
  basket.

#### Details

Errors: signals `BasketCsvImportError` when the file has no `symbol`
column, has no rows, or gives a weight or quantity to only some rows;
`ValueError` when a weight or quantity is not a number;
`BasketMemberError` when UBI could not find one or more of the
instruments, all of which the message lists; `AssetBasketError` when
`kind` is not one the store knows; a plain error when the file cannot be
read; and a plain error from mongolite when MongoDB could not be reached
or refused the write.

#### Returns

The `AssetBasket` that was built and saved.

#### Examples

    importer <- BasketCsvImporter$new()
    directory <- tempfile()
    dir.create(directory)
    path <- file.path(directory, "it.csv")
    writeLines(
      c(
        "Symbol,Weight",
        "INFY,50",
        "TCS,30",
        "HCLTECH,20"
      ),
      path
    )
    basket <- importer$import_file(
      path,
      name = "example-index-csv",
      effective_date = "2026-09-01"
    )
    unlink(directory, recursive = TRUE)
    tryCatch(
      {
        cat(basket$format(), basket$weighting, "\n")
        print(basket$weights)
      },
      finally = importer$store$delete("example-index-csv", "2026-09-01")
    )

    directory <- tempfile()
    dir.create(directory)
    path <- file.path(directory, "banks.csv")
    writeLines(
      c(
        "Symbol",
        "HDFCBANK",
        "ICICIBANK"
      ),
      path
    )
    basket <- importer$import_file(
      path,
      name = "example-index-csv-equal",
      effective_date = "2026-09-01",
      source = "example"
    )
    unlink(directory, recursive = TRUE)
    tryCatch(
      {
        print(basket$weighting)
        print(basket$weights)
      },
      finally = importer$store$delete("example-index-csv-equal", "2026-09-01")
    )

    directory <- tempfile()
    dir.create(directory)
    path <- file.path(directory, "wrong.csv")
    writeLines(
      c(
        "Company,Weight",
        "Infosys,100"
      ),
      path
    )
    tryCatch(
      importer$import_file(path, name = "example-index-csv-wrong"),
      BasketCsvImportError = function(error) print(conditionMessage(error))
    )
    unlink(directory, recursive = TRUE)

------------------------------------------------------------------------

### `BasketCsvImporter$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BasketCsvImporter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
importer <- BasketCsvImporter$new()
nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
basket <- importer$import_file(
  "ind_nifty50list.csv",
  name = "NIFTY",
  kind = "index",
  linked_instrument = nifty,
  effective_date = "2026-09-30"
)
} # }

## ------------------------------------------------
## Method `BasketCsvImporter$import_file()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
importer <- BasketCsvImporter$new()
directory <- tempfile()
dir.create(directory)
path <- file.path(directory, "it.csv")
writeLines(
  c(
    "Symbol,Weight",
    "INFY,50",
    "TCS,30",
    "HCLTECH,20"
  ),
  path
)
basket <- importer$import_file(
  path,
  name = "example-index-csv",
  effective_date = "2026-09-01"
)
unlink(directory, recursive = TRUE)
tryCatch(
  {
    cat(basket$format(), basket$weighting, "\n")
    print(basket$weights)
  },
  finally = importer$store$delete("example-index-csv", "2026-09-01")
)

directory <- tempfile()
dir.create(directory)
path <- file.path(directory, "banks.csv")
writeLines(
  c(
    "Symbol",
    "HDFCBANK",
    "ICICIBANK"
  ),
  path
)
basket <- importer$import_file(
  path,
  name = "example-index-csv-equal",
  effective_date = "2026-09-01",
  source = "example"
)
unlink(directory, recursive = TRUE)
tryCatch(
  {
    print(basket$weighting)
    print(basket$weights)
  },
  finally = importer$store$delete("example-index-csv-equal", "2026-09-01")
)

directory <- tempfile()
dir.create(directory)
path <- file.path(directory, "wrong.csv")
writeLines(
  c(
    "Company,Weight",
    "Infosys,100"
  ),
  path
)
tryCatch(
  importer$import_file(path, name = "example-index-csv-wrong"),
  BasketCsvImportError = function(error) print(conditionMessage(error))
)
unlink(directory, recursive = TRUE)
} # }
```
