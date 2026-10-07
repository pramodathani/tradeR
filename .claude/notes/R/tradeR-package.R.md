# R/tradeR-package.R

The package help page, and the one place that imports from each package in `DESCRIPTION`'s `Imports`.

Every call into `dotenv`, `httr2`, `jsonlite`, `mongolite` and `talib` is written with `::` inside an R6 method, and R CMD check does not look inside R6 class definitions, so on 2026-10-07 it reported "Namespaces in Imports field not imported from" for all five. One `@importFrom` per package, of a function the package really uses, records the dependency where the check can see it.
