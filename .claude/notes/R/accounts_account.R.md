# R/accounts_account.R

Port of `src/tradingmachine/accounts/account.py`, written on 2026-10-07.

`Account$flatten()` sends UBI's kill switch, `POST /api/orders/flatten`, which UBI built as a route rather than an order type. It halts every unfinished parent in the order engine, cancels every open order at every broker, waits for the cancellations to be confirmed, and only then closes every position with market orders at the broker holding each, waiting again until the brokers' positions show zero. The user chose on 2026-09-26 to keep `liquidate_all_positions` scoped to one instrument and to put flatten on a separate account object, because flatten acts on every instrument.

## The shared client

`Account$new()` takes the client from `Instrument$shared_unified_broker_interface()`. Sharing the client means the session holds one cached token and one place to reconnect after a 401, the same arrangement as the Python library.

## `confirm` is typed by the caller

UBI refuses the request unless the body carries `confirm` set to exactly `FLATTEN`. The method could fill that in itself, but then one stray `flatten()` call would unwind the account, which is exactly what UBI's confirm word exists to prevent. So `confirm` is a required argument with no default, and it is passed through unchecked, exactly as Python does; UBI answers HTTP 400, which becomes `BadRequestError`, for anything else. The test sends `"flatten"` in lower case to show the word is not checked or corrected locally.

## `dry_run` is sent as a real boolean

UBI reads `dry_run` with a plain Python `bool()`, so the string `"false"` would count as a dry run. The method sends `isTRUE(as.logical(dry_run))`, the counterpart of Python's `bool(dry_run)`, so the JSON always carries `true` or `false`. One difference: Python's `bool("false")` is `True`, while R's `as.logical("false")` is `FALSE`; a caller passing a string is misusing the argument in either language.

## The timeout

A flatten waits twice inside UBI and can take well over the client's default 30 seconds, so the method passes its own `timeout_seconds`, 120 by default, through the `post()` override. A timeout signals `UnreachableError`, but the flatten may have partly happened, so the documentation says to read the orders and positions before calling again rather than to retry.

## HTTP 207 is not an error

UBI answers 200 when everything was done and 207 when any part was not. Both are successes to the client, so nothing is signalled and the answer's `flat` field says whether the account is flat. The answer is returned as it came, a named list, because the caller needs the `closed` entries to see what is left.

## `parents` and `intent`

`parents` reads `GET /api/orders/parents` and builds a `data.frame` with `FrameBuilder`, so nested fields such as `body`, `parameters` and `legs` become list columns; it is `NULL` when no parent is open, as Python returns None. `intent()` reads `GET /api/orders/intents/<intent_id>`, the engine's stored answer to an order whose placement stopped waiting, kept five minutes by default.

The Python `Examples:` were translated into `@examples` inside `\dontrun{}`. The parents examples live on the class, because roxygen does not take examples on an active binding; `value_counts()` became `table()`.
