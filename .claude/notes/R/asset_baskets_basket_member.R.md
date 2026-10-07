# R/asset_baskets_basket_member.R

The R port of `src/tradingmachine/asset_baskets/basket_member.py`, made on 2026-10-07.

`BasketMember` is one instrument with an optional `weight`, `quantity` and `average_price`. One small class serves every kind of basket rather than a subclass per kind, because the three fields are the only difference and each basket checks the ones it needs: `Portfolio` requires a quantity, a `stated` `Index` requires a weight, and `AssetBasket` requires that weights are given to every member or to none.

## The label

`label` gives each member a readable name such as `nse:INFY`, used as the name of every weight vector and the column or row name of every table a basket returns. The exchange is part of it because the same symbol trades on the nse and the bse, and the holdings portfolio tested in Python on 2026-09-28 held both `bse:ITC` and `nse:ONGC`. A future or option has no symbol, so its label is built from the underlying, the expiry, the strike and the option type.

## `document`

`document` stores both the instrument id and the readable identity fields. The id is what the store uses to rebuild the member, since UBI computes it deterministically and it is the same at every broker; the readable fields are there so a person reading MongoDB can tell what the basket holds. `expiry_date` is written as `YYYY-MM-DD` text, exactly as Python writes it, so a basket saved by either library loads in the other. A missing value is `NULL` in the list, which becomes JSON `null` and BSON null, the same as Python's `None`.

## Where R differs from Python

| Python | R | Why |
|---|---|---|
| `__repr__` | `format()` and `print()` | The package's rule for `__repr__` |
| `repr()` of a number | `python_number_text`, which writes a whole double with `.0` and an integer without | So the label of an option, such as `nse:NIFTY 2026-10-27 25000.0CE`, and the description match Python. UBI's JSON writes a strike as `25000.0` and jsonlite reads that as a double, so the label matches. A whole number given in R as a plain `50` is a double and prints `50.0`, where Python would print `50` for an int; only the description text is affected. A value that needs 17 significant digits, such as `0.1 + 0.2`, prints with 15 in R. |
| `label` property | active binding | The package's rule for properties |
