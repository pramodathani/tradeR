# R/asset_baskets_member_resolver.R

Port of `src/tradingmachine/asset_baskets/member_resolver.py`, written on 2026-10-07.

`MemberResolver` turns rows that name instruments into `BasketMember` objects with one `POST /api/instruments/details` for the whole list. It exists because three places need the same step: `BasketStore$build()`, `BasketCsvImporter` and `Portfolio$from_holdings()` and `$from_positions()`. A 50-member index costs one request rather than fifty. An index row (a segment ending in `_indices`) becomes a `NonTradeableInstrument` and anything else a `TradeableInstrument`, built through the `details` argument of their constructors; a member does not need the family class, such as `Equity`, for anything a basket does.

A row with an `instrument_id` is looked up by that alone, because UBI's list route takes either an id or the identity fields, and a stored basket always has the id.

## Failures are collected, then raised together

A row UBI cannot find does not stop the others from being looked up, but `resolve()` signals one `BasketMemberError` naming every failed row at the end. A basket silently missing a member would give wrong weights, so a partial basket is never returned. Python verified on 2026-09-28 that a list with `INFY` and `NOSUCHSTOCK` raised `UBI could not find 1 of 2 instruments: {'exchange': 'nse', 'segment': 'equities', 'symbol': 'NOSUCHSTOCK'}: no instrument nse_equities NOSUCHSTOCK is mapped on 2026-09-28`.

## Differences from Python

| Python | R | Why |
|---|---|---|
| A row is a `dict` | A row is a named list; a missing key and a `NULL` value both count as not given | `row.get(field) is not None` is the Python test, and `row[[field]]` gives `NULL` for both cases |
| The failure message prints the lookup with Python's `dict` repr | The private `python_repr()` writes the same text: strings in single quotes, a whole double as `1.0`, an integer as `1`, `NULL` as `None`, a logical as `True` or `False` | So the messages read and grep the same in both languages |
| `request_index` indexes the lookup list from 0 | One is added before indexing the R list | R lists start at 1 |
| `_lookup_for` is a static method | A private method `lookup_for()` | R6 has no static methods; it uses no state |

As in Python, the answer's `results` are matched to rows by position, not sorted by `request_index`; UBI answers in request order.
