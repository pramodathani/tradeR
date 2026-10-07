# Funds and trusts

This family covers exchange traded funds, such as NIFTYBEES, and
investment trusts, such as the real estate trust EMBASSY and the
infrastructure trusts whose names end in INVIT. It lives in
`R/assets_funds.R` and has two classes rather than six, because UBI
carries no futures or options on a fund or a trust. Both behave like
shares in every way that matters: they are quoted continuously, they
take ordinary market and limit orders with the quantity as a plain count
of units, and they can be held.

The table below lists the two classes and how many instruments UBI held
in each on 2026-09-20.

| Kind | Class | What it is | UBI segment | Named by | Instruments in UBI |
|----|----|----|----|----|----|
| class | [`ExchangeTradedFund`](https://pramodathani.github.io/tradeR/reference/ExchangeTradedFund.md) | A fund listed and traded on an exchange | `exchange_traded_funds` | `exchange`, `symbol` | nse 353, bse 273 |
| class | [`InvestmentTrust`](https://pramodathani.github.io/tradeR/reference/InvestmentTrust.md) | A real estate or infrastructure investment trust | `investment_trusts` | `exchange`, `symbol` | nse 27, bse 27 |

A mutual fund is a different thing and has its own page, [Mutual
funds](https://pramodathani.github.io/tradeR/articles/asset-classes-mutual-funds.md),
because it is subscribed to at its net asset value rather than traded.

## The one difference between them

A fund and a trust work identically in this package except for one
thing, which is what UBI stores for them. A fund’s candles are adjusted
for splits and bonuses, like a share’s, and carry a `price_factor`
column. A trust’s candles are not stored at all yet, so `prices()`
returns `NULL` for an `InvestmentTrust` and the [analysis
methods](https://pramodathani.github.io/tradeR/articles/analysis.md)
have nothing to work on, even though the trust is quoted and traded
normally. The flowchart below shows the two paths.

``` mermaid

flowchart LR
    A["ExchangeTradedFund<br/>NIFTYBEES"] --> B["prices()"]
    B --> C["adjusted candles<br/>with price_factor"]
    C --> D["analysis methods<br/>return data frames"]
    E["InvestmentTrust<br/>EMBASSY"] --> F["prices()"]
    F --> G["NULL"]
    G --> H["analysis methods<br/>return NULL"]
```

The example below shows the difference through
`relative_strength_index()`.

``` r

library(tradeR)

fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
print(fund$relative_strength_index(window = 14, days = 90))

trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
print(trust$relative_strength_index(window = 14, days = 90))
```

The fund’s result was recorded on 2026-09-20 when the Python module was
checked. That call returned 63 rows, of which the note kept two, showing
only the `datetime`, `close` and `rsi_14` columns; the real data frame
carries every candle column as well. The block below reproduces the note
as a record of the values, not as R output. The same call on the trust
returned nothing, which is `NULL` in R.

``` text
                 datetime  close    rsi_14
2026-09-17 00:00:00+05:30 266.08 29.018966
2026-09-18 00:00:00+05:30 266.53 31.299985
```

## Listed on both exchanges

Both classes are listed on the `nse` and the `bse`, and the same fund is
quoted separately on each. The table below shows the three instruments
checked on 2026-09-20. The prices are that day’s, and “Candles” is the
number of daily rows `prices()` returned.

| Class | Instrument | Segment | `lot_size` | `tick_size` | Brokers | `last_price` | Candles |
|----|----|----|----|----|----|----|----|
| `ExchangeTradedFund` | nse NIFTYBEES | `nse_exchange_traded_funds` | 1 | 0.01 | 10 | 266.53 | 42, with `price_factor` |
| `ExchangeTradedFund` | bse NIFTYBEES | `bse_exchange_traded_funds` | 1 | 0.01 | 10 | 266.6 | 41, with `price_factor` |
| `InvestmentTrust` | nse EMBASSY | `nse_investment_trusts` | 1 | 0.01 | 9 | 441.07 | `NULL` |

The small gap between 266.53 and 266.6 is the ordinary difference
between two exchanges’ last trades, not something to correct.

## Finding a fund or a trust

Both class generators have a
[`search()`](https://rdrr.io/r/base/search.html) function that finds
symbols containing a term. The table below shows what it returned on
2026-09-20. Searching by a word such as GOLD or INVIT is often quicker
than remembering a fund’s exact ticker.

| Call | Result |
|----|----|
| `ExchangeTradedFund$search(exchange = "nse", term = "NIFTYBEE")` | 1 row, `NIFTYBEES` |
| `ExchangeTradedFund$search(exchange = "nse", term = "GOLD")` | 26 rows: `GOLD1`, `GOLD360`, `GOLDADD`, `GOLDAXIS`, `GOLDBEES`, `GOLDBETA` and more |
| `InvestmentTrust$search(exchange = "nse", term = "EMBAS")` | 1 row, `EMBASSY` |
| `InvestmentTrust$search(exchange = "nse", term = "INVIT")` | 9 rows: `CAPINVIT`, `CUBEINVIT`, `INDUSINVIT`, `IRBINVIT`, `NDRINVIT`, `PGINVIT` and more |

## Holding a fund or a trust

Both classes carry the same six holdings members as
[`Equity`](https://pramodathani.github.io/tradeR/articles/asset-classes-equities.html#holding-a-share),
copied into each class rather than shared. `exchange_traded_funds` and
`investment_trusts` are both cash segments in UBI, so a holding in
either is reported exactly as a share’s is, and `cnc` is the right
product for both. The table below lists the members, which
[Holdings](https://pramodathani.github.io/tradeR/articles/guide-holdings.md)
documents in full.

| Kind | Member | Description |
|----|----|----|
| active binding | `holdings` | This instrument’s row from the account’s holdings, or `NULL` when it is not held |
| active binding | `holdings_value` | What the holding is worth, as UBI prices it |
| active binding | `holdings_pnl` | The holding’s `day_change`, `day_change_percentage` and `unrealized` profit |
| places orders | `add_to_holdings()` | Buys more units as a `cnc` order |
| places orders | `reduce_holdings()` | Sells part of the units that are not pledged |
| places orders | `liquidate_holdings()` | Sells every unit that is not pledged |

Neither NIFTYBEES nor EMBASSY was held when the Python module was
checked, so only the not-held path has been seen live. The three order
methods were exercised against a recorder with invented holdings rows,
and no order was sent; the R port was checked the same way against a
fake client.

## What a fund holds

`ExchangeTradedFund` has a `constituents` active binding, which returns
the fund’s own portfolio as an
[`ExchangeTradedFundConstituents`](https://pramodathani.github.io/tradeR/reference/ExchangeTradedFundConstituents.md)
[asset
basket](https://pramodathani.github.io/tradeR/articles/guide-asset-baskets.html#an-index-or-a-fund-is-two-things),
or `NULL` when no basket has been stored for the fund. UBI stores no
fund holdings, so the basket lives in this project’s MongoDB and is
read, along with its members from UBI, every time the active binding is
read. The fund’s official price stays on the `ExchangeTradedFund`
object, and the basket’s `linked_instrument` points back to it, so the
two can be compared, for example to see how closely the fund tracks what
it holds. `InvestmentTrust` has no `constituents` active binding.

The fund’s `constituents` are not the same thing as its `holdings`.
`constituents` is what the fund itself owns, and `holdings` is how many
units of the fund this account owns.

## Errors

The table below lists what the two constructors signal.

| Condition | When |
|----|----|
| R’s error `argument "..." is missing, with no default` | The `exchange` or `symbol` argument is missing. R signals it before any request is sent. |
| `ExchangeTradedFundError` | UBI has no fund with that exchange and symbol, including a share asked for as a fund. |
| `InvestmentTrustError` | UBI has no trust with that exchange and symbol, including a fund asked for as a trust. |
