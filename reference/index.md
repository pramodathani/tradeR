# Package index

## Connecting to UBI

The client every object sends its requests through, and the settings it
reads.

- [`UnifiedBrokerInterface`](https://pramodathani.github.io/tradeR/reference/UnifiedBrokerInterface.md)
  : A connection to the Unified Broker Interface REST API
- [`Configuration`](https://pramodathani.github.io/tradeR/reference/Configuration.md)
  : The settings for one R session, read from the environment on first
  use

## Instruments

What every instrument can do: identity, candles, quotes, the order book,
orders and positions.

- [`Derivative`](https://pramodathani.github.io/tradeR/reference/Derivative.md)
  : A futures or option contract, which expires on a set day and is
  written on an underlying instrument
- [`Futures`](https://pramodathani.github.io/tradeR/reference/Futures.md)
  : A futures contract, an agreement to buy or sell the underlying at a
  set price on the expiry date
- [`IndexFutures`](https://pramodathani.github.io/tradeR/reference/IndexFutures.md)
  : A futures contract on an index, which settles in cash because an
  index cannot be delivered
- [`IndexOption`](https://pramodathani.github.io/tradeR/reference/IndexOption.md)
  : An option on an index, which settles in cash because an index cannot
  be delivered
- [`Instrument`](https://pramodathani.github.io/tradeR/reference/Instrument.md)
  : One instrument in UBI's unified instrument universe
- [`InstrumentCatalogue`](https://pramodathani.github.io/tradeR/reference/InstrumentCatalogue.md)
  : Discovery of instruments in UBI's catalogue
- [`NonTradeableInstrument`](https://pramodathani.github.io/tradeR/reference/NonTradeableInstrument.md)
  : An instrument that cannot be traded directly, which is an index
- [`Option`](https://pramodathani.github.io/tradeR/reference/Option.md)
  : An option contract, the right but not the obligation to buy the
  underlying at the strike price, for a call, or to sell it, for a put
- [`TradeableInstrument`](https://pramodathani.github.io/tradeR/reference/TradeableInstrument.md)
  : An instrument that can be traded, which is anything except an index

## Equities

Shares, equity indices and their futures and options.

- [`Equity`](https://pramodathani.github.io/tradeR/reference/Equity.md)
  : One listed share, such as RELIANCE on the nse
- [`EquityFutures`](https://pramodathani.github.io/tradeR/reference/EquityFutures.md)
  : One futures contract on a share, such as RELIANCE expiring in
  September
- [`EquityIndex`](https://pramodathani.github.io/tradeR/reference/EquityIndex.md)
  : One equity index, such as NIFTY on the nse, which is followed rather
  than traded
- [`EquityIndexFutures`](https://pramodathani.github.io/tradeR/reference/EquityIndexFutures.md)
  : One futures contract on an equity index, such as NIFTY expiring in
  September
- [`EquityIndexOption`](https://pramodathani.github.io/tradeR/reference/EquityIndexOption.md)
  : One option on an equity index, such as a NIFTY call at a given
  strike and expiry
- [`EquityOption`](https://pramodathani.github.io/tradeR/reference/EquityOption.md)
  : One option on a share, such as a RELIANCE call at a given strike and
  expiry

## Fixed income

Bonds, government securities and their derivatives.

- [`FixedIncome`](https://pramodathani.github.io/tradeR/reference/FixedIncome.md)
  : One listed fixed income security, such as a government bond or a
  treasury bill on the nse
- [`FixedIncomeFutures`](https://pramodathani.github.io/tradeR/reference/FixedIncomeFutures.md)
  : One futures contract on a bond, such as 633GS2035 expiring in
  September
- [`FixedIncomeIndex`](https://pramodathani.github.io/tradeR/reference/FixedIncomeIndex.md)
  : One fixed income index, such as ONMIBOR on the nse, which is
  followed rather than traded
- [`FixedIncomeIndexFutures`](https://pramodathani.github.io/tradeR/reference/FixedIncomeIndexFutures.md)
  : One futures contract on a fixed income index, such as ONMIBOR
  expiring in September
- [`FixedIncomeIndexOption`](https://pramodathani.github.io/tradeR/reference/FixedIncomeIndexOption.md)
  : One option on a fixed income index, which UBI carries none of yet
- [`FixedIncomeOption`](https://pramodathani.github.io/tradeR/reference/FixedIncomeOption.md)
  : One option on a bond, such as a 633GS2035 call at a given strike and
  expiry

## Commodities

Commodities, commodity indices and their derivatives.

- [`Commodity`](https://pramodathani.github.io/tradeR/reference/Commodity.md)
  : One commodity the exchange publishes as an underlying, such as GOLD
  on the mcx
- [`CommodityFutures`](https://pramodathani.github.io/tradeR/reference/CommodityFutures.md)
  : One futures contract on a commodity, such as GOLD expiring in
  October
- [`CommodityIndex`](https://pramodathani.github.io/tradeR/reference/CommodityIndex.md)
  : One commodity index, such as MCXBULLDEX on the mcx, which is
  followed rather than traded
- [`CommodityIndexFutures`](https://pramodathani.github.io/tradeR/reference/CommodityIndexFutures.md)
  : One futures contract on a commodity index, such as MCXBULLDEX
  expiring in October
- [`CommodityIndexOption`](https://pramodathani.github.io/tradeR/reference/CommodityIndexOption.md)
  : One option on a commodity index, such as an MCXBULLDEX call at a
  given strike and expiry
- [`CommodityOption`](https://pramodathani.github.io/tradeR/reference/CommodityOption.md)
  : One option on a commodity, such as a GOLD call at a given strike and
  expiry

## Currencies

Currency pairs, currency indices and their derivatives.

- [`Currency`](https://pramodathani.github.io/tradeR/reference/Currency.md)
  : One currency pair the exchange publishes as an underlying, such as
  USDINR on the nse
- [`CurrencyFutures`](https://pramodathani.github.io/tradeR/reference/CurrencyFutures.md)
  : One futures contract on a currency pair, such as USDINR expiring in
  September
- [`CurrencyIndex`](https://pramodathani.github.io/tradeR/reference/CurrencyIndex.md)
  : One currency index, which UBI carries none of yet
- [`CurrencyIndexFutures`](https://pramodathani.github.io/tradeR/reference/CurrencyIndexFutures.md)
  : One futures contract on a currency index, which UBI carries none of
  yet
- [`CurrencyIndexOption`](https://pramodathani.github.io/tradeR/reference/CurrencyIndexOption.md)
  : One option on a currency index, which UBI carries none of yet
- [`CurrencyOption`](https://pramodathani.github.io/tradeR/reference/CurrencyOption.md)
  : One option on a currency pair, such as a USDINR call at a given
  strike and expiry

## Funds and mutual funds

Exchange traded funds, investment trusts and mutual funds.

- [`ExchangeTradedFund`](https://pramodathani.github.io/tradeR/reference/ExchangeTradedFund.md)
  : One exchange-traded fund, such as NIFTYBEES on the nse
- [`InvestmentTrust`](https://pramodathani.github.io/tradeR/reference/InvestmentTrust.md)
  : One listed investment trust, such as the real estate trust EMBASSY
  on the nse
- [`MutualFund`](https://pramodathani.github.io/tradeR/reference/MutualFund.md)
  : One mutual fund scheme, such as ABSLFTTIDG on the nse

## Option pricing

Black-Scholes and Black-76 prices, greeks and implied volatility.

- [`Black76`](https://pramodathani.github.io/tradeR/reference/Black76.md)
  : One European option on a forward price, such as an option priced off
  a future, priced by the Black-76 model
- [`BlackScholes`](https://pramodathani.github.io/tradeR/reference/BlackScholes.md)
  : One European option priced by the Black-Scholes model without
  dividends
- [`OptionPricingModel`](https://pramodathani.github.io/tradeR/reference/OptionPricingModel.md)
  : The mechanism every pricing model here shares: the normal
  distribution and the search for an implied volatility

## Analysis

The analysis classes every instrument and basket inherits, in
inheritance order.

- [`CandlestickPatterns`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.md)
  : Candlestick pattern recognisers an instrument runs over its candles

- [`CycleIndicators`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.md)
  : Hilbert transform cycle indicators an instrument calculates from its
  candles

- [`MathOperators`](https://pramodathani.github.io/tradeR/reference/MathOperators.md)
  : Arithmetic and rolling extremes an instrument calculates from its
  candle columns

- [`MathTransforms`](https://pramodathani.github.io/tradeR/reference/MathTransforms.md)
  : Element-by-element mathematical functions an instrument applies to
  one candle column

- [`MomentumIndicators`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.md)
  : Oscillators and directional indicators an instrument calculates from
  its candles

- [`OverlapStudies`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.md)
  : Moving averages, Bollinger bands and other indicators an instrument
  draws over its candles

- [`PerformanceMeasures`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.md)
  : Return, risk and benchmark-relative measures calculated from closing
  prices

- [`PERFORMANCE_MEASURES_DAY_INTERVAL`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_DAY_INTERVAL.md)
  : The interval name of daily candles

- [`PERFORMANCE_MEASURES_HISTORICAL_METHOD`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_HISTORICAL_METHOD.md)
  : The value at risk method that reads the loss from past returns

- [`PERFORMANCE_MEASURES_MINUTE_INTERVAL_PATTERN`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_MINUTE_INTERVAL_PATTERN.md)
  :

  The pattern a minute interval such as `5minute` matches

- [`PERFORMANCE_MEASURES_PARAMETRIC_METHOD`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_PARAMETRIC_METHOD.md)
  : The value at risk method that assumes normally distributed returns

- [`PERFORMANCE_MEASURES_TRADING_DAYS_PER_YEAR`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_TRADING_DAYS_PER_YEAR.md)
  :

  The number of trading days in a year, used to annualise `day` candles

- [`PERFORMANCE_MEASURES_TRADING_MINUTES_PER_DAY`](https://pramodathani.github.io/tradeR/reference/PERFORMANCE_MEASURES_TRADING_MINUTES_PER_DAY.md)
  : The number of minutes in one NSE session, from 09:15 to 15:30

- [`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
  : A source of candles that analysis methods can be written against

- [`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
  : Summary statistics of the prices, volumes and returns in an
  instrument's candles

- [`PriceTransforms`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.md)
  : Per-candle price summaries an instrument calculates from its candles

- [`Signals`](https://pramodathani.github.io/tradeR/reference/Signals.md)
  : Crossover and crossunder detection between two columns of a frame

- [`StatisticFunctions`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.md)
  : Rolling statistics an instrument calculates from its candles with
  TA-Lib

- [`StrategyBacktests`](https://pramodathani.github.io/tradeR/reference/StrategyBacktests.md)
  : Backtests of trading strategies over an instrument's candles

- [`VolatilityIndicators`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.md)
  : Range-based volatility indicators an instrument calculates from its
  candles

- [`VolumeIndicators`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.md)
  : Indicators an instrument calculates from its candles' prices and
  volumes

## Backtesting engine

The R counterpart of the Python backtesting package that
StrategyBacktests runs on.

- [`Backtest`](https://pramodathani.github.io/tradeR/reference/Backtest.md)
  : One backtest of a strategy over a table of candles
- [`BacktestBroker`](https://pramodathani.github.io/tradeR/reference/BacktestBroker.md)
  : The simulated broker of a backtest
- [`BacktestOrder`](https://pramodathani.github.io/tradeR/reference/BacktestOrder.md)
  : One order waiting in a backtest's order queue
- [`BacktestPlot`](https://pramodathani.github.io/tradeR/reference/BacktestPlot.md)
  : A standalone HTML page showing one backtest
- [`BacktestPosition`](https://pramodathani.github.io/tradeR/reference/BacktestPosition.md)
  : The sum of a backtest's open trades
- [`BacktestStatistics`](https://pramodathani.github.io/tradeR/reference/BacktestStatistics.md)
  : The statistics table of a finished backtest
- [`BACKTESTING_FULL_EQUITY`](https://pramodathani.github.io/tradeR/reference/BACKTESTING_FULL_EQUITY.md)
  : The default order size, all of the available margin, which is the
  largest fraction below 1
- [`BacktestStrategy`](https://pramodathani.github.io/tradeR/reference/BacktestStrategy.md)
  : A trading strategy to run through a backtest
- [`BacktestTrade`](https://pramodathani.github.io/tradeR/reference/BacktestTrade.md)
  : One trade opened by a filled order in a backtest

## Synthetic orders

Order types that UBI’s order engine works on your behalf.

- [`AccountConditionalOrder`](https://pramodathani.github.io/tradeR/reference/AccountConditionalOrder.md)
  : An order sent, or cancelled, when the account's free margin, day's
  profit or open position count reaches a level
- [`AccumulationOrder`](https://pramodathani.github.io/tradeR/reference/AccumulationOrder.md)
  : A fixed quantity bought at a fixed interval, each purchase resting
  on its own side of the book
- [`AttachedHedgeOrder`](https://pramodathani.github.io/tradeR/reference/AttachedHedgeOrder.md)
  : An entry whose fills are hedged in another instrument as they
  happen, by a ratio or by an option's delta
- [`AverageTrueRangeTrailOrder`](https://pramodathani.github.io/tradeR/reference/AverageTrueRangeTrailOrder.md)
  : A trailing stop whose distance is a multiple of the recent average
  true range
- [`BasketOrder`](https://pramodathani.github.io/tradeR/reference/BasketOrder.md)
  : Orders on several instruments placed in one request, each reported
  on its own
- [`BracketOrder`](https://pramodathani.github.io/tradeR/reference/BracketOrder.md)
  : An entry that arms a stop and a target behind itself on its first
  fill, even a partial one
- [`CandleCloseStopOrder`](https://pramodathani.github.io/tradeR/reference/CandleCloseStopOrder.md)
  : A hidden stop that fires only when a whole bar closes past the level
- [`ChaserOrder`](https://pramodathani.github.io/tradeR/reference/ChaserOrder.md)
  : A limit order that starts on its own side of the book and steps
  towards the other until it fills
- [`CloseOnTriggerOrder`](https://pramodathani.github.io/tradeR/reference/CloseOnTriggerOrder.md)
  : A level that, when reached, cancels every order on the instrument to
  free margin and then closes the whole position
- [`ClosingPriceOrder`](https://pramodathani.github.io/tradeR/reference/ClosingPriceOrder.md)
  : An order sliced by volume through the half hour the day's closing
  price is computed from
- [`CoverOrder`](https://pramodathani.github.io/tradeR/reference/CoverOrder.md)
  : An entry with a compulsory stop and no target
- [`CrossInstrumentOrder`](https://pramodathani.github.io/tradeR/reference/CrossInstrumentOrder.md)
  : A limit-if-touched order whose trigger watches the last traded price
  of a different instrument
- [`DailyStopOrder`](https://pramodathani.github.io/tradeR/reference/DailyStopOrder.md)
  : A native stop placed afresh every morning for a position held
  overnight
- [`DiscretionaryOrder`](https://pramodathani.github.io/tradeR/reference/DiscretionaryOrder.md)
  : A limit order that shows one price and quietly takes a slightly
  worse one when it comes within reach
- [`ExposureHedgeOrder`](https://pramodathani.github.io/tradeR/reference/ExposureHedgeOrder.md)
  : A standing instruction to trade one hedge instrument whenever the
  watched instruments' net exposure leaves a band
- [`ExposureWatch`](https://pramodathani.github.io/tradeR/reference/ExposureWatch.md)
  : One watched instrument and how much exposure each unit of its
  position carries
- [`FreezeSlicerOrder`](https://pramodathani.github.io/tradeR/reference/FreezeSlicerOrder.md)
  : An order above the exchange's freeze quantity, split into even
  orders that each fit
- [`GoodTillTimeOrder`](https://pramodathani.github.io/tradeR/reference/GoodTillTimeOrder.md)
  : An order placed now whose unfilled part is cancelled at a time of
  day
- [`GoodTillTriggeredOrder`](https://pramodathani.github.io/tradeR/reference/GoodTillTriggeredOrder.md)
  : A limit-if-touched order that keeps waiting across days until it
  fires or expires
- [`GridOrder`](https://pramodathani.github.io/tradeR/reference/GridOrder.md)
  : Resting buys below the market and sells above it, where each fill
  places its opposite one step away
- [`HiddenStopOrder`](https://pramodathani.github.io/tradeR/reference/HiddenStopOrder.md)
  : A stop kept inside UBI that watches the bid or the offer, with an
  optional real stop behind it
- [`IcebergOrder`](https://pramodathani.github.io/tradeR/reference/IcebergOrder.md)
  : An order that rests one slice at a time and places the next when
  that slice fills
- [`ImplementationShortfallOrder`](https://pramodathani.github.io/tradeR/reference/ImplementationShortfallOrder.md)
  : A time-sliced order whose slices shrink, so most of it trades early
- [`IndicatorTriggeredOrder`](https://pramodathani.github.io/tradeR/reference/IndicatorTriggeredOrder.md)
  : An order sent as a limit when one field of the live quote crosses a
  level
- [`LadderOrder`](https://pramodathani.github.io/tradeR/reference/LadderOrder.md)
  : Several limit orders spaced evenly between two prices, sharing the
  quantity between them
- [`LeggedSpreadOrder`](https://pramodathani.github.io/tradeR/reference/LeggedSpreadOrder.md)
  : A two-legged spread worked passively on the first leg and completed
  on the second at the price that makes the net
- [`LimitIfTouchedOrder`](https://pramodathani.github.io/tradeR/reference/LimitIfTouchedOrder.md)
  : An order that waits for the price to touch a level and then rests a
  limit at another price
- [`LiquiditySeekingOrder`](https://pramodathani.github.io/tradeR/reference/LiquiditySeekingOrder.md)
  : An order that shows nothing and strikes only when enough size
  appears at an acceptable price
- [`MarketableLimitOrder`](https://pramodathani.github.io/tradeR/reference/MarketableLimitOrder.md)
  : A market order sent as a limit that follows the other side of the
  book until it fills
- [`MarketIfTouchedOrder`](https://pramodathani.github.io/tradeR/reference/MarketIfTouchedOrder.md)
  : An order that waits unseen for the price to touch a level and then
  takes what is there
- [`OneCancelsAllOrder`](https://pramodathani.github.io/tradeR/reference/OneCancelsAllOrder.md)
  : Several candidate entries, each on its own instrument, where the
  first fill cancels all the rest
- [`OneCancelsOtherOrder`](https://pramodathani.github.io/tradeR/reference/OneCancelsOtherOrder.md)
  : A stop and a target resting together on a position already held,
  each shrinking as the other fills
- [`OneTriggersOtherOrder`](https://pramodathani.github.io/tradeR/reference/OneTriggersOtherOrder.md)
  : An order that places a second, described in advance, once the first
  one fills
- [`OpeningAuctionOrder`](https://pramodathani.github.io/tradeR/reference/OpeningAuctionOrder.md)
  : An order placed during the pre-open session, so it fills at the
  price the opening call auction discovers
- [`OrderCandidate`](https://pramodathani.github.io/tradeR/reference/OrderCandidate.md)
  : One instrument's order inside a multi-instrument synthetic order,
  with the template fields it overrides
- [`ParticipationOrder`](https://pramodathani.github.io/tradeR/reference/ParticipationOrder.md)
  : An order that trades a fixed share of the volume the market itself
  trades
- [`PegOrder`](https://pramodathani.github.io/tradeR/reference/PegOrder.md)
  : A limit order kept re-priced to the bid, the offer or the midpoint
  as the book moves
- [`PostOnlyOrder`](https://pramodathani.github.io/tradeR/reference/PostOnlyOrder.md)
  : A limit order checked to rest rather than trade before it is sent
- [`ScaleOutOrder`](https://pramodathani.github.io/tradeR/reference/ScaleOutOrder.md)
  : A bracket with several targets that take the position off in
  tranches, and a stop that moves to breakeven
- [`ScaleWithProfitTakerOrder`](https://pramodathani.github.io/tradeR/reference/ScaleWithProfitTakerOrder.md)
  : A ladder whose every filled rung gets its own profit-taker, and is
  placed again once that profit is taken
- [`ScheduledOrder`](https://pramodathani.github.io/tradeR/reference/ScheduledOrder.md)
  : An order held until a time of day and then placed
- [`SimpleOrder`](https://pramodathani.github.io/tradeR/reference/SimpleOrder.md)
  : One plain order sent to one broker, with nothing watching it
  afterwards
- [`SquareOffOrder`](https://pramodathani.github.io/tradeR/reference/SquareOffOrder.md)
  : The day's positions on one product, closed with limit orders at a
  time of day after their resting orders are cancelled
- [`SteppedStopOrder`](https://pramodathani.github.io/tradeR/reference/SteppedStopOrder.md)
  : A native stop moved to set levels at set profits, and switched to
  trailing at the last
- [`StopAndReverseOrder`](https://pramodathani.github.io/tradeR/reference/StopAndReverseOrder.md)
  : A level that, when reached, closes the position and opens the same
  size the other way
- [`StrategyStopOrder`](https://pramodathani.github.io/tradeR/reference/StrategyStopOrder.md)
  : A basket whose every leg is closed when the whole strategy's profit
  or loss crosses a line
- [`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
  : One order for UBI's order engine: an order template and the
  synthetic type that works it
- [`TimeStopOrder`](https://pramodathani.github.io/tradeR/reference/TimeStopOrder.md)
  : An entry placed now whose filled part is closed at a time of day, or
  after some minutes
- [`TimeWeightedAveragePriceOrder`](https://pramodathani.github.io/tradeR/reference/TimeWeightedAveragePriceOrder.md)
  : A large order sent as equal slices at even intervals over a period
- [`TrailingEntryOrder`](https://pramodathani.github.io/tradeR/reference/TrailingEntryOrder.md)
  : A stop entry that follows a falling market down, so the first bounce
  of the trailing distance fills it
- [`TrailingStopOrder`](https://pramodathani.github.io/tradeR/reference/TrailingStopOrder.md)
  : A real stop at the broker whose trigger follows the market up, never
  down
- [`TwoSidedBreakoutOrder`](https://pramodathani.github.io/tradeR/reference/TwoSidedBreakoutOrder.md)
  : A buy stop above a range and a sell stop below it, where the first
  to fire cancels the other
- [`TwoSidedQuoteOrder`](https://pramodathani.github.io/tradeR/reference/TwoSidedQuoteOrder.md)
  : A bid and an offer kept around the fair price, leaning away from the
  inventory they build
- [`UnderlyingPegOrder`](https://pramodathani.github.io/tradeR/reference/UnderlyingPegOrder.md)
  : A resting limit whose price moves by delta times another
  instrument's move, such as an option bid following the index
- [`VirtualLimitOrder`](https://pramodathani.github.io/tradeR/reference/VirtualLimitOrder.md)
  : A limit order held inside UBI and sent only when the other side of
  the book reaches its price
- [`VolatilityOrder`](https://pramodathani.github.io/tradeR/reference/VolatilityOrder.md)
  : An option order stated as an implied volatility, priced with the
  Black-76 model and re-priced as the underlying and time move
- [`VolumeWeightedAveragePriceOrder`](https://pramodathani.github.io/tradeR/reference/VolumeWeightedAveragePriceOrder.md)
  : A time-sliced order whose slice sizes follow the shape of the day's
  volume

## Plan orders

An order described as a plan of parts.

- [`PlanOrder`](https://pramodathani.github.io/tradeR/reference/PlanOrder.md)
  : An order described as a tree of parts, which can combine the other
  synthetic order types

## Plan parts

The parts a plan is built from: structure, pricing, quantity, execution,
triggers, guards and lifetimes.

- [`AccountCondition`](https://pramodathani.github.io/tradeR/reference/AccountCondition.md)
  : A condition that holds when a figure from the account is at or past
  a level

- [`AllAtOnceExecution`](https://pramodathani.github.io/tradeR/reference/AllAtOnceExecution.md)
  : An execution that sends the order's whole quantity as one broker
  order, which is UBI's default

- [`AllConditions`](https://pramodathani.github.io/tradeR/reference/AllConditions.md)
  : A group of trigger conditions that must all hold

- [`AnyCondition`](https://pramodathani.github.io/tradeR/reference/AnyCondition.md)
  : A group of trigger conditions of which any one is enough

- [`BookDepthExecution`](https://pramodathani.github.io/tradeR/reference/BookDepthExecution.md)
  : An execution that waits for enough displayed size at or inside a
  price and then strikes

- [`CandleCloses`](https://pramodathani.github.io/tradeR/reference/CandleCloses.md)
  : A condition that holds when a bar UBI builds from its own ticks
  closes past a level

- [`CapModifier`](https://pramodathani.github.io/tradeR/reference/CapModifier.md)
  : A bound on the price a pricing rule may set

- [`ChasePricing`](https://pramodathani.github.io/tradeR/reference/ChasePricing.md)
  : A pricing rule that steps a limit from its own side of the book
  towards the other side

- [`DailyExecution`](https://pramodathani.github.io/tradeR/reference/DailyExecution.md)
  : An execution that sends the order again at a set time each trading
  day until anything trades

- [`DiscretionModifier`](https://pramodathani.github.io/tradeR/reference/DiscretionModifier.md)
  :

  A modifier that lets a resting limit take a price up to `points` worse
  than the one it shows

- [`EitherPart`](https://pramodathani.github.io/tradeR/reference/EitherPart.md)
  : Several plans run at once, joined by what a fill on one does to the
  others

- [`FixedPricing`](https://pramodathani.github.io/tradeR/reference/FixedPricing.md)
  : A pricing rule that sends the order at a set price, or at market

- [`FollowInstrumentPricing`](https://pramodathani.github.io/tradeR/reference/FollowInstrumentPricing.md)
  : A pricing rule that moves a resting limit after another instrument

- [`FreezeLimitExecution`](https://pramodathani.github.io/tradeR/reference/FreezeLimitExecution.md)
  : An execution that splits an order larger than the chosen broker's
  freeze quantity into equal orders sent together

- [`FromFillPricing`](https://pramodathani.github.io/tradeR/reference/FromFillPricing.md)
  : A pricing rule for an exit set a distance from the fill that opened
  its position

- [`FromParentFillPricing`](https://pramodathani.github.io/tradeR/reference/FromParentFillPricing.md)
  : A pricing rule for a spread's second leg, priced from the first
  leg's fill to reach a net price

- [`FrontLoadedExecution`](https://pramodathani.github.io/tradeR/reference/FrontLoadedExecution.md)
  : An execution that sends slices on a clock, each a fixed share
  smaller than the one before

- [`IcebergExecution`](https://pramodathani.github.io/tradeR/reference/IcebergExecution.md)
  : An execution that shows a small piece of the order at a time and
  sends the next once it has filled

- [`LadderExecution`](https://pramodathani.github.io/tradeR/reference/LadderExecution.md)
  : An execution that sends the order as several limit orders at evenly
  spaced prices, all at once

- [`Lifetime`](https://pramodathani.github.io/tradeR/reference/Lifetime.md)
  : When an order of a plan stops working, and what is done with it then

- [`LimitMarketable`](https://pramodathani.github.io/tradeR/reference/LimitMarketable.md)
  : A condition that holds once the order's own limit price would fill
  at once

- [`MarketablePricing`](https://pramodathani.github.io/tradeR/reference/MarketablePricing.md)
  : A pricing rule that sends a limit a few ticks past the opposite
  touch

- [`NativeStopPricing`](https://pramodathani.github.io/tradeR/reference/NativeStopPricing.md)
  : A pricing rule that sends a stop-limit order to rest at the broker

- [`OptionModelPricing`](https://pramodathani.github.io/tradeR/reference/OptionModelPricing.md)
  : A pricing rule that prices an option from an implied volatility and
  its underlying

- [`OrderPart`](https://pramodathani.github.io/tradeR/reference/OrderPart.md)
  : One order of a plan, with the presets and slot values that shape it

- [`PaperVenue`](https://pramodathani.github.io/tradeR/reference/PaperVenue.md)
  : Paper trading, where an order is filled from the queue estimate and
  nothing reaches a broker

- [`ParentFillDeltaQuantity`](https://pramodathani.github.io/tradeR/reference/ParentFillDeltaQuantity.md)
  : A quantity that is what an option entry filled times that option's
  delta

- [`ParentFillQuantity`](https://pramodathani.github.io/tradeR/reference/ParentFillQuantity.md)
  :

  A quantity that is a ratio of what the first plan of a `then` join has
  filled

- [`ParticipationExecution`](https://pramodathani.github.io/tradeR/reference/ParticipationExecution.md)
  : An execution that sends a share of the market's traded volume on
  each tick

- [`PegPricing`](https://pramodathani.github.io/tradeR/reference/PegPricing.md)
  : A pricing rule that keeps a limit at its reference in the book

- [`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
  : One piece of a plan order, which can describe itself as the object
  UBI's order engine reads

- [`PositionQuantity`](https://pramodathani.github.io/tradeR/reference/PositionQuantity.md)
  : A quantity that is the position held when the order fires, on one
  product and one or more instruments

- [`PostOnlyGuard`](https://pramodathani.github.io/tradeR/reference/PostOnlyGuard.md)
  : A guard that keeps an order's limit from crossing the book

- [`PreOpenVenue`](https://pramodathani.github.io/tradeR/reference/PreOpenVenue.md)
  : The pre-open session, with the time the order is sent into it

- [`Preset`](https://pramodathani.github.io/tradeR/reference/Preset.md)
  : One named preset and its settings

- [`PriceCrosses`](https://pramodathani.github.io/tradeR/reference/PriceCrosses.md)
  : A condition that holds once a price reaches a level from the side
  that fires

- [`RepeatPart`](https://pramodathani.github.io/tradeR/reference/RepeatPart.md)
  : One order sent a number of times, spaced by minutes or by trading
  days

- [`SequencePart`](https://pramodathani.github.io/tradeR/reference/SequencePart.md)
  : Several plans run one after another, each starting once the one
  before is done

- [`StageRule`](https://pramodathani.github.io/tradeR/reference/StageRule.md)
  :

  One milestone of a stepped stop, an entry of the `rules` list of
  `StagesPricing`

- [`StagesPricing`](https://pramodathani.github.io/tradeR/reference/StagesPricing.md)
  : A pricing rule that rests a stop-limit at the broker and steps it
  through profit milestones

- [`ThenPart`](https://pramodathani.github.io/tradeR/reference/ThenPart.md)
  : A first plan and the child plan it starts when it fills

- [`TimeAfter`](https://pramodathani.github.io/tradeR/reference/TimeAfter.md)
  : A condition that holds from a time of day onwards

- [`TimeAt`](https://pramodathani.github.io/tradeR/reference/TimeAt.md)
  : A condition that holds from a time of day onwards

- [`TimeBefore`](https://pramodathani.github.io/tradeR/reference/TimeBefore.md)
  : A condition that holds until a time of day

- [`TimeFrom`](https://pramodathani.github.io/tradeR/reference/TimeFrom.md)
  : A condition that holds from a time of day onwards, and at once when
  that time has already passed today

- [`TogetherPart`](https://pramodathani.github.io/tradeR/reference/TogetherPart.md)
  : Several plans started at once, each trading its own quantity

- [`TopUpExecution`](https://pramodathani.github.io/tradeR/reference/TopUpExecution.md)
  : An execution that sends one new broker order each time a join raises
  the order's target

- [`TrailPricing`](https://pramodathani.github.io/tradeR/reference/TrailPricing.md)
  : A pricing rule that rests a stop-limit at the broker and trails it
  behind the market

- [`Trails`](https://pramodathani.github.io/tradeR/reference/Trails.md)
  : A condition that holds once the last price has pulled back from its
  best by a distance

- [`TwapExecution`](https://pramodathani.github.io/tradeR/reference/TwapExecution.md)
  : An execution that sends equal slices at even intervals

- [`UsingPart`](https://pramodathani.github.io/tradeR/reference/UsingPart.md)
  : An order whose execution's pieces each become a whole plan with the
  same extra presets and slot values

- [`VwapExecution`](https://pramodathani.github.io/tradeR/reference/VwapExecution.md)
  : An execution that sends slices on a clock, each sized by the volume
  profile of the half hour it falls in

## Asset baskets

Portfolios, watchlists, indices and fund constituents, stored in
MongoDB.

- [`AssetBasket`](https://pramodathani.github.io/tradeR/reference/AssetBasket.md)
  : A named group of instruments that is priced, analysed and stored as
  one
- [`BasketCsvImporter`](https://pramodathani.github.io/tradeR/reference/BasketCsvImporter.md)
  : A reader of CSV files into stored baskets
- [`BasketMember`](https://pramodathani.github.io/tradeR/reference/BasketMember.md)
  : One instrument held in a basket
- [`BasketStore`](https://pramodathani.github.io/tradeR/reference/BasketStore.md)
  : The collection of baskets kept in the project's MongoDB
- [`ExchangeTradedFundConstituents`](https://pramodathani.github.io/tradeR/reference/ExchangeTradedFundConstituents.md)
  : The instruments an exchange traded fund holds, with their weights
- [`Index`](https://pramodathani.github.io/tradeR/reference/Index.md) :
  A weighted basket of instruments that is followed as one level
- [`MemberResolver`](https://pramodathani.github.io/tradeR/reference/MemberResolver.md)
  : A builder of basket members from rows that name their instruments
- [`MutualFundConstituents`](https://pramodathani.github.io/tradeR/reference/MutualFundConstituents.md)
  : The instruments a mutual fund holds, with their weights
- [`Portfolio`](https://pramodathani.github.io/tradeR/reference/Portfolio.md)
  : A basket of instruments held in known quantities
- [`Watchlist`](https://pramodathani.github.io/tradeR/reference/Watchlist.md)
  : A group of instruments followed together, each counting equally

## The account

Account-wide reads and the flatten operation.

- [`Account`](https://pramodathani.github.io/tradeR/reference/Account.md)
  : The trading account UBI trades for, across every broker it is
  connected to

## Errors

The condition classes, which keep the Python exception names and
hierarchy.

- [`ASSET_BASKETS_ERROR_PARENTS`](https://pramodathani.github.io/tradeR/reference/ASSET_BASKETS_ERROR_PARENTS.md)
  : The errors the asset basket classes signal
- [`ASSETS_ERROR_PARENTS`](https://pramodathani.github.io/tradeR/reference/ASSETS_ERROR_PARENTS.md)
  : The errors the instrument classes signal
- [`UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE`](https://pramodathani.github.io/tradeR/reference/UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE.md)
  : The error class UBI's client signals for each failing HTTP status
  code
- [`UNIFIED_BROKER_INTERFACE_ERROR_PARENTS`](https://pramodathani.github.io/tradeR/reference/UNIFIED_BROKER_INTERFACE_ERROR_PARENTS.md)
  : The errors the Unified Broker Interface client signals
- [`ErrorCatalogue`](https://pramodathani.github.io/tradeR/reference/ErrorCatalogue.md)
  : The catalogue of every error class the package signals
- [`UTILITIES_LANGUAGE_ERROR_PARENTS`](https://pramodathani.github.io/tradeR/reference/UTILITIES_LANGUAGE_ERROR_PARENTS.md)
  : The errors that stand in for Python's built-in exceptions

## Utilities

Turning UBI’s answers into data frames and dates.

- [`FrameBuilder`](https://pramodathani.github.io/tradeR/reference/FrameBuilder.md)
  : A converter between UBI's rows and R data frames
- [`TimeConverter`](https://pramodathani.github.io/tradeR/reference/TimeConverter.md)
  : A converter between UBI's date and time text and R's date and time
  types
