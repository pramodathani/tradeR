# Configuration

The package needs to know three things: where UBI is, where the
project’s MongoDB is, and UBI’s api key and secret. The first two come
from environment variables, usually written in a `.env` file in the
directory R is started from. The third comes from a document in MongoDB.
The same MongoDB database also holds the stored asset baskets, which
need no configuration of their own. UBI’s order engine must also be
running, which is set up in UBI, not here.

The variable names, the MongoDB database and the settings document are
exactly the ones the Python library `tradingmachine` uses. Both
libraries can therefore share one `.env` file and one MongoDB, so a
basket saved from one loads in the other.

## Where each setting is read

The diagram below shows every setting and the code or container that
reads it. Solid arrows are read by the package; dashed arrows are read
by Docker Compose or by UBI.

``` mermaid

flowchart LR
    ENV[".env in the<br/>working directory"]
    ENV --> CFG["Configuration<br/>ubi_base_url<br/>mongodb_host, _port, _database_name,<br/>_username, _password"]
    ENV -.-> DC["docker compose<br/>ports and passwords"]
    DC -.-> MG[("MongoDB<br/>port 2003")]
    CFG --> CL["UnifiedBrokerInterface$new()"]
    CL -- "reads settings where<br/>broker_name is<br/>unified_broker_interface" --> MG
    MG -- "api_key, api_secret" --> CL
    CL -- "POST /api/session/connect" --> UBI["UBI<br/>127.0.0.1:8080"]
    CFG --> BS["BasketStore$new()"]
    BS -- "reads and writes the<br/>asset_baskets collection" --> MG
    UENV["UBI's own .env<br/>order engine settings"] -.-> UBI
```

## How the variables are read

