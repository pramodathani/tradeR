# The collection of baskets kept in the project's MongoDB

UBI knows nothing about what an index or a fund holds, so baskets are
kept in this project's own MongoDB, in the `asset_baskets` collection of
the database `Configuration` names. Each document is one version of one
basket, identified by its `name` and the `effective_date` it takes
effect, because an index is rebalanced and a fund's holdings change
every month; [`load()`](https://rdrr.io/r/base/load.html) finds the
version in effect on a given day. A document names each member by its
UBI `instrument_id` beside its readable identity fields, and
[`load()`](https://rdrr.io/r/base/load.html) rebuilds every member in
one list request.

The `kind` field of a document decides which class
[`load()`](https://rdrr.io/r/base/load.html) builds: `portfolio`,
`watchlist`, `index`, `exchange_traded_fund_constituents`,
`mutual_fund_constituents`, or `basket` for a plain `AssetBasket`.
`load_for_instrument()` finds the basket whose `linked_instrument_id` is
a given instrument, which is how `constituents` on an index or a fund
finds its contents.

The store shares its collection and document shape with the Python
library `tradingmachine`, so a basket saved from Python loads here and
the other way round. Dates are stored as `"YYYY-MM-DD"` text and
`updated_at` as a MongoDB date, exactly as Python stores them.

## Public fields

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` that rebuilt baskets send their requests
  through.

## Methods

### Public methods

- [`BasketStore$new()`](#method-BasketStore-initialize)

- [`BasketStore$save()`](#method-BasketStore-save)

- [`BasketStore$load()`](#method-BasketStore-load)

- [`BasketStore$load_for_instrument()`](#method-BasketStore-load_for_instrument)

- [`BasketStore$names()`](#method-BasketStore-names)

- [`BasketStore$history()`](#method-BasketStore-history)

- [`BasketStore$delete()`](#method-BasketStore-delete)

- [`BasketStore$build()`](#method-BasketStore-build)

- [`BasketStore$clone()`](#method-BasketStore-clone)

------------------------------------------------------------------------

### `BasketStore$new()`

Initialises the store with the configuration it connects with.

Nothing connects to MongoDB until the first read or write.

#### Usage

    BasketStore$new(
      project_configuration = NULL,
      unified_broker_interface = NULL,
      collection = NULL
    )

#### Arguments

- `project_configuration`:

  The `Configuration` to read the MongoDB settings from, or `NULL` to
  build one that reads the environment and the `.env` file.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` for rebuilt baskets, or `NULL` to share
  the one every instrument uses.

- `collection`:

  A collection object with the methods of a
  [`mongolite::mongo()`](https://jeroen.r-universe.dev/mongolite/reference/mongo.html)
  connection to use instead of connecting, such as a stand-in for tests,
  or `NULL` to connect to the `asset_baskets` collection of the
  configured database on first use.

#### Returns

A new `BasketStore` object.

------------------------------------------------------------------------

### `BasketStore$save()`

Stores a basket as the version of its name in effect from a date,
replacing any version already stored for that date.

#### Usage

    BasketStore$save(basket, effective_date = NULL, source = "user")

#### Arguments

- `basket`:

  The `AssetBasket` to store.

- `effective_date`:

  The first day this version is in effect as a `Date` or a
  `"YYYY-MM-DD"` character value, or `NULL` for today.

- `source`:

  The character name of where the members came from, such as `"user"`,
  `"csv"` or `"nse"`.

#### Details

Errors: signals `ValueError` when the project's MongoDB database name is
not configured; and a plain error from mongolite when MongoDB could not
be reached or refused the write.

#### Returns

The named list document that was stored, with `source` and `updated_at`,
a `POSIXct` in UTC.

#### Examples

    shares <- list(
      Equity$new(exchange = "nse", symbol = "IDEA"),
      Equity$new(exchange = "nse", symbol = "INFY")
    )
    store <- BasketStore$new()
    followed <- Watchlist$new(
      name = "example-watchlist-save",
      instruments = shares
    )
    document <- store$save(followed, source = "example")
    tryCatch(
      {
        cat(document$name, document$kind, document$effective_date, "\n")
        print(length(document$members))
      },
      finally = store$delete(document$name, document$effective_date)
    )

    followed <- Watchlist$new(
      name = "example-watchlist-versions",
      instruments = shares
    )
    dates <- c(
      "2026-01-01",
      "2026-07-01"
    )
    tryCatch(
      {
        for (effective_date in dates) {
          store$save(followed, effective_date = effective_date)
        }
        print(store$history("example-watchlist-versions")$effective_date)
      },
      finally = {
        for (effective_date in dates) {
          store$delete("example-watchlist-versions", effective_date)
        }
      }
    )

------------------------------------------------------------------------

### `BasketStore$load()`

Rebuilds the version of a basket in effect on a day.

#### Usage

    BasketStore$load(name, as_of = NULL)

#### Arguments

- `name`:

  The character name of the basket.

- `as_of`:

  The day as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for
  today.

#### Details

Errors: signals `BasketNotFoundError` when no version of the basket is
in effect on that day; `BasketMemberError` when UBI could not find one
or more of the stored instruments; `AssetBasketError` when the stored
kind is not one this store knows; and a plain error from mongolite when
MongoDB could not be reached.

#### Returns

The `AssetBasket` subclass the stored `kind` names, with its members
rebuilt in one request.

#### Examples

    shares <- list(
      Equity$new(exchange = "nse", symbol = "IDEA"),
      Equity$new(exchange = "nse", symbol = "INFY")
    )
    store <- BasketStore$new()
    followed <- Watchlist$new(
      name = "example-watchlist-load",
      instruments = shares
    )
    document <- store$save(followed)
    tryCatch(
      {
        loaded <- store$load("example-watchlist-load")
        print(loaded)
        print(loaded$labels)
      },
      finally = store$delete(document$name, document$effective_date)
    )

    tryCatch(
      store$load("example-watchlist-never-saved"),
      BasketNotFoundError = function(error) print(conditionMessage(error))
    )

------------------------------------------------------------------------

### `BasketStore$load_for_instrument()`

Rebuilds the basket that describes an instrument's contents, such as the
members of an index.

#### Usage

    BasketStore$load_for_instrument(instrument, as_of = NULL)

#### Arguments

- `instrument`:

  The `Instrument` whose contents to find, which becomes the basket's
  `linked_instrument`.

- `as_of`:

  The day as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for
  today.

#### Details

Errors: signals `BasketMemberError` when UBI could not find one or more
of the stored instruments; `AssetBasketError` when the stored kind is
not one this store knows; and a plain error from mongolite when MongoDB
could not be reached.

#### Returns

The `AssetBasket` subclass the stored `kind` names, or `NULL` when no
basket describes the instrument on that day.

#### Examples

    nifty_it <- EquityIndex$new(exchange = "nse", symbol = "NIFTYIT")
    members <- list()
    for (symbol in c(
      "INFY",
      "TCS"
    )) {
      share <- Equity$new(exchange = "nse", symbol = symbol)
      members[[length(members) + 1]] <- BasketMember$new(share)
    }
    it_index <- Index$new(
      name = "example-index-linked",
      members = members,
      weighting = "equal",
      linked_instrument = nifty_it
    )
    store <- BasketStore$new()
    document <- store$save(it_index)
    tryCatch(
      {
        found <- store$load_for_instrument(nifty_it)
        print(found)
        print(found$linked_instrument$symbol)
      },
      finally = store$delete(document$name, document$effective_date)
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    print(BasketStore$new()$load_for_instrument(idea))

------------------------------------------------------------------------

### `BasketStore$names()`

Lists the names of the stored baskets.

#### Usage

    BasketStore$names(kind = NULL)

#### Arguments

- `kind`:

  The character kind to list, such as `"index"`, or `NULL` for every
  kind.

#### Details

Errors: signals a plain error from mongolite when MongoDB could not be
reached.

#### Returns

A sorted character vector of basket names.

#### Examples

    print(BasketStore$new()$names())

    shares <- list(
      Equity$new(exchange = "nse", symbol = "IDEA"),
      Equity$new(exchange = "nse", symbol = "INFY")
    )
    store <- BasketStore$new()
    followed <- Watchlist$new(
      name = "example-watchlist-names",
      instruments = shares
    )
    document <- store$save(followed)
    tryCatch(
      print("example-watchlist-names" %in% store$names(kind = "watchlist")),
      finally = store$delete(document$name, document$effective_date)
    )

------------------------------------------------------------------------

### `BasketStore$history()`

Lists every stored version of a basket.

#### Usage

    BasketStore$history(name)

#### Arguments

- `name`:

  The character name of the basket.

#### Details

Errors: signals a plain error from mongolite when MongoDB could not be
reached.

#### Returns

A `data.frame` with one row per version, oldest first, holding `name`,
`kind`, `effective_date`, `source`, `size`, `linked_instrument_id` and
`updated_at`, or `NULL` when no version is stored.

#### Examples

    shares <- list(
      Equity$new(exchange = "nse", symbol = "IDEA"),
      Equity$new(exchange = "nse", symbol = "INFY")
    )
    store <- BasketStore$new()
    followed <- Watchlist$new(
      name = "example-watchlist-history",
      instruments = shares
    )
    store$save(followed, effective_date = "2026-03-01", source = "example")
    store$save(followed, effective_date = "2026-06-01", source = "example")
    tryCatch(
      {
        history <- store$history("example-watchlist-history")
        print(history[, c("name", "effective_date", "source", "size")])
      },
      finally = {
        store$delete("example-watchlist-history", "2026-03-01")
        store$delete("example-watchlist-history", "2026-06-01")
      }
    )

    print(BasketStore$new()$history("example-watchlist-never-saved"))

------------------------------------------------------------------------

### `BasketStore$delete()`

Deletes one stored version of a basket.

#### Usage

    BasketStore$delete(name, effective_date)

#### Arguments

- `name`:

  The character name of the basket.

- `effective_date`:

  The version's effective date as a `Date` or a `"YYYY-MM-DD"` character
  value.

#### Details

Errors: signals a plain error from mongolite when MongoDB could not be
reached.

#### Returns

A logical that is `TRUE` when a version was deleted and `FALSE` when
none matched.

#### Examples

    shares <- list(
      Equity$new(exchange = "nse", symbol = "IDEA"),
      Equity$new(exchange = "nse", symbol = "INFY")
    )
    store <- BasketStore$new()
    followed <- Watchlist$new(
      name = "example-watchlist-delete",
      instruments = shares
    )
    document <- store$save(followed, effective_date = "2026-09-01")
    print(store$delete("example-watchlist-delete", "2026-09-01"))

    print(store$delete("example-watchlist-missing", as.Date("2026-09-01")))

------------------------------------------------------------------------

### `BasketStore$build()`

Builds the basket a stored document describes, as the class its `kind`
names.

#### Usage

    BasketStore$build(document, linked_instrument = NULL)

#### Arguments

- `document`:

  A named list in the form `AssetBasket$document()` gives, with a
  `members` list naming each instrument.

- `linked_instrument`:

  The `Instrument` to link the basket to, or `NULL` to look up the
  document's `linked_instrument_id` when it has one.

#### Details

Errors: signals `BasketMemberError` when the document has no members, or
UBI could not find one or more of its instruments; and
`AssetBasketError` when the document's kind is not one this store knows.

#### Returns

The `AssetBasket` subclass the document's `kind` names.

#### Examples

    document <- list(
      name = "two IT shares",
      kind = "index",
      weighting = "equal",
      members = list(
        list(
          exchange = "nse",
          segment = "equities",
          symbol = "INFY"
        ),
        list(
          exchange = "nse",
          segment = "equities",
          symbol = "TCS"
        )
      )
    )
    basket <- BasketStore$new()$build(document)
    print(basket)
    print(basket$weights)

    document <- list(
      name = "mystery",
      kind = "hedge_fund",
      members = list(
        list(
          exchange = "nse",
          segment = "equities",
          symbol = "INFY"
        )
      )
    )
    tryCatch(
      BasketStore$new()$build(document),
      AssetBasketError = function(error) print(conditionMessage(error))
    )

------------------------------------------------------------------------

### `BasketStore$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BasketStore$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
store <- BasketStore$new()
store$save(my_index, effective_date = "2026-09-30", source = "csv")
nifty_basket <- store$load("NIFTY")
every_index <- store$names(kind = "index")
} # }

## ------------------------------------------------
## Method `BasketStore$save()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
shares <- list(
  Equity$new(exchange = "nse", symbol = "IDEA"),
  Equity$new(exchange = "nse", symbol = "INFY")
)
store <- BasketStore$new()
followed <- Watchlist$new(
  name = "example-watchlist-save",
  instruments = shares
)
document <- store$save(followed, source = "example")
tryCatch(
  {
    cat(document$name, document$kind, document$effective_date, "\n")
    print(length(document$members))
  },
  finally = store$delete(document$name, document$effective_date)
)

followed <- Watchlist$new(
  name = "example-watchlist-versions",
  instruments = shares
)
dates <- c(
  "2026-01-01",
  "2026-07-01"
)
tryCatch(
  {
    for (effective_date in dates) {
      store$save(followed, effective_date = effective_date)
    }
    print(store$history("example-watchlist-versions")$effective_date)
  },
  finally = {
    for (effective_date in dates) {
      store$delete("example-watchlist-versions", effective_date)
    }
  }
)
} # }

## ------------------------------------------------
## Method `BasketStore$load()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
shares <- list(
  Equity$new(exchange = "nse", symbol = "IDEA"),
  Equity$new(exchange = "nse", symbol = "INFY")
)
store <- BasketStore$new()
followed <- Watchlist$new(
  name = "example-watchlist-load",
  instruments = shares
)
document <- store$save(followed)
tryCatch(
  {
    loaded <- store$load("example-watchlist-load")
    print(loaded)
    print(loaded$labels)
  },
  finally = store$delete(document$name, document$effective_date)
)

tryCatch(
  store$load("example-watchlist-never-saved"),
  BasketNotFoundError = function(error) print(conditionMessage(error))
)
} # }

## ------------------------------------------------
## Method `BasketStore$load_for_instrument()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty_it <- EquityIndex$new(exchange = "nse", symbol = "NIFTYIT")
members <- list()
for (symbol in c(
  "INFY",
  "TCS"
)) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  members[[length(members) + 1]] <- BasketMember$new(share)
}
it_index <- Index$new(
  name = "example-index-linked",
  members = members,
  weighting = "equal",
  linked_instrument = nifty_it
)
store <- BasketStore$new()
document <- store$save(it_index)
tryCatch(
  {
    found <- store$load_for_instrument(nifty_it)
    print(found)
    print(found$linked_instrument$symbol)
  },
  finally = store$delete(document$name, document$effective_date)
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
print(BasketStore$new()$load_for_instrument(idea))
} # }

## ------------------------------------------------
## Method `BasketStore$names()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(BasketStore$new()$names())

shares <- list(
  Equity$new(exchange = "nse", symbol = "IDEA"),
  Equity$new(exchange = "nse", symbol = "INFY")
)
store <- BasketStore$new()
followed <- Watchlist$new(
  name = "example-watchlist-names",
  instruments = shares
)
document <- store$save(followed)
tryCatch(
  print("example-watchlist-names" %in% store$names(kind = "watchlist")),
  finally = store$delete(document$name, document$effective_date)
)
} # }

