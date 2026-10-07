# The errors the Unified Broker Interface client signals

Each name is an error class and each value is its parent class.
`UnifiedBrokerInterfaceError` is the root, carrying a `status_code` and
a `detail` holding UBI's parsed answer, and every other class here is
one HTTP status code UBI returns, or a failure to reach UBI at all.

## Usage

``` r
UNIFIED_BROKER_INTERFACE_ERROR_PARENTS
```

## Format

A named character vector, one entry per error class:

- `UnifiedBrokerInterfaceError`:

  A failure reported by, or on the way to, the Unified Broker Interface.
  The condition carries `message`, a character description taken from
  the response's `error` field when it has one; `status_code`, the
  integer HTTP status code, or `NULL` when no response arrived; and
  `detail`, the parsed JSON body as a named list, or an empty list when
  there was none.

- `BadRequestError`:

  The request was malformed, such as a missing or invalid parameter
  (HTTP 400).

- `AuthenticationError`:

  The api key or secret was wrong, or the access token was missing,
  invalid or expired (HTTP 401).

- `LossLockoutError`:

  The day's loss is past UBI's daily loss limit, so the order engine
  refuses every new order (HTTP 403).

- `NotFoundError`:

  The requested instrument, profile or order does not exist (HTTP 404).

- `ConflictError`:

  The request conflicts with the account's state, such as an order no
  longer open, a position that is not held, or an order the engine read
  too late (HTTP 409).

- `OrderRejectedError`:

  The broker rejected the order, and the detail holds the order document
  (HTTP 422).

- `RateLimitError`:

  The broker chosen for the order is at its order limit, or has used its
  daily order cap (HTTP 429).

- `BrokerError`:

  No broker's data could be read for the request (HTTP 502).

- `ServiceUnavailableError`:

  The requested data is stale or not being kept, no broker can take the
  order, or a price reference cannot be resolved (HTTP 503).

- `OrderOutcomeUnknownError`:

  The order was sent but its outcome is unknown, and the detail holds
  the order document (HTTP 504).

- `ServerError`:

  A failure status that has no more specific class, such as HTTP 500 or
  405.

- `UnreachableError`:

  The Unified Broker Interface could not be reached, so no response
  arrived.
