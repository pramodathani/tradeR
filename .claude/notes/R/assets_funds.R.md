# R/assets_funds.R

Port of `src/tradingmachine/assets/funds.py`, written on 2026-10-07 by following `R/assets_equities.R`. It holds `ExchangeTradedFund` on the `exchange_traded_funds` segment and `InvestmentTrust` on the `investment_trusts` segment, both built on `TradeableInstrument` and named by exchange and symbol. The Python note `.claude/notes/src/tradingmachine/assets/funds.py.md` holds the live measurements.

## What carries over from Python

- The family is two classes rather than six, because UBI has no futures or options segment for a fund or a trust at all.
- The mutual fund is in its own file, `R/assets_mutual_funds.R`, because it is subscribed to at net asset value, has no quote and is carried by one broker.
- Both classes carry the same holdings members as `Equity`, copied into each class rather than shared, which is the standing decision for these families. **Unlike `FixedIncome` and `MutualFund`, their holdings orders use the ordinary wrappers**, so a `day` limit order is held by UBI's order engine until the book reaches its price, and a market order runs as a marketable limit. That is right here, because both instruments are quoted. The order bodies therefore carry no `synthetic` field.
- An investment trust has no stored candles, so `prices()` returns `NULL` for it.
- `ExchangeTradedFund` has `constituents`, the stored basket of what the fund holds, read through `BasketStore$new(unified_broker_interface = ...)$load_for_instrument(self)`. It is named `constituents` because `holdings` already means the units this account holds. `InvestmentTrust` has none, because a trust holds property and infrastructure rather than instruments UBI can price.

## Where the R version differs from Python

- Python imports the basket store inside the property to avoid a circular import. R needs no such trick: the active binding looks `BasketStore` up when it runs, after every file has loaded, exactly as `NonTradeableInstrument$constituents` in `R/assets_instruments.R` does.
- The constants carry the prefix `FUNDS_`, such as `FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT`.
- The examples of the holdings methods are in each method's `@examples`. Python's `try: ... finally: cancel` became `tryCatch(print(answer), finally = print(...$cancel_parent(...)))`, and `try / except HoldingError / else` became a `tryCatch` that returns `NULL` on the error, followed by an `if`. Python's `matches[["symbol", "exchange", "segment"]]` became a named `columns` vector written one element per line.
- The rest matches `R/assets_fixed_income.R`: no `SEGMENT` attribute, the module docstring in the first class's description, and `self$format()` for `{self!r}`.

## Checked against a fake client on 2026-10-07

No order was sent. Both classes built from canned details. An equity given as a fund signalled `ExchangeTradedFundError` "is not an ExchangeTradedFund", a fund given as a trust signalled `InvestmentTrustError`, and a not-found answer became each class's own error. The holdings members matched by instrument id and fell back to the symbol. Over the four holding states the order bodies were plain `cnc` market and limit orders with no `synthetic` field, liquidating ten units with four pledged sold six, and the errors named the free and pledged counts. `constituents` passed this instrument and the instrument's own client to the store. `tests/testthat/test-assets_funds.R` has 32 expectations, all passing; it swaps a stand-in `BasketStore` in for the duration of one test and restores the real one afterwards, so it never reaches MongoDB.
