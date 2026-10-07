# The instrument model

Every instrument in the package is an object of one R6 class, and the
class says what kind of contract it is. This article shows how those
classes are layered, what each layer adds, how an instrument is looked
up in UBI, and how the asset baskets, the synthetic order classes and
the account sit beside the instruments rather than inside them.

## The levels of class

The instrument classes form three levels, with a fourth for contracts.
The base, `Instrument`, holds everything any instrument can do,
including 209 analysis methods it inherits from fourteen analysis
classes. The middle level splits instruments into those that can be
traded and indices, which cannot. Below `TradeableInstrument`, five
derivative base classes hold what every futures or option contract
shares. The bottom level is 27 family classes, one per UBI segment,
which is what you actually construct.

The class diagram below shows the levels above the family classes, with
their main members. The analysis classes are drawn as three boxes to
keep the diagram readable. In R they are not fourteen separate parents,
because an R6 class can have only one parent: they form one chain, in
which each analysis class inherits the one before it, and `Instrument`
inherits the last link, `PerformanceMeasures`. [One chain of analysis
classes](#one-chain-of-analysis-classes) below draws the whole chain.

``` mermaid

classDiagram
    direction TB
    class PriceAnalysis {
        root of the chain
        prices() signals an error
    }
    class AnalysisChain {
        <<thirteen classes, each inheriting the one above>>
        PriceStatistics
        OverlapStudies
        MomentumIndicators
        VolumeIndicators
        CycleIndicators
        PriceTransforms
        VolatilityIndicators
        StatisticFunctions
        MathTransforms
        MathOperators
        CandlestickPatterns
        Signals
        StrategyBacktests
    }
    class PerformanceMeasures {
        last link of the chain
    }
    class Instrument {
        instrument_id
        exchange, segment, shape
        symbol, underlying_symbol
        expiry_date, strike_price, option_type
        lot_size, tick_size, carried_by
        quote
        last_price
        ohlc
        prices(interval, from_date, to_date, days, adjusted)
        the shared client
    }
    class TradeableInstrument {
        bids, offers, best_bid, best_offer
        mid_price, bid_offer_spread
        orders, open_orders, trades
        net_positions, day_positions
        positions_value, positions_pnl
        place_order(...)
        modify_order(...)
        cancel_order(...)
        32 price wrappers
        add_to_position(...)
        reduce_position(...)
        liquidate_position(...)
    }
    class NonTradeableInstrument {
        accepts only an index
        constituents
    }
    class Derivative {
        underlying_segment
        days_to_expiry, expired
        expiry_kind, next_expiry
        underlying, underlying_price
        contract_value
    }
    class Futures {
        basis, basis_percent, cost_of_carry
        expiries(), contracts()
    }
    class Option {
        intrinsic_value, time_value
        moneyness_percent, breakeven_price
        implied_volatility(), greeks()
        expiries(), strikes(), chain()
    }
    class IndexFutures {
        underlying is an index
    }
    class IndexOption {
        underlying is an index
    }
    PriceAnalysis <|-- AnalysisChain
    AnalysisChain <|-- PerformanceMeasures
    PerformanceMeasures <|-- Instrument
    Instrument <|-- TradeableInstrument
    Instrument <|-- NonTradeableInstrument
    TradeableInstrument <|-- Derivative
    Derivative <|-- Futures
    Derivative <|-- Option
    Futures <|-- IndexFutures
    Option <|-- IndexOption
```

The diagram lists only the main members of `TradeableInstrument` and the
derivative classes. The
[guide](https://pramodathani.github.io/tradeR/articles/guide.md)
documents every one of them,
[Derivatives](https://pramodathani.github.io/tradeR/articles/guide-derivatives.md)
the contract members in particular, and
[Analysis](https://pramodathani.github.io/tradeR/articles/analysis.md)
the inherited analysis methods. The reference pages for
[`Instrument`](https://pramodathani.github.io/tradeR/reference/Instrument.md),
[`TradeableInstrument`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.md),
[`NonTradeableInstrument`](https://pramodathani.github.io/tradeR/reference/NonTradeableInstrument.md),
[`Derivative`](https://pramodathani.github.io/tradeR/reference/Derivative.md),
[`Futures`](https://pramodathani.github.io/tradeR/reference/Futures.md)
and
[`Option`](https://pramodathani.github.io/tradeR/reference/Option.md)
list their members in full.

### One chain of analysis classes

The Python library writes its fourteen analysis classes as mixins, which
`Instrument` inherits all at once through multiple inheritance. R6
allows a class only one parent, so the R port links the same fourteen
classes into a single chain, from `PriceAnalysis` at the root to
`PerformanceMeasures` at the end. The flowchart below shows the chain in
order, with the two classes that inherit its last link.

``` mermaid

flowchart TB
    A["PriceAnalysis"] --> B["PriceStatistics"]
    B --> C["OverlapStudies"]
    C --> D["MomentumIndicators"]
    D --> E["VolumeIndicators"]
    E --> F["CycleIndicators"]
    F --> G["PriceTransforms"]
    G --> H["VolatilityIndicators"]
    H --> I["StatisticFunctions"]
    I --> J["MathTransforms"]
    J --> K["MathOperators"]
    K --> L["CandlestickPatterns"]
    L --> M["Signals"]
    M --> N["StrategyBacktests"]
    N --> O["PerformanceMeasures"]
    O --> P["Instrument"]
    O --> Q["AssetBasket"]
```

The analysis methods all have distinct names, so the order of the chain
changes nothing about what any method does. The order is still fixed,
because each file’s `inherit =` line names the class before it, and the
sidecar notes ask that those lines stay as they are. Two consequences of
the chain are worth knowing:

- Every class in the chain can see the private methods of every class
  above it, because R6 private members are shared along an inheritance
  chain. A private method in a later class with the same name as one in
  an earlier class would therefore replace it. The private helpers of
  `PriceStatistics` carry a `price_statistics_` prefix for that reason,
  and the helpers of `PerformanceMeasures` keep names no other analysis
  class uses.
- A reference page such as
  [`Equity`](https://pramodathani.github.io/tradeR/reference/Equity.md)
  lists the inherited analysis methods as links to the class in the
  chain that defines them, rather than repeating their documentation.

## The 27 family classes

The flowchart below shows the bottom level, grouped by the file each
class lives in. The cash classes and the funds inherit
`TradeableInstrument` directly, the four index classes are the only ones
built on `NonTradeableInstrument`, and the sixteen futures and option
classes inherit `Futures`, `Option`, `IndexFutures` or `IndexOption`,
which all sit on `TradeableInstrument` through `Derivative`.

``` mermaid

flowchart LR
    T["TradeableInstrument"]
    N["NonTradeableInstrument"]
    FB["Futures"]
    OB["Option"]
    IF["IndexFutures"]
    IO["IndexOption"]
    subgraph EQ["R/assets_equities.R"]
        E1["Equity"]
        E2["EquityFutures"]
        E3["EquityOption"]
        E4["EquityIndex"]
        E5["EquityIndexFutures"]
        E6["EquityIndexOption"]
    end
    subgraph FI["R/assets_fixed_income.R"]
        F1["FixedIncome"]
        F2["FixedIncomeFutures"]
        F3["FixedIncomeOption"]
        F4["FixedIncomeIndex"]
        F5["FixedIncomeIndexFutures"]
        F6["FixedIncomeIndexOption"]
    end
    subgraph CO["R/assets_commodities.R"]
        C1["Commodity"]
        C2["CommodityFutures"]
        C3["CommodityOption"]
        C4["CommodityIndex"]
        C5["CommodityIndexFutures"]
        C6["CommodityIndexOption"]
    end
    subgraph CU["R/assets_currencies.R"]
        U1["Currency"]
        U2["CurrencyFutures"]
        U3["CurrencyOption"]
        U4["CurrencyIndex"]
        U5["CurrencyIndexFutures"]
        U6["CurrencyIndexOption"]
    end
    subgraph FU["R/assets_funds.R and R/assets_mutual_funds.R"]
        D1["ExchangeTradedFund"]
        D2["InvestmentTrust"]
        D3["MutualFund"]
    end
    T --> E1 & F1 & C1 & U1
    T --> D1 & D2 & D3
    T --> FB & OB
    FB --> IF
    OB --> IO
    FB --> E2 & F2 & C2 & U2
    OB --> E3 & F3 & C3 & U3
    IF --> E5 & F5 & C5 & U5
    IO --> E6 & F6 & C6 & U6
    N --> E4 & F4 & C4 & U4
```

The table below counts the classes in each file and says what the file’s
cash class can do that the others cannot.

| File | Classes | Tradeable | On `NonTradeableInstrument` | Holdings members on |
|----|---:|---:|---:|----|
| `R/assets_equities.R` | 6 | 5 | 1 | `Equity` |
| `R/assets_fixed_income.R` | 6 | 5 | 1 | `FixedIncome` |
| `R/assets_commodities.R` | 6 | 5 | 1 | none |
| `R/assets_currencies.R` | 6 | 5 | 1 | none |
| `R/assets_funds.R` | 2 | 2 | 0 | `ExchangeTradedFund`, `InvestmentTrust` |
| `R/assets_mutual_funds.R` | 1 | 1 | 0 | `MutualFund` |
| **Total** | **27** | **23** | **4** | five classes |

Commodities and currencies have no holdings members because UBI can only
report a holding for a segment in its `CASH_SEGMENTS`, which excludes
both. The [Asset
classes](https://pramodathani.github.io/tradeR/articles/asset-classes.md)
section covers each family’s own traps.

## What lives at each level

Each level adds only what is true of every class below it. The table
below lists what each level holds and why it sits there rather than
higher or lower.

| Level | Holds | Why here |
|----|----|----|
| `PriceAnalysis` and the fourteen analysis classes in their chain | TA-Lib indicators, candlestick patterns, statistics, crossovers, a backtest and performance measures such as the Sharpe ratio, 209 methods | Every instrument with candles can be analysed, including an index, and so can every basket |
| `Instrument` | Identity fields, `lot_size`, `tick_size`, `carried_by`; `prices`, `quote`, `last_price`, `ohlc`; the shared client; a `details` argument for building from an answer already fetched | UBI quotes indices too, and an index’s last price is one of the most used values |
| `InstrumentCatalogue` | The discovery helpers `search`, `master`, `contracts_for`, `expiry_dates`, `strikes` and `identity_frame` | In Python these are protected class methods on `Instrument`; R6 generators do not pass functions on to subclasses, so the R port gives them a small helper class of their own |
| `TradeableInstrument` | The eleven order-book values, the order and trade readers, `place_order`, `modify_order`, `cancel_order`, `cancel_open_orders`, the parent members, the 32 price wrappers, the position readers, totals and the four position methods | An index has no order book, no orders and no position |
| `NonTradeableInstrument` | A refusal of any segment that does not end in `_indices`, and `constituents`, the index’s stored basket | An index is the one kind of instrument whose members are worth storing |
| `Derivative` | The expiry members, the underlying’s segment, object and price, the open interest range and the value of one lot | Every futures and option contract expires and is written on something |
| `Futures`, `Option` | The basis members on `Futures`; moneyness, intrinsic and time value, implied volatility and greeks on `Option` | They were identical in all sixteen derivative classes apart from the segment |
| `IndexFutures`, `IndexOption` | A check that the segment is an index one, and an `underlying` that is a `NonTradeableInstrument` | An index cannot be delivered, so these contracts differ in what their underlying is |
| Family class | A fixed segment, named in a package constant such as `EQUITIES_EQUITY_FUTURES_SEGMENT` (Python declares it in a `SEGMENT` class attribute on a derivative class), a constructor taking exactly that segment’s identity fields, its own error class, the discovery functions on its class generator, and on five classes the holdings members | The kind of contract is the class, not a segment string passed by hand |

The discovery calls follow the same pattern in every six-class file. In
Python they are class methods; in R they are functions stored on each
family class’s generator, such as `Equity$search()` or
`EquityOption$chain()`, because R6 generators do not inherit such
functions. Each one builds an `InstrumentCatalogue` and calls it. The
table below shows which functions each kind of class offers.

| Kind of class | Examples | Discovery functions on the class generator |
|----|----|----|
| A cash security or an index | `Equity`, `EquityIndex`, `Commodity`, `MutualFund` | `search` |
| A futures class | `EquityFutures`, `CurrencyIndexFutures` | `expiries`, `contracts` |
| An option class | `EquityOption`, `FixedIncomeIndexOption` | `expiries`, `strikes`, `chain` |

`Futures$expiries()`, `Futures$contracts()`, `Option$expiries()`,
`Option$strikes()` and `Option$chain()` also exist on the base
generators, but they only signal `FuturesError` or `OptionError`, as
calling them on the Python base classes does, because those classes name
no segment. All of the working functions read `/api/instruments/master`
rather than `/api/instruments/search`, for the reason given in [Design
choices](https://pramodathani.github.io/tradeR/articles/architecture-design-choices.html#discovery-reads-the-master-rather-than-search).

## Active bindings and methods

A member that only reports a value is an active binding, the R6
counterpart of a Python property, and a member is a method only when it
takes an argument or writes to the market. The user decided this for the
Python library on 2026-09-22, so that a caller reads what a member
means, such as `share$last_price`, rather than how it is fetched, and
the R port keeps the rule. An active binding is read without brackets
and signals an error when assigned to. The table below sorts the
instrument surface by that rule.

| Kind | Written as | Members |
|----|----|----|
| Reads a value | active binding | `quote`, `last_price`, `ohlc`; `bids`, `offers`, `best_bid`, `best_offer`, `bid_offer_spread`, `mid_price`, `volume_weighted_average_price`, `last_quantity`, `total_traded_volume`, `open_interest`, `last_trade_time`; `parents`, `orders`, `open_orders`, `completed_orders`, `rejected_orders`, `cancelled_orders`, `trades`; `net_positions`, `day_positions`, `positions_value`, `positions_pnl`; `holdings`, `holdings_value`, `holdings_pnl`; `constituents` on an index, an exchange traded fund and a mutual fund; the twenty-one contract bindings on [Derivatives](https://pramodathani.github.io/tradeR/articles/guide-derivatives.md), from `days_to_expiry` to `notional_value` |
| Takes arguments, only reads | method | `prices`, `parent`, `parent_orders`, `parent_trades`, `implied_volatility`, `greeks` and every analysis method |
| Finds instruments | function on the class generator | `search`, `expiries`, `contracts`, `strikes`, `chain` |
| Sends orders | method that places orders | `place_order`, `modify_order`, `cancel_order`, `cancel_open_orders`, `cancel_parent`, the 32 price wrappers, `add_to_position`, `reduce_position`, `liquidate_position`, `liquidate_all_positions`, `add_to_holdings`, `reduce_holdings`, `liquidate_holdings` |

**An active binding is still a request.**

Every read of an active binding sends its own request to UBI, and
nothing is cached. Code that needs a value twice, such as
`share$net_positions` checked and then used, should assign it to a local
variable first, or the two reads may see two different moments.

The identity fields, such as `exchange`, `symbol` and `lot_size`, are
plain public fields rather than active bindings. They are read once,
when the object is built, and never change.

## How an instrument is looked up

Building an instrument sends exactly one request,
`GET /api/instruments/details`, unless the answer is passed in already
through the `details` argument of `Instrument$new()`,
`TradeableInstrument$new()` or `NonTradeableInstrument$new()`, which is
how a basket builds all its members from one
`POST /api/instruments/details`. Every later request names the
instrument only by the `instrument_id` that answer carried, which is a
UUID UBI computes from the identity and which is the same at every
broker. The sequence below shows the lookup for
`Equity$new("nse", "RELIANCE")`, including the two ways it can fail.

``` mermaid

sequenceDiagram
    autonumber
    participant P as Your program
    participant E as Equity initialize
    participant I as Instrument initialize
    participant C as Shared client
    participant A as UBI
    P->>E: Equity$new("nse", "RELIANCE")
    E->>I: super$initialize(exchange, segment = "equities", symbol)
    I->>C: Instrument$shared_unified_broker_interface()
    I->>C: get("/api/instruments/details", params)
    C->>A: GET /api/instruments/details
    alt UBI knows the share
        A-->>C: identity, lot_size, tick_size, carried_by
        C-->>I: named list
        I->>I: store fields, parse dates, tick_size as numeric
        I-->>E: done
        E->>E: segment is nse_equities, or signal EquityError
        E-->>P: Equity object
    else HTTP 404
        A-->>C: not found
        C-->>I: NotFoundError
        I-->>E: InstrumentError, with the NotFoundError as its parent
        E-->>P: EquityError, with the InstrumentError as its parent
    end
```

The table below lists what the constructor does with each part of UBI’s
answer.

| From `/details` | Stored as | Note |
|----|----|----|
| `instrument_id` | `instrument_id`, a character string | Used alone in every later request, and by `equals()` |
| `exchange`, `segment` | lower case, segment prefixed such as `nse_equities` | UBI accepts a bare segment but always returns it prefixed |
| `expiry_date`, `mapping_date`, `first_seen_date`, `last_seen_date` | `Date` or `NULL` |  |
| `lot_size` | integer or `NULL` | `NULL` when UBI’s brokers disagree |
| `tick_size` | numeric or `NULL` | Python keeps it as a `decimal.Decimal`; base R has no decimal type, and a tick size is only ever compared or multiplied, so a double is close enough, and the exact text UBI sent can still be read from `carried_by` |
| `carried_by` | a list of named lists, one per broker | Each broker’s own token, order symbol, lot size and tick size, raw |

The code below prints the object and then each of its public identity
fields. When the Python library ran the same lookup against a local UBI
on 2026-09-26, the share’s `instrument_id` was
`3f92570a-9924-5bf5-9f9d-e006cd9f4202`, its `lot_size` was 1, its
`tick_size` was 0.1, and `carried_by` held one entry for each of nine
brokers, starting with Dhan and Flattrade.

``` r

reliance <- Equity$new("nse", "RELIANCE")
print(reliance)
field_names <- c(
  "instrument_id",
  "exchange",
  "segment",
  "shape",
  "symbol",
  "underlying_symbol",
  "expiry_date",
  "strike_price",
  "option_type",
  "mapping_date",
  "first_seen_date",
  "last_seen_date",
  "lot_size",
  "tick_size"
)
for (field_name in field_names) {
  cat(field_name, ": ", sep = "")
  str(reliance[[field_name]])
}
str(reliance$carried_by[[1]])
```

[`print()`](https://rdrr.io/r/base/print.html) writes the same text the
Python object’s `repr` gives,
`Equity(exchange='nse', segment='nse_equities', symbol='RELIANCE')`,
because the R class’s [`format()`](https://rdrr.io/r/base/format.html)
method follows it.

**Two objects for one instrument are equal.**

`equals()` compares `instrument_id`, so two objects built separately for
the same contract compare equal with `first$equals(second)`. The Python
library also lets such objects be used as the same dictionary key
through `__hash__`; R has no counterpart, because R6 objects are not
used as keys.

A family class refuses anything else. Its constructor takes only the
identity fields its shape needs, all required, so a missing expiry date
stops R with an “argument is missing, with no default” error during
construction, before any request is sent, rather than an HTTP 400 a
round trip later. A UBI 404 becomes the class’s own error, such as
`EquityOptionError`, whose `parent` field holds the `InstrumentError`
underneath, the R counterpart of Python’s exception chaining.
[Errors](https://pramodathani.github.io/tradeR/articles/guide-errors.md)
lists every one.

## One shared client

Every instrument, synthetic order and `Account` in an R session sends
its requests through one `UnifiedBrokerInterface`, which
`Instrument$shared_unified_broker_interface()` creates on first use. UBI
holds a single access token for the whole application and every connect
replaces it, so two clients would keep logging each other out and each
would pay a reconnect on its next call.

The Python library stores the client on `Instrument` as a class
attribute. The R port keeps it in a small environment inside the
package, `.trade_r_state`, because storing state on an R6 generator is
fragile when `devtools::load_all()` reloads the package.
`Instrument$set_shared_unified_broker_interface()`, which has no Python
counterpart, installs a client of your own as the shared one, such as
one built with the `credentials` argument that only the R client has. A
caller can still pass a client of its own to any constructor through
`unified_broker_interface`, but then it owns the token clash that
follows. [The UBI
client](https://pramodathani.github.io/tradeR/articles/guide-client.md)
documents the client’s own members.

## Synthetic orders sit beside the instrument

A synthetic order, such as a bracket, a trailing stop or an iceberg, is
not a member of the instrument. It is an object of its own, defined in
one of the `R/orders_*.R` files, that holds an instrument and an order
template and sends both through the instrument’s `place_order`. The
class diagram below shows how the pieces relate.

``` mermaid

classDiagram
    direction LR
    class SyntheticOrder {
        SYNTHETIC_TYPE simple
        instrument
        transaction_type, product, order_type
        quantity, price, trigger_price
        price_reference, quantity_reference
        closes_position, reduce_only, dry_run
        parent_id
        synthetic
        synthetic_fields()
        place()
        cancel()
        parent, orders, trades
    }
    class BracketOrder {
        SYNTHETIC_TYPE bracket
        stop_price, stop_limit_price, target_price
        synthetic_fields()
    }
    class BasketOrder {
        SYNTHETIC_TYPE basket
        candidates
        synthetic_fields()
    }
    class ExposureHedgeOrder {
        SYNTHETIC_TYPE exposure_hedge
        watched, lower_band, upper_band
        synthetic_fields()
    }
    class OrderCandidate {
        instrument
        document()
    }
    class ExposureWatch {
        instrument
        exposure_per_unit
    }
    class TradeableInstrument {
        place_order(..., synthetic)
    }
    SyntheticOrder <|-- BracketOrder
    SyntheticOrder <|-- BasketOrder
    SyntheticOrder <|-- ExposureHedgeOrder
    SyntheticOrder --> TradeableInstrument : place() calls place_order
    BasketOrder o-- OrderCandidate
    ExposureHedgeOrder o-- ExposureWatch
    OrderCandidate --> TradeableInstrument
    ExposureWatch --> TradeableInstrument
```

The three subclasses in the diagram stand for all of them. Every type is
its own R6 class in its own file, and each adds only its settings and a
`synthetic_fields()` method that names them the way UBI does.
`SYNTHETIC_TYPE` is a public field rather than a class attribute,
because R6 has no class attributes, and each subclass overrides it with
its own type name. The base class builds the `synthetic` object, a named
list holding the type and the settings, and `place()` calls
`place_order` with it, so a synthetic order is placed exactly like a
plain one, through [UBI’s order
engine](https://pramodathani.github.io/tradeR/articles/architecture-order-engine.md).
`place()` keeps the `parent_id` UBI answers with, and `cancel()` and the
`parent`, `orders` and `trades` active bindings use it to reach the
parent through the instrument’s parent members.

Five types take a list of instruments rather than one. `BasketOrder`,
`OneCancelsAllOrder`, `LeggedSpreadOrder` and `StrategyStopOrder` take a
list of `OrderCandidate` objects, and the first candidate’s instrument
anchors the request. `ExposureHedgeOrder` is built on the hedge
instrument and takes a list of `ExposureWatch` objects for the
instruments it watches. These lists must be R
[`list()`](https://rdrr.io/r/base/list.html) values rather than atomic
vectors, because the client writes a one-element vector as a single JSON
value rather than as an array. [Synthetic
orders](https://pramodathani.github.io/tradeR/articles/guide-synthetic-orders.md)
documents every type.

## Baskets sit beside the instruments

An asset basket is a group of instruments, such as a portfolio, a
watchlist, an index’s constituents or what a fund holds. It is not an
instrument and does not inherit `Instrument`, but `AssetBasket` inherits
`PerformanceMeasures`, the same last link of the analysis chain that
`Instrument` inherits, so every analysis method and performance measure
works on a basket too, over candles the basket builds from its members.
The class diagram below shows how the two sides link.

``` mermaid

classDiagram
    direction LR
    class PerformanceMeasures {
        <<last link of the analysis chain>>
    }
    class AssetBasket {
        members, weights
        last_prices, quotes
        prices()
    }
    class Portfolio {
        place_orders()
        rebalance()
    }
    class Index
    class Instrument
    class NonTradeableInstrument {
        constituents
    }
    class BasketStore {
        save(), load()
        load_for_instrument()
    }
    PerformanceMeasures <|-- AssetBasket
    PerformanceMeasures <|-- Instrument
    Instrument <|-- NonTradeableInstrument
    AssetBasket <|-- Portfolio
    AssetBasket <|-- Index
    NonTradeableInstrument ..> BasketStore : constituents calls
    BasketStore ..> AssetBasket : builds
    AssetBasket --> Instrument : linked_instrument
```

`Watchlist`, `ExchangeTradedFundConstituents` and
`MutualFundConstituents` are left out of the diagram and sit on
`AssetBasket` in the same way. `ExchangeTradedFund` and `MutualFund`
have a `constituents` active binding just like `NonTradeableInstrument`.
The link runs both ways without merging the two objects: an instrument’s
`constituents` returns the stored basket, whose `linked_instrument` is
that instrument again, and the official price stays on the instrument.
[Asset
baskets](https://pramodathani.github.io/tradeR/articles/guide-asset-baskets.md)
documents the classes and [Design
choices](https://pramodathani.github.io/tradeR/articles/architecture-design-choices.html#baskets-are-stored-here-and-linked-to-instruments)
records why they are built this way.

## The account sits above the instruments

[`Account`](https://pramodathani.github.io/tradeR/reference/Account.md),
in `R/accounts_account.R`, stands for the whole trading account rather
than one instrument. It takes the same shared client. Its `flatten()`
sends `POST /api/orders/flatten`, which halts every synthetic order the
engine is running, cancels every open order at every broker and then
closes every position; its `parents` active binding lists every open
parent in the account; and its `intent()` method reads the engine’s
answer to an order whose placement stopped waiting. The caller must pass
`confirm = "FLATTEN"`. The table below compares it with the closest
per-instrument member.

|  | `TradeableInstrument$liquidate_all_positions()` | `Account$flatten()` |
|----|----|----|
| Scope | This instrument’s positions | Every position and open order in the account |
| Open orders | Left alone | Cancelled first, at every broker |
| UBI route | One `POST /api/orders/place` per product held | One `POST /api/orders/flatten` |
| Armed synthetic orders | Left alone | Halted first, so they cannot trade afterwards |
| Timeout | The client’s 30 seconds per request | 120 seconds by default, through its `timeout_seconds` argument, which it passes to `post()` |

[The
account](https://pramodathani.github.io/tradeR/articles/guide-account.md)
documents its members in full.
