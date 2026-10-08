# examples/

These 468 programs are R translations of the Python library's example programs in `/home/pramod/Projects/tradingmachine/examples/`, made on 2026-10-07 by nine parallel helpers working from one brief. Each Python file `examples/<path>/<program>.py` became `examples/<same path>/<program>.R`, and the two trees match file for file.

## Shape

Each program keeps the Python shape: a `#'` block for the module docstring, one R6 class with the Python class's name and methods, `#'` tags as the docstrings of the class and its public methods (`#` lines for private ones), and `if (sys.nframe() == 0) { Program$new()$run() }` at the end. That guard is the R form of `if __name__ == "__main__":`: it is true under `Rscript` and false when the file is loaded with `source()`, which was checked before the translation began.

## Where they live

They were first written to `inst/examples/`, so that they would be installed with the package. R CMD check then noted that many paths are longer than the 100 bytes a tarball stores portably, because the tree mirrors the Python package five levels deep. They were moved to a top-level `examples/` folder, which `.Rbuildignore` keeps out of the built package, in the same way the Python library keeps its examples out of its wheel. The check is clean again.

## How they were checked

None has been run, because about 83 place real orders and others write to MongoDB. All 468 parse. A checker loaded the package, collected every class name and every method, field, active binding and generator function along each class's inheritance chain, and compared each `Class$` and `$method(` use in the programs against them, ignoring each program's own methods; it found no unknown name apart from mongolite's `$insert` and the backtest data frame's `Close` column, both correct. The helpers also checked each constructor argument by hand.

## Deliberate differences from the Python programs

- `TimeoutError`, `RuntimeError` and `SystemExit` have no class in `ErrorCatalogue`, so programs that raised them signal a plain error with `stop(..., call. = FALSE)`; `ValueError` uses `ErrorCatalogue$raise("ValueError", ...)`.
- `sprintf()` prints nothing for a `NULL` argument, where Python prints `None`, so many programs gained a small helper method (`text_of`, `display_text` and similar) that prints `"NULL"` instead. The order programs written by different helpers differ in whether they have `text_of`; behaviour is otherwise the same.
- A Python `try`/`except` that used `continue`, `break` or `return` became a `tryCatch` whose handler returns a marker, which the loop then acts on, because `return()` inside an R handler leaves only the handler.
- Dicts printed on one line are printed as one line of JSON with `jsonlite::toJSON(auto_unbox = TRUE, null = "null")`, whole numbers print without Python's `.0`, and positions in vectors count from 1.
- A `for` loop over a `Date` vector drops the class, so date loops run over `seq_along()`.
- `configuration_report.R` and the two authentication-error programs talk to MongoDB through mongolite; the shape of `connection$run()`'s answer in `configuration_report.R` is unverified.
- `option_type = "ce"` is passed in lower case as the Python originals do; both libraries pass it to UBI unchanged.
