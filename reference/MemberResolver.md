# A builder of basket members from rows that name their instruments

A stored basket, a CSV file and the account's holdings all describe
their instruments as plain rows, each naming an instrument by
`instrument_id` or by exchange, segment and identity fields, beside a
weight or a quantity. `resolve()` sends every row to
`POST /api/instruments/details` at once and builds each member's
instrument from its entry of the answer, so a basket of five hundred
instruments costs one request rather than five hundred.

A row is a named list, such as
`list(exchange = "nse", segment = "equities", symbol = "INFY", weight = 0.6)`.

## Public fields

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` the details request is sent through.

## Methods

### Public methods

- [`MemberResolver$new()`](#method-MemberResolver-initialize)

- [`MemberResolver$resolve()`](#method-MemberResolver-resolve)

- [`MemberResolver$resolve_one()`](#method-MemberResolver-resolve_one)

- [`MemberResolver$clone()`](#method-MemberResolver-clone)

------------------------------------------------------------------------

### `MemberResolver$new()`

Initialises the resolver with the client it sends requests through.

#### Usage

    MemberResolver$new(unified_broker_interface = NULL)

#### Arguments

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to use, or `NULL` to share the one every
  instrument uses.

#### Details

Errors: signals `ValueError` when no client was given and the shared
client's base url or MongoDB credentials are not configured.

#### Returns

A new `MemberResolver` object.

------------------------------------------------------------------------

### `MemberResolver$resolve()`

Looks every row's instrument up in UBI and returns one member per row.

An index becomes a `NonTradeableInstrument` and anything else a
`TradeableInstrument`. A row that names its instrument by
`instrument_id` is looked up by that alone, and any other row by the
identity fields it has.

#### Usage

    MemberResolver$resolve(rows)

#### Arguments

- `rows`:

  A list of named lists, each with `instrument_id` or `exchange`,
  `segment` and the identity fields its shape needs, and optionally
  `weight`, `quantity` and `average_price`.

#### Details

Errors: signals `BasketMemberError` when `rows` is empty, a row names no
instrument, or UBI could not find one or more of the instruments, all of
which the message lists; and a `UnifiedBrokerInterfaceError` subclass
when the whole request was refused by, or failed on the way to, UBI.

#### Returns

A list of `BasketMember` objects, in the order of `rows`.

#### Examples

    rows <- list(
      list(
        exchange = "nse",
        segment = "equities",
        symbol = "INFY",
        weight = 0.5
      ),
      list(
        exchange = "nse",
        segment = "equities",
        symbol = "TCS",
        weight = 0.3
      ),
      list(
        exchange = "nse",
        segment = "equity_indices",
        symbol = "NIFTY",
        weight = 0.2
      )
    )
    for (member in MemberResolver$new()$resolve(rows)) {
      cat(member$format(), class(member$instrument)[[1]], "\n")
    }

    rows <- list(
      list(
        exchange = "nse",
        segment = "equities",
        symbol = "INFY"
      ),
      list(
        exchange = "nse",
        segment = "equities",
        symbol = "NOSUCHSHARE"
      )
    )
    tryCatch(
      MemberResolver$new()$resolve(rows),
      BasketMemberError = function(error) print(conditionMessage(error))
    )

------------------------------------------------------------------------

### `MemberResolver$resolve_one()`

Looks one row's instrument up in UBI.

#### Usage

    MemberResolver$resolve_one(row)

#### Arguments

- `row`:

  A named list with `instrument_id` or `exchange`, `segment` and the
  identity fields its shape needs.

#### Details

Errors: signals `BasketMemberError` when UBI could not find the
instrument; and a `UnifiedBrokerInterfaceError` subclass when the
request was refused by, or failed on the way to, UBI.

#### Returns

The `NonTradeableInstrument` for an index, or the `TradeableInstrument`
for anything else.

#### Examples

    resolver <- MemberResolver$new()
    idea <- resolver$resolve_one(
      list(
        exchange = "nse",
        segment = "equities",
        symbol = "IDEA"
      )
    )
    cat(idea$instrument_id, idea$last_price, "\n")

    nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    same_index <- resolver$resolve_one(
      list(
        instrument_id = nifty$instrument_id
      )
    )
    cat(class(same_index)[[1]], same_index$symbol, "\n")

------------------------------------------------------------------------

### `MemberResolver$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MemberResolver$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
resolver <- MemberResolver$new()
members <- resolver$resolve(
  list(
    list(exchange = "nse", segment = "equities", symbol = "INFY", weight = 0.6),
    list(exchange = "nse", segment = "equities", symbol = "TCS", weight = 0.4)
  )
)
} # }

## ------------------------------------------------
## Method `MemberResolver$resolve()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
rows <- list(
  list(
    exchange = "nse",
    segment = "equities",
    symbol = "INFY",
    weight = 0.5
  ),
  list(
    exchange = "nse",
    segment = "equities",
    symbol = "TCS",
    weight = 0.3
  ),
  list(
    exchange = "nse",
    segment = "equity_indices",
    symbol = "NIFTY",
    weight = 0.2
  )
)
for (member in MemberResolver$new()$resolve(rows)) {
  cat(member$format(), class(member$instrument)[[1]], "\n")
}

rows <- list(
  list(
    exchange = "nse",
    segment = "equities",
    symbol = "INFY"
  ),
  list(
    exchange = "nse",
    segment = "equities",
    symbol = "NOSUCHSHARE"
  )
)
tryCatch(
  MemberResolver$new()$resolve(rows),
  BasketMemberError = function(error) print(conditionMessage(error))
)
} # }

## ------------------------------------------------
## Method `MemberResolver$resolve_one()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
resolver <- MemberResolver$new()
idea <- resolver$resolve_one(
  list(
    exchange = "nse",
    segment = "equities",
    symbol = "IDEA"
  )
)
cat(idea$instrument_id, idea$last_price, "\n")

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
same_index <- resolver$resolve_one(
  list(
    instrument_id = nifty$instrument_id
  )
)
cat(class(same_index)[[1]], same_index$symbol, "\n")
} # }
```
