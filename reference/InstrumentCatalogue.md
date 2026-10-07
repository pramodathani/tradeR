# Discovery of instruments in UBI's catalogue

The R home of the Python library's protected class methods
`Instrument._search_catalogue`, `_master_catalogue`, `_contracts_for`,
`_expiry_dates` and `_identity_frame`, which every family class's
discovery functions, such as `Equity$search()` and
`EquityOption$chain()`, call.

UBI's search route ranks an exact match first, then names starting with
the term, then names containing it, and returns at most 200 rows in
expiry order, so it is the right way to look for a security by name and
the wrong way to look for a contract. The master route returns a whole
segment with no limit, which is the only way to reach a live expiry, so
contracts are found by fetching the segment and narrowing it here.

## Methods

### Public methods

- [`InstrumentCatalogue$new()`](#method-InstrumentCatalogue-initialize)

- [`InstrumentCatalogue$search()`](#method-InstrumentCatalogue-search)

- [`InstrumentCatalogue$master()`](#method-InstrumentCatalogue-master)

- [`InstrumentCatalogue$contracts_for()`](#method-InstrumentCatalogue-contracts_for)

- [`InstrumentCatalogue$expiry_dates()`](#method-InstrumentCatalogue-expiry_dates)

- [`InstrumentCatalogue$strikes()`](#method-InstrumentCatalogue-strikes)

- [`InstrumentCatalogue$identity_frame()`](#method-InstrumentCatalogue-identity_frame)

- [`InstrumentCatalogue$clone()`](#method-InstrumentCatalogue-clone)

------------------------------------------------------------------------

### `InstrumentCatalogue$new()`

Prepares a catalogue reader that sends its requests through one client.

#### Usage

    InstrumentCatalogue$new(unified_broker_interface = NULL)

#### Arguments

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

#### Returns

A new `InstrumentCatalogue` object.

------------------------------------------------------------------------

### `InstrumentCatalogue$search()`

Finds instruments in one segment whose name contains a term.

#### Usage

    InstrumentCatalogue$search(exchange, segment, term, limit)

#### Arguments

- `exchange`:

  The character exchange to search, such as `"nse"`.

- `segment`:

  The character segment to search, bare such as `"equities"` or prefixed
  such as `"nse_equities"`.

- `term`:

  The character text the name must contain, matched without regard to
  case.

- `limit`:

  The integer most rows to return, which UBI caps at 200.

#### Details

Errors: signals `BadRequestError` when the exchange or segment is not
one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for
any other failure.

#### Returns

A `data.frame` of identities, with `instrument_id`, `exchange`,
`segment`, `shape`, `symbol`, `underlying_symbol`, `expiry_date`,
`strike_price` and `option_type`, or `NULL` when nothing matches.

------------------------------------------------------------------------

### `InstrumentCatalogue$master()`

Fetches every instrument UBI holds in one segment.

#### Usage

    InstrumentCatalogue$master(exchange, segment)

#### Arguments

- `exchange`:

  The character exchange, such as `"nse"`.

- `segment`:

  The character segment, bare such as `"equity_options"` or prefixed
  such as `"nse_equity_options"`.

#### Details

Errors: signals `BadRequestError` when the exchange or segment is not
one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for
any other failure.

#### Returns

A `data.frame` of every identity in the segment, shaped as
[`search()`](https://rdrr.io/r/base/search.html) returns, or `NULL` when
the segment holds nothing.

------------------------------------------------------------------------

### `InstrumentCatalogue$contracts_for()`

Finds the contracts in one segment, narrowed by underlying and expiry.

#### Usage

    InstrumentCatalogue$contracts_for(
      exchange,
      segment,
      underlying_symbol,
      expiry_date,
      include_expired
    )

#### Arguments

- `exchange`:

  The character exchange, such as `"nse"`.

- `segment`:

  The character segment of the contracts, such as `"equity_options"`.

- `underlying_symbol`:

  The character symbol of the underlying to keep, or `NULL` to keep
  every underlying.

- `expiry_date`:

  The expiry to keep, as a `Date` or a `"YYYY-MM-DD"` character value,
  or `NULL` to keep every expiry.

- `include_expired`:

  A logical that is `TRUE` to keep contracts whose expiry has passed.

#### Details

Errors: signals `BadRequestError` when the exchange or segment is not
one UBI knows; a plain error when `expiry_date` is text that is not a
valid ISO date; and another `UnifiedBrokerInterfaceError` subclass for
any other failure.

#### Returns

A `data.frame` of the matching identities, sorted by expiry, strike
price and option type, or `NULL` when nothing matches.

------------------------------------------------------------------------

### `InstrumentCatalogue$expiry_dates()`

Lists the expiries one underlying has contracts for in a segment.

#### Usage

    InstrumentCatalogue$expiry_dates(
      exchange,
      segment,
      underlying_symbol,
      include_expired
    )

#### Arguments

- `exchange`:

  The character exchange, such as `"nse"`.

- `segment`:

  The character segment of the contracts, such as `"equity_futures"`.

- `underlying_symbol`:

  The character symbol of the underlying, such as `"RELIANCE"`.

- `include_expired`:

  A logical that is `TRUE` to include expiries that have passed.

#### Details

Errors: signals `BadRequestError` when the exchange or segment is not
one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for
any other failure.

#### Returns

A `Date` vector, soonest first, which is empty when the underlying has
no contracts.

------------------------------------------------------------------------

### `InstrumentCatalogue$strikes()`

Lists the strike prices listed on one underlying for one expiry in a
segment.

#### Usage

    InstrumentCatalogue$strikes(
      exchange,
      segment,
      underlying_symbol,
      expiry_date,
      include_expired
    )

#### Arguments

- `exchange`:

  The character exchange, such as `"nse"`.

- `segment`:

  The character segment of the options, such as `"equity_options"`.

- `underlying_symbol`:

  The character symbol of the underlying, such as `"RELIANCE"`.

- `expiry_date`:

  The expiry as a `Date` or a `"YYYY-MM-DD"` character value.

- `include_expired`:

  A logical that is `TRUE` to allow an expiry that has already passed.

#### Details

Errors: signals `BadRequestError` when the exchange or segment is not
one UBI knows; a plain error when `expiry_date` is text that is not a
valid ISO date; and another `UnifiedBrokerInterfaceError` subclass for
any other failure.

#### Returns

A numeric vector of strike prices, lowest first, which is empty when
nothing is listed for that expiry.

------------------------------------------------------------------------

### `InstrumentCatalogue$identity_frame()`

Turns UBI's identity rows into a frame, with real dates in it.

#### Usage

    InstrumentCatalogue$identity_frame(rows)

#### Arguments

- `rows`:

  A list of named lists as UBI's search and master routes return them.

#### Details

Errors: signals a plain error when an expiry date is not a valid ISO
date.

#### Returns

A `data.frame` of the rows, with `expiry_date` as a `Date` column, or
`NULL` when there are no rows.

------------------------------------------------------------------------

### `InstrumentCatalogue$clone()`

The objects of this class are cloneable with this method.

#### Usage

    InstrumentCatalogue$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
