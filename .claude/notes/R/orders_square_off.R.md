# R/orders_square_off.R

Port of `src/tradingmachine/orders/square_off.py`. What follows the first heading below is carried over from the Python note and still applies.

## From the Python note

`SquareOffOrder` mirrors UBI's `square_off` synthetic order type, `unified_broker_interface/utilities/order_engine/square_off.py` in the sibling project. Its settings, their defaults and their limits were taken from `../unified_broker_interface/docs/rest-api/synthetic-orders.md` on 2026-09-26, and its parameter names are UBI's field names.

In the Synthetic Order Atlas that UBI's engine was designed from, it is row C4 own end-of-day square-off.

It checks none of its settings before sending, following the rule that UBI holds the order rules; UBI's engine checks each field when it builds the order and answers HTTP 400 naming the one that is wrong, and a dry run shows that without sending anything.

UBI's `SquareOff` decides the side, the order type and the quantity of every closing order from the positions, but the route still runs `PlaceOrderRequest` over the body first, so the body needs a valid side, order type and quantity. The class fills them with placeholders, `sell`, `market` and 1, and does not accept them from the caller, since a caller's values would be ignored. The instrument only anchors the request, which UBI's docstring on the class says plainly: it does not limit what is closed. `only_instruments` does, and is named that way rather than `instruments`, which would shadow the module of the same name inside the constructor.

The product appears twice, in two spellings, and this is the one trap in the type. UBI's comment on `SquareOff.product_to_close` says the closing orders are sent with the product from the body, on the order vocabulary (`MIS`, `CNC`, `NRML`), while `synthetic.product` filters the positions on the positions' vocabulary. Conflating the two produced "product must be one of CNC, MIS, NRML" in UBI's own history. The class takes one `product` on the order vocabulary, defaulting to `mis` because a square-off is an intraday habit, and translates it for the synthetic field with `POSITION_PRODUCT_FOR_ORDER_PRODUCT`. That comment calls the carry product `carryforward` while the positions document and this library's mapping say `carry`; the mapping's spelling is used, and a dry run would show a mismatch.

`closes_position` defaults to True here and only here, because every order a square-off sends is an exit, and a square-off that could not use the exit share of a broker's daily cap would fail on exactly the day that cap was used up. UBI never resolves price or quantity references for this type, so the class does not accept them.

## How the R version differs

- `SquareOffOrder` is an R6 class inheriting `SyntheticOrder`, which does the sending, keeps the `parent_id`, and offers `cancel()`, `parent`, `orders` and `trades`. This file adds only the type's own settings and its `synthetic_fields()`, in line with the user's rule of one self-contained class per case over a shallow base.
- Python's keyword-only arguments became ordinary named arguments in the same order and with the same defaults. R would accept them by position too, but every example names them, for the same reason Python made them keyword-only: several are prices in rupees that are easy to swap.
- `SYNTHETIC_TYPE` is a public field whose value comes from the package constant `ORDERS_SQUARE_OFF_SYNTHETIC_TYPE`, so `order$SYNTHETIC_TYPE` reads the same as Python's class attribute.
- `synthetic_fields()` returns a named list that keeps `NULL` entries, and the base class's `synthetic` binding drops them, so a setting left as `NULL` is left out of the request body exactly where Python leaves out `None`.
- The order product is translated to the positions' spelling with `INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT`, the R copy of Python's `POSITION_PRODUCT_FOR_ORDER_PRODUCT`, falling back to the product as given when it is not one of the three known ones. `instrument_ids` is built as an unnamed `list()`, so one chosen instrument still encodes as a JSON array, and it is `NULL`, and so left out, when `only_instruments` is `NULL` or empty, as Python's truthiness test does.

## How it was written and checked

The file was generated on 2026-10-07 from the Python module by a scratch script that read the constructor's signature, the body of `synthetic_fields()` and the docstrings with `ast`, then reviewed and corrected by hand. The examples are the Python docstring examples translated line for line.

Parity was checked the same day against fake clients on both sides: the type was built in Python and in R from the required arguments only, from every argument set, and, when it takes a list, with one-element lists, and the JSON body each sent to `/api/orders/place` was parsed and compared key by key. All of them matched.
