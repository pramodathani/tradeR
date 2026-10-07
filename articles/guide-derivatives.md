# Derivatives

A futures or option contract has things a share does not: a day it
expires, an underlying it is written on, and a price that is partly the
underlying’s price and partly something else. The members on this page
report those things. They live on five base classes in
`R/assets_instruments.R`, and every futures and option class, such as
`EquityFutures` or `CommodityIndexOption`, inherits them, so they work
on all sixteen derivative classes in the same way.

None of these members places an order. The table below lists them.

| Kind | Member | Description |
|----|----|----|
| field | [`underlying_segment`](#underlying_segment) | The segment of the instrument the contract is written on, such as `nse_equities`. |
| active binding | [`days_to_expiry`](#days_to_expiry) | The calendar days left until the contract expires. |
| active binding | [`expired`](#expired) | Whether the expiry date has passed. |
| active binding | [`expiry_kind`](#expiry_kind) | Whether the contract is the month’s last expiry or a weekly one. |
| active binding | [`next_expiry`](#next_expiry) | The next expiry after this one, where a position rolls to. |
| active binding | [`underlying`](#underlying) | The underlying instrument: the one given when the contract was built, or one found through UBI’s link or the family’s default. |
| active binding | [`underlying_price`](#underlying_price) | The underlying’s last traded price. |
| active binding | [`open_interest_day_high`](#open_interest_day_high) | The highest open interest reached today. |
| active binding | [`open_interest_day_low`](#open_interest_day_low) | The lowest open interest reached today. |
| active binding | [`contract_value`](#contract_value) | What one lot is worth at the last price. |
| active binding | [`basis`](#basis) | How far a future’s price is above its underlying’s. Futures only. |
| active binding | [`basis_percent`](#basis_percent) | The basis as a percentage of the underlying’s price. Futures only. |
| active binding | [`cost_of_carry`](#cost_of_carry) | The basis as a yearly rate. Futures only. |
| active binding | [`is_call`](#is_call) | Whether an option is a call. Options only. |
| active binding | [`is_put`](#is_put) | Whether an option is a put. Options only. |
| active binding | [`intrinsic_value`](#intrinsic_value) | What the option would be worth if exercised now. Options only. |
| active binding | [`time_value`](#time_value) | The part of the premium above the intrinsic value. Options only. |
| active binding | [`in_the_money`](#in_the_money) | Whether the option has intrinsic value. Options only. |
| active binding | [`moneyness_percent`](#moneyness_percent) | How far in or out of the money the option is, in per cent. Options only. |
| active binding | [`breakeven_price`](#breakeven_price) | The underlying price at which a buyer breaks even at expiry. Options only. |
| active binding | [`premium_per_lot`](#premium_per_lot) | What one lot costs to buy. Options only. |
| active binding | [`notional_value`](#notional_value) | What one lot controls at the strike price. Options only. |
| method | [`implied_volatility`](#implied_volatility) | The volatility the option’s price implies. Options only. |
| method | [`greeks`](#greeks) | The option’s fair price, delta, gamma, theta, vega and rho. Options only. |

The reference pages
[Derivative](https://pramodathani.github.io/tradeR/reference/Derivative.md),
[Futures](https://pramodathani.github.io/tradeR/reference/Futures.md)
and [Option](https://pramodathani.github.io/tradeR/reference/Option.md)
document the same members as they appear in the package’s roxygen2
documentation. The discovery functions `expiries`, `contracts`,
`strikes` and `chain` live on the class generators, such as
`EquityOption$chain()`, and are documented on [Finding
instruments](https://pramodathani.github.io/tradeR/articles/guide-discovery.md).
The bare generators `Futures` and `Option` carry them too, but there
they only signal an error, because those two classes name no segment.

## The five base classes

The class diagram below shows where the base classes sit. `Derivative`
holds what every contract shares, `Futures` and `Option` add what is
particular to each, and `IndexFutures` and `IndexOption` narrow those
two to contracts on an index. The family classes inherit the matching
base, and each fixes its own segment, which is what the discovery
functions on its class generator read.

``` mermaid

classDiagram
    direction TB
    class TradeableInstrument {
        order book, orders, positions
    }
    class Derivative {
        underlying_segment
        days_to_expiry, expired
        expiry_kind, next_expiry
        underlying, underlying_price
        open_interest_day_high, open_interest_day_low
        contract_value
    }
    class Futures {
        basis, basis_percent, cost_of_carry
    }
    class Option {
        is_call, is_put
        intrinsic_value, time_value, in_the_money
        moneyness_percent, breakeven_price
        premium_per_lot, notional_value
        implied_volatility(), greeks()
    }
    class IndexFutures {
        underlying is an index
    }
    class IndexOption {
        underlying is an index
    }
    class EquityFutures {
        segment equity_futures
        expiries(), contracts()
    }
    class EquityOption {
        segment equity_options
        expiries(), strikes(), chain()
    }
    class EquityIndexFutures {
        segment equity_index_futures
        expiries(), contracts()
    }
    class EquityIndexOption {
        segment equity_index_options
        expiries(), strikes(), chain()
    }
    TradeableInstrument <|-- Derivative
    Derivative <|-- Futures
    Derivative <|-- Option
    Futures <|-- IndexFutures
    Option <|-- IndexOption
    Futures <|-- EquityFutures
    Option <|-- EquityOption
    IndexFutures <|-- EquityIndexFutures
    IndexOption <|-- EquityIndexOption
```

The equity classes stand for all sixteen. The table below shows which
base each kind of family class inherits.

| Family classes | Base |
|----|----|
| `EquityFutures`, `FixedIncomeFutures`, `CommodityFutures`, `CurrencyFutures` | `Futures` |
| `EquityOption`, `FixedIncomeOption`, `CommodityOption`, `CurrencyOption` | `Option` |
| `EquityIndexFutures`, `FixedIncomeIndexFutures`, `CommodityIndexFutures`, `CurrencyIndexFutures` | `IndexFutures` |
| `EquityIndexOption`, `FixedIncomeIndexOption`, `CommodityIndexOption`, `CurrencyIndexOption` | `IndexOption` |

In the Python library each family class names its segment in a `SEGMENT`
class attribute. The R port has no such attribute: each family class
passes its segment constant, such as `EQUITIES_EQUITY_OPTIONS_SEGMENT`,
to the base class when it is built, and each discovery function on its
class generator names the same constant directly. The diagram therefore
draws the discovery functions on the family classes, because R6 class
generators do not inherit the functions stored on them.

You normally build a family class. The base classes can be built
directly too, by `instrument_id` or by exchange, segment and identity
fields, which is useful when you hold an id from an order or position
row and do not know its family. Each checks what it was given and
signals its own error if the contract is the wrong kind, as
[Errors](https://pramodathani.github.io/tradeR/articles/guide-errors.html#derivativeerror)
lists.

## How a contract finds its underlying

Many of the members on this page need the underlying: its price for the
basis, the moneyness and the greeks, and the object itself for
`underlying`. A contract finds it in the order below, and the first way
that applies wins.

| Order | Way | When it applies |
|----|----|----|
| 1 | The object you gave, as `underlying =` when building the contract | Always, when you gave one |
| 2 | UBI’s `underlying_instrument_id` | When UBI’s instrument details carry it, resolved from the brokers’ own records |
| 3 | The family’s default | Otherwise, as the next table shows |
| 4 | [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | When the way chosen finds nothing |

The default differs by family, because UBI has prices for some
underlyings and not others. A check of UBI’s database on 2026-09-28
found that the underlying of an equity contract is almost always found
by its name, that the underlying of a commodity or currency contract is
a reference record with no price, and that 98.9 per cent of options have
a future on the same underlying expiring on or after them.

| Contract | Default underlying | Priced with |
|----|----|----|
| Equity future or option, on a share or an index | The share or index with the same symbol | Black-Scholes |
| Option on a commodity, a currency pair or a bond | The future on the same underlying that expires first on or after the option | Black-76 |
| Future on a commodity, a currency pair or a bond | There is none, so the basis members signal `UnderlyingError` unless you give one |  |

The future is taken on or after the option’s expiry, not in the same
month, because that is what an option settles into: an MCX GOLD option
expiring on 30 October is priced off the December future, since the
October one expired on 5 October. The example below finds a bond
option’s underlying with nothing given.

``` r

bond_call <- FixedIncomeOption$new(
  exchange = "nse",
  underlying_symbol = "633GS2035",
  expiry_date = "2026-10-29",
  strike_price = 96.75,
  option_type = "CE"
)
print(bond_call$underlying)
print(bond_call$underlying_price)
greeks <- bond_call$greeks()
cat(greeks[["model"]], round(bond_call$implied_volatility(), 4), "\n")
```

When the Python version of this example ran against a local UBI at 18:50
IST on 2026-09-28, the underlying it found was a `Futures` object for
the nse `nse_fixed_income_futures` contract on `633GS2035` expiring on
2026-10-29. That future’s last price was 96.83, and the option was
priced with the `black_76` model at an implied volatility of 0.068.

UBI’s link is what finds an index whose derivatives use a different name
from it. UBI has served it since 2026-09-28, so a `NIFTYFPI` option
finds the index UBI stores as “Nifty FPI 150”, and a `SENSEX50` contract
the one stored as “SNSX50”. Futures on commodities, currencies and bonds
deliberately find nothing, and the bse `USDINR-CNV` and `USDINR-STD`
options have no future to be priced off; on 2026-09-28 those were 825
and 832 of the 198,122 live derivatives, and every other one found an
underlying. A date before 2026-09-22 has no link in UBI, because the
brokers’ codes were not stored then.

**An option still needs a price of its own.**

The default underlying makes the pricing members work, but
`implied_volatility()` and `greeks()` also need the option’s own last
price. Some contracts have none: on 2026-09-28 no broker that serves
quotes carried the MCX GOLD options or any bse currency contract, and
those signal
[`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror).

## Every contract

The members in this section are on
[Derivative](https://pramodathani.github.io/tradeR/reference/Derivative.md),
so every futures and option class has them. The example below reads them
from the nearest NIFTY future.

``` r

future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = "2026-09-29"
)
print(future$underlying_segment)
cat(future$days_to_expiry, future$expired, "\n")
cat(future$expiry_kind, format(future$next_expiry), "\n")
print(future$underlying)
print(future$underlying_price)
cat(future$open_interest_day_high, future$open_interest_day_low, "\n")
print(future$contract_value)
```

When the Python version of this example ran against a local UBI at 17:30
IST on 2026-09-28, after the close, it reported the underlying segment
`nse_equity_indices`, one day to expiry and not expired, a `monthly`
expiry whose next expiry was 2026-10-27, and the NIFTY index as a
`NonTradeableInstrument`. The index’s last price was 22780.25, the day’s
open interest ran between 10349495 and 11670165, and one lot was worth
1482968.5 rupees.

### underlying_segment

`underlying_segment` is a public field of every contract.

This field is the exchange-prefixed segment of the underlying, such as
`nse_equities` for a share future or `nse_equity_indices` for an index
option. It is set when the contract is built and never changes. With an
`underlying` given, it is that object’s own segment, such as
`mcx_commodity_futures` for an option given its future. Without one, it
is worked out from the contract’s own segment through a fixed table,
`INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT`, because the
rule is not a simple rename: `equity_futures` maps to `equities`, but
`fixed_income_options` maps to `fixed_income_futures`, and
`fixed_income_futures` maps to nothing.

It is a character value, or `NULL` when no underlying was given and the
family has no default, which is the case for a future on a commodity, a
currency pair or a bond.

### days_to_expiry

`days_to_expiry` is an active binding, and reading it sends no request.

This active binding counts the calendar days from today until the expiry
date, with today measured in India time. It sends no request.

#### Returns

An integer. It is 0 on the day of expiry, and negative once the contract
has expired.

#### Errors

It signals nothing.

### expired

`expired` is an active binding, and reading it sends no request.

This active binding says whether the expiry date has passed. A contract
expiring today is not expired, because it can still be traded until the
market closes, which is the same rule the discovery functions use to
leave out dead contracts. It sends no request.

#### Returns

A logical value that is `TRUE` once the expiry date is in the past.

#### Errors

It signals nothing.

### expiry_kind

`expiry_kind` is an active binding, and each read sends
`GET /api/instruments/master`.

This active binding says whether the contract is the last expiry of its
month for its underlying, or one of the weekly expiries before it. It
lists every expiry of the same underlying in the same segment, and calls
the contract `monthly` when none of the later ones falls in the same
calendar month. Quarterly and longer-dated contracts count as monthly,
because each is the last of its month.

Each read downloads the segment’s whole instrument list, which took
about two and a half seconds for RELIANCE options on 2026-09-28 and a
quarter of a second for NIFTY options, measured with the Python library.

#### Returns

The character value `"monthly"` or `"weekly"`.

#### Errors

| Condition | When |
|----|----|
| [`BadRequestError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#badrequesterror) | The exchange or segment is not one UBI knows |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### next_expiry

`next_expiry` is an active binding, and each read sends
`GET /api/instruments/master`.

This active binding gives the first live expiry after this contract’s,
on the same underlying in the same segment, which is where a position is
rolled to. It costs the same as `expiry_kind`.

#### Returns

A `Date`, or `NULL` when this contract is the last one listed.

#### Errors

| Condition | When |
|----|----|
| [`BadRequestError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#badrequesterror) | The exchange or segment is not one UBI knows |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### underlying

`underlying` is an active binding, and a read may send
`GET /api/instruments/details`.

This active binding gives the instrument the contract is written on,
found in the [order above](#how-a-contract-finds-its-underlying). What
comes back depends on how it was found, as the table below shows.

| How it was found | What `underlying` returns | Requests per read |
|----|----|----|
| You gave it, such as `EquityOption$new(..., underlying = reliance)` | That same object, of whatever class it is, such as `Equity` | None |
| UBI’s link | A `TradeableInstrument`, or a `NonTradeableInstrument` for an index | One or two |
| An equity’s default, by symbol | A `TradeableInstrument`, or a `NonTradeableInstrument` for an index | One |
| An option’s default future | A `Futures` | Two |

Only a given object is kept; the others are looked up again on every
read, so assign the result to a variable to use it more than once.
Giving it is still worth doing when you have it: it costs nothing, it
keeps its own class, so an `Equity` keeps its holdings members, and it
cannot be defeated by a name mismatch.

``` r

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
reliance_call <- EquityOption$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = "2026-10-27",
  strike_price = 1200,
  option_type = "CE",
  underlying = reliance
)
print(reliance_call$underlying)
print(identical(reliance_call$underlying, reliance))
```

The second line prints `TRUE`, because an R6 object is an environment
and [`identical()`](https://rdrr.io/r/base/identical.html) compares
environments by reference, so the contract hands back the very object it
was given.

#### Returns

The underlying, as an `Instrument`: the given object, or a
`TradeableInstrument`, `NonTradeableInstrument` or `Futures` from the
lookup.

#### Errors

| Condition | When |
|----|----|
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | No underlying was given, UBI gives no link, and the family’s default finds none |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### underlying_price

`underlying_price` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding reads the last traded price of the instrument
[`underlying`](#underlying) finds, as cheaply as that way allows: a
given object’s own `last_price`, one request by id for UBI’s link, one
request by exchange, segment and symbol for an equity’s default, and the
future’s lookup and price for an option’s default future. It is the
cheap way to get the one figure most members on this page need, and on
2026-09-28 it equalled `underlying$last_price` exactly. See [How a
contract finds its underlying](#how-a-contract-finds-its-underlying) for
the families where it signals an error.

#### Returns

A numeric value, or `NULL` when UBI has no last price.

#### Errors

| Condition | When |
|----|----|
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | The underlying cannot be found |
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote for the underlying |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### open_interest_day_high

`open_interest_day_high` is an active binding, and each read sends
`GET /api/instruments/quote`.

This active binding gives the highest open interest the contract reached
today, in underlying units. Read with
[`open_interest`](https://pramodathani.github.io/tradeR/articles/guide-market-data.html#open_interest)
and the day’s low, it shows whether positions were built up or unwound
during the session.

#### Returns

An integer, or `NULL` when the broker serving the quote does not report
it.

#### Errors

| Condition | When |
|----|----|
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote and no broker could supply one |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### open_interest_day_low

`open_interest_day_low` is an active binding, and each read sends
`GET /api/instruments/quote`.

This active binding gives the lowest open interest the contract reached
today, in underlying units.

#### Returns

An integer, or `NULL` when the broker serving the quote does not report
it.

#### Errors

| Condition | When |
|----|----|
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote and no broker could supply one |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### contract_value

`contract_value` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding gives the last price times the lot size. For a
future that is the exposure one lot carries, and for an option it is the
premium one lot costs. For currency contracts the lot size UBI reports
is the plurality of the brokers’ figures rather than the lot an order is
measured against, so there the figure is approximate.

#### Returns

A numeric value in rupees, or `NULL` when the last price or the lot size
is unknown.

#### Errors

| Condition | When |
|----|----|
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote and no broker could supply one |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

## Futures

The three members in this section are on
[Futures](https://pramodathani.github.io/tradeR/reference/Futures.md),
so every futures class has them. Each reads the future’s last price and
the underlying’s in two requests, which may be a moment apart. The
example below reads them from the RELIANCE October future.

``` r

future <- EquityFutures$new(
  exchange = "nse",
  underlying_symbol = "RELIANCE",
  expiry_date = "2026-10-27"
)
cat(future$last_price, future$underlying_price, "\n")
print(round(future$basis, 2))
print(round(future$basis_percent, 4))
print(round(future$cost_of_carry, 2))
```

When the Python version of this example ran against a local UBI at 17:30
IST on 2026-09-28, the future’s last price was 1208.0 and the share’s
was 1197.6, so the basis was 10.4, the basis percentage 0.8684 and the
cost of carry 10.93 per cent a year.

### basis

`basis` is an active binding, and each read sends
`GET /api/instruments/ltp` twice.

This active binding gives the future’s last price minus the
underlying’s. A positive basis, called a premium, is usual, because
holding the future instead of the underlying saves the cost of financing
it until expiry.

#### Returns

A numeric value in the underlying’s price units, or `NULL` when either
last price is unknown.

#### Errors

| Condition | When |
|----|----|
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | The underlying cannot be found |
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | No broker that serves quotes carries the future or its underlying |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### basis_percent

`basis_percent` is an active binding, and each read sends
`GET /api/instruments/ltp` twice.

This active binding gives the basis as a percentage of the underlying’s
last price, so 0.87 means the future is 0.87 per cent above its
underlying.

#### Returns

A numeric percentage, or `NULL` when either last price is unknown or the
underlying’s is zero.

#### Errors

It signals the same conditions as [`basis`](#basis).

### cost_of_carry

`cost_of_carry` is an active binding, and each read sends
`GET /api/instruments/ltp` twice.

This active binding gives the basis as a yearly rate: the basis
percentage times 365, divided by the calendar days left. Compared with
the risk-free rate, it says whether the future is dear or cheap. The
RELIANCE October future above, 0.87 per cent over its underlying with 29
days to go, carries 10.93 per cent a year.

**Close to expiry the figure means little.**

Dividing by a small number of days magnifies small differences. On
2026-09-28, with one day left, the NIFTY September future’s basis of
0.15 per cent read as 55.5 per cent a year, and RELIANCE’s 0.28 per cent
as 103.6 per cent.

#### Returns

A numeric annual percentage, or `NULL` when the contract expires today
or has expired, or when either last price is unknown.

#### Errors

It signals the same conditions as [`basis`](#basis).

## Options

The members in this section are on
[Option](https://pramodathani.github.io/tradeR/reference/Option.md), so
every option class has them. The example below reads them from a NIFTY
call. The call’s strike of 22800 was the one nearest the index’s close
of 22780.25 on 2026-09-28, so it was just out of the money.

``` r

option <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = "2026-10-06",
  strike_price = 22800,
  option_type = "CE"
)
cat(option$is_call, option$is_put, "\n")
cat(option$last_price, option$underlying_price, "\n")
cat(option$intrinsic_value, option$time_value, option$in_the_money, "\n")
print(round(option$moneyness_percent, 4))
print(option$breakeven_price)
cat(option$premium_per_lot, option$notional_value, "\n")
```

When the Python version of this example ran against a local UBI at 17:30
IST on 2026-09-28, the option was a call and not a put, its last price
was 203.7 against an index at 22780.25, its intrinsic value was 0 and
its time value 203.7, so it was not in the money. Its moneyness was
−0.0867 per cent, its breakeven price 23003.7, one lot cost 13240.5
rupees, and one lot controlled 1482000 rupees at the strike.

### is_call

`is_call` is an active binding, and reading it sends no request.

This active binding says whether the option is a call, the right to buy
the underlying at the strike. It sends no request.

#### Returns

A logical value that is `TRUE` when `option_type` is `"CE"`.

#### Errors

It signals nothing.

### is_put

`is_put` is an active binding, and reading it sends no request.

This active binding says whether the option is a put, the right to sell
the underlying at the strike. It sends no request.

#### Returns

A logical value that is `TRUE` when `option_type` is `"PE"`.

#### Errors

It signals nothing.

### intrinsic_value

`intrinsic_value` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding gives what the option would be worth if it were
exercised now. For a call that is how far the underlying is above the
strike, and for a put how far it is below, and it is never less than
zero.

#### Returns

A numeric value per unit of the underlying, or `NULL` when the
underlying’s last price is unknown.

#### Errors

| Condition | When |
|----|----|
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | The underlying cannot be found |
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote for the underlying |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### time_value

`time_value` is an active binding, and each read sends
`GET /api/instruments/ltp` twice.

This active binding gives the option’s last price minus its intrinsic
value, which is what the time left until expiry is worth. An
out-of-the-money option, like the call above, is all time value.

#### Returns

A numeric value per unit of the underlying, or `NULL` when either last
price is unknown.

#### Errors

It signals the same conditions as [`intrinsic_value`](#intrinsic_value),
plus `ServiceUnavailableError` when the option itself has no quote.

### in_the_money

`in_the_money` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding says whether the option has intrinsic value: a call
whose strike is below the underlying, or a put whose strike is above it.

#### Returns

A logical value, or `NULL` when the underlying’s last price is unknown.

#### Errors

It signals the same conditions as [`intrinsic_value`](#intrinsic_value).

### moneyness_percent

`moneyness_percent` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding gives how far the option is in or out of the money,
as a percentage of the underlying’s last price. The sign means the same
for a call and a put: positive is in the money and negative is out of
it. The call above, struck 19.75 points over an index at 22780.25, reads
−0.0867.

#### Returns

A signed numeric percentage, or `NULL` when the underlying’s last price
is unknown or zero.

#### Errors

It signals the same conditions as [`intrinsic_value`](#intrinsic_value).

### breakeven_price

`breakeven_price` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding gives the underlying price at expiry at which
someone who bought the option at its last price neither gains nor loses:
the strike plus the premium for a call, and the strike minus the premium
for a put.

#### Returns

A numeric value, or `NULL` when the option’s last price is unknown.

#### Errors

| Condition | When |
|----|----|
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | UBI has no recent quote for the option and no broker could supply one |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### premium_per_lot

`premium_per_lot` is an active binding, and each read sends
`GET /api/instruments/ltp`.

This active binding gives what buying one lot of the option costs at its
last price, which is the last price times the lot size. It is the same
figure as [`contract_value`](#contract_value), under the name an option
trader uses.

#### Returns

A numeric value in rupees, or `NULL` when the last price or the lot size
is unknown.

#### Errors

It signals the same conditions as [`breakeven_price`](#breakeven_price).

### notional_value

`notional_value` is an active binding, and reading it sends no request.

This active binding gives the value of the underlying one lot controls
at the strike price, which is the strike times the lot size. It sends no
request.

#### Returns

A numeric value in rupees, or `NULL` when the lot size is unknown.

#### Errors

It signals nothing.

## Implied volatility and greeks

The two methods in this section price the option with a model from
`R/assets_option_pricing.R`:
[Black76](https://pramodathani.github.io/tradeR/reference/Black76.md)
when the option is priced off a future, and
[BlackScholes](https://pramodathani.github.io/tradeR/reference/BlackScholes.md)
otherwise. UBI has no route for either, so the package works them out
from the option’s and the underlying’s last prices, in the same way it
works out the technical indicators from candles. The example below
prices the same NIFTY call, and its last line asks what the call would
be worth at 18 per cent volatility.

``` r

option <- EquityIndexOption$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = "2026-10-06",
  strike_price = 22800,
  option_type = "CE"
)
print(round(option$implied_volatility(), 4))
greeks <- option$greeks()
print(greeks[["model"]])
greek_names <- c(
  "volatility",
  "price",
  "delta",
  "gamma",
  "theta",
  "vega",
  "rho"
)
for (name in greek_names) {
  cat(sprintf("%-10s %.5f\n", name, greeks[[name]]))
}
print(round(option$greeks(volatility = 0.18)[["price"]], 2))
```

The table below gives the figures the Python version of this example
returned when it ran against a local UBI at 18:50 IST on 2026-09-28,
after the equity close. The implied volatility was 0.1482, the model was
`black_scholes`, and the call was worth 246.12 at 18 per cent
volatility. The R port’s models were checked against the Python ones on
2026-10-07 and agreed to ten decimal places.

| Key          | Value     |
|--------------|-----------|
| `volatility` | 0.14818   |
| `price`      | 203.70000 |
| `delta`      | 0.51412   |
| `gamma`      | 0.00080   |
| `theta`      | −14.61175 |
| `vega`       | 13.32858  |
| `rho`        | 2.47843   |

The table below lists the conventions the two methods follow. Each is a
choice worth knowing before comparing these figures with a broker’s
option chain.

| Convention | Value |
|----|----|
| Model | Black-76 on the future’s price when the option is priced off a future, which is the default for options on commodities, currencies and bonds and the case whenever the underlying you give is a future; Black-Scholes on the spot price otherwise. Both treat the option as European, with no dividends. `greeks()` names the model it used under `model`. |
| Time to expiry | From now until 15:30 India time on the expiry date, over a 365-day year |
| Risk-free rate | 0.065 by default, the constant `OPTION_PRICING_DEFAULT_RISK_FREE_RATE`, an approximation of India’s 91-day treasury bill yield; pass your own |
| Theta | Per calendar day |
| Vega | Per one percentage point of volatility |
| Rho | Per one percentage point of the rate |

**Why two models.**

A future’s price already includes the cost of holding the underlying
until expiry. Black-Scholes, given a future’s price, adds that cost
again; Black-76 takes the forward price as it is and only discounts, and
it is the model UBI’s order engine uses, so the two agree whenever an
option is priced off a future. Under Black-76, delta and gamma are
measured against the future’s price, and rho holds that price still, so
it is small and negative for calls and puts alike.

**After 15:30 on expiry day.**

From 15:30 India time on the expiry date both methods return `NULL`,
because there is no time left to price, while `expired` stays `FALSE`
until the next day. MCX commodity options trade into the evening, so
15:30 is only an approximation for them.

### implied_volatility

`implied_volatility(risk_free_rate = 0.065, underlying_price = NULL)` is
a method of
[Option](https://pramodathani.github.io/tradeR/reference/Option.html#method-Option-implied_volatility),
and each call sends `GET /api/instruments/ltp` twice.

This method finds the volatility at which the model’s price equals the
option’s last price. The underlying’s price is read from UBI unless you
give one; a figure you give is taken as the same kind of price, spot or
future, as the underlying it stands in for, which is how to ask what the
volatility would be at another underlying price. The option still needs
a last price of its own.

On 2026-09-28 the MCX CRUDEOIL 9100 call for 2026-10-15, with no
underlying given, found the future expiring on 2026-10-19 and gave an
implied volatility of 0.6092 under Black-76, measured with the Python
library.

#### Parameters

| Name | Type | Required | Default | Description |
|----|----|----|----|----|
| `risk_free_rate` | numeric | No | `0.065` | The annual risk-free rate, continuously compounded |
| `underlying_price` | numeric or `NULL` | No | `NULL` | The underlying price to use, or `NULL` to read it from UBI |

#### Returns

A numeric annual volatility, such as 0.1475 for 14.75 per cent. It is
`NULL` when either price is unknown, when the option is at or past 15:30
on its expiry date, or when the premium is below the option’s discounted
intrinsic value, where no volatility can explain it.

#### Errors

| Condition | When |
|----|----|
| `ValueError` | `underlying_price` is given and is not above zero |
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | The underlying cannot be found |
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | No broker that serves quotes carries the option, or the underlying when no price is given |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

### greeks

`greeks(risk_free_rate = 0.065, volatility = NULL, underlying_price = NULL)`
is a method of
[Option](https://pramodathani.github.io/tradeR/reference/Option.html#method-Option-greeks),
and each call sends `GET /api/instruments/ltp` twice.

This method works out the option’s fair price and its five greeks.
Without a volatility it uses the implied volatility, so the fair price
equals the last price and the greeks describe the option as the market
prices it. With a volatility it answers “what if”, as the last line of
the example does.

The table below says what each greek measures.

| Name | Measures |
|----|----|
| `volatility` | The volatility the figures were worked out at |
| `price` | The model’s fair price |
| `delta` | How much the option’s price moves for a one-unit move in the underlying, from 0 to 1 for a call and from −1 to 0 for a put |
| `gamma` | How much the delta moves for a one-unit move in the underlying |
| `theta` | How much the option’s price changes as one calendar day passes, usually negative |
| `vega` | How much the option’s price moves when volatility rises by one percentage point |
| `rho` | How much the option’s price moves when the rate rises by one percentage point |

#### Parameters

| Name | Type | Required | Default | Description |
|----|----|----|----|----|
| `risk_free_rate` | numeric | No | `0.065` | The annual risk-free rate, continuously compounded |
| `volatility` | numeric or `NULL` | No | `NULL` | The annual volatility to use, or `NULL` for the implied volatility |
| `underlying_price` | numeric or `NULL` | No | `NULL` | The underlying price to use, or `NULL` to read it from UBI |

#### Returns

A named list with `model`, the character value `"black_76"` or
`"black_scholes"`, and the seven names above, each numeric. The method
returns `NULL` instead when a price it needs is unknown, when the option
is at or past 15:30 on its expiry date, or when no implied volatility
can be found.

#### Errors

| Condition | When |
|----|----|
| `ValueError` | `underlying_price` or `volatility` is given and is not above zero |
| [`UnderlyingError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#underlyingerror) | The underlying cannot be found |
| [`ServiceUnavailableError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#serviceunavailableerror) | No broker that serves quotes carries the option, or the underlying when no price is given |
| [`UnifiedBrokerInterfaceError`](https://pramodathani.github.io/tradeR/articles/guide-errors.html#unifiedbrokerinterfaceerror) | Any other failure reported by, or on the way to, UBI |

**Under the hood.**

`underlying_price` sends `GET /api/instruments/ltp` with `instrument_id`
set to `underlying_instrument_id` when UBI gives that link. For an
equity’s default it sends `exchange`, `segment` set to
`underlying_segment` and `symbol` set to `underlying_symbol` instead,
which UBI’s [quote
routes](https://pramodathani.github.io/unified_broker_interface/rest-api/market-quotes/)
accept in place of an `instrument_id`. `expiry_kind` and `next_expiry`
read the same master list the [discovery
functions](https://pramodathani.github.io/tradeR/articles/guide-discovery.html#why-two-different-ubi-routes)
read.
[BlackScholes](https://pramodathani.github.io/tradeR/reference/BlackScholes.md)
and
[Black76](https://pramodathani.github.io/tradeR/reference/Black76.md) in
`R/assets_option_pricing.R`, over their shared
[OptionPricingModel](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.md)
base, do the maths in base R, with
[`stats::pnorm()`](https://rdrr.io/r/stats/Normal.html) for the
cumulative normal distribution, and the implied volatility search halves
the range from 0.0001 to 5.0 a hundred times, the same bounds UBI’s own
search uses.
