# R/orders_cross_instrument.R

Port of `src/tradingmachine/orders/cross_instrument.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`CrossInstrumentOrder` mirrors UBI's `cross_instrument` synthetic order type, `unified_broker_interface/utilities/order_engine/cross_instrument.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row B10 cross-instrument conditional.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI's `CrossInstrument` is a `LimitIfTouched` whose trigger reads another instrument's last traded price, named by `watch_instrument_id`. The class takes the instrument object as `watch_instrument`, as every other part of the library does, and `synthetic_fields()` sends its id under UBI's name. The watched instrument may be any `Instrument`, including an index, because it is only read; the order itself goes to the tradeable instrument the class is built on. `trigger_price` is the level on the watched instrument and is stored as `trigger_level`, for the reason given in the note on `market_if_touched.py`.

On 2026-09-27 UBI added `trigger_on` and `hold_seconds` to its price-trigger base, the Atlas's G10 trigger methods, so the class gained both. UBI refuses them on the types that choose their own watched price, `indicator_triggered`, `hidden_stop`, `candle_close_stop` and `virtual_limit`, so those classes do not take them.

## How the R version differs

- `CrossInstrumentOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_CROSS_INSTRUMENT_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- As in Python, the argument `trigger_price` is the type's own level: it is stored in the field `trigger_level` and sent as the synthetic object's `trigger_price`, while the template's own `trigger_price` is passed to the base class as `NULL`.
- The watched instrument is sent as `watch_instrument_id`, read from the instrument object, as in Python.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
