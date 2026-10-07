# DESCRIPTION

The package is named `tradeR`, the name of the repository the user created on 2026-10-07. R package names may contain capitals, and `library(tradeR)` is how it is loaded.

## Licence

The Python library `tradingmachine` deliberately declares no licence until the user chooses one. R CMD check refuses a package with no `License` field at all, so `License: file LICENSE` points at a one-line `LICENSE` stating that no licence has been chosen and all rights are reserved. Replace both when the user picks one.

## Dependencies

| Package | Why it is needed |
|---|---|
| `R6` | Every class is an R6 class, because R6 gives reference semantics, active bindings for Python's properties, and `super$` calls, which is the closest match to Python classes |
| `httr2` | The HTTP client behind `UnifiedBrokerInterface`, the counterpart of `requests` |
| `jsonlite` | Encodes request bodies and parses UBI's answers |
| `mongolite` | Reads the api key and secret from MongoDB and stores asset baskets, the counterpart of `pymongo` |
| `dotenv` | Loads `.env`, the counterpart of `python-dotenv` |
| `talib` | The R binding of the TA-Lib C library, published on CRAN on 2026-10-05, which bundles the C library and needs only CMake; it covers 121 of the 150 TA-Lib functions the Python library calls, and the other 29 are simple arithmetic written in base R |

The tidyverse is deliberately left out, because the user's rules ask for simple R that a one-year R user can follow and base R covers everything needed.
