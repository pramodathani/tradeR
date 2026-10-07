# The UBI client

`UnifiedBrokerInterface` is the thin layer that actually speaks HTTP to
UBI. It logs in with UBI’s api key and secret, sends every request with
the access token, logs in again once when the token is refused, and
turns every failed answer into a typed condition. It knows nothing about
instruments or orders: callers give it a route such as
`/api/instruments/ltp` and get the parsed JSON back as R lists.
`Configuration` sits underneath it and says where UBI and MongoDB are.

You rarely use either class directly, because every instrument and the
account already share one client. The table below lists what the two
classes offer, for the times you do.

| Kind | Member | Description |
|----|----|----|
| class | [`UnifiedBrokerInterface`](#unifiedbrokerinterface) | A connection to UBI’s REST API |
| method | [`connect`](#connect) | Exchanges the api key and secret for an access token |
| method | [`disconnect`](#disconnect) | Revokes the access token for every client |
| method | [`status`](#status) | Reports whether the session is connected and when it expires |
| method | [`get`](#get), [`post`](#post), [`put`](#put), [`patch`](#patch), [`delete`](#delete) | Send one request to any UBI route |
| field | [`token_expires_at`](#token_expires_at) | When the current token expires, as UBI reported it |
| class | [`Configuration`](#configuration) | The settings for one R session, read from the environment on first use |

## UnifiedBrokerInterface

The constructor is called as
`UnifiedBrokerInterface$new(base_url = NULL, timeout_seconds = 30, project_configuration = NULL, credentials = NULL)`.

The constructor finds UBI’s address and reads UBI’s api key and secret,
from MongoDB unless you hand them over in `credentials`. It does not
connect: the first request connects on its own. The class lives in
`R/unified_broker_interface_client.R`, and its reference page is
[`UnifiedBrokerInterface`](https://pramodathani.github.io/tradeR/reference/UnifiedBrokerInterface.md).

#### Parameters

The table below lists the constructor’s arguments. The last one,
`credentials`, exists only in the R port; the Python client always reads
MongoDB.

| Name | Type | Required | Default | Description |
|----|----|----|----|----|
| `base_url` | character or `NULL` | No | `NULL` | UBI’s address, such as `http://127.0.0.1:8080`. `NULL` reads `TRADINGMACHINE_UBI_BASE_URL`. |
| `timeout_seconds` | numeric | No | `30` | How long to wait for each response |
| `project_configuration` | `Configuration` or `NULL` | No | `NULL` | Where to read the base url and the MongoDB settings from. `NULL` builds a plain [`Configuration`](#configuration). |
| `credentials` | named list or `NULL` | No | `NULL` | A named list with `api_key` and `api_secret` to use instead of reading MongoDB, or `NULL` to read MongoDB. It lets tests and scripts that already hold the key build a client without a database. |

#### Example

This example builds a client of its own and reads the session status.
The status request sends a real connect first, so under the rules in
[One token for everyone](#one-token-for-everyone) it would mint a new
token, and log out every other client, if UBI’s current token was issued
before the latest 07:00. Its output was not captured.

``` r

library(tradeR)

unified_broker_interface <- UnifiedBrokerInterface$new()
print(unified_broker_interface$status())
```

The example below builds a client from a key and secret held in the
session’s own environment variables rather than in MongoDB, and installs
it as the client every instrument shares. The variable names here are
only an illustration; the package reads no such variables itself.

``` r

own_client <- UnifiedBrokerInterface$new(
  credentials = list(
    api_key = Sys.getenv("MY_UBI_API_KEY"),
    api_secret = Sys.getenv("MY_UBI_API_SECRET")
  )
)
Instrument$set_shared_unified_broker_interface(own_client)
```

#### Returns

The constructor returns the client, with `token_expires_at` set to
`NULL`.

#### Errors

The table below lists the conditions the constructor can signal. They
are plain R errors from [`stop()`](https://rdrr.io/r/base/stop.html),
where the Python client raises `ValueError`.

| Condition | When |
|----|----|
| A plain R error | No base url is configured, or MongoDB has no `settings` document for UBI, or the document, or the `credentials` list, has no `api_key` or no `api_secret` |

### Where the key and secret come from

Unless `credentials` is given, the client does not read UBI’s
credentials from the environment. It reads them once, in the
constructor, from this project’s own MongoDB, from the `settings`
collection document whose `broker_name` is `unified_broker_interface`.
The document looks like the one below; the values are placeholders, and
they must match the same document in UBI’s own MongoDB.

``` json
{
  "broker_name": "unified_broker_interface",
  "api_key": "<the key UBI has in its own settings>",
  "api_secret": "<the secret UBI has in its own settings>"
}
```

The MongoDB connection is opened with the mongolite package and closed
by [`on.exit()`](https://rdrr.io/r/base/on.exit.html) as soon as the
document has been read, so no database connection stays open for the
life of the client. The R package reads the same environment variables
and the same MongoDB as the Python library, so both can share one
document. No code in this package creates the document;
[Configuration](https://pramodathani.github.io/tradeR/articles/get-started-configuration.html#the-mongodb-settings-document)
shows how to seed it.

### One token for everyone

UBI holds a single access token for the whole application, not one per
client, and every client shares it: R sessions, Python scripts and UBI’s
own REST API test page alike. The rules that govern it come from UBI,
and [How the token lives and
dies](https://pramodathani.github.io/unified_broker_interface/rest-api/session/#how-the-token-lives-and-dies)
on the UBI site has them in full. The three that matter here are listed
below.

1.  A `connect` returns the token already in force when it was issued at
    or after the most recent 07:00 and has not expired, so a client that
    connects later in the day gets the same token and every other client
    keeps working.
2.  Only the first `connect` after 07:00, when the token in force is
    older, mints a new token. Every other client still holding the old
    one then starts getting HTTP 401, including UBI’s own REST API test
    page, until it connects again.
3.  A `disconnect` revokes the token for everyone, not only for the
    client that sent it. A token is accepted for one day by default, set
    by UBI’s `UNIFIED_BROKER_INTERFACE_API_TOKEN_TTL_SECONDS`.

So a token held by this package can be refused at any moment, either
because the first connect of a new day replaced it or because someone
disconnected. The client does not check `token_expires_at` before a
request. It sends the request, and on a 401 it throws the token away,
connects again and retries exactly once.

That is also why every instrument shares one client through
[`Instrument$shared_unified_broker_interface()`](https://pramodathani.github.io/tradeR/articles/guide-instruments.html#shared_unified_broker_interface).
One client per R session means one login and one retry path, rather than
many clients each tripping over the same refused token.

### The retry on 401

The sequence below shows a `get` whose token has gone stale. The retry
happens once only: a second 401 is signalled as
[`AuthenticationError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#authenticationerror),
so a wrong key or secret cannot cause a loop, and `connect` itself never
retries.

``` mermaid

sequenceDiagram
    autonumber
    participant You as Your code
    participant Client as UBI client
    participant UBI as UBI
    You->>Client: get("/api/instruments/ltp", params)
    Client->>UBI: GET with the stale access-token
    UBI-->>Client: 401 Invalid access token
    Client->>Client: forget the token
    Client->>UBI: POST /api/session/connect<br/>api-key and api-secret headers
    UBI-->>Client: 200 with access-token and expires_at
    Client->>UBI: GET again with the new access-token
    UBI-->>Client: 200 with the quote
    Client-->>You: the parsed JSON
```

If the second attempt also fails, the client signals the condition that
matches its status code, as described under [How failures become
conditions](#how-failures-become-conditions).

## connect

The method is called as `connect()`, and it sends
`POST /api/session/connect`.

This method sends the api key and secret as the `api-key` and
`api-secret` headers and keeps the access token UBI returns, with its
expiry in `token_expires_at`. Under the rules above, that is the token
already in force when it was issued at or after the most recent 07:00,
and a new one only on the first connect after 07:00. You do not need to
call it: the first request connects by itself, and a refused token
reconnects by itself.

#### Parameters

This method takes no arguments.

#### Returns

The access token as a character value.

#### Errors

The table below lists the conditions the method can signal.

| Condition | When |
|----|----|
| [`AuthenticationError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#authenticationerror) | UBI refused the key or secret |
| [`UnreachableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unreachableerror) | UBI could not be reached |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure |

## disconnect

The method is called as `disconnect()`, and it sends
`DELETE /api/session/disconnect`.

This method revokes the access token on UBI, which ends the session for
every client at once, not only this one, and clears the client’s own
copy. That includes other R sessions and any running Python script. The
next request made through any client connects again.

#### Parameters

This method takes no arguments.

#### Returns

UBI’s answer as a named list, such as `list(status = "disconnected")`.

#### Errors

The table below lists the conditions the method can signal.

| Condition | When |
|----|----|
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | UBI reported a failure or could not be reached |

## status

The method is called as `status()`, and it sends
`GET /api/session/status`.

This method asks UBI whether the token is valid and when it expires.
Like every request it connects first if the client has no token yet.

#### Parameters

This method takes no arguments.

#### Returns

UBI’s answer as a named list, such as
`list(status = "connected", expires_at = "...")`.

#### Errors

The table below lists the conditions the method can signal.

| Condition | When |
|----|----|
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | UBI reported a failure or could not be reached |

## Sending requests

The five methods in this section send one authenticated request to any
route and return the parsed JSON. They are what every other class in the
package is built on, and they all behave the same way: connect first if
there is no token, send the request with the `access-token` header,
retry once on a 401, and signal the condition that matches any other
failure status.

The table below lists their arguments together, because they share them.

| Name | Type | Required | Default | Description |
|----|----|----|----|----|
| `path` | character | Yes |  | The route, starting with `/api/` |
| `params` | named list or `NULL` | No | `NULL` | Query string parameters. A `NULL` value inside the list is left out. |
| `body` | a list, or `NULL` | No | `NULL` | The request body, sent as JSON with every length-one vector written as a scalar. `get` takes none. |
| `timeout_seconds` | numeric or `NULL` | No | `NULL` | `post` only. The seconds to wait for this one response, or `NULL` for the client’s own timeout. |

Because a length-one vector in `body` is written as a JSON scalar, a
field that must be a JSON array has to be built with
[`list()`](https://rdrr.io/r/base/list.html) rather than
[`c()`](https://rdrr.io/r/base/c.html), or a one-element array would be
sent as a single value.

Each method returns the parsed JSON body as R lists, with objects as
named lists and arrays as unnamed lists, or `NULL` when the body is
empty or not JSON. Each signals a subclass of
[`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror)
chosen by the status code when UBI answers with a failure, and
[`UnreachableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unreachableerror)
when no answer arrives.

### get

The method is called as `get(path, params = NULL)`, and it sends a `GET`
to any route.

This method sends a GET request. Every read in the package, from an
instrument lookup to a quote, goes through it.

#### Example

This example reads a last price through the shared client. Its output
was not captured, but the same route answered 1226.0 for RELIANCE
through
[`last_price`](https://pramodathani.github.io/tradeR/articles/guide-market-data.html#last_price)
when the Python library read it on 2026-09-26.

``` r

shared_client <- Instrument$shared_unified_broker_interface()
answer <- shared_client$get(
  "/api/instruments/ltp",
  params = list(
    exchange = "nse",
    segment = "equities",
    symbol = "RELIANCE"
  )
)
print(answer[["last_price"]])
```

### post

The method is called as
`post(path, body = NULL, params = NULL, timeout_seconds = NULL)`, and it
sends a `POST` to any route.

This method sends a POST request with a JSON body. `post` alone takes a
`timeout_seconds` for one slow request, which exists for
[`Account$flatten()`](https://pramodathani.github.io/tradeR/articles/guide-account.md),
because closing several positions one after another can take well over
thirty seconds. Placing an order goes through `post`, so a POST to
`/api/orders/place` without `dry_run = TRUE` in the body is a real
order.

### put

The method is called as `put(path, body = NULL, params = NULL)`, and it
sends a `PUT` to any route.

This method sends a PUT request with a JSON body.

### patch

The method is called as `patch(path, body = NULL, params = NULL)`, and
it sends a `PATCH` to any route.

This method sends a PATCH request with a JSON body. UBI has no PATCH
route today, so a PATCH gets HTTP 405 from UBI’s web framework, which
the client signals as
[`ServerError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#servererror).
The method is there so that a future route needs no change here.

### delete

The method is called as `delete(path, body = NULL, params = NULL)`, and
it sends a `DELETE` to any route.

This method sends a DELETE request. It accepts a body as well as query
parameters, because UBI’s order routes read both.

### How failures become conditions

UBI reports a failure as a status code and a JSON body, and has no
error-type field to switch on, so the status code alone chooses the
condition class, looked up in the package constant
[`UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE`](https://pramodathani.github.io/tradeR/reference/UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE.md),
with `ServerError` for any status it does not list. The message is taken
from the body’s `error` field, or from its `status_message` when there
is no `error`, which is how UBI’s order engine explains a 504, or else
it reads `UBI returned HTTP <status>`. When the body lists brokers UBI
passed over, their names and reasons are added to the message. The whole
body is kept in the condition’s `detail` element, and the status code in
its `status_code` element.
[Errors](https://pramodathani.github.io/tradeR/articles/guide-errors.html#which-status-becomes-which-error)
has the full table of status codes.

## token_expires_at

`token_expires_at` is a public field holding the character time the
current token expires, exactly as UBI reported it, or `NULL` before the
first connect and after a disconnect. The client never reads it; it is
there for code that wants to show the expiry or plan around it.

## Configuration

The constructor is called as
`Configuration$new(environment_file = NULL, load_environment_file = TRUE)`.

[`Configuration`](https://pramodathani.github.io/tradeR/reference/Configuration.md),
in `R/utilities_configuration.R`, is the one place that knows which
environment variable holds which setting. It reads nothing when it is
created or when the package is loaded. The first time one of its active
bindings is read, it loads the `.env` file once, if asked to, and then
every value is read from the session’s environment at that moment.

#### Parameters

The table below lists the constructor’s arguments.

| Name | Type | Required | Default | Description |
|----|----|----|----|----|
| `environment_file` | character or `NULL` | No | `NULL` | The path of a `.env` file to load, or `NULL` for the file named `.env` in the working directory. Unlike the Python library, the R port does not search the parent directories, and a missing file is skipped silently. |
| `load_environment_file` | logical | No | `TRUE` | `FALSE` to load no file at all and rely only on variables already set |

#### Active bindings

The table below lists what the object reports and which variable each
value comes from. Every value is a character value, or `NULL` when the
variable is not set.

| Active binding | Environment variable |
|----|----|
| `ubi_base_url` | `TRADINGMACHINE_UBI_BASE_URL` |
| `mongodb_host` | `TRADINGMACHINE_MONGODB_HOST` |
| `mongodb_port` | `TRADINGMACHINE_MONGODB_PORT` |
| `mongodb_database_name` | `TRADINGMACHINE_MONGODB_DB` |
| `mongodb_username` | `TRADINGMACHINE_MONGODB_USERNAME` |
| `mongodb_password` | `TRADINGMACHINE_MONGODB_PASSWORD` |
| `mongodb_connection_string` | Built from the four MongoDB connection values above, as `mongodb://<username>:<password>@<host>:<port>/?authSource=admin`, with the username and password escaped |

The variable names keep the `TRADINGMACHINE_` prefix of the Python
library on purpose, so both projects can read one `.env` file and talk
to one MongoDB. The method `reload()` forgets that the file was loaded,
so the next read loads it again. Note that loading a `.env` file never
overrides a variable that is already set, so a value set with
[`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html) or exported in
the shell always wins over the file.

#### Example

The three ways to point the package at its settings are shown below. The
last part hands a custom client to an instrument, which is how one
session can talk to a different UBI from another.

``` r

from_working_directory <- Configuration$new()
from_elsewhere <- Configuration$new(
  environment_file = "/etc/tradingmachine.env"
)
exported_only <- Configuration$new(load_environment_file = FALSE)

custom_client <- UnifiedBrokerInterface$new(
  project_configuration = from_elsewhere
)
reliance <- Equity$new(
  exchange = "nse",
  symbol = "RELIANCE",
  unified_broker_interface = custom_client
)
```

**A second client means a second login.**

A custom client holds its own copy of the token and makes its own
connect. Pointed at the same UBI, that connect normally hands back the
token already in force, so both clients keep working. If it happens to
be the first connect after 07:00 and UBI mints a new token, the shared
client’s next request gets a 401 and reconnects, which picks up the new
token. That costs an extra round trip but never fails, because each side
retries once.

#### Errors

`Configuration` signals nothing. A missing variable is reported as
`NULL`, and it is the client that signals an error when the base url or
the credentials are missing.

**Under the hood.**

Every request goes through one private method, `request`, which adds the
`access-token` header, sends the request with the httr2 package, and on
a first 401 clears the token and calls itself once more. A failure to
get any response, such as a refused connection or a timeout, arrives as
httr2’s `httr2_failure` condition and becomes `UnreachableError`, with
the original condition kept as its parent. See
[Session](https://pramodathani.github.io/unified_broker_interface/rest-api/session/)
on the UBI site for the three session routes, and
`.claude/notes/R/unified_broker_interface_client.R.md` for the reasoning
behind the R client.
