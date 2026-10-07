# A connection to the Unified Broker Interface REST API

A thin REST client for the Unified Broker Interface (UBI). It reads its
api key and secret from the `settings` collection of the project's
MongoDB, exchanges them for an access token on the first request, sends
that token with every request, reconnects and retries once when UBI
answers HTTP 401, and turns every other failing status code into its own
error class from `UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE`.

UBI holds one access token for the whole application, and every client
shares it. `connect()` hands back the token in force when it was issued
at or after the most recent 07:00 and has not expired, so other clients,
such as a running Python script, keep working. Only the first
`connect()` after 07:00 on an older token mints a new one, and
`disconnect()` revokes the token for everyone; a client holding the old
token then gets HTTP 401, which this client answers by connecting again
and retrying once. Instruments share one client, which
`Instrument$shared_unified_broker_interface()` creates on first use.

## Public fields

- `token_expires_at`:

  The character expiry time of the access token as UBI reported it, or
  `NULL` before the first connection.

## Methods

### Public methods

- [`UnifiedBrokerInterface$new()`](#method-UnifiedBrokerInterface-initialize)

- [`UnifiedBrokerInterface$connect()`](#method-UnifiedBrokerInterface-connect)

- [`UnifiedBrokerInterface$disconnect()`](#method-UnifiedBrokerInterface-disconnect)

- [`UnifiedBrokerInterface$status()`](#method-UnifiedBrokerInterface-status)

- [`UnifiedBrokerInterface$get()`](#method-UnifiedBrokerInterface-get)

- [`UnifiedBrokerInterface$post()`](#method-UnifiedBrokerInterface-post)

- [`UnifiedBrokerInterface$put()`](#method-UnifiedBrokerInterface-put)

- [`UnifiedBrokerInterface$patch()`](#method-UnifiedBrokerInterface-patch)

- [`UnifiedBrokerInterface$delete()`](#method-UnifiedBrokerInterface-delete)

- [`UnifiedBrokerInterface$clone()`](#method-UnifiedBrokerInterface-clone)

------------------------------------------------------------------------

### `UnifiedBrokerInterface$new()`

Initialises the client and reads its api key and secret from MongoDB.

#### Usage

    UnifiedBrokerInterface$new(
      base_url = NULL,
      timeout_seconds = CLIENT_DEFAULT_TIMEOUT_SECONDS,
      project_configuration = NULL,
      credentials = NULL
    )

#### Arguments

- `base_url`:

  A character address of UBI, such as `"http://127.0.0.1:8080"`, or
  `NULL` to read `TRADINGMACHINE_UBI_BASE_URL`.

- `timeout_seconds`:

  A numeric number of seconds to wait for each response.

- `project_configuration`:

  A `Configuration` object, or `NULL` to create one that reads `.env`.

- `credentials`:

  A named list with `api_key` and `api_secret` to use instead of reading
  MongoDB, or `NULL` to read MongoDB.

#### Details

Errors: signals a plain error when no base url is configured, when
MongoDB holds no settings document for UBI, or when that document lacks
the api key or secret.

#### Returns

A new `UnifiedBrokerInterface` object, not yet connected.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$connect()`

Exchanges the api key and secret for UBI's shared access token: the one
in force when it was issued at or after the most recent 07:00 and has
not expired, or else a new one that other clients must reconnect to get.

#### Usage

    UnifiedBrokerInterface$connect()

#### Details

Errors: signals `AuthenticationError` when UBI refuses the key or
secret, another `UnifiedBrokerInterfaceError` subclass for any other
failing status, and `UnreachableError` when UBI cannot be reached.

#### Returns

The character access token.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$disconnect()`

Revokes the access token in force on the server, which ends every
client's session, including other R sessions and Python scripts.

#### Usage

    UnifiedBrokerInterface$disconnect()

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

A named list holding UBI's answer.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$status()`

Reports whether the session is connected and when its token expires.

#### Usage

    UnifiedBrokerInterface$status()

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

A named list holding UBI's answer.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$get()`

Sends a GET request.

#### Usage

    UnifiedBrokerInterface$get(path, params = NULL)

#### Arguments

- `path`:

  A character route, such as `"/api/instruments/ltp"`.

- `params`:

  A named list of query parameters, or `NULL`. A `NULL` value inside it
  is left out.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

The parsed JSON answer as a list, or `NULL` when the answer was not
JSON.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$post()`

Sends a POST request.

#### Usage

    UnifiedBrokerInterface$post(
      path,
      body = NULL,
      params = NULL,
      timeout_seconds = NULL
    )

#### Arguments

- `path`:

  A character route, such as `"/api/orders/place"`.

- `body`:

  A list to send as the JSON body, or `NULL` for none.

- `params`:

  A named list of query parameters, or `NULL`.

- `timeout_seconds`:

  A numeric number of seconds to wait for this response, or `NULL` for
  the client's default.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

The parsed JSON answer as a list, or `NULL` when the answer was not
JSON.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$put()`

Sends a PUT request.

#### Usage

    UnifiedBrokerInterface$put(path, body = NULL, params = NULL)

#### Arguments

- `path`:

  A character route, such as `"/api/orders/modify"`.

- `body`:

  A list to send as the JSON body, or `NULL` for none.

- `params`:

  A named list of query parameters, or `NULL`.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

The parsed JSON answer as a list, or `NULL` when the answer was not
JSON.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$patch()`

Sends a PATCH request.

#### Usage

    UnifiedBrokerInterface$patch(path, body = NULL, params = NULL)

#### Arguments

- `path`:

  A character route.

- `body`:

  A list to send as the JSON body, or `NULL` for none.

- `params`:

  A named list of query parameters, or `NULL`.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

The parsed JSON answer as a list, or `NULL` when the answer was not
JSON.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$delete()`

Sends a DELETE request.

#### Usage

    UnifiedBrokerInterface$delete(path, body = NULL, params = NULL)

#### Arguments

- `path`:

  A character route, such as `"/api/orders/cancel"`.

- `body`:

  A list to send as the JSON body, or `NULL` for none.

- `params`:

  A named list of query parameters, or `NULL`.

#### Details

Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI
refuses the request or cannot be reached.

#### Returns

The parsed JSON answer as a list, or `NULL` when the answer was not
JSON.

------------------------------------------------------------------------

### `UnifiedBrokerInterface$clone()`

The objects of this class are cloneable with this method.

#### Usage

    UnifiedBrokerInterface$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
client <- UnifiedBrokerInterface$new()
client$status()
client$get("/api/instruments/ltp", params = list(instrument_id = "..."))
} # }
```
