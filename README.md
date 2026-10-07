# tradeR

tradeR is an R package in which an Indian market instrument is an R object. You name a share, a futures contract or an option once, and from that one object you get its candles, its live quote, its order book, its analysis methods, the orders you have placed in it, the positions you hold in it and the units of it sitting in your demat account. It can also send any of the synthetic order types UBI's order engine runs, such as a bracket, a trailing stop or an iceberg, and it can gather instruments into baskets, such as a portfolio, a watchlist or an index, which are priced and analysed the same way as one instrument.

It is a native R port of the sibling Python library `tradingmachine`, with the same classes, the same member names and the same behaviour, so a Python example translates line for line by writing `$` where Python writes `.`.

Nothing in this package talks to a broker. Every call goes to the sibling project `unified_broker_interface` (UBI), which runs on the same machine, speaks to ten Indian retail brokers and normalises what they say.

```r
library(tradeR)

infosys <- Equity$new(exchange = "nse", symbol = "INFY")

candles <- infosys$prices(days = 365)
strength <- infosys$relative_strength_index(window = 14, days = 365)
spread <- infosys$bid_offer_spread

placed <- infosys$buy_at_limit_price(quantity = 1, price = 1450, product = "cnc")
waiting <- infosys$open_orders
infosys$cancel_open_orders()
```

> [!CAUTION]
> This package places real orders with real money. `place_order()` and its thirty-two wrappers, the position methods, the holdings methods, every synthetic order class, `Portfolio$place_orders()`, `Portfolio$rebalance()` and `Account$flatten()` all reach a live broker account, and there is no paper trading mode and no simulator. A synthetic order can go on placing orders long after the call returns. `dry_run = TRUE` asks UBI to build the broker's request and hand it back unsent, which is the only rehearsal available.

## How it fits together

The package has four layers, each with one job, sitting on the UBI REST API.

| Layer | Files | What it does |
|---|---|---|
| Asset families | `R/assets_equities.R`, `R/assets_fixed_income.R`, `R/assets_commodities.R`, `R/assets_currencies.R`, `R/assets_funds.R`, `R/assets_mutual_funds.R` | One named class per UBI segment, such as `Equity` or `EquityIndexOption`, whose constructor asks only for what identifies one of its own contracts |
| Instruments | `R/assets_instruments.R` | Identity, candles, quotes, order book, orders and positions, inherited by every family class |
| Analysis | `R/assets_analysis_*.R` | Fourteen classes of candle analysis in one inheritance chain that `Instrument` and every basket inherit |
| Client | `R/unified_broker_interface_client.R` | The session, the token, one retry and typed errors, shared by every object in the R session |

The synthetic order classes in `R/orders_*.R` and `Account` in `R/accounts_account.R` send through the same client. The baskets in `R/asset_baskets_*.R` read every member's prices in one list request, inherit the same analysis classes, and are stored in MongoDB, because UBI keeps no index constituents or fund holdings.

## Mapping Python to R

The table below shows how a Python construct is written in this package.

| Python | R |
|---|---|
| `equities.Equity(exchange="nse", symbol="INFY")` | `Equity$new(exchange = "nse", symbol = "INFY")` |
| A property, `share.last_price` | An active binding, `share$last_price` |
| A method, `share.prices(days=30)` | A method, `share$prices(days = 30)` |
| A class method, `EquityOption.chain(...)` | A function on the class, `EquityOption$chain(...)` |
| `None` | `NULL`, or `NA` inside a data frame |
| A `pandas.DataFrame`, or `None` when there are no rows | A `data.frame`, or `NULL` when there are no rows |
| A `dict` | A named list |
| `except InstrumentError as error:` | `tryCatch(..., InstrumentError = function(error) ...)` |

The errors keep their Python names and hierarchy, so a handler for `UnifiedBrokerInterfaceError` catches every failure UBI reports, and one for `InstrumentError` catches every instrument problem.

## Requirements

The table below lists what must be installed and why.

| Requirement | Why |
|---|---|
| R 4.3 or later | The package was developed on R 4.6.1 |
| The system libraries for curl, OpenSSL, SASL and libuv | `httr2`, `mongolite` and the development tools compile against them |
| CMake | The `talib` package builds its bundled TA-Lib C library with it |
| Unified Broker Interface, running on `127.0.0.1:8080` | Every price and every order comes from it |
| MongoDB | Holds the api key and secret the client authenticates with, and the stored asset baskets |

On Ubuntu the system libraries are installed with:

```bash
sudo apt install -y libcurl4-openssl-dev libssl-dev libsasl2-dev libuv1-dev libgit2-dev libicu-dev libharfbuzz-dev libfribidi-dev libfreetype-dev libpng-dev libtiff-dev libjpeg-dev libfontconfig1-dev libxml2-dev cmake
```

## Getting started

1. **Install the R packages the library imports, and the development tools.**

   ```r
   install.packages(c("R6", "httr2", "jsonlite", "mongolite", "dotenv", "talib", "devtools", "testthat", "withr"))
   ```

2. **Install the package from the repository root.**

   ```r
   devtools::install()
   ```

3. **Give it the same `.env` file the Python library uses.** It reads the same variables, such as `TRADINGMACHINE_UBI_BASE_URL` and the `TRADINGMACHINE_MONGODB_` host, port, database, username and password, from a `.env` file in the working directory. Using the Python project's file means both libraries share one MongoDB, so a basket saved from one loads in the other. The file is excluded by `.gitignore` and should never be committed.

4. **Check the whole chain.** This proves the credentials, UBI and a broker that serves quotes:

   ```r
   library(tradeR)
   infosys <- Equity$new(exchange = "nse", symbol = "INFY")
   print(infosys)
   infosys$last_price
   ```

> [!NOTE]
> UBI holds one access token for the whole application, and every client shares it. Connecting hands back that token, so an R session and a running Python script that uses `tradingmachine` work side by side. Calling `disconnect()` revokes the token and ends every client's session, so if a long-running script suddenly starts seeing 401s, something else disconnected.

## Tests

The tests drive every class through a fake client and mocked HTTP responses, so they never reach UBI and never place an order.

```bash
Rscript -e 'devtools::test()'
Rscript -e 'lintr::lint_package()'
```

This package keeps no explanatory comments in source files. Reasoning, trade-offs and the record of where the R version differs from Python go into a sidecar note under `.claude/notes/`, mirroring the source tree, so `R/assets_equities.R` is documented by `.claude/notes/R/assets_equities.R.md`.