## ------------------------------------------------
## Method `BasketStore$history()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
shares <- list(
  Equity$new(exchange = "nse", symbol = "IDEA"),
  Equity$new(exchange = "nse", symbol = "INFY")
)
store <- BasketStore$new()
followed <- Watchlist$new(
  name = "example-watchlist-history",
  instruments = shares
)
store$save(followed, effective_date = "2026-03-01", source = "example")
store$save(followed, effective_date = "2026-06-01", source = "example")
tryCatch(
  {
    history <- store$history("example-watchlist-history")
    print(history[, c("name", "effective_date", "source", "size")])
  },
  finally = {
    store$delete("example-watchlist-history", "2026-03-01")
    store$delete("example-watchlist-history", "2026-06-01")
  }
)

print(BasketStore$new()$history("example-watchlist-never-saved"))
} # }

## ------------------------------------------------
## Method `BasketStore$delete()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
shares <- list(
  Equity$new(exchange = "nse", symbol = "IDEA"),
  Equity$new(exchange = "nse", symbol = "INFY")
)
store <- BasketStore$new()
followed <- Watchlist$new(
  name = "example-watchlist-delete",
  instruments = shares
)
document <- store$save(followed, effective_date = "2026-09-01")
print(store$delete("example-watchlist-delete", "2026-09-01"))

print(store$delete("example-watchlist-missing", as.Date("2026-09-01")))
} # }

## ------------------------------------------------
## Method `BasketStore$build()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
document <- list(
  name = "two IT shares",
  kind = "index",
  weighting = "equal",
  members = list(
    list(
      exchange = "nse",
      segment = "equities",
      symbol = "INFY"
    ),
    list(
      exchange = "nse",
      segment = "equities",
      symbol = "TCS"
    )
  )
)
basket <- BasketStore$new()$build(document)
print(basket)
print(basket$weights)

document <- list(
  name = "mystery",
  kind = "hedge_fund",
  members = list(
    list(
      exchange = "nse",
      segment = "equities",
      symbol = "INFY"
    )
  )
)
tryCatch(
  BasketStore$new()$build(document),
  AssetBasketError = function(error) print(conditionMessage(error))
)
} # }
```
