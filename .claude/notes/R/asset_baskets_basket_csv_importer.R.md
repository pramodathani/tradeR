# R/asset_baskets_basket_csv_importer.R

Port of `src/tradingmachine/asset_baskets/basket_csv_importer.py`, written on 2026-10-07.

The Python library chose on 2026-09-28 a generic CSV importer, with download scripts meant to call it rather than write to MongoDB themselves. `import_file()` reads the file, turns its rows into member rows, lets `BasketStore$build()` resolve them in one request and build the class `kind` names, and saves the basket.

## Columns

Only `symbol` is required, or `instrument_id` instead. Column names are lower-cased and stripped, so the NSE's constituent files, whose header is `Company Name, Industry, Symbol, Series, ISIN Code`, import without editing, and their extra columns are ignored. A row's `exchange` and `segment` default to the arguments, `nse` and `equities`.

## Weights

A file without a `weight` column makes an equally weighted index, stored with `weighting` set to `equal`, so the missing weights are visible in the document. A weight may be a fraction or a percentage, with thousands separators or a trailing `%`, because every basket normalises its weights. A file that gives a weight or a quantity to only some rows is refused, because filling the gaps would be a guess.

## Reading the file the way pandas does

Python reads the file with `pd.read_csv(path, dtype=str, skipinitialspace=True)`. The R port reads it with `utils::read.csv()` and then copies pandas' choices, so the same file gives the same rows in both languages:

| pandas | R |
|---|---|
| `dtype=str` | `colClasses = "character"` |
| `skipinitialspace=True` removes spaces after each comma | Leading spaces are removed from every cell after reading (`strip.white` would also remove trailing ones, which pandas keeps until `_text` strips them) |
| Its default missing-value words (`""`, `NA`, `N/A`, `NULL`, `NaN`, `None`, `n/a`, `nan`, `null`, `#N/A` and the others) become NaN | The same 19 words, kept in `ASSET_BASKETS_CSV_MISSING_VALUES` from pandas' `STR_NA_VALUES`, become `NA` after the leading spaces are removed |
| The C parser drops a UTF-8 byte order mark | `fileEncoding = "UTF-8-BOM"` |
| Blank lines skipped, short rows filled with NaN | `read.csv` does the same by default |

`float(text)` in Python raises `ValueError` for text that is not a number; R's `as.numeric()` gives `NA` with a warning, so the port signals `ValueError` with Python's message, `could not convert string to float: '...'`. Python's `float` also accepts underscores between digits, such as `1_000`, which R does not; no constituent file writes numbers that way.

## Differences from Python

The constructor takes a third argument, `collection`, passed to `BasketStore` so tests can use a stand-in collection; see `asset_baskets_basket_store.R.md`. `path` is a character path; Python also accepts a `pathlib.Path`, which R has no counterpart for. A row's `symbol` key is kept with a `NULL` value when the row names its instrument only by `instrument_id`, as Python keeps `None`.
