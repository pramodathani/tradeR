# An instrument that can be traded, which is anything except an index

Adds the order book, orders, positions and the price wrappers to
`Instrument`. Every order goes through UBI's order engine, and the
values are sent exactly as given, without rounding the price to the tick
size or checking the quantity against the lot size, because UBI and the
broker behind it hold those rules.

The members that read orders, trades and positions read the whole
account's document from UBI and keep this instrument's own rows, because
UBI has no route for one instrument.

The examples below start with a short tour of the class, then show its
properties, in this order:

- For `bids`, print every level on the buy side of the Infosys order
  book, best first.

- For `bids`, add up how many shares are bid for across the visible
  levels of the Reliance book.

- For `offers`, print every level on the sell side of the Infosys order
  book, best first.

- For `offers`, compare the quantity offered with the quantity bid in
  the visible book, a rough measure of selling pressure.

- For `best_bid`, print the highest bid for Infosys, or say that nobody
  is bidding.

- For `best_bid`, measure how far the best bid is below the last traded
  price.

- For `best_offer`, print the lowest offer for Infosys, or say that
  nobody is offering.

- For `best_offer`, work out what buying 10 shares at the best offer
  would cost, when that level holds enough.

- For `bid_offer_spread`, print the spread of Infosys in rupees.

- For `bid_offer_spread`, express the spread in ticks, which says how
  liquid the book is.

- For `bid_offer_spread`, rank three shares by their spread as a
  percentage of the last price.

- For `mid_price`, print the mid price of Infosys.

- For `mid_price`, compare the mid price with the last traded price to
  see which side traded last.

- For `volume_weighted_average_price`, print today's volume weighted
  average price of Infosys.

- For `volume_weighted_average_price`, say whether Reliance is trading
  above or below its average price for the day, a common intraday bias
  check.

- For `last_quantity`, print the size of the last Infosys trade.

- For `last_quantity`, show the value of the last Reliance trade in
  rupees.

- For `total_traded_volume`, print how many Infosys shares have traded
  today.

- For `total_traded_volume`, compare today's volume with the average
  daily volume of the last month.

- For `open_interest`, print the open interest of the nearest Nifty
  future.

- For `open_interest`, express the open interest of the nearest Nifty
  future in lots rather than units.

- For `open_interest`, show that a share has no open interest, so the
  property is `NULL`.

- For `last_trade_time`, print when Infosys last traded, in India time.

- For `last_trade_time`, work out how many seconds ago Reliance last
  traded, a quick check that the feed is alive.

- For `parents`, print the parents UBI's order engine is still working
  in Vodafone Idea.

- For `parents`, hold a buy limit order 3 per cent below the market,
  find it among the parents, and cancel it.

- For `orders`, print today's Vodafone Idea orders with their status, or
  `NULL` when there are none.

- For `orders`, count today's orders in Vodafone Idea by status, which
  is how an order whose status has no property of its own, such as
  `EXPIRED`, is found.

- For `orders`, split today's Vodafone Idea orders by whether UBI's
  order engine placed them for a parent.

- For `open_orders`, print the Vodafone Idea orders still waiting in the
  market.

- For `open_orders`, add up the quantity still waiting to fill on each
  side of the Infosys book from this account's open orders.

- For `completed_orders`, print the Vodafone Idea orders that filled in
  full today.

- For `completed_orders`, work out the average buying and selling prices
  of today's filled Vodafone Idea orders.

- For `rejected_orders`, print why each of today's refused Vodafone Idea
  orders was refused.

- For `rejected_orders`, count today's refusals in Vodafone Idea by
  broker.

- For `cancelled_orders`, print today's cancelled Vodafone Idea orders.

- For `cancelled_orders`, count how many of today's cancelled Vodafone
  Idea orders had partly filled first.

- For `trades`, print today's Vodafone Idea trades.

- For `trades`, add up the value bought and sold in Vodafone Idea today
  from its trades.

- For `net_positions`, print the positions open in Vodafone Idea, or
  `NULL` when nothing is held.

- For `net_positions`, say whether each Reliance position is long or
  short, and under which product.

- For `day_positions`, print today's own positions in Vodafone Idea.

- For `day_positions`, compare how many rows the day bucket and the net
  bucket report for Vodafone Idea.

- For `positions_value`, print what the Vodafone Idea positions are
  worth now, or `NULL` when nothing is held.

- For `positions_value`, add up the value of the positions in three
  shares, counting a short as negative.

- For `positions_pnl`, print the profit or loss on the Vodafone Idea
  positions, or `NULL` when nothing is held.

- For `positions_pnl`, say whether the Reliance positions are making or
  losing money overall.

## Super classes