[`Configuration`](https://pramodathani.github.io/tradeR/reference/Configuration.md),
in `R/utilities_configuration.R`, is the only place in the package that
reads the environment, and it reads nothing until a value is first asked
for. At that moment it loads `.env` from the working directory, unless
it was given another file, and reads the variables from the process
environment. Loading the package therefore never touches the file
system.

**Start R in the directory that holds `.env`.**

The Python library searches the working directory and then each of its
parents for `.env`. The R package looks only in the working directory,
so start R, or call [`setwd()`](https://rdrr.io/r/base/getwd.html), in
the directory holding the file, or name the file with
`Configuration$new(environment_file = "/path/to/.env")`. A missing file
is skipped silently, and the first sign of it is the error about the
base url in the table at the end of this page.

Three rules follow from the way the variables are read, and they explain
most surprises.

1.  A variable already set in the environment wins over the same
    variable in `.env`, because loading the file never overrides a value
    that is set. When a change to `.env` seems to have no effect, check
    [`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html) for a value
    set earlier, for example in `~/.Renviron` or by an earlier
    [`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html).
2.  The file is loaded once per `Configuration` object. A long-running R
    session that needs a changed `.env` calls
    [`reload()`](https://pramodathani.github.io/tradeR/reference/Configuration.html#method-Configuration-reload)
    on it.
3.  A missing variable is `NULL`, not an error. The client signals an
    error when it needs a value that is missing.

[The UBI
client](https://pramodathani.github.io/tradeR/articles/guide-client.html#configuration)
shows how to point a `Configuration` at a different file, or at no file
at all.

## The environment variables

`.env` is excluded by both `.gitignore` and `.Rbuildignore` and must
never be committed. The table below lists every variable in it, whether
the package reads it, whether the Docker containers read it, and the
default Compose falls back to.

| Variable | Read by the package | Read by the containers | Compose default | What it is |
|----|:--:|:--:|----|----|
| `TRADINGMACHINE_UBI_BASE_URL` | Yes |  |  | UBI’s address, `http://127.0.0.1:8080` |
| `TRADINGMACHINE_MONGODB_HOST` | Yes |  |  | The host MongoDB is reachable on |
| `TRADINGMACHINE_MONGODB_PORT` | Yes | Yes | `2003` | The published MongoDB port |
| `TRADINGMACHINE_MONGODB_DB` | Yes |  |  | The database holding the `settings` and `asset_baskets` collections |
| `TRADINGMACHINE_MONGODB_USERNAME` | Yes | Yes | `tradingmachine` | The MongoDB root user |
| `TRADINGMACHINE_MONGODB_PASSWORD` | Yes | Yes |  | The MongoDB root password |
| `TRADINGMACHINE_REDIS_HOST` |  |  |  | Redis’s host, for future code |
| `TRADINGMACHINE_REDIS_PORT` |  | Yes | `2002` | The published Redis port |
| `TRADINGMACHINE_REDIS_DB` |  |  |  | The Redis database number, for future code |
| `TRADINGMACHINE_REDIS_USERNAME` |  |  |  | `default`, the user Redis’s password belongs to |
| `TRADINGMACHINE_REDIS_PASSWORD` |  | Yes |  | Set with `--requirepass` on every start |
| `TRADINGMACHINE_TIMESCALEDB_HOST` |  |  |  | TimescaleDB’s host, for future code |
| `TRADINGMACHINE_TIMESCALEDB_PORT` |  | Yes | `2004` | The published TimescaleDB port |
| `TRADINGMACHINE_TIMESCALEDB_DB` |  | Yes | `tradingmachine` | The database created at first start |
| `TRADINGMACHINE_TIMESCALEDB_USERNAME` |  | Yes | `tradingmachine` | The superuser |
| `TRADINGMACHINE_TIMESCALEDB_PASSWORD` |  | Yes |  | The superuser’s password |

The package reads exactly six variables, all through `Configuration`,
whose names are kept in the package constants such as
`CONFIGURATION_UBI_BASE_URL_VARIABLE`. The variables keep their
`TRADINGMACHINE_` prefix on purpose, so that this package and the Python
library read one file. The Redis and TimescaleDB variables exist for the
containers and for code that has not been written yet. The Python
project’s file also holds a leftover `PYTHONPATH` line from before that
project became an installable library; it does nothing, and it is the
cause of the harmless Compose warning shown on
[Installation](https://pramodathani.github.io/tradeR/articles/get-started-installation.html#start-the-containers).

A `.env` with placeholder values is shown below. The hosts are
illustrative: on the development machine the databases are reached
through the machine’s local network address, while UBI is always reached
on `127.0.0.1`, because it binds only there.

``` bash
TRADINGMACHINE_UBI_BASE_URL=http://127.0.0.1:8080

TRADINGMACHINE_MONGODB_HOST=127.0.0.1
TRADINGMACHINE_MONGODB_PORT=2003
TRADINGMACHINE_MONGODB_DB=tradingmachine
TRADINGMACHINE_MONGODB_USERNAME=tradingmachine
TRADINGMACHINE_MONGODB_PASSWORD=<a password>

TRADINGMACHINE_REDIS_HOST=127.0.0.1
TRADINGMACHINE_REDIS_PORT=2002
TRADINGMACHINE_REDIS_DB=0
TRADINGMACHINE_REDIS_USERNAME=default
TRADINGMACHINE_REDIS_PASSWORD=<a password>

TRADINGMACHINE_TIMESCALEDB_HOST=127.0.0.1
TRADINGMACHINE_TIMESCALEDB_PORT=2004
TRADINGMACHINE_TIMESCALEDB_DB=tradingmachine
TRADINGMACHINE_TIMESCALEDB_USERNAME=tradingmachine
TRADINGMACHINE_TIMESCALEDB_PASSWORD=<a password>
```

The package builds its MongoDB address from those values as
`mongodb://<username>:<password>@<host>:<port>/?authSource=admin`, which
the active binding `mongodb_connection_string` returns. The
`authSource=admin` part is needed because the container creates its root
user in the `admin` database, and the username and password are
percent-encoded, so a generated password containing `@` or `/` is safe.

## The MongoDB settings document

UBI’s api key and secret are not environment variables. The client reads
them from the project’s MongoDB, in the database named by
`TRADINGMACHINE_MONGODB_DB`, from the `settings` collection document
whose `broker_name` is `unified_broker_interface`. The values must match
the same document in UBI’s own MongoDB, which is what UBI checks a login
against; [The `settings`
documents](https://pramodathani.github.io/unified_broker_interface/get-started/configuration/#the-settings-documents)
on the UBI site describes UBI’s side.

The document looks like the one below. The values here are placeholders.

``` json
{
  "broker_name": "unified_broker_interface",
  "api_key": "<the key UBI has in its own settings>",
  "api_secret": "<the secret UBI has in its own settings>"
}
```

No code in the package creates this document; it is seeded by hand once,
and if the Python library is already set up the document is already
there. One way to seed it from R is the snippet below, which upserts the
document so that running it twice does no harm. It uses the package’s
own `Configuration` to find MongoDB, and `mongolite`, which the package
already imports.

``` r

library(tradeR)

project_configuration <- Configuration$new()
settings_collection <- mongolite::mongo(
  collection = "settings",
  db = project_configuration$mongodb_database_name,
  url = project_configuration$mongodb_connection_string
)
query <- jsonlite::toJSON(
  list(
    broker_name = "unified_broker_interface"
  ),
  auto_unbox = TRUE
)
update <- jsonlite::toJSON(
  list(
    `$set` = list(
      api_key = "<the key UBI has in its own settings>",
      api_secret = "<the secret UBI has in its own settings>"
    )
  ),
  auto_unbox = TRUE
)
settings_collection$update(query = query, update = update, upsert = TRUE)
settings_collection$disconnect()
```

If UBI’s key or secret ever changes, this document must be changed to
match. Until it is, every request fails with
[`AuthenticationError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#authenticationerror)
after its one retry.

**Giving the client its credentials directly.**

The R client has one argument the Python client does not.
`UnifiedBrokerInterface$new(credentials = list(api_key = "...", api_secret = "..."))`
uses the key and secret it is given and does not read MongoDB at all,
which suits a script that already holds them. The
[`UnifiedBrokerInterface`](https://pramodathani.github.io/tradeR/reference/UnifiedBrokerInterface.md)
reference describes it.

The table below lists what goes wrong when part of this configuration is
missing, and when you find out. The first three are plain R errors,
signalled with [`stop()`](https://rdrr.io/r/base/stop.html), where the
Python library raises `ValueError`.

| What is missing | What you see | When |
|----|----|----|
| `TRADINGMACHINE_UBI_BASE_URL` | `Error: UBI base url is not configured: TRADINGMACHINE_UBI_BASE_URL` | The first instrument is built |
| The `settings` document | `Error: No settings document with broker_name='unified_broker_interface' in MongoDB database '...'` | The first instrument is built |
| `api_key` or `api_secret` in it | `Error: Settings document 'unified_broker_interface' is missing api_key or api_secret` | The first instrument is built |
| The right key or secret | [`AuthenticationError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#authenticationerror) | The first request |
| UBI itself | [`UnreachableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unreachableerror) | The first request |

## Stored baskets use the same database

Asset baskets, such as an index’s constituents or a portfolio, are kept
in the `asset_baskets` collection of the same database, because UBI
stores no index constituents or fund holdings.
[`BasketStore`](https://pramodathani.github.io/tradeR/reference/BasketStore.md)
finds MongoDB through the same `Configuration`, so there is nothing more
to set. The collection and its indexes are created by the first
[`save()`](https://pramodathani.github.io/tradeR/reference/BasketStore.html#method-BasketStore-save),
and there is no setup step. Because the Python library uses the same
collection, a basket saved from Python loads in R and the other way
round. [Asset
baskets](https://pramodathani.github.io/tradeR/articles/guide-asset-baskets.md)
explains how baskets are saved, imported from a CSV file and loaded.

## The order engine is configured in UBI

UBI places every order through its order engine, a separate UBI process,
and its settings live in UBI’s own `.env`, not in this project. There is
nothing to configure here. Until 2026-09-27 UBI also had a direct
placement mode, chosen with
`UNIFIED_BROKER_INTERFACE_API_ORDER_PLACEMENT`; that setting no longer
exists and UBI ignores it if it is still set.

The table below shows which parts of the package need the engine
running.

| Part of the package | Needs the order engine |
|----|:--:|
| Candles, quotes, discovery, positions, holdings and order book reads | No |
| Every order: `place_order()`, every price wrapper, the position and holdings methods, and every synthetic order class in `R/orders_*.R` | Yes |
| `modify_order()` and `cancel_order()` on an order placed outside the engine | No, UBI sends them from its API |
| `modify_order()` and `cancel_order()` on an order the engine placed, `cancel_parent()` and the halt in `Account$flatten()` | Yes |

[Order
engine](https://pramodathani.github.io/tradeR/articles/architecture-order-engine.md)
explains what the engine does with an order, including why it holds a
plain limit order.
