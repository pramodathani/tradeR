# DESCRIPTION

The package is named `tradeR`, the name of the repository the user created on 2026-10-07. R package names may contain capitals, and `library(tradeR)` is how it is loaded.

## Licence

The user chose the MIT licence on 2026-10-07, when the repository was made public on GitHub. It follows the layout `usethis::use_mit_license()` produces: `License: MIT + file LICENSE` in `DESCRIPTION`, a two-line `LICENSE` giving the year and copyright holder as CRAN's MIT template requires, and the full text in `LICENSE.md`, which GitHub reads to label the repository and `.Rbuildignore` keeps out of the built package. The Python library `tradingmachine` still declares no licence.

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

## Links

`URL` names the pkgdown site first and the GitHub repository second, because pkgdown reads the first `URL` entry as the site's address when it links pages together, and `BugReports` points at the repository's issues. Both were added on 2026-10-07, when the repository was made public and the site was set up.
