# The errors the instrument classes signal

Each name is an error class and each value is its parent class.
`InstrumentError` is the root, and every other class is a flat sibling
under it, so catch the contract's own error or `InstrumentError` for any
instrument problem.

## Usage

``` r
ASSETS_ERROR_PARENTS
```

## Format

A named character vector, one entry per error class:

- `InstrumentError`:

  An instrument UBI does not know, or one that cannot be used as asked.

- `TradeableInstrumentError`:

  An instrument asked for as tradeable that cannot be traded, such as an
  index.

- `NonTradeableInstrumentError`:

  An instrument asked for as non-tradeable that can in fact be traded.

- `DerivativeError`:

  An instrument asked for as a derivative that is neither a future nor
  an option, has no expiry date, or sits in a segment with no known
  underlying segment.

- `FuturesError`:

  An instrument asked for as a futures contract that is not one, or a
  futures discovery call made on a class that names no segment.

- `OptionError`:

  An instrument asked for as an option that is not one or lacks a strike
  price or option type, or an option discovery call made on a class that
  names no segment.

- `IndexFuturesError`:

  A futures contract asked for as an index future whose segment is not
  an index futures segment.

- `IndexOptionError`:

  An option asked for as an index option whose segment is not an index
  options segment.

- `UnderlyingError`:

  A futures or option contract whose underlying cannot be found: none
  was given, UBI links it to none, and its family's default finds none.

- `PositionError`:

  A position that cannot be changed as asked, or one that is not held at
  all.

- `HoldingError`:

  A holding that cannot be changed as asked, or one that is not held at
  all.

- `EquityError`:

  An equity share UBI does not know, or one that is not in the equities
  segment.

- `EquityFuturesError`:

  An equity futures contract UBI does not know, or one that is not in
  the equity futures segment.

- `EquityOptionError`:

  An equity option UBI does not know, or one that is not in the equity
  options segment.

- `EquityIndexError`:

  An equity index UBI does not know, or one that is not in the equity
  indices segment.

- `EquityIndexFuturesError`:

  An equity index futures contract UBI does not know, or one that is not
  in the equity index futures segment.

- `EquityIndexOptionError`:

  An equity index option UBI does not know, or one that is not in the
  equity index options segment.

- `FixedIncomeError`:

  A bond UBI does not know, or one that is not in the fixed income
  segment.

- `FixedIncomeFuturesError`:

  A bond futures contract UBI does not know, or one that is not in the
  fixed income futures segment.

- `FixedIncomeOptionError`:

  A bond option UBI does not know, or one that is not in the fixed
  income options segment.

- `FixedIncomeIndexError`:

  A fixed income index UBI does not know, or one that is not in the
  fixed income indices segment.

- `FixedIncomeIndexFuturesError`:

  A fixed income index futures contract UBI does not know, or one that
  is not in the fixed income index futures segment.

- `FixedIncomeIndexOptionError`:

  A fixed income index option UBI does not know, which is true of every
  one of them today, or one that is not in the fixed income index
  options segment.

- `CommodityError`:

  A commodity UBI does not know, or one that is not in the commodities
  segment.

- `CommodityFuturesError`:

  A commodity futures contract UBI does not know, or one that is not in
  the commodity futures segment.

- `CommodityOptionError`:

  A commodity option UBI does not know, or one that is not in the
  commodity options segment.

- `CommodityIndexError`:

  A commodity index UBI does not know, or one that is not in the
  commodity indices segment.

- `CommodityIndexFuturesError`:

  A commodity index futures contract UBI does not know, or one that is
  not in the commodity index futures segment.

- `CommodityIndexOptionError`:

  A commodity index option UBI does not know, or one that is not in the
  commodity index options segment.

- `CurrencyError`:

  A currency pair UBI does not know, or one that is not in the
  currencies segment.

- `CurrencyFuturesError`:

  A currency futures contract UBI does not know, or one that is not in
  the currency futures segment.

- `CurrencyOptionError`:

  A currency option UBI does not know, or one that is not in the
  currency options segment.

- `CurrencyIndexError`:

  A currency index UBI does not know, which is true of every one of them
  today, or one that is not in the currency indices segment.

- `CurrencyIndexFuturesError`:

  A currency index futures contract UBI does not know, which is true of
  every one of them today, or one that is not in the currency index
  futures segment.

- `CurrencyIndexOptionError`:

  A currency index option UBI does not know, which is true of every one
  of them today, or one that is not in the currency index options
  segment.

- `ExchangeTradedFundError`:

  An exchange traded fund UBI does not know, or one that is not in the
  exchange traded funds segment.

- `InvestmentTrustError`:

  An investment trust UBI does not know, or one that is not in the
  investment trusts segment.

- `MutualFundError`:

  A mutual fund scheme UBI does not know, or one that is not in the
  mutual funds segment.
