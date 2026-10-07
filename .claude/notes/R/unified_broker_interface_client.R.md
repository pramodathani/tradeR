# R/unified_broker_interface_client.R

Port of `src/tradingmachine/unified_broker_interface/client.py`. The behaviour is the same: credentials from MongoDB's `settings` collection, a connection on first use, one reconnect and retry on HTTP 401, and one error class per failing status code.

## R-only additions

- `credentials`, an optional named list with `api_key` and `api_secret`, skips MongoDB. It exists so tests and scripts that already hold the key can build a client without a database. The Python client has no such argument.

## How requests are built

- The headers are added with one `do.call(httr2::req_headers, ...)`, because `req_headers()` takes each header as its own named argument and has no argument that accepts a list. An earlier version passed `.headers =`, which httr2 treated as a header literally named `.headers`; the mocked-response tests caught it on 2026-10-07.

- `httr2::req_error(is_error = function(response) FALSE)` stops httr2 from turning failing statuses into its own errors, so `raise_for_failure` can map them to UBI's classes exactly as the Python code does with `response.ok`.
- A connection failure arrives as an `httr2_failure` condition and becomes `UnreachableError`, the counterpart of catching `requests.RequestException`.
- Query parameters are written by `query_text` rather than `httr2::req_url_query()`, because the latter needs rlang's `!!!` splicing for a list of parameters, which the user's simplicity rule discourages. `NULL` values are dropped, as `requests` drops `None`, and a vector value repeats the key, as `requests` does for a list.
- A logical parameter is written `True` or `False`, the way `requests` writes a Python bool, although the library itself only ever sends the strings `"true"` and `"false"`.
- A body is written with `auto_unbox = TRUE`, so a length-one vector becomes a JSON scalar. A field that must be a JSON array therefore has to be built as a `list()`, never as an atomic vector, or a one-element array would be sent as a scalar.