[`PriceAnalysis`](https://pramodathani.github.io/tradeR/reference/PriceAnalysis.md)
-\>
[`PriceStatistics`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.md)
-\>
[`OverlapStudies`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.md)
-\>
[`MomentumIndicators`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.md)
-\>
[`VolumeIndicators`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.md)
-\>
[`CycleIndicators`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.md)
-\>
[`PriceTransforms`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.md)
-\>
[`VolatilityIndicators`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.md)
-\>
[`StatisticFunctions`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.md)
-\>
[`MathTransforms`](https://pramodathani.github.io/tradeR/reference/MathTransforms.md)
-\>
[`MathOperators`](https://pramodathani.github.io/tradeR/reference/MathOperators.md)
-\>
[`CandlestickPatterns`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.md)
-\>
[`Signals`](https://pramodathani.github.io/tradeR/reference/Signals.md)
-\>
[`StrategyBacktests`](https://pramodathani.github.io/tradeR/reference/StrategyBacktests.md)
-\>
[`PerformanceMeasures`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.md)
-\>
[`Instrument`](https://pramodathani.github.io/tradeR/reference/Instrument.md)
-\> `TradeableInstrument`

## Active bindings

- `bids`:

  The buy side of the order book as a list of named lists with `price`,
  `quantity` and `orders`, best first, read from UBI on every access.

- `offers`:

  The sell side of the order book as a list of named lists with `price`,
  `quantity` and `orders`, best first, read from UBI on every access.

- `best_bid`:

  The highest bid in the order book as a named list with `price`,
  `quantity` and `orders`, or `NULL` when nobody is bidding.

- `best_offer`:

  The lowest offer in the order book as a named list with `price`,
  `quantity` and `orders`, or `NULL` when nobody is offering.

- `bid_offer_spread`:

  The numeric gap between the best offer and the best bid, measured from
  one quote, or `NULL` when either side is empty.

- `mid_price`:

  The numeric price halfway between the best bid and the best offer,
  from one quote, or `NULL` when either side is empty.

- `volume_weighted_average_price`:

  Today's numeric volume weighted average price, or `NULL` when UBI has
  none.

- `last_quantity`:

  The integer quantity of the last trade, or `NULL` when UBI has none.

- `total_traded_volume`:

  The integer quantity traded so far today, or `NULL` when UBI has none.

- `open_interest`:

  The integer open interest of a future or an option, or `NULL` when UBI
  has none.

- `last_trade_time`:

  When the last trade happened, as a `POSIXct` in India time, or `NULL`
  when UBI has none.

- `parents`:

  The synthetic orders and held orders in this instrument that UBI's
  order engine has not finished, as a `data.frame`, or `NULL` when there
  are none. A parent is one order the engine was asked for, such as a
  bracket, a trailing stop or a held limit order, and its legs are the
  broker orders it placed. This is the only way to see a parent that has
  placed nothing yet, such as an armed trigger. UBI lists every open
  parent in the account, so this reads them all and keeps this
  instrument's own.

- `orders`:

  Every one of today's orders in this instrument, whatever its status,
  as a `data.frame`, or `NULL` when there are none. UBI serves the whole
  account's order book and has no route for one instrument, so reading
  this reads the whole book and keeps this instrument's own rows. The
  book is not merged across brokers, so one order placed at one broker
  appears once, and the same instrument traded at two brokers gives a
  row from each. The `status` column holds UBI's own upper-case status,
  one of `PENDING`, `OPEN`, `COMPLETE`, `CANCELLED`, `REJECTED` or
  `EXPIRED`. An order still waiting in the market is `PENDING` at some
  brokers and `OPEN` at others, so `open_orders` is the way to ask for
  those. An order UBI's order engine is still holding has not reached a
  broker and is not here; it is in `parents`.

- `open_orders`:

  Today's orders in this instrument that can still be changed, as a
  `data.frame`, or `NULL` when there are none. An order counts as open
  while it is waiting in the market, which UBI reports as `PENDING` at
  some brokers and `OPEN` at others. Those are the orders
  `modify_order()` and `cancel_order()` will accept; every other status
  is final. An order UBI's order engine is still holding has not reached
  the market, so it is not here; `parents` lists it.

- `completed_orders`:

  Today's orders in this instrument that filled in full, as a
  `data.frame`, or `NULL` when there are none.

- `rejected_orders`:

  Today's orders in this instrument that a broker or the exchange
  refused, as a `data.frame`, or `NULL` when there are none. The
  `status_message` column holds the reason each one was refused, in the
  words of whoever refused it.

- `cancelled_orders`:

  Today's orders in this instrument that were cancelled, as a
  `data.frame`, or `NULL` when there are none.

- `trades`:

  Today's trades in this instrument as a `data.frame`, or `NULL` when
  there are none. UBI serves the whole account's trade book and has no
  route for one instrument, so this reads the book and keeps its own
  rows. One order can produce several trades, and each trade names the
  order it came from.

- `net_positions`:

  The positions held in this instrument now, merged across every broker,
  as a `data.frame` whose `pnl` column is a list column, or `NULL` when
  none is held. This is UBI's `net` bucket, which counts everything open
  in this instrument whenever it was opened, as against `day_positions`,
  which counts only today. A position is what a derivative or an
  intraday trade leaves open, as against a holding, which is a share
  kept in the demat account and belongs to `Equity` instead. UBI merges
  the brokers' positions by instrument and product, so one instrument
  gives one row per product it is held under, and no row names a broker.

- `day_positions`:

  Today's own positions in this instrument, without what was carried in,
  as a `data.frame`, or `NULL` when there are none. This is UBI's `day`
  bucket. It has the same shape as `net_positions` and counts only what
  was opened and closed today, so it is usually empty even when
  `net_positions` is not, because only some brokers report a position on
  a day basis at all.

- `positions_value`:

  The numeric worth of this instrument's open positions at the moment,
  rounded to two places, or `NULL` when none is held or any position has
  no last price. Each position is counted as its quantity times its last
  price, and the sign is kept, so a long position adds and a short one
  subtracts. UBI prices a holding but not a position, so this is worked
  out here. This counts every position, including those held under
  `margin_trading`, `cover` and `bracket`, because they are real money
  even though UBI cannot send an order to close them.

- `positions_pnl`:

  What this instrument's positions have made or lost, as a named list
  with numeric `realized`, `unrealized` and `total`, each rounded to two
  places, or `NULL` when none is held. The realised part is profit
  already booked by closing some of a position today, and the unrealised
  part is what is still riding on what remains open. Both are added
  across every position in this instrument, including those held under
  `margin_trading`, `cover` and `bracket`.

## Methods

### Public methods

- [`TradeableInstrument$new()`](#method-TradeableInstrument-initialize)

- [`TradeableInstrument$place_order()`](#method-TradeableInstrument-place_order)

- [`TradeableInstrument$modify_order()`](#method-TradeableInstrument-modify_order)

- [`TradeableInstrument$cancel_order()`](#method-TradeableInstrument-cancel_order)

- [`TradeableInstrument$cancel_open_orders()`](#method-TradeableInstrument-cancel_open_orders)

- [`TradeableInstrument$parent()`](#method-TradeableInstrument-parent)

- [`TradeableInstrument$cancel_parent()`](#method-TradeableInstrument-cancel_parent)

- [`TradeableInstrument$parent_orders()`](#method-TradeableInstrument-parent_orders)

- [`TradeableInstrument$parent_trades()`](#method-TradeableInstrument-parent_trades)

- [`TradeableInstrument$buy_at_market_price()`](#method-TradeableInstrument-buy_at_market_price)

- [`TradeableInstrument$sell_at_market_price()`](#method-TradeableInstrument-sell_at_market_price)

- [`TradeableInstrument$buy_at_limit_price()`](#method-TradeableInstrument-buy_at_limit_price)

- [`TradeableInstrument$sell_at_limit_price()`](#method-TradeableInstrument-sell_at_limit_price)

- [`TradeableInstrument$buy_at_best_bid_price()`](#method-TradeableInstrument-buy_at_best_bid_price)

- [`TradeableInstrument$buy_at_best_offer_price()`](#method-TradeableInstrument-buy_at_best_offer_price)

- [`TradeableInstrument$sell_at_best_offer_price()`](#method-TradeableInstrument-sell_at_best_offer_price)

- [`TradeableInstrument$sell_at_best_bid_price()`](#method-TradeableInstrument-sell_at_best_bid_price)

- [`TradeableInstrument$buy_at_mid_price()`](#method-TradeableInstrument-buy_at_mid_price)

- [`TradeableInstrument$sell_at_mid_price()`](#method-TradeableInstrument-sell_at_mid_price)

- [`TradeableInstrument$buy_at_volume_weighted_average_price()`](#method-TradeableInstrument-buy_at_volume_weighted_average_price)

- [`TradeableInstrument$sell_at_volume_weighted_average_price()`](#method-TradeableInstrument-sell_at_volume_weighted_average_price)

- [`TradeableInstrument$buy_at_marketable_price()`](#method-TradeableInstrument-buy_at_marketable_price)

- [`TradeableInstrument$sell_at_marketable_price()`](#method-TradeableInstrument-sell_at_marketable_price)

- [`TradeableInstrument$buy_at_last_price()`](#method-TradeableInstrument-buy_at_last_price)

- [`TradeableInstrument$sell_at_last_price()`](#method-TradeableInstrument-sell_at_last_price)

- [`TradeableInstrument$buy_at_second_best_bid_price()`](#method-TradeableInstrument-buy_at_second_best_bid_price)

- [`TradeableInstrument$buy_at_third_best_bid_price()`](#method-TradeableInstrument-buy_at_third_best_bid_price)

- [`TradeableInstrument$buy_at_fourth_best_bid_price()`](#method-TradeableInstrument-buy_at_fourth_best_bid_price)

- [`TradeableInstrument$buy_at_fifth_best_bid_price()`](#method-TradeableInstrument-buy_at_fifth_best_bid_price)

- [`TradeableInstrument$sell_at_second_best_bid_price()`](#method-TradeableInstrument-sell_at_second_best_bid_price)

- [`TradeableInstrument$sell_at_third_best_bid_price()`](#method-TradeableInstrument-sell_at_third_best_bid_price)

- [`TradeableInstrument$sell_at_fourth_best_bid_price()`](#method-TradeableInstrument-sell_at_fourth_best_bid_price)

- [`TradeableInstrument$sell_at_fifth_best_bid_price()`](#method-TradeableInstrument-sell_at_fifth_best_bid_price)

- [`TradeableInstrument$buy_at_second_best_offer_price()`](#method-TradeableInstrument-buy_at_second_best_offer_price)

- [`TradeableInstrument$buy_at_third_best_offer_price()`](#method-TradeableInstrument-buy_at_third_best_offer_price)

- [`TradeableInstrument$buy_at_fourth_best_offer_price()`](#method-TradeableInstrument-buy_at_fourth_best_offer_price)

- [`TradeableInstrument$buy_at_fifth_best_offer_price()`](#method-TradeableInstrument-buy_at_fifth_best_offer_price)

- [`TradeableInstrument$sell_at_second_best_offer_price()`](#method-TradeableInstrument-sell_at_second_best_offer_price)

- [`TradeableInstrument$sell_at_third_best_offer_price()`](#method-TradeableInstrument-sell_at_third_best_offer_price)

- [`TradeableInstrument$sell_at_fourth_best_offer_price()`](#method-TradeableInstrument-sell_at_fourth_best_offer_price)

- [`TradeableInstrument$sell_at_fifth_best_offer_price()`](#method-TradeableInstrument-sell_at_fifth_best_offer_price)

- [`TradeableInstrument$add_to_position()`](#method-TradeableInstrument-add_to_position)

- [`TradeableInstrument$reduce_position()`](#method-TradeableInstrument-reduce_position)

- [`TradeableInstrument$liquidate_position()`](#method-TradeableInstrument-liquidate_position)

- [`TradeableInstrument$liquidate_all_positions()`](#method-TradeableInstrument-liquidate_all_positions)

- [`TradeableInstrument$clone()`](#method-TradeableInstrument-clone)

Inherited methods

- [`PriceStatistics$price_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_high)
- [`PriceStatistics$price_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_histogram)
- [`PriceStatistics$price_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_kurtosis)
- [`PriceStatistics$price_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_low)
- [`PriceStatistics$price_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_mean)
- [`PriceStatistics$price_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_mean_absolute_deviation)
- [`PriceStatistics$price_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_median)
- [`PriceStatistics$price_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_quantile)
- [`PriceStatistics$price_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_skewness)
- [`PriceStatistics$price_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_standard_deviation)
- [`PriceStatistics$price_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_summary)
- [`PriceStatistics$price_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-price_variance)
- [`PriceStatistics$returns()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns)
- [`PriceStatistics$returns_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_high)
- [`PriceStatistics$returns_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_histogram)
- [`PriceStatistics$returns_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_kurtosis)
- [`PriceStatistics$returns_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_low)
- [`PriceStatistics$returns_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_mean)
- [`PriceStatistics$returns_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_mean_absolute_deviation)
- [`PriceStatistics$returns_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_median)
- [`PriceStatistics$returns_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_quantile)
- [`PriceStatistics$returns_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_skewness)
- [`PriceStatistics$returns_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_standard_deviation)
- [`PriceStatistics$returns_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_summary)
- [`PriceStatistics$returns_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-returns_variance)
- [`PriceStatistics$volume_high()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_high)
- [`PriceStatistics$volume_histogram()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_histogram)
- [`PriceStatistics$volume_kurtosis()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_kurtosis)
- [`PriceStatistics$volume_low()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_low)
- [`PriceStatistics$volume_mean()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_mean)
- [`PriceStatistics$volume_mean_absolute_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_mean_absolute_deviation)
- [`PriceStatistics$volume_median()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_median)
- [`PriceStatistics$volume_quantile()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_quantile)
- [`PriceStatistics$volume_skewness()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_skewness)
- [`PriceStatistics$volume_standard_deviation()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_standard_deviation)
- [`PriceStatistics$volume_summary()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_summary)
- [`PriceStatistics$volume_total()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_total)
- [`PriceStatistics$volume_variance()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volume_variance)
- [`PriceStatistics$volumes()`](https://pramodathani.github.io/tradeR/reference/PriceStatistics.html#method-volumes)
- [`OverlapStudies$bollinger_bands()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-bollinger_bands)
- [`OverlapStudies$double_exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-double_exponential_moving_average)
- [`OverlapStudies$exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-exponential_moving_average)
- [`OverlapStudies$kaufman_adaptive_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-kaufman_adaptive_moving_average)
- [`OverlapStudies$mesa_adaptive_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-mesa_adaptive_moving_average)
- [`OverlapStudies$mid_point()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-mid_point)
- [`OverlapStudies$middle_price()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-middle_price)
- [`OverlapStudies$parabolic_sar()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-parabolic_sar)
- [`OverlapStudies$simple_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-simple_moving_average)
- [`OverlapStudies$triangular_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-triangular_moving_average)
- [`OverlapStudies$triple_exponential_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-triple_exponential_moving_average)
- [`OverlapStudies$weighted_moving_average()`](https://pramodathani.github.io/tradeR/reference/OverlapStudies.html#method-weighted_moving_average)
- [`MomentumIndicators$absolute_price_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-absolute_price_oscillator)
- [`MomentumIndicators$aroon()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-aroon)
- [`MomentumIndicators$aroon_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-aroon_oscillator)
- [`MomentumIndicators$average_directional_movement_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-average_directional_movement_index)
- [`MomentumIndicators$average_directional_movement_index_rating()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-average_directional_movement_index_rating)
- [`MomentumIndicators$balance_of_power()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-balance_of_power)
- [`MomentumIndicators$chande_momentum_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-chande_momentum_oscillator)
- [`MomentumIndicators$commodity_channel_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-commodity_channel_index)
- [`MomentumIndicators$directional_movement_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-directional_movement_index)
- [`MomentumIndicators$minus_directional_indicator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-minus_directional_indicator)
- [`MomentumIndicators$minus_directional_movement()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-minus_directional_movement)
- [`MomentumIndicators$momentum()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-momentum)
- [`MomentumIndicators$money_flow_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-money_flow_index)
- [`MomentumIndicators$moving_average_convergence_divergence()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-moving_average_convergence_divergence)
- [`MomentumIndicators$moving_average_convergence_divergence_extended()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-moving_average_convergence_divergence_extended)
- [`MomentumIndicators$percentage_price_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-percentage_price_oscillator)
- [`MomentumIndicators$plus_directional_indicator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-plus_directional_indicator)
- [`MomentumIndicators$plus_directional_movement()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-plus_directional_movement)
- [`MomentumIndicators$rate_of_change()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change)
- [`MomentumIndicators$rate_of_change_percent()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change_percent)
- [`MomentumIndicators$rate_of_change_ratio()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-rate_of_change_ratio)
- [`MomentumIndicators$relative_strength_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-relative_strength_index)
- [`MomentumIndicators$stochastic_fast_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_fast_oscillator)
- [`MomentumIndicators$stochastic_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_oscillator)
- [`MomentumIndicators$stochastic_relative_strength_index()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-stochastic_relative_strength_index)
- [`MomentumIndicators$trix()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-trix)
- [`MomentumIndicators$ultimate_oscillator()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-ultimate_oscillator)
- [`MomentumIndicators$williams_percent_r()`](https://pramodathani.github.io/tradeR/reference/MomentumIndicators.html#method-williams_percent_r)
- [`VolumeIndicators$chaikin_accumulation_distribution_line()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-chaikin_accumulation_distribution_line)
- [`VolumeIndicators$chaikin_accumulation_distribution_oscillator()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-chaikin_accumulation_distribution_oscillator)
- [`VolumeIndicators$on_balance_volume()`](https://pramodathani.github.io/tradeR/reference/VolumeIndicators.html#method-on_balance_volume)
- [`CycleIndicators$hilbert_transform_dominant_cycle_period()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_dominant_cycle_period)
- [`CycleIndicators$hilbert_transform_dominant_cycle_phase()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_dominant_cycle_phase)
- [`CycleIndicators$hilbert_transform_phasor_components()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_phasor_components)
- [`CycleIndicators$hilbert_transform_sine_wave()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_sine_wave)
- [`CycleIndicators$hilbert_transform_trend_line()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_trend_line)
- [`CycleIndicators$hilbert_transform_trend_mode()`](https://pramodathani.github.io/tradeR/reference/CycleIndicators.html#method-hilbert_transform_trend_mode)
- [`PriceTransforms$average_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-average_price)
- [`PriceTransforms$median_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-median_price)
- [`PriceTransforms$typical_price()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-typical_price)
- [`PriceTransforms$weighted_close()`](https://pramodathani.github.io/tradeR/reference/PriceTransforms.html#method-weighted_close)
- [`VolatilityIndicators$average_true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-average_true_range)
- [`VolatilityIndicators$normalized_average_true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-normalized_average_true_range)
- [`VolatilityIndicators$true_range()`](https://pramodathani.github.io/tradeR/reference/VolatilityIndicators.html#method-true_range)
- [`StatisticFunctions$beta()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-beta)
- [`StatisticFunctions$correlation_coefficient()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-correlation_coefficient)
- [`StatisticFunctions$linear_regression()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression)
- [`StatisticFunctions$linear_regression_angle()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_angle)
- [`StatisticFunctions$linear_regression_intercept()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_intercept)
- [`StatisticFunctions$linear_regression_slope()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-linear_regression_slope)
- [`StatisticFunctions$standard_deviation()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-standard_deviation)
- [`StatisticFunctions$variance()`](https://pramodathani.github.io/tradeR/reference/StatisticFunctions.html#method-variance)
- [`MathTransforms$arc_cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_cosine)
- [`MathTransforms$arc_sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_sine)
- [`MathTransforms$arc_tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-arc_tangent)
- [`MathTransforms$ceiling()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-ceiling)
- [`MathTransforms$cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-cosine)
- [`MathTransforms$exponential()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-exponential)
- [`MathTransforms$floor()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-floor)
- [`MathTransforms$hyperbolic_cosine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_cosine)
- [`MathTransforms$hyperbolic_sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_sine)
- [`MathTransforms$hyperbolic_tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-hyperbolic_tangent)
- [`MathTransforms$logarithm_base_10()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-logarithm_base_10)
- [`MathTransforms$natural_logarithm()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-natural_logarithm)
- [`MathTransforms$sine()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-sine)
- [`MathTransforms$square_root()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-square_root)
- [`MathTransforms$tangent()`](https://pramodathani.github.io/tradeR/reference/MathTransforms.html#method-tangent)
- [`MathOperators$add()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-add)
- [`MathOperators$divide()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-divide)
- [`MathOperators$maximum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-maximum)
- [`MathOperators$maximum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-maximum_index)
- [`MathOperators$minimum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum)
- [`MathOperators$minimum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_index)
- [`MathOperators$minimum_maximum()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_maximum)
- [`MathOperators$minimum_maximum_index()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-minimum_maximum_index)
- [`MathOperators$multiply()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-multiply)
- [`MathOperators$subtract()`](https://pramodathani.github.io/tradeR/reference/MathOperators.html#method-subtract)
- [`CandlestickPatterns$candle_abandoned_baby()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_abandoned_baby)
- [`CandlestickPatterns$candle_advance_block()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_advance_block)
- [`CandlestickPatterns$candle_belt_hold()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_belt_hold)
- [`CandlestickPatterns$candle_breakaway()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_breakaway)
- [`CandlestickPatterns$candle_closing_marubozu()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_closing_marubozu)
- [`CandlestickPatterns$candle_concealing_baby_swallow()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_concealing_baby_swallow)
- [`CandlestickPatterns$candle_counter_attack()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_counter_attack)
- [`CandlestickPatterns$candle_dark_cloud_cover()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_dark_cloud_cover)
- [`CandlestickPatterns$candle_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_doji)
- [`CandlestickPatterns$candle_doji_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_doji_star)
- [`CandlestickPatterns$candle_dragonfly_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_dragonfly_doji)
- [`CandlestickPatterns$candle_engulfing()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_engulfing)
- [`CandlestickPatterns$candle_evening_doji_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_evening_doji_star)
- [`CandlestickPatterns$candle_evening_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_evening_star)
- [`CandlestickPatterns$candle_gravestone_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_gravestone_doji)
- [`CandlestickPatterns$candle_hammer()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hammer)
- [`CandlestickPatterns$candle_hanging_man()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hanging_man)
- [`CandlestickPatterns$candle_harami()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_harami)
- [`CandlestickPatterns$candle_harami_cross()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_harami_cross)
- [`CandlestickPatterns$candle_high_wave()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_high_wave)
- [`CandlestickPatterns$candle_hikkake()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_hikkake)
- [`CandlestickPatterns$candle_homing_pigeon()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_homing_pigeon)
- [`CandlestickPatterns$candle_identical_three_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_identical_three_crows)
- [`CandlestickPatterns$candle_in_neck()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_in_neck)
- [`CandlestickPatterns$candle_inverted_hammer()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_inverted_hammer)
- [`CandlestickPatterns$candle_kicking()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_kicking)
- [`CandlestickPatterns$candle_kicking_by_length()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_kicking_by_length)
- [`CandlestickPatterns$candle_ladder_bottom()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_ladder_bottom)
- [`CandlestickPatterns$candle_long_legged_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_long_legged_doji)
- [`CandlestickPatterns$candle_long_line()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_long_line)
- [`CandlestickPatterns$candle_marubozu()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_marubozu)
- [`CandlestickPatterns$candle_mat_hold()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_mat_hold)
- [`CandlestickPatterns$candle_matching_low()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_matching_low)
- [`CandlestickPatterns$candle_modified_hikkake()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_modified_hikkake)
- [`CandlestickPatterns$candle_morning_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_morning_star)
- [`CandlestickPatterns$candle_morning_star_doji()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_morning_star_doji)
- [`CandlestickPatterns$candle_on_neck()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_on_neck)
- [`CandlestickPatterns$candle_piercing()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_piercing)
- [`CandlestickPatterns$candle_rickshaw_man()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_rickshaw_man)
- [`CandlestickPatterns$candle_rise_fall_three_methods()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_rise_fall_three_methods)
- [`CandlestickPatterns$candle_separating_lines()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_separating_lines)
- [`CandlestickPatterns$candle_shooting_star()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_shooting_star)
- [`CandlestickPatterns$candle_short_line()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_short_line)
- [`CandlestickPatterns$candle_side_by_side_white_lines()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_side_by_side_white_lines)
- [`CandlestickPatterns$candle_spinning_top()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_spinning_top)
- [`CandlestickPatterns$candle_stalled_pattern()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_stalled_pattern)
- [`CandlestickPatterns$candle_stick_sandwich()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_stick_sandwich)
- [`CandlestickPatterns$candle_takuri()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_takuri)
- [`CandlestickPatterns$candle_tasuki_gap()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_tasuki_gap)
- [`CandlestickPatterns$candle_three_black_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_black_crows)
- [`CandlestickPatterns$candle_three_inside_up_down()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_inside_up_down)
- [`CandlestickPatterns$candle_three_line_strike()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_line_strike)
- [`CandlestickPatterns$candle_three_outside_up_down()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_outside_up_down)
- [`CandlestickPatterns$candle_three_stars_in_the_south()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_stars_in_the_south)
- [`CandlestickPatterns$candle_three_white_soldiers()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_three_white_soldiers)
- [`CandlestickPatterns$candle_thrusting_pattern()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_thrusting_pattern)
- [`CandlestickPatterns$candle_tristar()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_tristar)
- [`CandlestickPatterns$candle_two_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_two_crows)
- [`CandlestickPatterns$candle_unique_three_river()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_unique_three_river)
- [`CandlestickPatterns$candle_up_side_down_side_gap_three_methods()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_up_side_down_side_gap_three_methods)
- [`CandlestickPatterns$candle_up_side_gap_two_crows()`](https://pramodathani.github.io/tradeR/reference/CandlestickPatterns.html#method-candle_up_side_gap_two_crows)
- [`Signals$is_cross_over()`](https://pramodathani.github.io/tradeR/reference/Signals.html#method-is_cross_over)
- [`Signals$is_cross_under()`](https://pramodathani.github.io/tradeR/reference/Signals.html#method-is_cross_under)
- [`StrategyBacktests$run_backtest()`](https://pramodathani.github.io/tradeR/reference/StrategyBacktests.html#method-run_backtest)
- [`PerformanceMeasures$alpha()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-alpha)
- [`PerformanceMeasures$annualised_return()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-annualised_return)
- [`PerformanceMeasures$annualised_volatility()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-annualised_volatility)
- [`PerformanceMeasures$benchmark_beta()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-benchmark_beta)
- [`PerformanceMeasures$calmar_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-calmar_ratio)
- [`PerformanceMeasures$cumulative_return()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-cumulative_return)
- [`PerformanceMeasures$down_capture_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-down_capture_ratio)
- [`PerformanceMeasures$drawdowns()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-drawdowns)
- [`PerformanceMeasures$expected_shortfall()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-expected_shortfall)
- [`PerformanceMeasures$information_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-information_ratio)
- [`PerformanceMeasures$maximum_drawdown()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-maximum_drawdown)
- [`PerformanceMeasures$performance_summary()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-performance_summary)
- [`PerformanceMeasures$sharpe_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-sharpe_ratio)
- [`PerformanceMeasures$sortino_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-sortino_ratio)
- [`PerformanceMeasures$tracking_error()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-tracking_error)
- [`PerformanceMeasures$up_capture_ratio()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-up_capture_ratio)
- [`PerformanceMeasures$value_at_risk()`](https://pramodathani.github.io/tradeR/reference/PerformanceMeasures.html#method-value_at_risk)
- [`Instrument$equals()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-equals)
- [`Instrument$format()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-format)
- [`Instrument$prices()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-prices)
- [`Instrument$print()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-print)
- [`Instrument$ticks()`](https://pramodathani.github.io/tradeR/reference/Instrument.html#method-ticks)

------------------------------------------------------------------------

### `TradeableInstrument$new()`

Looks the instrument up in UBI and checks that it is not an index.

#### Usage

    TradeableInstrument$new(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      unified_broker_interface = NULL,
      details = NULL
    )

#### Arguments

- `instrument_id`:

  The character UUID of the instrument, or `NULL` to look it up by
  exchange, segment and identity fields.

- `exchange`:

  The character exchange, such as `"nse"`, or `NULL` when
  `instrument_id` is given.

- `segment`:

  The character segment, bare such as `"equities"` or prefixed such as
  `"nse_equities"`, or `NULL` when `instrument_id` is given.

- `symbol`:

  The character symbol of a security, or `NULL`.

- `underlying_symbol`:

  The character symbol of a future's or option's underlying, or `NULL`.

- `expiry_date`:

  The expiry of a future or option as a `Date` or a `"YYYY-MM-DD"`
  character value, or `NULL`.

- `strike_price`:

  The numeric strike price of an option, or `NULL`.

- `option_type`:

  The character option type of an option, `"CE"` or `"PE"`, or `NULL`.

- `unified_broker_interface`:

  The `UnifiedBrokerInterface` to send requests through, or `NULL` to
  share one client among all instruments.

- `details`:

  The named list UBI returned for this instrument from
  `/api/instruments/details`, used instead of looking the instrument up
  again, or `NULL` to look it up from the other arguments.

#### Details

Errors: signals `TradeableInstrumentError` when the instrument is an
index; `InstrumentError` when UBI has no instrument matching the lookup;
`BadRequestError` when the lookup is incomplete or malformed; and
another `UnifiedBrokerInterfaceError` subclass for any other failure
reported by, or on the way to, UBI.

#### Returns

A new `TradeableInstrument` object.

------------------------------------------------------------------------

### `TradeableInstrument$place_order()`

Places one order in this instrument through UBI.

UBI chooses the broker itself, so no broker is named here. The values
are sent exactly as given, without rounding the price to the tick size
or checking the quantity against the lot size, because UBI and the
broker behind it hold those rules.

UBI couples the price fields to the order type and answers HTTP 400 when
they do not agree: a `limit` or `sl` order needs a price, an `sl` or
`sl-m` order needs a trigger price, and a `market` or `sl-m` order must
carry no price at all. A `price_reference` stands in for the price and a
`quantity_reference` for the quantity.

An outcome of `accepted` means the broker took the order, not that the
order survived. The exchange can still refuse it afterwards, which is
what happens to an ordinary order sent while the market is closed, so
the order's real fate is read from `orders` rather than from this
answer. Neither this class nor UBI checks the market's hours, so use
`after_market` to queue an order for the next session.

Every order goes through UBI's order engine, which is the only way UBI
places orders. A plain `limit` order with a price of its own, `day`
validity, no `synthetic` object and `after_market` `FALSE` is not sent
to a broker straight away: the engine holds it as a `virtual_limit`
order and sends it only once the other side of the book reaches its
price, answering HTTP 202 with an outcome of `armed`, a `parent_id` and
no `order_id`. Such a held order is changed with
`modify_order(parent_id = ...)` and cancelled with `cancel_parent()`,
and it never appears in `orders` until it has been sent. Pass
`synthetic = list(type = "simple")` to send a limit order at once, which
matters for an instrument that has no live quote, because the engine
would hold its order for the whole day without ever sending it.

A plain `market` order with no `synthetic` object and `after_market`
`FALSE` is not sent as a market order either. The engine runs it as a
`marketable_limit` order: a `limit` two ticks past the other side's best
price, moved after that price until it fills, with whatever is left
cancelled 30 seconds after it was placed. Such an order is refused with
HTTP 409, and nothing is sent, when nobody is on the other side of the
book, no live quote has arrived or the quote is marked stale. Pass
`synthetic = list(type = "simple")` to send a real market order, which
an instrument with no live quote needs.

The examples below, in order:

- Have UBI build a limit buy for one Vodafone Idea share without sending
  it, and print the request it would send.

- Place a plain limit buy 3 per cent below the market, which the order
  engine holds until a seller reaches the price, and cancel it.

- Describe the price rather than state it, here the third best bid, and
  see the price UBI works out in a dry run.

#### Usage

    TradeableInstrument$place_order(
      transaction_type,
      order_type,
      quantity,
      product,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      dry_run = FALSE,
      price_reference = NULL,
      quantity_reference = NULL,
      synthetic = NULL
    )

#### Arguments

- `transaction_type`:

  The character side of the order, `"buy"` or `"sell"`. UBI overrides it
  for a quantity reference that reduces or closes a position.

- `order_type`:

  The character kind of order, `"market"`, `"limit"`, `"sl"` or
  `"sl-m"`.

- `quantity`:

  The integer quantity in underlying units, not lots, or `NULL` when a
  quantity reference supplies it.

- `product`:

  The character product, `"cnc"` for delivery, `"mis"` for intraday or
  `"nrml"` for carry forward.

- `price`:

  The numeric limit price in rupees, or `NULL` for an order type that
  takes no price or when a price reference supplies it.

- `trigger_price`:

  The numeric trigger price in rupees, or `NULL` for an order type that
  takes no trigger.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `disclosed_quantity`:

  The integer quantity to show on the exchange, or `NULL` to disclose
  the whole order.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

- `dry_run`:

  A logical that is `TRUE` to have UBI build the broker's request and
  return it without sending it.

- `price_reference`:

  A named list that describes the price instead of stating it, such as
  `list(kind = "offer_level", level = 2)`, which UBI resolves from the
  live quote and rounds to the tick, or `NULL`. Its `kind` is
  `absolute`, `bid_level`, `offer_level`, `mid`, `vwap`, `last` or
  `marketable`, and it may carry `price`, `level`, `buffer_percent`,
  `offset_percent` and `offset_ticks`.

- `quantity_reference`:

  A named list that describes the quantity instead of stating it, such
  as `list(kind = "liquidate_position", product = "intraday")`, which
  UBI resolves from the positions, or `NULL`. Its `kind` is
  `add_to_position`, `reduce_position` or `liquidate_position`, and its
  optional `product` is spelled the positions' way.

- `synthetic`:

  A named list that makes the order one of UBI's synthetic order types,
  such as
  `list(type = "bracket", stop_price = 990, stop_limit_price = 988, target_price = 1010)`,
  or `NULL` for a plain order. The synthetic order classes, such as
  `BracketOrder`, build it.

#### Details

Errors: signals `BadRequestError` when a field is invalid, the price
fields do not fit the order type, or a synthetic order's own fields are
wrong; `LossLockoutError` when the day's loss is past UBI's daily loss
limit; `NotFoundError` when no broker has a mapping for this instrument;
`ConflictError` when a quantity reference asked to reduce or close a
position that is not held, a market order sent as a marketable limit
found nobody on the other side of the book or no fresh quote, a
reduce-only order would not reduce the position, or the engine read the
order too late or had already started it before a restart;
`OrderRejectedError` when the broker refused the order, and the detail
holds its answer; `RateLimitError` when the broker's daily order cap has
no room for this order; `ServiceUnavailableError` when no broker could
take the order, the order engine is not running, or a price reference
could not be resolved; `OrderOutcomeUnknownError` when the order was
sent but its outcome is unknown, so read the order book, or
`Account$intent()` with the detail's `intent_id`, before sending it
again; and another `UnifiedBrokerInterfaceError` subclass for any other
failure reported by, or on the way to, UBI.

#### Returns

A named list with `broker`, `instrument_id`, `order_id`, `outcome`,
`status_message`, `broker_response`, `skipped`, `timing_ms` and
`intent_id`, and `parent_id` for an order the engine recorded, or, for a
dry run, a named list with `dry_run` and the `request` UBI would have
sent. The `order_id` is `NULL` unless the outcome is `accepted`. A held
limit order, and a synthetic order that is waiting for a price or a
time, answers with an outcome of `armed` and a `broker` and `order_id`
of `NULL`. The types that send several orders at once add a `legs` list,
one entry per order with its plan `path`, `instrument_id`, `outcome`,
`order_id` and `status_message`, and their `outcome` is `partial` when
some of those orders were accepted and some were not.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")

    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$place_order(
      transaction_type = "buy",
      order_type = "limit",
      quantity = 1,
      product = "cnc",
      price = price,
      dry_run = TRUE
    )
    print(answer)

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")

    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$place_order(
      transaction_type = "buy",
      order_type = "limit",
      quantity = 1,
      product = "cnc",
      price = price
    )
    tryCatch(
      {
        cat(
          answer[["outcome"]],
          answer[["parent_id"]],
          answer[["order_id"]],
          "\n"
        )
      },
      finally = {
        print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")

    answer <- idea$place_order(
      transaction_type = "buy",
      order_type = "limit",
      quantity = 1,
      product = "mis",
      price_reference = list(
        kind = "bid_level",
        level = 3
      ),
      dry_run = TRUE
    )
    print(answer)

------------------------------------------------------------------------

### `TradeableInstrument$modify_order()`

Changes one pending order through UBI.

UBI finds the order by its id in the brokers' order books, so this does
not check that the order belongs to this instrument. Give at least one
field to change; every field left as `NULL` keeps the value the order
already has.

Those order books are copies that UBI's own collectors refresh every few
seconds, so an order placed a moment ago is not in them yet and signals
`NotFoundError`. Wait for the order to appear in `orders` before
changing it.

An order that is a leg of one of UBI's synthetic orders is handed to the
engine, which lets the order type carry on from the change, so a
trailing stop trails from the new trigger. Only its `price`,
`trigger_price` and `quantity` can change, and anything else signals
`ConflictError`.

An order the engine is still holding, such as a plain limit order
waiting for the other side to reach its price, has no broker order id
yet. Name it by the `parent_id` that `place_order()` answered with
instead of `order_id`; only its `price` and `quantity` can change, and
nothing is sent to a broker.

A part of a `plan` order that has not sent anything yet, such as a
bracket's stop before the entry fills, is named by the plan's
`parent_id` and the part's path in `part`, such as
`"root.each_fill.children.0"`, as the parent's `parameters.parts` lists
it. Its `price`, `trigger_price` and `quantity` can change, and it keeps
the new values until its turn comes, without anything being sent to a
broker. Only a part with a fixed price, a plain limit or a native stop,
takes a price, and only a stop takes a trigger price.

The examples below, in order:

- Lower the price of a held limit buy from 3 to 4 per cent below the
  market, naming it by its parent id, then cancel it.

- Send a limit buy 3 per cent below the market to the broker at once,
  wait for it to reach the order book, lower its price by a tick, and
  cancel it.

#### Usage

    TradeableInstrument$modify_order(
      order_id = NULL,
      quantity = NULL,
      price = NULL,
      trigger_price = NULL,
      order_type = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      broker = NULL,
      dry_run = FALSE,
      parent_id = NULL,
      part = NULL
    )

#### Arguments

- `order_id`:

  The character id the broker gave the order, as `place_order()`
  returned it, or `NULL` when naming a held order by `parent_id`.

- `quantity`:

  The integer new total quantity in underlying units, counting what is
  already filled, or `NULL` to leave it.

- `price`:

  The numeric new limit price in rupees, or `NULL` to leave it.

- `trigger_price`:

  The numeric new trigger price in rupees, or `NULL` to leave it.

- `order_type`:

  The character new kind of order, `"market"`, `"limit"`, `"sl"` or
  `"sl-m"`, or `NULL` to leave it.

- `validity`:

  The character new validity, `"day"` or `"ioc"`, or `NULL` to leave it.

- `disclosed_quantity`:

  The integer new quantity to show on the exchange, or `NULL` to leave
  it.

- `broker`:

  The character name of the broker holding the order, which is needed
  only after a `ConflictError` reporting that two brokers share the id,
  or `NULL`.

- `dry_run`:

  A logical that is `TRUE` to have UBI build the broker's request and
  return it without sending it.

- `parent_id`:

  The character id of an order the engine is still holding, or of the
  plan that holds `part`, as `place_order()` returned it, or `NULL` when
  naming a broker order by `order_id`.

- `part`:

  The character path of a part of a plan that has not been sent, such as
  `"root.each_fill.children.0"`, given with `parent_id`, or `NULL`.

#### Details

Errors: signals `BadRequestError` when no field was given to change, a
field is invalid or is one this broker cannot change, or a plan part
works its price out from the market or is not a stop and was given a
price or trigger price it cannot take; `NotFoundError` when no broker's
order book holds this order id, the engine holds no parent with this
parent id, or the plan has no part at this path; `ConflictError` when
the order is already complete, cancelled, rejected or expired, two
brokers hold the id and the detail lists them under `brokers`, a leg of
a synthetic order was asked to change a field other than its price,
trigger price or quantity, a held order or plan part has already been
sent, when the detail names its `broker` and `order_id`, or a plan part
is sized by an earlier part's fills, is kept whole, or closes a position
and was asked to grow; `OrderRejectedError` when the broker refused the
change, and the detail holds its answer; `ServiceUnavailableError` when
the broker's order rate budget was full, so the change was not sent;
`OrderOutcomeUnknownError` when the change was sent but its outcome is
unknown; and another `UnifiedBrokerInterfaceError` subclass for any
other failure reported by, or on the way to, UBI.

#### Returns

A named list with `broker`, `order_id`, `instrument_id`,
`status_before_modify`, `outcome`, `status_message`, `broker_response`
and `timing_ms`, and `parent_id` and `synthetic_type` for a leg of a
synthetic order, or, for a dry run, a named list with `dry_run` and the
`request` UBI would have sent. A held order answers with `parent_id`,
`synthetic_type`, `held` set to `TRUE`, the new `price` and `quantity`,
and an `outcome` of `accepted`. A part of a plan answers with
`parent_id`, `synthetic_type`, `part`, its `state`, the new `price`,
`trigger_price` and `quantity`, and an `outcome` of `accepted`.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    tryCatch(
      {
        new_price <- round(idea$last_price * 0.96, 2)
        changed <- idea$modify_order(parent_id = parent_id, price = new_price)
        cat(changed[["outcome"]], changed[["price"]], changed[["held"]], "\n")
      },
      finally = {
        print(idea$cancel_parent(parent_id)[["state"]])
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 0.97, 2)
        answer <- idea$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        changed <- idea$modify_order(
          order_id = order_id,
          price = round(price - 0.01, 2)
        )
        cat(changed[["broker"]], changed[["outcome"]], "\n")
        print(idea$cancel_order(order_id)[["outcome"]])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$cancel_order()`

Cancels one pending order through UBI.

UBI finds the order by its id in the brokers' order books, so this does
not check that the order belongs to this instrument.

Those order books are copies that UBI's own collectors refresh every few
seconds, so an order placed a moment ago is not in them yet and signals
`NotFoundError`. Wait for the order to appear in `orders` before
cancelling it.

An order that is a leg of one of UBI's synthetic orders is cancelled
through the engine, so the order type knows about it, but the synthetic
order itself carries on. Use `cancel_parent()` to stop a synthetic
order, or to cancel an order the engine is still holding, which has no
broker order id.

The examples below, in order:

- Send a limit buy 3 per cent below the market to the broker at once,
  wait for it to reach the order book, and cancel it.

- Look at the cancel request UBI would send in a dry run first, then
  cancel a resting sell 3 per cent above the market for real.

#### Usage

    TradeableInstrument$cancel_order(order_id, broker = NULL, dry_run = FALSE)

#### Arguments

- `order_id`:

  The character id the broker gave the order, as `place_order()`
  returned it.

- `broker`:

  The character name of the broker holding the order, which is needed
  only after a `ConflictError` reporting that two brokers share the id,
  or `NULL`.

- `dry_run`:

  A logical that is `TRUE` to have UBI build the broker's request and
  return it without sending it.

#### Details

Errors: signals `BadRequestError` when the order id, broker or dry run
flag is malformed; `NotFoundError` when no broker's order book holds
this order id; `ConflictError` when the order is already complete,
cancelled, rejected or expired, or two brokers hold the id and the
detail lists them under `brokers`; `OrderRejectedError` when the broker
refused the cancellation, and the detail holds its answer;
`ServiceUnavailableError` when the broker's order rate budget was full,
so the cancellation was not sent; `OrderOutcomeUnknownError` when the
cancellation was sent but its outcome is unknown; and another
`UnifiedBrokerInterfaceError` subclass for any other failure reported
by, or on the way to, UBI.

#### Returns

A named list with `broker`, `order_id`, `status_before_cancel`,
`outcome`, `status_message`, `broker_response` and `timing_ms`, and
`parent_id` and `synthetic_type` for a leg of a synthetic order, or, for
a dry run, a named list with `dry_run` and the `request` UBI would have
sent.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 0.97, 2)
        answer <- idea$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        cancelled <- idea$cancel_order(order_id)
        cat(cancelled[["broker"]], cancelled[["outcome"]], "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 1.03, 2)
        answer <- idea$sell_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        print(idea$cancel_order(order_id, dry_run = TRUE))
        print(idea$cancel_order(order_id)[["outcome"]])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$cancel_open_orders()`

Cancels every order in this instrument that is still waiting, whether at
a broker or held in UBI's order engine.

The engine's open parents in this instrument are cancelled first, each
with the orders it has resting at a broker, because a synthetic order
left running could place a new order after its old ones were cancelled.
Then every open order in the order book that did not belong to one of
those parents is cancelled in one request. Every order and parent is
attempted even when an earlier one fails, and a failure is reported in
the returned frame rather than signalled, so one order that can no
longer be cancelled does not leave the rest of them open.

The examples below, in order:

- Place a held limit buy and a limit buy sent to the broker, then cancel
  everything still waiting in Vodafone Idea in one call.

- Place two held limit orders on either side of the market, cancel them
  together, and check that no parent is left open.

#### Usage

    TradeableInstrument$cancel_open_orders()

#### Details

Errors: signals `BrokerError` when no broker's order book could be read;
`ServiceUnavailableError` when UBI's order book document is missing or
too old to serve, or UBI's parents could not be read; and another
`UnifiedBrokerInterfaceError` subclass when the order book or the
parents could not be read for any other reason, or the list of cancels
was refused whole. A failure to cancel one order or parent is reported
in the frame instead.

#### Returns

A `data.frame` with one row per parent or order, holding `parent_id`,
`order_id`, `broker`, `cancelled` and `error`, where `parent_id` is `NA`
for an order cancelled on its own, `order_id` and `broker` are `NA` for
a parent, and `error` is `NA` for a cancel that was accepted and the
status and message of the failure otherwise, or `NULL` when nothing in
this instrument is waiting.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        held <- idea$buy_at_limit_price(
          price = round(idea$last_price * 0.97, 2),
          quantity = 1,
          product = "cnc"
        )
        answers[[length(answers) + 1]] <- held
        price <- round(idea$last_price * 0.96, 2)
        answer <- idea$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        outcomes <- idea$cancel_open_orders()
        print(outcomes[, c(
          "parent_id",
          "order_id",
          "cancelled",
          "error"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")

    last_price <- idea$last_price
    idea$buy_at_limit_price(
      price = round(last_price * 0.97, 2),
      quantity = 1,
      product = "mis"
    )
    idea$sell_at_limit_price(
      price = round(last_price * 1.03, 2),
      quantity = 1,
      product = "mis"
    )
    outcomes <- idea$cancel_open_orders()
    cat(nrow(outcomes), "cancelled:", outcomes$cancelled, "\n")
    cat("Open parents left:", "\n")
    print(idea$parents)

------------------------------------------------------------------------

### `TradeableInstrument$parent()`

Reads one of the order engine's parents, whether or not it has finished.

UBI finds the parent by its id alone, so this does not check that it
belongs to this instrument.

The examples below, in order:

- Read a held limit buy back from the order engine, then cancel it.

- Read a parent again after cancelling it, which works because the
  engine keeps finished parents too.

#### Usage

    TradeableInstrument$parent(parent_id)

#### Arguments

- `parent_id`:

  The character `parent_id` that `place_order()` answered with.

#### Details

Errors: signals `NotFoundError` when the order engine holds no parent
with this id; `ServiceUnavailableError` when UBI's parents could not be
read; and another `UnifiedBrokerInterfaceError` subclass for any other
failure reported by, or on the way to, UBI.

#### Returns

A named list holding the parent as the engine keeps it, with
`parent_order_id`, `synthetic_type`, `state`, `instrument_id`, the
caller's `body`, the type's `parameters` and one entry per leg under
`legs`.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    tryCatch(
      {
        held <- idea$parent(parent_id)
        cat(held[["synthetic_type"]], held[["state"]], "\n")
        print(held[["body"]])
      },
      finally = {
        idea$cancel_parent(parent_id)
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    idea$cancel_parent(parent_id)
    print(idea$parent(parent_id)[["state"]])

------------------------------------------------------------------------

### `TradeableInstrument$cancel_parent()`

Cancels one of the order engine's parents, with every leg it still has
resting at a broker, or one part of a plan.

This is how a synthetic order is stopped and how an order the engine is
still holding is cancelled. A position the parent has already opened is
not closed.

With `part`, only that part of a `plan` order is cancelled, named by its
path, such as `"root.each_fill.children.0"` for a bracket's stop, as the
parent's `parameters.parts` lists it. A part whose turn has not come is
never sent, a part waiting on its trigger is ended at once, and a part
that has sent orders sends no more pieces and has each of its resting
orders cancelled; the rest of the plan carries on, reacting as it does
to that part finishing.

When a broker refuses the cancel of one leg, or its outcome is unknown,
UBI answers HTTP 207, which is returned rather than signalled, with the
parent's `state` as `cancelling` rather than `cancelled`. The parent no
longer acts, and becomes `cancelled` once the broker reports that leg
finished, so read `cancelled_legs` to see which one may still be live,
and call this again to retry it.

The examples below, in order:

- Cancel a held limit buy and print the cancelled parent's state and
  legs.

- Show that a parent that has already finished cannot be cancelled a
  second time.

#### Usage

    TradeableInstrument$cancel_parent(parent_id, part = NULL, dry_run = FALSE)

#### Arguments

- `parent_id`:

  The character `parent_id` that `place_order()` answered with.

- `part`:

  The character path of one part of a plan to cancel, or `NULL` to
  cancel the whole parent.

- `dry_run`:

  A logical that is `TRUE` to have UBI say what would be cancelled,
  under `resting_legs` for a whole parent or `orders` for a part,
  without cancelling anything.

#### Details

Errors: signals `BadRequestError` when the parent id or part path is
malformed; `NotFoundError` when the order engine holds no parent with
this id, or the plan has no part at this path; `ConflictError` when the
parent or part has already finished, or the part is kept whole and has
not started, or the parent is not a plan and was given a part;
`ServiceUnavailableError` when the order engine is not running;
`OrderOutcomeUnknownError` when the engine did not answer in time; and
another `UnifiedBrokerInterfaceError` subclass for any other failure
reported by, or on the way to, UBI.

#### Returns

A named list with `parent_id`, `synthetic_type`, `state`, `intent_id`
and `cancelled_legs`, one entry per leg with its `leg_id`, `broker`,
`order_id`, `outcome` and `status_message`. A part answers instead with
`parent_id`, `synthetic_type`, `part`, its `state`, `outcome`,
`status_message`, `intent_id` and `orders`, where each order says in
`cancel_accepted` whether its broker accepted the cancel, and HTTP 207
with an `outcome` of `partial` or `rejected` is returned rather than
signalled.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    cancelled <- idea$cancel_parent(parent_id)
    cat(cancelled[["state"]], cancelled[["synthetic_type"]], "\n")
    print(cancelled[["cancelled_legs"]])

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    idea$cancel_parent(parent_id)
    tryCatch(
      idea$cancel_parent(parent_id),
      ConflictError = function(error) {
        cat("Refused:", conditionMessage(error), "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$parent_orders()`

Today's broker orders that one of the order engine's parents placed.

The examples below, in order:

- Show that a held limit buy has placed no broker order yet, then cancel
  it.

- Send a limit buy to the broker at once and list the broker order its
  parent placed, then cancel it.

#### Usage

    TradeableInstrument$parent_orders(parent_id)

#### Arguments

- `parent_id`:

  The character `parent_id` that `place_order()` answered with.

#### Details

Errors: signals `BrokerError` when no broker's order book could be read;
`ServiceUnavailableError` when UBI's order book document is missing or
too old to serve; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` shaped like `orders`, whose `leg_role` column says what
each order was to the parent, such as `entry`, `stop` or `target`, or
`NULL` when the parent has placed nothing that the order book shows yet.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    tryCatch(
      print(idea$parent_orders(parent_id)),
      finally = {
        idea$cancel_parent(parent_id)
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 0.97, 2)
        answer <- idea$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        legs <- idea$parent_orders(answer[["parent_id"]])
        print(legs[, c(
          "order_id",
          "leg_role",
          "status",
          "price"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$parent_trades()`

Today's trades in the broker orders that one of the order engine's
parents placed.

The examples below, in order:

- Show that a held limit buy has no trades, then cancel it.

- Buy one Vodafone Idea share at once with a marketable limit as an
  intraday order, list the trades its parent made, which is `NULL` until
  the broker's trade book links them to the parent, and close the
  position again.

#### Usage

    TradeableInstrument$parent_trades(parent_id)

#### Arguments

- `parent_id`:

  The character `parent_id` that `place_order()` answered with.

#### Details

Errors: signals `BrokerError` when no broker's trade book could be read;
`ServiceUnavailableError` when UBI's trade book document is missing or
too old to serve; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

A `data.frame` shaped like `trades`, or `NULL` when none of the parent's
orders has traded.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    tryCatch(
      print(idea$parent_trades(parent_id)),
      finally = {
        idea$cancel_parent(parent_id)
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        bought <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- bought
        Sys.sleep(3)
        print(idea$parent_trades(bought[["parent_id"]]))
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_market_price()`

Buys at whatever price the market is asking.

A market order takes the best price on offer and fills straight away
while the market is open. The price is therefore not known before the
order is sent, and in a thin book it can be a good deal worse than the
last traded price.

UBI's order engine does not send this to a broker as a market order. It
sends a `limit` two ticks past the best offer, moves it after that price
on every tick until it fills, and cancels whatever has not filled 30
seconds after it was placed, so the order cannot fill far from the price
that was showing. UBI refuses the order with HTTP 409, and sends
nothing, when nobody is offering, no live quote has arrived or the quote
is marked stale. An after-market order is always sent as a market order.
Pass `as_marketable_limit = FALSE` to send a real market order at once,
which an instrument with no live quote needs, and use
`tradingmachine.orders.marketable_limit.MarketableLimitOrder` to choose
a different buffer or time. Some brokers refuse a market order sent
through an API outright: on 2026-10-06 Flattrade answered
`ALGO_CHK: MKT Order type not allowed for API order`, which raises
`OrderRejectedError`.

The examples below, in order:

- Buy one Vodafone Idea share at the market as an intraday order, print
  the price it filled at, and close it again through
  `reduce_position()`, which UBI routes against the broker holding the
  position, until the position is back where it started.

- Do the same round trip with a tag on the buy, so the order can be
  picked out of the order book later.

- Try the same round trip with a real market order, which UBI sends to
  the broker at once rather than as a limit following the book, and
  report the broker's refusal when it does not accept market orders from
  an API.

#### Usage

    TradeableInstrument$buy_at_market_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      as_marketable_limit = TRUE
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `as_marketable_limit`:

  A logical that is `TRUE` to let UBI's order engine send the order as a
  limit that follows the other side of the book for up to 30 seconds,
  and `FALSE` to send a market order to a broker at once.

#### Details

Errors: signals `BadRequestError` when a field is invalid;
`ConflictError` when the order was to be sent as a marketable limit and
could not be priced, because nobody is offering, no live quote has
arrived or the quote is marked stale; `OrderRejectedError` when the
broker refused the order, which some brokers do for every real market
order sent through an API; `UnifiedBrokerInterfaceError` when any other
failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opening <- idea$buy_at_market_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- opening
        cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "filled_quantity",
          "average_price"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opening <- idea$buy_at_market_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- opening
        cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "filled_quantity",
          "average_price"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        caught_error <- tryCatch(
          {
            opening <- idea$buy_at_market_price(
              quantity = 1,
              product = "mis",
              as_marketable_limit = FALSE
            )
            NULL
          },
          OrderRejectedError = function(error) error
        )
        if (inherits(caught_error, "OrderRejectedError")) {
          error <- caught_error
          cat(
            "The broker refused a real market order:",
            conditionMessage(error),
            "\n"
          )
          opening <- NULL
        }
        if (!is.null(opening)) {
          answers[[length(answers) + 1]] <- opening
          cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
          Sys.sleep(3)
          orders <- idea$orders
          mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
          print(mine[, c(
            "status",
            "filled_quantity",
            "average_price"
          )])
        }
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_market_price()`

Sells at whatever price the market is bidding.

A market order takes the best price being bid and fills straight away
while the market is open. The price is therefore not known before the
order is sent, and in a thin book it can be a good deal worse than the
last traded price.

UBI's order engine does not send this to a broker as a market order. It
sends a `limit` two ticks past the best bid, moves it after that price
on every tick until it fills, and cancels whatever has not filled 30
seconds after it was placed, so the order cannot fill far from the price
that was showing. UBI refuses the order with HTTP 409, and sends
nothing, when nobody is bidding, no live quote has arrived or the quote
is marked stale. An after-market order is always sent as a market order.
Pass `as_marketable_limit = FALSE` to send a real market order at once,
which an instrument with no live quote needs, and use
`tradingmachine.orders.marketable_limit.MarketableLimitOrder` to choose
a different buffer or time. Some brokers refuse a market order sent
through an API outright: on 2026-10-06 Flattrade answered
`ALGO_CHK: MKT Order type not allowed for API order`, which raises
`OrderRejectedError`.

The examples below, in order:

- Sell one Vodafone Idea share short at the market as an intraday order,
  print the price it filled at, and buy it back through
  `reduce_position()` until the position is back where it started.

- Do the same round trip with a tag on the sale.

- Try the same round trip with a real market order, which UBI sends to
  the broker at once rather than as a limit following the book, and
  report the broker's refusal when it does not accept market orders from
  an API.

#### Usage

    TradeableInstrument$sell_at_market_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      as_marketable_limit = TRUE
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `as_marketable_limit`:

  A logical that is `TRUE` to let UBI's order engine send the order as a
  limit that follows the other side of the book for up to 30 seconds,
  and `FALSE` to send a market order to a broker at once.

#### Details

Errors: signals `BadRequestError` when a field is invalid;
`ConflictError` when the order was to be sent as a marketable limit and
could not be priced, because nobody is bidding, no live quote has
arrived or the quote is marked stale; `OrderRejectedError` when the
broker refused the order, which some brokers do for every real market
order sent through an API; `UnifiedBrokerInterfaceError` when any other
failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opening <- idea$sell_at_market_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- opening
        cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "filled_quantity",
          "average_price"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opening <- idea$sell_at_market_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- opening
        cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "filled_quantity",
          "average_price"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        caught_error <- tryCatch(
          {
            opening <- idea$sell_at_market_price(
              quantity = 1,
              product = "mis",
              as_marketable_limit = FALSE
            )
            NULL
          },
          OrderRejectedError = function(error) error
        )
        if (inherits(caught_error, "OrderRejectedError")) {
          error <- caught_error
          cat(
            "The broker refused a real market order:",
            conditionMessage(error),
            "\n"
          )
          opening <- NULL
        }
        if (!is.null(opening)) {
          answers[[length(answers) + 1]] <- opening
          cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
          Sys.sleep(3)
          orders <- idea$orders
          mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
          print(mine[, c(
            "status",
            "filled_quantity",
            "average_price"
          )])
        }
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_limit_price()`

Buys at a price of your choosing, or better.

A limit buy never pays more than the price given. It waits in the market
until someone sells at that price or lower, and it may never fill at
all.

UBI's order engine holds a `day` limit order that is not an after-market
order rather than resting it at a broker, and sends it only once the
other side of the book reaches the price, so an order that never fills
costs no order messages. Until then `place_order` answers with an
outcome of `armed` and a `parent_id` rather than an `order_id`, the
order is not in `orders` but in `parents`, and it is changed with
`modify_order(parent_id = ...)` and cancelled with `cancel_parent`.

The examples below, in order:

- Bid for one Vodafone Idea share 3 per cent below the market, which the
  order engine holds until a seller reaches the price, and cancel it.

- Send the bid to the broker at once instead of letting the engine hold
  it, wait for it to rest in the order book, and cancel it.

#### Usage

    TradeableInstrument$buy_at_limit_price(
      price,
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      hold = TRUE
    )

#### Arguments

- `price`:

  The numeric limit price in rupees.

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `hold`:

  A logical that is `TRUE` to let UBI's order engine hold a `day` order
  until the other side of the book reaches the price, and `FALSE` to
  send it to a broker at once. An after-market order is always sent at
  once, whatever this says. Pass `FALSE` for an instrument with no live
  quote, whose order the engine would otherwise hold all day without
  sending.

#### Details

Errors: signals `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    parent_id <- answer[["parent_id"]]

    tryCatch(
      cat(answer[["outcome"]], "at", price, "as parent", parent_id, "\n"),
      finally = {
        print(idea$cancel_parent(parent_id)[["state"]])
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 0.97, 2)
        answer <- idea$buy_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        print(idea$cancel_order(order_id)[["outcome"]])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_limit_price()`

Sells at a price of your choosing, or better.

A limit sell never accepts less than the price given. It waits in the
market until someone buys at that price or higher, and it may never fill
at all.

UBI's order engine holds a `day` limit order that is not an after-market
order rather than resting it at a broker, and sends it only once the
other side of the book reaches the price, so an order that never fills
costs no order messages. Until then `place_order` answers with an
outcome of `armed` and a `parent_id` rather than an `order_id`, the
order is not in `orders` but in `parents`, and it is changed with
`modify_order(parent_id = ...)` and cancelled with `cancel_parent`.

The examples below, in order:

- Offer one Vodafone Idea share 3 per cent above the market as an
  intraday order, which the order engine holds until a buyer reaches the
  price, and cancel it.

- Send the offer to the broker at once with a tag, wait for it to rest
  in the order book, and cancel it.

#### Usage

    TradeableInstrument$sell_at_limit_price(
      price,
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      hold = TRUE
    )

#### Arguments

- `price`:

  The numeric limit price in rupees.

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `hold`:

  A logical that is `TRUE` to let UBI's order engine hold a `day` order
  until the other side of the book reaches the price, and `FALSE` to
  send it to a broker at once. An after-market order is always sent at
  once, whatever this says. Pass `FALSE` for an instrument with no live
  quote, whose order the engine would otherwise hold all day without
  sending.

#### Details

Errors: signals `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")

    price <- round(idea$last_price * 1.03, 2)
    answer <- idea$sell_at_limit_price(price = price, quantity = 1, product = "mis")
    tryCatch(
      {
        cat(
          answer[["outcome"]],
          "at",
          price,
          "as parent",
          answer[["parent_id"]],
          "\n"
        )
      },
      finally = {
        print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        price <- round(idea$last_price * 1.03, 2)
        answer <- idea$sell_at_limit_price(
          price = price,
          quantity = 1,
          product = "mis",
          tag = "examples",
          hold = FALSE
        )
        answers[[length(answers) + 1]] <- answer
        order_id <- answer[["order_id"]]
        cat(answer[["outcome"]], order_id, "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          open_orders <- idea$open_orders
          if (!is.null(open_orders)) {
            if (order_id %in% open_orders$order_id) {
              break
            }
          }
        }
        print(idea$cancel_order(order_id)[["outcome"]])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_best_bid_price()`

Buys patiently, joining the queue at the highest price anyone is
bidding.

This is the patient side of the pair. It prices the order alongside
everyone already waiting at the best price on its own side of the book,
so it saves the spread but only fills when the market comes to it.

The examples below, in order:

- Bid for one Vodafone Idea share at the best bid as an intraday order,
  then cancel it, closing any share that filled in the meantime.

- Send the same bid at the best bid as an immediate-or-cancel order,
  which the exchange cancels at once unless a seller is already there.

#### Usage

    TradeableInstrument$buy_at_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_best_bid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_best_offer_price()`

Buys at once, by crossing the spread to the lowest price anyone is
offering.

This is the aggressive side of the pair. It prices the order where the
other side of the market already is, so it fills immediately against
whoever is waiting there, and it pays the spread for that certainty.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the best offer as
  an immediate-or-cancel intraday order, then sell it straight back.

- Buy one share with a limit at the best offer as an ordinary day order
  with a tag, cancel it if it is still resting, and sell back whatever
  filled.

#### Usage

    TradeableInstrument$buy_at_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_best_offer_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_best_offer_price()`

Sells patiently, joining the queue at the lowest price anyone is
offering.

This is the patient side of the pair. It prices the order alongside
everyone already waiting at the best price on its own side of the book,
so it saves the spread but only fills when the market comes to it.

The examples below, in order:

- Offer one Vodafone Idea share at the best offer as an intraday short
  sale, then cancel it, buying back any share that sold in the meantime.

- Send the same offer at the best offer with a tag, so it can be picked
  out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_best_offer_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_best_bid_price()`

Sells at once, by crossing the spread to the highest price anyone is
bidding.

This is the aggressive side of the pair. It prices the order where the
other side of the market already is, so it fills immediately against
whoever is waiting there, and it pays the spread for that certainty.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the best
  bid as an immediate-or-cancel intraday order, then buy it straight
  back.

- Sell one share short with a limit at the best bid as an ordinary day
  order with a tag, cancel it if it is still resting, and buy back
  whatever filled.

#### Usage

    TradeableInstrument$sell_at_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_best_bid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_mid_price()`

Buys halfway between the best bid and the best offer.

The mid price sits inside the spread, where nobody is waiting, so the
order is better than joining its own side of the book and cheaper than
crossing to the other. It fills only if the market moves that far. UBI
works the midpoint out when it sends the order and rounds it to the
tick, down for a buy and up for a sell, so the order never crosses the
spread.

The examples below, in order:

- Bid for one Vodafone Idea share at the mid price as an intraday order,
  then cancel it, closing any share that filled in the meantime.

- Send the same bid at the mid price as an immediate-or-cancel order,
  which the exchange cancels at once unless a seller is already there.

#### Usage

    TradeableInstrument$buy_at_mid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_mid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_mid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_mid_price()`

Sells halfway between the best bid and the best offer.

The mid price sits inside the spread, where nobody is waiting, so the
order is better than joining its own side of the book and cheaper than
crossing to the other. It fills only if the market moves that far. UBI
works the midpoint out when it sends the order and rounds it to the
tick, down for a buy and up for a sell, so the order never crosses the
spread.

The examples below, in order:

- Offer one Vodafone Idea share at the mid price as an intraday short
  sale, then cancel it, buying back any share that sold in the meantime.

- Send the same offer at the mid price with a tag, so it can be picked
  out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_mid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_mid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_mid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_volume_weighted_average_price()`

Buys at the average price the day has traded at so far.

The volume weighted average price is where the day's business has
actually been done, which makes it a common benchmark to measure a fill
against. It has no relation to where the book is now, so the order may
cross the spread or sit far away from it. Not every broker reports it.
UBI reads it when it sends the order and rounds it to the tick.

The examples below, in order:

- Bid for one Vodafone Idea share at today's volume weighted average
  price as an intraday order, which may fill or rest, then cancel
  whatever rests and sell back whatever filled.

- Send the same bid at today's volume weighted average price as an
  immediate-or-cancel order, so nothing is left resting, and sell back
  anything that filled.

#### Usage

    TradeableInstrument$buy_at_volume_weighted_average_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_volume_weighted_average_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_volume_weighted_average_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_volume_weighted_average_price()`

Sells at the average price the day has traded at so far.

The volume weighted average price is where the day's business has
actually been done, which makes it a common benchmark to measure a fill
against. It has no relation to where the book is now, so the order may
cross the spread or sit far away from it. Not every broker reports it.
UBI reads it when it sends the order and rounds it to the tick.

The examples below, in order:

- Offer one Vodafone Idea share short at today's volume weighted average
  price as an intraday order, which may fill or rest, then cancel
  whatever rests and buy back whatever sold.

- Send the same offer at today's volume weighted average price as an
  immediate-or-cancel order, so nothing is left resting, and buy back
  anything that sold.

#### Usage

    TradeableInstrument$sell_at_volume_weighted_average_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_volume_weighted_average_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_volume_weighted_average_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_marketable_price()`

Buys now with a limit order priced at the best offer, the price it takes
to fill immediately.

This is what a market order has become in India: brokers convert an API
market order into a limit order with price protection, and some refuse
market orders outright. A marketable limit states the cap itself, so the
order fills at once up to that price and never beyond it. UBI reads the
best offer when it sends the order, and `buffer_percent` moves the cap
that far above it to reach deeper into the book. Pair it with
`validity = "ioc"` to cancel whatever cannot fill at once.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the best offer as
  an immediate-or-cancel intraday order, then sell it straight back.

- Reach half a per cent past the best offer, which still fills at the
  best price available but tolerates the book moving, and sell back what
  filled.

#### Usage

    TradeableInstrument$buy_at_marketable_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      buffer_percent = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `buffer_percent`:

  The numeric percentage to move the cap past the best offer, such as
  0.5, or `NULL` for no buffer. A cap too far from the market is refused
  by the exchange's price protection.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_marketable_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_marketable_price(
          quantity = 1,
          product = "mis",
          validity = "ioc",
          buffer_percent = 0.5
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_marketable_price()`

Sells now with a limit order priced at the best bid, the price it takes
to fill immediately.

This is what a market order has become in India: brokers convert an API
market order into a limit order with price protection, and some refuse
market orders outright. A marketable limit states the cap itself, so the
order fills at once up to that price and never beyond it. UBI reads the
best bid when it sends the order, and `buffer_percent` moves the cap
that far below it to reach deeper into the book. Pair it with
`validity = "ioc"` to cancel whatever cannot fill at once.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the best
  bid as an immediate-or-cancel intraday order, then buy it straight
  back.

- Reach half a per cent below the best bid, which still fills at the
  best price available but tolerates the book moving, and buy back what
  sold.

#### Usage

    TradeableInstrument$sell_at_marketable_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      buffer_percent = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

- `buffer_percent`:

  The numeric percentage to move the cap past the best bid, such as 0.5,
  or `NULL` for no buffer. A cap too far from the market is refused by
  the exchange's price protection.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_marketable_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_marketable_price(
          quantity = 1,
          product = "mis",
          validity = "ioc",
          buffer_percent = 0.5
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_last_price()`

Buys with a limit order at the price the instrument last traded at.

The last traded price is where the most recent deal was done, which may
be on either side of the book by the time the order arrives, so the
order may fill at once or rest. UBI reads it when it sends the order and
rounds it to the tick.

The examples below, in order:

- Bid for one Vodafone Idea share at the last traded price as an
  intraday order, which may fill or rest, then cancel whatever rests and
  sell back whatever filled.

- Send the same bid at the last traded price as an immediate-or-cancel
  order, so nothing is left resting, and sell back anything that filled.

#### Usage

    TradeableInstrument$buy_at_last_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_last_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_last_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_last_price()`

Sells with a limit order at the price the instrument last traded at.

The last traded price is where the most recent deal was done, which may
be on either side of the book by the time the order arrives, so the
order may fill at once or rest. UBI reads it when it sends the order and
rounds it to the tick.

The examples below, in order:

- Offer one Vodafone Idea share short at the last traded price as an
  intraday order, which may fill or rest, then cancel whatever rests and
  buy back whatever sold.

- Send the same offer at the last traded price as an immediate-or-cancel
  order, so nothing is left resting, and buy back anything that sold.

#### Usage

    TradeableInstrument$sell_at_last_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_last_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_last_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_second_best_bid_price()`

Buys at the second best price on the buy side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the second best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Bid for one Vodafone Idea share at the second best bid as an intraday
  order, then cancel it, closing any share that filled in the meantime.

- Send the same bid at the second best bid as an immediate-or-cancel
  order, which the exchange cancels at once unless a seller is already
  there.

#### Usage

    TradeableInstrument$buy_at_second_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_second_best_bid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_second_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_third_best_bid_price()`

Buys at the third best price on the buy side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the third best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Bid for one Vodafone Idea share at the third best bid as an intraday
  order, then cancel it, closing any share that filled in the meantime.

- Send the same bid at the third best bid as an immediate-or-cancel
  order, which the exchange cancels at once unless a seller is already
  there.

#### Usage

    TradeableInstrument$buy_at_third_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_third_best_bid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_third_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_fourth_best_bid_price()`

Buys at the fourth best price on the buy side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the fourth best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Bid for one Vodafone Idea share at the fourth best bid as an intraday
  order, then cancel it, closing any share that filled in the meantime.

- Send the same bid at the fourth best bid as an immediate-or-cancel
  order, which the exchange cancels at once unless a seller is already
  there.

#### Usage

    TradeableInstrument$buy_at_fourth_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fourth_best_bid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fourth_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_fifth_best_bid_price()`

Buys at the fifth best price on the buy side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the fifth best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Bid for one Vodafone Idea share at the fifth best bid as an intraday
  order, then cancel it, closing any share that filled in the meantime.

- Send the same bid at the fifth best bid as an immediate-or-cancel
  order, which the exchange cancels at once unless a seller is already
  there.

#### Usage

    TradeableInstrument$buy_at_fifth_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fifth_best_bid_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fifth_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_second_best_bid_price()`

Sells at the second best price on the buy side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the second. Expect a larger fill at a worse average price.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the second
  best bid as an immediate-or-cancel intraday order, then buy it
  straight back.

- Sell one share short with a limit at the second best bid as an
  ordinary day order with a tag, cancel it if it is still resting, and
  buy back whatever filled.

#### Usage

    TradeableInstrument$sell_at_second_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_second_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_second_best_bid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_third_best_bid_price()`

Sells at the third best price on the buy side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the third. Expect a larger fill at a worse average price.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the third
  best bid as an immediate-or-cancel intraday order, then buy it
  straight back.

- Sell one share short with a limit at the third best bid as an ordinary
  day order with a tag, cancel it if it is still resting, and buy back
  whatever filled.

#### Usage

    TradeableInstrument$sell_at_third_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_third_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_third_best_bid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_fourth_best_bid_price()`

Sells at the fourth best price on the buy side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the fourth. Expect a larger fill at a worse average price.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the fourth
  best bid as an immediate-or-cancel intraday order, then buy it
  straight back.

- Sell one share short with a limit at the fourth best bid as an
  ordinary day order with a tag, cancel it if it is still resting, and
  buy back whatever filled.

#### Usage

    TradeableInstrument$sell_at_fourth_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fourth_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fourth_best_bid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_fifth_best_bid_price()`

Sells at the fifth best price on the buy side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the fifth. Expect a larger fill at a worse average price.

The examples below, in order:

- Sell one Vodafone Idea share short at once with a limit at the fifth
  best bid as an immediate-or-cancel intraday order, then buy it
  straight back.

- Sell one share short with a limit at the fifth best bid as an ordinary
  day order with a tag, cancel it if it is still resting, and buy back
  whatever filled.

#### Usage

    TradeableInstrument$sell_at_fifth_best_bid_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fifth_best_bid_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fifth_best_bid_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_second_best_offer_price()`

Buys at the second best price on the sell side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the second. Expect a larger fill at a worse average price.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the second best
  offer as an immediate-or-cancel intraday order, then sell it straight
  back.

- Buy one share with a limit at the second best offer as an ordinary day
  order with a tag, cancel it if it is still resting, and sell back
  whatever filled.

#### Usage

    TradeableInstrument$buy_at_second_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_second_best_offer_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_second_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_third_best_offer_price()`

Buys at the third best price on the sell side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the third. Expect a larger fill at a worse average price.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the third best
  offer as an immediate-or-cancel intraday order, then sell it straight
  back.

- Buy one share with a limit at the third best offer as an ordinary day
  order with a tag, cancel it if it is still resting, and sell back
  whatever filled.

#### Usage

    TradeableInstrument$buy_at_third_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_third_best_offer_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_third_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_fourth_best_offer_price()`

Buys at the fourth best price on the sell side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the fourth. Expect a larger fill at a worse average price.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the fourth best
  offer as an immediate-or-cancel intraday order, then sell it straight
  back.

- Buy one share with a limit at the fourth best offer as an ordinary day
  order with a tag, cancel it if it is still resting, and sell back
  whatever filled.

#### Usage

    TradeableInstrument$buy_at_fourth_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fourth_best_offer_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fourth_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$buy_at_fifth_best_offer_price()`

Buys at the fifth best price on the sell side of the book.

This is more aggressive than pricing at the best level, because the
order reaches past the front of the other side and can sweep every level
down to the fifth. Expect a larger fill at a worse average price.

The examples below, in order:

- Buy one Vodafone Idea share at once with a limit at the fifth best
  offer as an immediate-or-cancel intraday order, then sell it straight
  back.

- Buy one share with a limit at the fifth best offer as an ordinary day
  order with a tag, cancel it if it is still resting, and sell back
  whatever filled.

#### Usage

    TradeableInstrument$buy_at_fifth_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fifth_best_offer_price(
          quantity = 1,
          product = "mis",
          validity = "ioc"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$buy_at_fifth_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_second_best_offer_price()`

Sells at the second best price on the sell side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the second best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Offer one Vodafone Idea share at the second best offer as an intraday
  short sale, then cancel it, buying back any share that sold in the
  meantime.

- Send the same offer at the second best offer with a tag, so it can be
  picked out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_second_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_second_best_offer_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_second_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_third_best_offer_price()`

Sells at the third best price on the sell side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the third best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Offer one Vodafone Idea share at the third best offer as an intraday
  short sale, then cancel it, buying back any share that sold in the
  meantime.

- Send the same offer at the third best offer with a tag, so it can be
  picked out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_third_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_third_best_offer_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_third_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_fourth_best_offer_price()`

Sells at the fourth best price on the sell side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the fourth best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Offer one Vodafone Idea share at the fourth best offer as an intraday
  short sale, then cancel it, buying back any share that sold in the
  meantime.

- Send the same offer at the fourth best offer with a tag, so it can be
  picked out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_fourth_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fourth_best_offer_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fourth_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$sell_at_fifth_best_offer_price()`

Sells at the fifth best price on the sell side of the book.

This is more patient than pricing at the best level, because the order
waits behind everyone at the fifth best price on its own side. It fills
less often, and at a better price when it does.

The examples below, in order:

- Offer one Vodafone Idea share at the fifth best offer as an intraday
  short sale, then cancel it, buying back any share that sold in the
  meantime.

- Send the same offer at the fifth best offer with a tag, so it can be
  picked out of the order book later, and cancel it.

#### Usage

    TradeableInstrument$sell_at_fifth_best_offer_price(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity in underlying units, not lots.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the order
  with, or `NULL`.

#### Details

Errors: signals `ServiceUnavailableError` when UBI could not work the
price out, because there is no live quote, the order book is not that
deep or no tick size is agreed, which is what the book looks like
outside market hours; `BadRequestError` when a field is invalid;
`OrderRejectedError` when the broker refused the order;
`UnifiedBrokerInterfaceError` when any other failure reported by, or on
the way to, UBI.

#### Returns

The named list `place_order` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fifth_best_offer_price(
          quantity = 1,
          product = "mis"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        answer <- idea$sell_at_fifth_best_offer_price(
          quantity = 1,
          product = "mis",
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- answer
        cat(
          answer[["outcome"]],
          answer[["broker"]],
          answer[["order_id"]],
          "\n"
        )
        Sys.sleep(3)
        orders <- idea$orders
        mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
        print(mine[, c(
          "status",
          "price",
          "filled_quantity"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$add_to_position()`

Makes an existing position bigger, or opens a new one.

The direction follows the position you already hold: a long position is
added to by buying and a short one by selling, so `transaction_type` is
needed only when you hold nothing yet. Holding nothing also means there
is no position to read a product from, so `product` is needed then too.

Only positions held under `cnc`, `mis` and `nrml` are visible here. UBI
also reports positions under `margin_trading`, `cover` and `bracket`,
which come from order kinds it cannot send, and those are ignored as
though they were not there.

The examples below, in order:

- Add one Vodafone Idea share to the intraday position with a limit a
  per cent above the market, so it fills at once even at a broker that
  refuses market orders, then add a second without naming a side, and
  sell both back until the position is where it started.

- Show that naming a side against the position held is refused, because
  a sell would reduce a long position rather than add to it.

#### Usage

    TradeableInstrument$add_to_position(
      quantity,
      product = NULL,
      transaction_type = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer quantity to add, in underlying units and always positive,
  whichever way the position points.

- `product`:

  The character product of the position to add to, `"cnc"`, `"mis"` or
  `"nrml"`, or `NULL` when only one position is held.

- `transaction_type`:

  The character direction to open in, `"buy"` or `"sell"`, used only
  when no position is held yet.

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals `PositionError` when several positions are held and none
was named, the direction given contradicts the position held, or nothing
is held and no direction and product were given; and a
`UnifiedBrokerInterfaceError` subclass for any failure reported by, or
on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$add_to_position(
          quantity = 1,
          product = "mis",
          transaction_type = "buy",
          price = round(idea$last_price * 1.01, 2)
        )
        answers[[length(answers) + 1]] <- opened
        cat("Opened:", opened[["outcome"]], "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        added <- idea$add_to_position(
          quantity = 1,
          product = "mis",
          price = round(idea$last_price * 1.01, 2)
        )
        answers[[length(answers) + 1]] <- added
        cat("Added:", added[["outcome"]], "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 2) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        tryCatch(
          {
            idea$add_to_position(
              quantity = 1,
              product = "mis",
              transaction_type = "sell"
            )
          },
          PositionError = function(error) {
            cat("Refused:", conditionMessage(error), "\n")
          }
        )
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$reduce_position()`

Makes an existing position smaller, without turning it around.

UBI works the direction out from the position when it sends the order: a
long position is reduced by selling and a short one by buying. It also
caps the order at what is held, so asking for more than the position
closes the whole position and never opens a new one the other way round.

Only positions held under `cnc`, `mis` and `nrml` are visible here, for
the reason given on `add_to_position()`. When no product is named, the
positions are read once to find the only one held; when one is named,
nothing is read here and UBI reads the positions itself.

The examples below, in order:

- Buy two Vodafone Idea shares intraday, reduce the position by one with
  a limit a per cent below the market, and sell the other back.

- Ask to reduce a one-share intraday position by five, which UBI caps at
  what is held, so the position closes and never turns short.

#### Usage

    TradeableInstrument$reduce_position(
      quantity,
      product = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `quantity`:

  The integer largest quantity to close, in underlying units and always
  positive, whichever way the position points.

- `product`:

  The character product of the position to reduce, `"cnc"`, `"mis"` or
  `"nrml"`, or `NULL` when only one position is held.

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals `PositionError` when no product was named and nothing is
held, several positions are held, or the product named is not `cnc`,
`mis` or `nrml`; `ConflictError` when the product named is not held in
this instrument; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$buy_at_marketable_price(quantity = 2, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 2) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        reduced <- idea$reduce_position(
          quantity = 1,
          product = "mis",
          price = round(idea$last_price * 0.99, 2)
        )
        answers[[length(answers) + 1]] <- reduced
        cat("Reduced:", reduced[["outcome"]], "\n")
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    if (start != 0) {
      stop("An intraday IDEA position is already open.")
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        reduced <- idea$reduce_position(
          quantity = 5,
          product = "mis",
          price = round(idea$last_price * 0.99, 2)
        )
        answers[[length(answers) + 1]] <- reduced
        cat("Reduced:", reduced[["outcome"]], "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$liquidate_position()`

Closes one position in this instrument completely.

UBI reads the position when it sends the order and closes the whole of
it, so a long position is sold and a short one is bought back.

Only positions held under `cnc`, `mis` and `nrml` are visible here, for
the reason given on `add_to_position()`. When no product is named, the
positions are read once to find the only one held; when one is named,
nothing is read here and UBI reads the positions itself.

The examples below, in order:

- Buy one Vodafone Idea share intraday and close the whole position,
  with a limit a per cent below the market because some brokers refuse
  market orders from an API.

- Close a short intraday position by buying it back, which UBI works out
  from the position, with a tag on the closing order.

#### Usage

    TradeableInstrument$liquidate_position(
      product = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `product`:

  The character product of the position to close, `"cnc"`, `"mis"` or
  `"nrml"`, or `NULL` when only one position is held.

- `price`:

  The numeric limit price in rupees, or `NULL` to send a market order.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character label of up to twenty letters and digits for the order, or
  `NULL`.

#### Details

Errors: signals `PositionError` when no product was named and nothing is
held, several positions are held, or the product named is not `cnc`,
`mis` or `nrml`; `ConflictError` when the product named is not held in
this instrument; and another `UnifiedBrokerInterfaceError` subclass for
any other failure reported by, or on the way to, UBI.

#### Returns

The named list `place_order()` returns, holding `broker`, `order_id`,
`outcome` and the rest.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    if (start != 0) {
      stop("An intraday IDEA position is already open.")
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        closed <- idea$liquidate_position(
          product = "mis",
          price = round(idea$last_price * 0.99, 2)
        )
        answers[[length(answers) + 1]] <- closed
        cat("Closed:", closed[["outcome"]], closed[["order_id"]], "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    if (start != 0) {
      stop("An intraday IDEA position is already open.")
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start - 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        closed <- idea$liquidate_position(
          product = "mis",
          price = round(idea$last_price * 1.01, 2),
          tag = "examples"
        )
        answers[[length(answers) + 1]] <- closed
        cat("Bought back:", closed[["outcome"]], closed[["order_id"]], "\n")
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$liquidate_all_positions()`

Closes every position this instrument holds, under every product.

The positions are read once to list them, and each is then closed with
its own order, which UBI sizes and directs from the position when it
sends it. Every one is attempted even when an earlier one fails, so a
single refusal does not leave the rest open. A position held under a
product UBI cannot send an order for, which is `margin_trading`, `cover`
or `bracket`, is reported as ignored rather than passed over in silence,
and has to be closed at the broker directly.

The examples below, in order:

- Buy one Vodafone Idea share intraday, then close every position the
  share holds, under every product, and print what was done.

- Sell one share short intraday, close every position the share holds
  with tagged orders, and list any that could not be closed through UBI.

#### Usage

    TradeableInstrument$liquidate_all_positions(
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    )

#### Arguments

- `price`:

  The numeric limit price in rupees for every order, or `NULL` to send
  market orders.

- `validity`:

  The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use
  `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the orders as after-market orders.

- `tag`:

  A character label of up to twenty letters and digits for the orders,
  or `NULL`.

#### Details

Errors: signals `BrokerError` when no broker's positions could be read;
`ServiceUnavailableError` when UBI's positions document is missing or
too old to serve; and another `UnifiedBrokerInterfaceError` subclass
when the positions could not be read for any other reason. A failure to
close one position is reported in the frame instead.

#### Returns

A `data.frame` with one row per position, holding `product`,
`order_product`, `quantity`, `closed`, `order_id` and `error`, or `NULL`
when this instrument holds no position at all.

#### Examples

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    if (start != 0) {
      stop("An intraday IDEA position is already open.")
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start + 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        outcomes <- idea$liquidate_all_positions(
          price = round(idea$last_price * 0.99, 2)
        )
        print(outcomes)
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    start <- 0
    positions <- idea$net_positions
    if (!is.null(positions)) {
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      start <- sum(intraday$quantity)
    }
    if (start != 0) {
      stop("An intraday IDEA position is already open.")
    }
    answers <- list()
    tryCatch(
      {
        opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
        answers[[length(answers) + 1]] <- opened
        for (attempt in seq_len(30)) {
          Sys.sleep(1)
          positions <- idea$net_positions
          intraday <- positions[positions$product == "intraday", , drop = FALSE]
          if (sum(intraday$quantity) == start - 1) {
            break
          }
        }
        cat("Intraday quantity:", sum(intraday$quantity), "\n")
        outcomes <- idea$liquidate_all_positions(
          price = round(idea$last_price * 1.01, 2),
          tag = "examples"
        )
        print(outcomes[, c(
          "product",
          "quantity",
          "closed",
          "order_id"
        )])
        print(outcomes[!outcomes$closed, , drop = FALSE][, c(
          "product",
          "error"
        )])
      },
      finally = {
        for (answer in answers) {
          for (attempt in seq_len(3)) {
            caught_error <- tryCatch(
              {
                cancelled <- idea$cancel_parent(answer[["parent_id"]])
                NULL
              },
              ConflictError = function(error) error,
              UnifiedBrokerInterfaceError = function(error) error
            )
            if (inherits(caught_error, "ConflictError")) {
              cat("The order had already finished.", "\n")
              break
            } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
              error <- caught_error
              cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
              Sys.sleep(2)
              next
            }
            if (cancelled[["state"]] == "cancelled") {
              cat("Cancelled what was still waiting.", "\n")
              break
            }
            Sys.sleep(2)
          }
        }
        quantity <- NA
        for (attempt in seq_len(6)) {
          Sys.sleep(5)
          caught_error <- tryCatch(
            {
              quantity <- 0
              positions <- idea$net_positions
              if (!is.null(positions)) {
                intraday <- positions[positions$product == "intraday", , drop = FALSE]
                quantity <- sum(intraday$quantity)
              }
              if (quantity == start) {
                break
              }
              difference <- as.integer(quantity - start)
              if (difference > 0) {
                price <- round(idea$last_price * 0.99, 2)
              } else {
                price <- round(idea$last_price * 1.01, 2)
              }
              if ((difference > 0) == (quantity > 0)) {
                idea$reduce_position(
                  quantity = abs(difference),
                  product = "mis",
                  price = price
                )
              } else if (difference > 0) {
                idea$sell_at_limit_price(
                  price = price,
                  quantity = difference,
                  product = "mis",
                  hold = FALSE
                )
              } else {
                idea$buy_at_limit_price(
                  price = price,
                  quantity = -difference,
                  product = "mis",
                  hold = FALSE
                )
              }
              NULL
            },
            UnifiedBrokerInterfaceError = function(error) error
          )
          if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
            error <- caught_error
            quantity <- NA
            cat("Closing failed, trying again:", conditionMessage(error), "\n")
          }
        }
        if (is.na(quantity) || quantity != start) {
          stop(sprintf("The position is %s, not %s.", quantity, start))
        }
        cat("The intraday position is back at", start, "\n")
      }
    )

------------------------------------------------------------------------

### `TradeableInstrument$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TradeableInstrument$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)
infosys$best_bid
infosys$bid_offer_spread
answer <- infosys$buy_at_best_bid_price(quantity = 1, product = "mis")
infosys$cancel_open_orders()

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

for (level in infosys$bids) {
  cat(level[["price"]], level[["quantity"]], level[["orders"]], "\n")
}

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

total_quantity <- 0
for (level in reliance$bids) {
  total_quantity <- total_quantity + level[["quantity"]]
}
cat(
  sprintf(
    "%s levels bid for %s shares",
    length(reliance$bids),
    total_quantity
  ),
  "\n"
)

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

for (level in infosys$offers) {
  cat(level[["price"]], level[["quantity"]], level[["orders"]], "\n")
}

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

offered <- 0
for (level in reliance$offers) {
  offered <- offered + level[["quantity"]]
}
bid <- 0
for (level in reliance$bids) {
  bid <- bid + level[["quantity"]]
}
cat(sprintf("Offered %s against bid %s", offered, bid), "\n")

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

best_bid <- infosys$best_bid
if (is.null(best_bid)) {
  cat("Nobody is bidding.", "\n")
} else {
  cat(
    sprintf(
      "%s shares bid at %s",
      best_bid[["quantity"]],
      best_bid[["price"]]
    ),
    "\n"
  )
}

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

best_bid <- reliance$best_bid
last_price <- reliance$last_price
if (is.null(best_bid) || is.null(last_price)) {
  cat("The book or the last price is empty.", "\n")
} else {
  cat(
    sprintf(
      "The best bid is %.2f below",
      last_price - best_bid[["price"]]
    ),
    "\n"
  )
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

best_offer <- infosys$best_offer
if (is.null(best_offer)) {
  cat("Nobody is offering.", "\n")
} else {
  cat(
    sprintf(
      "%s shares offered at %s",
      best_offer[["quantity"]],
      best_offer[["price"]]
    ),
    "\n"
  )
}

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

wanted_quantity <- 10
best_offer <- reliance$best_offer
if (is.null(best_offer)) {
  cat("Nobody is offering.", "\n")
} else if (best_offer[["quantity"]] < wanted_quantity) {
  cat("The best offer is too small for 10 shares.", "\n")
} else {
  cat(
    sprintf("Cost: Rs %.2f", best_offer[["price"]] * wanted_quantity),
    "\n"
  )
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$bid_offer_spread)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

spread <- reliance$bid_offer_spread
if (is.null(spread)) {
  cat("One side of the book is empty.", "\n")
} else {
  ticks <- round(spread / as.numeric(reliance$tick_size))
  cat(
    sprintf("The spread is %.2f rupees, or %s ticks", spread, ticks),
    "\n"
  )
}

symbols <- c(
  "INFY",
  "TCS",
  "HDFCBANK"
)
for (symbol in symbols) {
  share <- TradeableInstrument$new(
    exchange = "nse",
    segment = "equities",
    symbol = symbol
  )
  spread <- share$bid_offer_spread
  last_price <- share$last_price
  if (is.null(spread) || is.null(last_price)) {
    cat(sprintf("%s: no two-sided book", symbol), "\n")
  } else {
    cat(sprintf("%s: %.4f%%", symbol, spread / last_price * 100), "\n")
  }
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$mid_price)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

mid_price <- reliance$mid_price
last_price <- reliance$last_price
if (is.null(mid_price) || is.null(last_price)) {
  cat("The book is one-sided or there is no last price.", "\n")
} else if (last_price >= mid_price) {
  cat(
    sprintf("Last %s is at or above mid %s", last_price, mid_price),
    "\n"
  )
} else {
  cat(sprintf("Last %s is below mid %s", last_price, mid_price), "\n")
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$volume_weighted_average_price)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

average_price <- reliance$volume_weighted_average_price
last_price <- reliance$last_price
if (is.null(average_price) || is.null(last_price)) {
  cat("The average price or the last price is unknown.", "\n")
} else if (last_price > average_price) {
  cat(
    sprintf("Above the average: %s > %s", last_price, average_price),
    "\n"
  )
} else {
  cat(
    sprintf(
      "At or below the average: %s <= %s",
      last_price,
      average_price
    ),
    "\n"
  )
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$last_quantity)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

last_quantity <- reliance$last_quantity
last_price <- reliance$last_price
if (is.null(last_quantity) || is.null(last_price)) {
  cat("The last trade is unknown.", "\n")
} else {
  cat(
    sprintf("Rs %.2f changed hands last", last_quantity * last_price),
    "\n"
  )
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$total_traded_volume)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)

candles <- reliance$prices(days = 30)
average_volume <- mean(candles$volume)
today_volume <- reliance$total_traded_volume
if (is.null(today_volume)) {
  cat("Today's volume is unknown.", "\n")
} else {
  cat(
    sprintf("Today is %.2f times average", today_volume / average_volume),
    "\n"
  )
}

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

cat(format(nifty_future), nifty_future$open_interest, "\n")

expiries <- EquityIndexFutures$expiries(
  exchange = "nse",
  underlying_symbol = "NIFTY"
)
nifty_future <- EquityIndexFutures$new(
  exchange = "nse",
  underlying_symbol = "NIFTY",
  expiry_date = expiries[[1]]
)

open_interest <- nifty_future$open_interest
if (is.null(open_interest) || is.null(nifty_future$lot_size)) {
  cat("The open interest or the lot size is unknown.", "\n")
} else {
  cat(
    sprintf("%s lots are open", open_interest %/% nifty_future$lot_size),
    "\n"
  )
}

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$open_interest)

infosys <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "INFY"
)

print(infosys$last_trade_time)

reliance <- TradeableInstrument$new(
  exchange = "nse",
  segment = "equities",
  symbol = "RELIANCE"
)
last_trade_time <- reliance$last_trade_time
if (is.null(last_trade_time)) {
  cat("The broker does not report the last trade time.", "\n")
} else {
  now <- Sys.time()
  seconds <- as.numeric(difftime(now, last_trade_time, units = "secs"))
  cat(sprintf("Last traded %.0f seconds ago", seconds), "\n")
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

parents <- idea$parents
if (is.null(parents)) {
  cat("No parent is open in IDEA.", "\n")
} else {
  print(parents[, c(
    "parent_order_id",
    "synthetic_type",
    "state"
  )])
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
tryCatch(
  {
    parents <- idea$parents
    mine <- parents[parents$parent_order_id == answer[["parent_id"]], , drop = FALSE]
    print(mine[, c(
      "parent_order_id",
      "synthetic_type",
      "state"
    )])
  },
  finally = {
    print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

orders <- idea$orders
if (is.null(orders)) {
  cat("No orders in IDEA today.", "\n")
} else {
  columns <- c(
    "order_id",
    "status",
    "transaction_type",
    "quantity",
    "price"
  )
  print(orders[, columns])
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

orders <- idea$orders
if (is.null(orders)) {
  cat("No orders in IDEA today.", "\n")
} else {
  print(sort(table(orders$status), decreasing = TRUE))
  expired <- orders[orders$status == "EXPIRED", , drop = FALSE]
  cat(nrow(expired), "expired", "\n")
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

orders <- idea$orders
if (is.null(orders)) {
  cat("No orders in IDEA today.", "\n")
} else {
  from_engine <- orders[!is.na(orders$engine_parent_id), , drop = FALSE]
  cat(
    nrow(from_engine),
    "of",
    nrow(orders),
    "orders came from a parent",
    "\n"
  )
  print(sort(table(from_engine$leg_role), decreasing = TRUE))
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

print(idea$open_orders)

infosys <- Equity$new(exchange = "nse", symbol = "INFY")
open_orders <- infosys$open_orders
if (is.null(open_orders)) {
  cat("Nothing is waiting in the market for INFY.", "\n")
} else {
  open_orders$remaining <- open_orders$quantity - open_orders$filled_quantity
  print(tapply(open_orders$remaining, open_orders$transaction_type, sum))
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

completed <- idea$completed_orders
if (is.null(completed)) {
  cat("Nothing filled in IDEA today.", "\n")
} else {
  print(completed[, c(
    "order_id",
    "transaction_type",
    "average_price"
  )])
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

completed <- idea$completed_orders
if (is.null(completed)) {
  cat("Nothing filled in IDEA today.", "\n")
} else {
  for (side in c(
    "BUY",
    "SELL"
  )) {
    rows <- completed[toupper(completed$transaction_type) == side, , drop = FALSE]
    if (nrow(rows) == 0) {
      next
    }
    spent <- sum(rows$average_price * rows$filled_quantity)
    quantity <- sum(rows$filled_quantity)
    cat(side, quantity, "at", round(spent / quantity, 4), "\n")
  }
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

rejected <- idea$rejected_orders
if (is.null(rejected)) {
  cat("Nothing was refused in IDEA today.", "\n")
} else {
  for (row in FrameBuilder$new()$rows(rejected)) {
    cat(row[["order_id"]], row[["broker"]], row[["status_message"]], "\n")
  }
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

rejected <- idea$rejected_orders
if (is.null(rejected)) {
  cat("Nothing was refused in IDEA today.", "\n")
} else {
  print(sort(table(rejected$broker), decreasing = TRUE))
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

cancelled <- idea$cancelled_orders
if (is.null(cancelled)) {
  cat("Nothing was cancelled in IDEA today.", "\n")
} else {
  print(cancelled[, c(
    "order_id",
    "broker",
    "price",
    "order_timestamp"
  )])
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

cancelled <- idea$cancelled_orders
if (is.null(cancelled)) {
  cat("Nothing was cancelled in IDEA today.", "\n")
} else {
  partly_filled <- cancelled[cancelled$filled_quantity > 0, , drop = FALSE]
  cat(
    nrow(partly_filled),
    "of",
    nrow(cancelled),
    "had partly filled",
    "\n"
  )
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

trades <- idea$trades
if (is.null(trades)) {
  cat("No trades in IDEA today.", "\n")
} else {
  columns <- c(
    "trade_id",
    "order_id",
    "transaction_type",
    "quantity",
    "price"
  )
  print(trades[, columns])
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

trades <- idea$trades
if (is.null(trades)) {
  cat("No trades in IDEA today.", "\n")
} else {
  totals <- tapply(trades$value, trades$transaction_type, sum)
  print(totals)
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

positions <- idea$net_positions
if (is.null(positions)) {
  cat("Nothing is held in IDEA.", "\n")
} else {
  print(positions[, c(
    "product",
    "quantity",
    "average_price",
    "last_price"
  )])
}

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
positions <- reliance$net_positions
if (is.null(positions)) {
  cat("Nothing is held in RELIANCE.", "\n")
} else {
  for (row in FrameBuilder$new()$rows(positions)) {
    if (row[["quantity"]] > 0) {
      cat(row[["product"]], "long", row[["quantity"]], "\n")
    } else if (row[["quantity"]] < 0) {
      cat(row[["product"]], "short", -row[["quantity"]], "\n")
    } else {
      cat(row[["product"]], "flat, closed today", "\n")
    }
  }
}

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

print(idea$day_positions)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

day_positions <- idea$day_positions
net_positions <- idea$net_positions
day_count <- 0
if (!is.null(day_positions)) {
  day_count <- nrow(day_positions)
}
net_count <- 0
if (!is.null(net_positions)) {
  net_count <- nrow(net_positions)
}
cat(
  sprintf("%s day rows and %s net rows", day_count, net_count),
  "\n"
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

print(idea$positions_value)

symbols <- c(
  "IDEA",
  "RELIANCE",
  "INFY"
)
total <- 0.0
for (symbol in symbols) {
  share <- Equity$new(exchange = "nse", symbol = symbol)
  value <- share$positions_value
  cat(symbol, value, "\n")
  if (!is.null(value)) {
    total <- total + value
  }
}
cat(sprintf("Total: Rs %.2f", total), "\n")

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

print(idea$positions_pnl)

reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
pnl <- reliance$positions_pnl
if (is.null(pnl)) {
  cat("Nothing is held in RELIANCE.", "\n")
} else if (pnl[["total"]] >= 0) {
  cat(
    sprintf(
      "Up Rs %s, of which Rs %s is booked",
      pnl[["total"]],
      pnl[["realized"]]
    ),
    "\n"
  )
} else {
  cat(
    sprintf(
      "Down Rs %s, of which Rs %s is booked",
      -pnl[["total"]],
      pnl[["realized"]]
    ),
    "\n"
  )
}
} # }

## ------------------------------------------------
## Method `TradeableInstrument$place_order()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")

price <- round(idea$last_price * 0.97, 2)
answer <- idea$place_order(
  transaction_type = "buy",
  order_type = "limit",
  quantity = 1,
  product = "cnc",
  price = price,
  dry_run = TRUE
)
print(answer)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

price <- round(idea$last_price * 0.97, 2)
answer <- idea$place_order(
  transaction_type = "buy",
  order_type = "limit",
  quantity = 1,
  product = "cnc",
  price = price
)
tryCatch(
  {
    cat(
      answer[["outcome"]],
      answer[["parent_id"]],
      answer[["order_id"]],
      "\n"
    )
  },
  finally = {
    print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

answer <- idea$place_order(
  transaction_type = "buy",
  order_type = "limit",
  quantity = 1,
  product = "mis",
  price_reference = list(
    kind = "bid_level",
    level = 3
  ),
  dry_run = TRUE
)
print(answer)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$modify_order()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

tryCatch(
  {
    new_price <- round(idea$last_price * 0.96, 2)
    changed <- idea$modify_order(parent_id = parent_id, price = new_price)
    cat(changed[["outcome"]], changed[["price"]], changed[["held"]], "\n")
  },
  finally = {
    print(idea$cancel_parent(parent_id)[["state"]])
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    changed <- idea$modify_order(
      order_id = order_id,
      price = round(price - 0.01, 2)
    )
    cat(changed[["broker"]], changed[["outcome"]], "\n")
    print(idea$cancel_order(order_id)[["outcome"]])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$cancel_order()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    cancelled <- idea$cancel_order(order_id)
    cat(cancelled[["broker"]], cancelled[["outcome"]], "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 1.03, 2)
    answer <- idea$sell_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    print(idea$cancel_order(order_id, dry_run = TRUE))
    print(idea$cancel_order(order_id)[["outcome"]])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$cancel_open_orders()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    held <- idea$buy_at_limit_price(
      price = round(idea$last_price * 0.97, 2),
      quantity = 1,
      product = "cnc"
    )
    answers[[length(answers) + 1]] <- held
    price <- round(idea$last_price * 0.96, 2)
    answer <- idea$buy_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    outcomes <- idea$cancel_open_orders()
    print(outcomes[, c(
      "parent_id",
      "order_id",
      "cancelled",
      "error"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")

last_price <- idea$last_price
idea$buy_at_limit_price(
  price = round(last_price * 0.97, 2),
  quantity = 1,
  product = "mis"
)
idea$sell_at_limit_price(
  price = round(last_price * 1.03, 2),
  quantity = 1,
  product = "mis"
)
outcomes <- idea$cancel_open_orders()
cat(nrow(outcomes), "cancelled:", outcomes$cancelled, "\n")
cat("Open parents left:", "\n")
print(idea$parents)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$parent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

tryCatch(
  {
    held <- idea$parent(parent_id)
    cat(held[["synthetic_type"]], held[["state"]], "\n")
    print(held[["body"]])
  },
  finally = {
    idea$cancel_parent(parent_id)
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

idea$cancel_parent(parent_id)
print(idea$parent(parent_id)[["state"]])
} # }

## ------------------------------------------------
## Method `TradeableInstrument$cancel_parent()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

cancelled <- idea$cancel_parent(parent_id)
cat(cancelled[["state"]], cancelled[["synthetic_type"]], "\n")
print(cancelled[["cancelled_legs"]])

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

idea$cancel_parent(parent_id)
tryCatch(
  idea$cancel_parent(parent_id),
  ConflictError = function(error) {
    cat("Refused:", conditionMessage(error), "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$parent_orders()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

tryCatch(
  print(idea$parent_orders(parent_id)),
  finally = {
    idea$cancel_parent(parent_id)
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    legs <- idea$parent_orders(answer[["parent_id"]])
    print(legs[, c(
      "order_id",
      "leg_role",
      "status",
      "price"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$parent_trades()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

tryCatch(
  print(idea$parent_trades(parent_id)),
  finally = {
    idea$cancel_parent(parent_id)
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    bought <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- bought
    Sys.sleep(3)
    print(idea$parent_trades(bought[["parent_id"]]))
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_market_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opening <- idea$buy_at_market_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- opening
    cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "filled_quantity",
      "average_price"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opening <- idea$buy_at_market_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- opening
    cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "filled_quantity",
      "average_price"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    caught_error <- tryCatch(
      {
        opening <- idea$buy_at_market_price(
          quantity = 1,
          product = "mis",
          as_marketable_limit = FALSE
        )
        NULL
      },
      OrderRejectedError = function(error) error
    )
    if (inherits(caught_error, "OrderRejectedError")) {
      error <- caught_error
      cat(
        "The broker refused a real market order:",
        conditionMessage(error),
        "\n"
      )
      opening <- NULL
    }
    if (!is.null(opening)) {
      answers[[length(answers) + 1]] <- opening
      cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
      Sys.sleep(3)
      orders <- idea$orders
      mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
      print(mine[, c(
        "status",
        "filled_quantity",
        "average_price"
      )])
    }
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_market_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opening <- idea$sell_at_market_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- opening
    cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "filled_quantity",
      "average_price"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opening <- idea$sell_at_market_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- opening
    cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "filled_quantity",
      "average_price"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    caught_error <- tryCatch(
      {
        opening <- idea$sell_at_market_price(
          quantity = 1,
          product = "mis",
          as_marketable_limit = FALSE
        )
        NULL
      },
      OrderRejectedError = function(error) error
    )
    if (inherits(caught_error, "OrderRejectedError")) {
      error <- caught_error
      cat(
        "The broker refused a real market order:",
        conditionMessage(error),
        "\n"
      )
      opening <- NULL
    }
    if (!is.null(opening)) {
      answers[[length(answers) + 1]] <- opening
      cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
      Sys.sleep(3)
      orders <- idea$orders
      mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
      print(mine[, c(
        "status",
        "filled_quantity",
        "average_price"
      )])
    }
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_limit_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
price <- round(idea$last_price * 0.97, 2)
answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
parent_id <- answer[["parent_id"]]

tryCatch(
  cat(answer[["outcome"]], "at", price, "as parent", parent_id, "\n"),
  finally = {
    print(idea$cancel_parent(parent_id)[["state"]])
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 0.97, 2)
    answer <- idea$buy_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    print(idea$cancel_order(order_id)[["outcome"]])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_limit_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")

price <- round(idea$last_price * 1.03, 2)
answer <- idea$sell_at_limit_price(price = price, quantity = 1, product = "mis")
tryCatch(
  {
    cat(
      answer[["outcome"]],
      "at",
      price,
      "as parent",
      answer[["parent_id"]],
      "\n"
    )
  },
  finally = {
    print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    price <- round(idea$last_price * 1.03, 2)
    answer <- idea$sell_at_limit_price(
      price = price,
      quantity = 1,
      product = "mis",
      tag = "examples",
      hold = FALSE
    )
    answers[[length(answers) + 1]] <- answer
    order_id <- answer[["order_id"]]
    cat(answer[["outcome"]], order_id, "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      open_orders <- idea$open_orders
      if (!is.null(open_orders)) {
        if (order_id %in% open_orders$order_id) {
          break
        }
      }
    }
    print(idea$cancel_order(order_id)[["outcome"]])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_best_bid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_best_offer_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_best_offer_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_best_bid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_mid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_mid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_mid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_mid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_mid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_mid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_volume_weighted_average_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_volume_weighted_average_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_volume_weighted_average_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_volume_weighted_average_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_volume_weighted_average_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_volume_weighted_average_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_marketable_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_marketable_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_marketable_price(
      quantity = 1,
      product = "mis",
      validity = "ioc",
      buffer_percent = 0.5
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_marketable_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_marketable_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_marketable_price(
      quantity = 1,
      product = "mis",
      validity = "ioc",
      buffer_percent = 0.5
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_last_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_last_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_last_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_last_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_last_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_last_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_second_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_second_best_bid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_second_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_third_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_third_best_bid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_third_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_fourth_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fourth_best_bid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fourth_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_fifth_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fifth_best_bid_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fifth_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_second_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_second_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_second_best_bid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_third_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_third_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_third_best_bid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_fourth_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fourth_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fourth_best_bid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_fifth_best_bid_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fifth_best_bid_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fifth_best_bid_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_second_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_second_best_offer_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_second_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_third_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_third_best_offer_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_third_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_fourth_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fourth_best_offer_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fourth_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$buy_at_fifth_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fifth_best_offer_price(
      quantity = 1,
      product = "mis",
      validity = "ioc"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$buy_at_fifth_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_second_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_second_best_offer_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_second_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_third_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_third_best_offer_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_third_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_fourth_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fourth_best_offer_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fourth_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$sell_at_fifth_best_offer_price()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fifth_best_offer_price(
      quantity = 1,
      product = "mis"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    answer <- idea$sell_at_fifth_best_offer_price(
      quantity = 1,
      product = "mis",
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- answer
    cat(
      answer[["outcome"]],
      answer[["broker"]],
      answer[["order_id"]],
      "\n"
    )
    Sys.sleep(3)
    orders <- idea$orders
    mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    print(mine[, c(
      "status",
      "price",
      "filled_quantity"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$add_to_position()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opened <- idea$add_to_position(
      quantity = 1,
      product = "mis",
      transaction_type = "buy",
      price = round(idea$last_price * 1.01, 2)
    )
    answers[[length(answers) + 1]] <- opened
    cat("Opened:", opened[["outcome"]], "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    added <- idea$add_to_position(
      quantity = 1,
      product = "mis",
      price = round(idea$last_price * 1.01, 2)
    )
    answers[[length(answers) + 1]] <- added
    cat("Added:", added[["outcome"]], "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 2) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    tryCatch(
      {
        idea$add_to_position(
          quantity = 1,
          product = "mis",
          transaction_type = "sell"
        )
      },
      PositionError = function(error) {
        cat("Refused:", conditionMessage(error), "\n")
      }
    )
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$reduce_position()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
answers <- list()
tryCatch(
  {
    opened <- idea$buy_at_marketable_price(quantity = 2, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 2) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    reduced <- idea$reduce_position(
      quantity = 1,
      product = "mis",
      price = round(idea$last_price * 0.99, 2)
    )
    answers[[length(answers) + 1]] <- reduced
    cat("Reduced:", reduced[["outcome"]], "\n")
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
if (start != 0) {
  stop("An intraday IDEA position is already open.")
}
answers <- list()
tryCatch(
  {
    opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    reduced <- idea$reduce_position(
      quantity = 5,
      product = "mis",
      price = round(idea$last_price * 0.99, 2)
    )
    answers[[length(answers) + 1]] <- reduced
    cat("Reduced:", reduced[["outcome"]], "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$liquidate_position()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
if (start != 0) {
  stop("An intraday IDEA position is already open.")
}
answers <- list()
tryCatch(
  {
    opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    closed <- idea$liquidate_position(
      product = "mis",
      price = round(idea$last_price * 0.99, 2)
    )
    answers[[length(answers) + 1]] <- closed
    cat("Closed:", closed[["outcome"]], closed[["order_id"]], "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
if (start != 0) {
  stop("An intraday IDEA position is already open.")
}
answers <- list()
tryCatch(
  {
    opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start - 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    closed <- idea$liquidate_position(
      product = "mis",
      price = round(idea$last_price * 1.01, 2),
      tag = "examples"
    )
    answers[[length(answers) + 1]] <- closed
    cat("Bought back:", closed[["outcome"]], closed[["order_id"]], "\n")
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }

## ------------------------------------------------
## Method `TradeableInstrument$liquidate_all_positions()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
if (start != 0) {
  stop("An intraday IDEA position is already open.")
}
answers <- list()
tryCatch(
  {
    opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start + 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    outcomes <- idea$liquidate_all_positions(
      price = round(idea$last_price * 0.99, 2)
    )
    print(outcomes)
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
start <- 0
positions <- idea$net_positions
if (!is.null(positions)) {
  intraday <- positions[positions$product == "intraday", , drop = FALSE]
  start <- sum(intraday$quantity)
}
if (start != 0) {
  stop("An intraday IDEA position is already open.")
}
answers <- list()
tryCatch(
  {
    opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
    answers[[length(answers) + 1]] <- opened
    for (attempt in seq_len(30)) {
      Sys.sleep(1)
      positions <- idea$net_positions
      intraday <- positions[positions$product == "intraday", , drop = FALSE]
      if (sum(intraday$quantity) == start - 1) {
        break
      }
    }
    cat("Intraday quantity:", sum(intraday$quantity), "\n")
    outcomes <- idea$liquidate_all_positions(
      price = round(idea$last_price * 1.01, 2),
      tag = "examples"
    )
    print(outcomes[, c(
      "product",
      "quantity",
      "closed",
      "order_id"
    )])
    print(outcomes[!outcomes$closed, , drop = FALSE][, c(
      "product",
      "error"
    )])
  },
  finally = {
    for (answer in answers) {
      for (attempt in seq_len(3)) {
        caught_error <- tryCatch(
          {
            cancelled <- idea$cancel_parent(answer[["parent_id"]])
            NULL
          },
          ConflictError = function(error) error,
          UnifiedBrokerInterfaceError = function(error) error
        )
        if (inherits(caught_error, "ConflictError")) {
          cat("The order had already finished.", "\n")
          break
        } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
          error <- caught_error
          cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
          Sys.sleep(2)
          next
        }
        if (cancelled[["state"]] == "cancelled") {
          cat("Cancelled what was still waiting.", "\n")
          break
        }
        Sys.sleep(2)
      }
    }
    quantity <- NA
    for (attempt in seq_len(6)) {
      Sys.sleep(5)
      caught_error <- tryCatch(
        {
          quantity <- 0
          positions <- idea$net_positions
          if (!is.null(positions)) {
            intraday <- positions[positions$product == "intraday", , drop = FALSE]
            quantity <- sum(intraday$quantity)
          }
          if (quantity == start) {
            break
          }
          difference <- as.integer(quantity - start)
          if (difference > 0) {
            price <- round(idea$last_price * 0.99, 2)
          } else {
            price <- round(idea$last_price * 1.01, 2)
          }
          if ((difference > 0) == (quantity > 0)) {
            idea$reduce_position(
              quantity = abs(difference),
              product = "mis",
              price = price
            )
          } else if (difference > 0) {
            idea$sell_at_limit_price(
              price = price,
              quantity = difference,
              product = "mis",
              hold = FALSE
            )
          } else {
            idea$buy_at_limit_price(
              price = price,
              quantity = -difference,
              product = "mis",
              hold = FALSE
            )
          }
          NULL
        },
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
        error <- caught_error
        quantity <- NA
        cat("Closing failed, trying again:", conditionMessage(error), "\n")
      }
    }
    if (is.na(quantity) || quantity != start) {
      stop(sprintf("The position is %s, not %s.", quantity, start))
    }
    cat("The intraday position is back at", start, "\n")
  }
)
} # }
```
