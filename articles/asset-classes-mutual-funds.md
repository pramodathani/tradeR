# Mutual funds

A mutual fund is unlike everything else in this package. It is not
bought and sold in a continuous market; you subscribe to it and redeem
it at the day’s net asset value, the price the fund house publishes once
a day. UBI has no quote for one and stores no candles, so a mutual fund
is not something to analyse or trade on price. What does work is holding
it, and that is what
[`MutualFund`](https://pramodathani.github.io/tradeR/reference/MutualFund.md)
is for. The one way to measure a scheme is through its stored
[constituents](#measuring-a-scheme-through-its-constituents).

The table below describes the one class in `R/assets_mutual_funds.R`.

| Kind | Class | UBI segment | Named by | Instruments in UBI |
|----|----|----|----|----|
| class | [`MutualFund`](https://pramodathani.github.io/tradeR/reference/MutualFund.md) | `mutual_funds` | `exchange`, `symbol` | 279, on the `nse` only |

There is one class because UBI has no futures or options on a mutual
fund and carries the segment on a single exchange. It is kept apart from
[Funds and
trusts](https://pramodathani.github.io/tradeR/articles/asset-classes-funds.md),
because an exchange traded fund and an investment trust do trade like
shares, and putting a mutual fund beside them would suggest it does too.

## A scheme is named by its exchange code

A mutual fund scheme’s symbol is the exchange’s short code for it, such
as `ABSLFTTIDG`, not the scheme’s published name. The code usually
begins with the fund house’s prefix, so the practical way to find one is
to search by that prefix, as the example below does.

``` r

library(tradeR)

matches <- MutualFund$search(exchange = "nse", term = "ABSL")
fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
```

On 2026-09-20 that search returned 18 rows, beginning `ABSLFTTIDG`,
`ABSLFTTIDN`, `ABSLFTTIRG`, `ABSLFTTIRN` and `ABSLFTTJDG`.

## What works and what does not

Only one broker, Stoxkart, carries the segment, and no broker that
serves quotes does. The diagram below shows which members of a
`MutualFund` return something and which signal an error or come back
empty.

``` mermaid

flowchart LR
    F["MutualFund<br/>ABSLFTTIDG"] --> Q["quote, last_price, ohlc<br/>order-book values"]
    Q --> E["ServiceUnavailableError"]
    F --> P["prices() and every<br/>analysis method"]
    P --> N["NULL"]
    F --> H["holdings, holdings_value<br/>holdings_pnl"]
    H --> R["the account's row<br/>or NULL when not held"]
    F --> O["add_to_holdings()<br/>reduce_holdings()<br/>liquidate_holdings()"]
    O --> C["a cnc order<br/>give a limit price"]
```

The Python module was checked against UBI on 2026-09-20. The block below
is the check’s own summary of the instrument, as recorded then; it is a
record of the values, not R output, and in R a missing value reads as
`NULL`.

``` text
MutualFund(exchange='nse', segment='nse_mutual_funds', symbol='ABSLFTTIDG')
  segment    nse_mutual_funds   shape security   lot 1   tick 0.01
  brokers    ['stoxkart']
  last_price ServiceUnavailableError
  candles    None
  holdings   None
```

## Holding a mutual fund

`mutual_funds` is one of UBI’s cash segments, so a scheme is reported in
the account’s holdings exactly as a share is, and `MutualFund` carries
the same six holdings members as
[`Equity`](https://pramodathani.github.io/tradeR/articles/asset-classes-equities.html#holding-a-share).
[Holdings](https://pramodathani.github.io/tradeR/articles/guide-holdings.md)
documents them. The old tradingmachine project gave mutual funds the
three reading members only, and the Python library and this package give
them the three order methods as well, so that no holdable class is an
exception you have to remember.

The three order methods send ordinary `cnc` orders, which is the product
UBI accepts for this segment. Three things follow from that.

- **Give a price.** With no quote, there is nothing for a market order
  to be priced against, so a limit price is the only sensible form. The
  methods still send a market order, with `as_marketable_limit = FALSE`
  so that it goes to a broker at once, if you pass no price, because the
  package does not second-guess what UBI will accept, but the
  documentation asks for a price.
- **The limit order is sent at once.** Since 2026-09-27 UBI’s order
  engine holds a plain limit order until a live quote shows the other
  side reaching its price. Nothing quotes a mutual fund, so a held order
  would wait all day and never be sent. The holdings methods therefore
  pass `hold = FALSE`, which sends the order to a broker at once, as
  [Order
  engine](https://pramodathani.github.io/tradeR/articles/architecture-order-engine.html#when-to-send-a-limit-order-at-once)
  explains. Call `buy_at_limit_price()` or `sell_at_limit_price()`
  yourself only with `hold = FALSE` too.
- **Whether it becomes a subscription is up to the broker.** No live
  order has been sent through these methods, so it is not known how the
  broker treats a `cnc` order for a mutual fund.

**These are real orders.**

`add_to_holdings()`, `reduce_holdings()` and `liquidate_holdings()` send
real orders to a real broker, with real money. The example below would
buy ten units at a limit price of 25.00 if you ran it.

``` r

fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
fund$add_to_holdings(quantity = 10, price = 25.0)
```

As with every holdable class, `reduce_holdings()` and
`liquidate_holdings()` sell only units that are not pledged as
collateral, and signal `HoldingError` when the scheme is not held or
every unit is pledged. No scheme was held when the module was checked,
so the live check proved only the not-held case, and the order methods
were exercised against a recorder rather than a broker; the R port was
checked against a fake client in the same way.

## Measuring a scheme through its constituents

A scheme’s own analysis and [performance
measures](https://pramodathani.github.io/tradeR/articles/analysis-performance.md)
all return `NULL`, because UBI has no price history for it. What a
scheme holds can still be measured. The `constituents` active binding
returns a
[`MutualFundConstituents`](https://pramodathani.github.io/tradeR/reference/MutualFundConstituents.md)
[asset
basket](https://pramodathani.github.io/tradeR/articles/guide-asset-baskets.html#an-index-or-a-fund-is-two-things)
of the scheme’s portfolio, read from this project’s MongoDB and UBI
every time it is read, or `NULL` when no basket has been stored for the
scheme. UBI stores no fund holdings, so a basket exists only when one
was saved with this scheme as its linked instrument. The basket has
candles built from its members, so every analysis and performance method
works on it.

A scheme’s `constituents` and its `holdings` are different things.
`constituents` is what the fund itself owns, and `holdings` is how many
units of the fund this account owns. The example below compares a
scheme’s portfolio with NIFTY over a year. It was not run for this page,
and it prints nothing unless a basket has been stored for the scheme.

``` r

nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
portfolio <- fund$constituents
if (!is.null(portfolio)) {
  print(portfolio$performance_summary(benchmark = nifty, days = 365))
}
```

## Errors

The table below lists what this class signals.

| Condition | When |
|----|----|
| R’s error `argument "..." is missing, with no default` | The `exchange` or `symbol` argument is missing. R signals it before any request is sent. |
| `MutualFundError` | UBI has no scheme with that exchange and code, including a share asked for as a scheme. |
| `ServiceUnavailableError` | A quote or an order-book value is read. |
| `HoldingError` | `reduce_holdings()` or `liquidate_holdings()` is called when nothing free is held, or `reduce_holdings()` asks for more than is free. |
