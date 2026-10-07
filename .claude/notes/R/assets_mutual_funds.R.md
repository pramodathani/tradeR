# R/assets_mutual_funds.R

Port of `src/tradingmachine/assets/mutual_funds.py`, written on 2026-10-07 by following `R/assets_equities.R`. It holds one class, `MutualFund`, built on `TradeableInstrument` on the `mutual_funds` segment, which UBI carries on the `nse` only. The Python note `.claude/notes/src/tradingmachine/assets/mutual_funds.py.md` holds the live measurements.

## What carries over from Python

- A mutual fund has no quote and no candles, because only Stoxkart carries the segment and no broker that serves quotes does. Holding is what the class is for.
- The user chose on 2026-09-20 to give it the full holdings surface, including the three order methods, rather than the read-only version the old project had.
- **Its holdings orders are sent at once, like `FixedIncome`'s.** Limit orders pass `hold = FALSE` and market orders pass `as_marketable_limit = FALSE`, so every body carries `synthetic = list(type = "simple")`. Without that a limit order would be held all day and a market order would always be refused with HTTP 409. A price should still be given, and the documentation asks for one, but `NULL` still sends a market order rather than refusing.
- `constituents` returns the stored basket of what the scheme holds. Because a scheme has no price, its own performance methods return `NULL`, and the basket is the only way to measure it. `prices()` deliberately does not fall back to the basket.

## Where the R version differs from Python

- `constituents` looks `BasketStore` up when it runs, rather than importing it inside the property, for the reason given in `R/assets_funds.R.md`.
- The constants carry the prefix `MUTUAL_FUNDS_`, giving `MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT`.
- The Python examples use `time.sleep()` and a `for attempt in range(30)` loop, which became `Sys.sleep()` and `for (attempt in seq_len(30))`. The nested `if open_orders is not None: if order_id in ...` became one `if` joined with `&&`. The fund house prefixes in the `search` example became a `c()` literal written one element per line.
- The rest matches `R/assets_fixed_income.R`.

## Checked against a fake client on 2026-10-07

No order was sent. The class built from canned details, the segment check and a not-found answer both gave `MutualFundError`, and search named the `mutual_funds` segment. Over the four holding states every order body carried `product = "cnc"` and `synthetic = list(type = "simple")`, liquidating ten units with four pledged sold six, and the refusals matched Python's messages. `constituents` passed the instrument and its client to the store. `tests/testthat/test-assets_mutual_funds.R` has 27 expectations, all passing, with the same stand-in store swap as the funds tests.
