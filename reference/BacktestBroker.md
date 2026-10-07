# The simulated broker of a backtest

The R counterpart of the `_Broker` class inside the Python `backtesting`
package (version 0.6.5). It holds the cash, the order queue, the open
and closed trades and the equity of every candle, and on each candle it
fills the orders whose conditions the candle met.

A strategy never builds one; `Backtest$run()` does, and the strategy
reaches it through `BacktestStrategy$buy()`, `BacktestStrategy$sell()`,
`BacktestStrategy$position` and the other members of `BacktestStrategy`.

The fill rules are backtesting.py's:

- A market order fills at the open of the candle after the one it was
  placed on, or at the close of the candle it was placed on when
  `trade_on_close` is `TRUE`.

- A stop order waits until a candle's high reaches the stop for a buy,
  or its low reaches it for a sell, and then fills like a market or
  limit order.

- A limit order fills when a candle's low reaches the limit for a buy,
  or its high reaches it for a sell, at the limit or at the open when
  the open is better.

- An order sized as a fraction between 0 and 1 buys as many whole units
  as that fraction of the available margin, times the leverage, pays
  for.

- Without hedging, an order first closes opposite trades, oldest first.

- An order the margin cannot pay for is dropped.

- Commission is a fraction of each fill's value, charged when a trade
  opens and again when it closes.

## Public fields

- `candles`:

  The `data.frame` of every candle, with `datetime`, `Open`, `High`,
  `Low`, `Close` and `Volume` columns.

- `cash`:

  The numeric cash held, which changes as trades open and close.

- `commission`:

  The numeric commission as a fraction of each fill's value.

- `leverage`:

  The numeric leverage, which is 1 divided by the margin.

- `trade_on_close`:

  A logical that is `TRUE` to fill market orders at the close of the
  candle they were placed on.

- `hedging`:

  A logical that is `TRUE` to let long and short trades stay open
  together.

- `exclusive_orders`:

  A logical that is `TRUE` to cancel waiting orders and close open
  trades whenever a new order is placed.

- `equity_curve`:

  A numeric vector with the equity at the end of each candle, `NA` for
  the candles before the strategy started.

- `orders`:

  A list of the waiting `BacktestOrder` objects, in the order they will
  be processed.

- `trades`:

  A list of the open `BacktestTrade` objects, oldest first.

- `closed_trades`:

  A list of the closed `BacktestTrade` objects, in the order they
  closed.

- `position`:

  The `BacktestPosition` summing the open trades.

- `current_bar`:

  The integer number of the candle being processed, counting from 1.

## Active bindings

- `last_price`:

  The numeric close of the candle being processed.

- `equity`:

  The numeric cash plus the profit or loss of the open trades.

- `margin_available`:

  The numeric equity left after the margin the open trades use, never
  below zero.

## Methods

### Public methods

- [`BacktestBroker$new()`](#method-BacktestBroker-initialize)

- [`BacktestBroker$commission_of()`](#method-BacktestBroker-commission_of)

- [`BacktestBroker$new_order()`](#method-BacktestBroker-new_order)

- [`BacktestBroker$insert_order_first()`](#method-BacktestBroker-insert_order_first)

- [`BacktestBroker$remove_order()`](#method-BacktestBroker-remove_order)

- [`BacktestBroker$next_bar()`](#method-BacktestBroker-next_bar)

- [`BacktestBroker$clone()`](#method-BacktestBroker-clone)

------------------------------------------------------------------------

### `BacktestBroker$new()`

Creates a broker with its starting cash and rules.

#### Usage

    BacktestBroker$new(
      candles,
      cash,
      commission,
      margin,
      trade_on_close,
      hedging,
      exclusive_orders
    )

#### Arguments

- `candles`:

  A `data.frame` with `datetime`, `Open`, `High`, `Low`, `Close` and
  `Volume` columns, oldest candle first.

- `cash`:

  The numeric starting cash, above zero.

- `commission`:

  The numeric commission as a fraction of each fill's value, from -0.1
  up to but not including 0.1.

- `margin`:

  The numeric margin as a fraction, above 0 and at most 1, where 1 means
  no leverage.

- `trade_on_close`:

  A logical that is `TRUE` to fill market orders at the current candle's
  close.

- `hedging`:

  A logical that is `TRUE` to allow long and short trades at the same
  time.

- `exclusive_orders`:

  A logical that is `TRUE` to close the open trades whenever a new order
  is placed.

#### Details

Errors: signals `ValueError` when `cash`, `commission` or `margin` is
outside its allowed range.

#### Returns

A new `BacktestBroker` object.

------------------------------------------------------------------------

### `BacktestBroker$commission_of()`

Works out the commission on one fill.

#### Usage

    BacktestBroker$commission_of(order_size, price)

#### Arguments

- `order_size`:

  The numeric number of units, of either sign.

- `price`:

  The numeric fill price.

#### Returns

The numeric commission in cash.

------------------------------------------------------------------------

### `BacktestBroker$new_order()`

Checks an order's prices and puts it in the queue.

#### Usage

    BacktestBroker$new_order(
      size,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL,
      trade = NULL
    )

#### Arguments

- `size`:

  The numeric size, positive to buy and negative to sell.

- `limit`:

  The numeric limit price, or `NULL`.

- `stop`:

  The numeric stop price, or `NULL`.

- `sl`:

  The numeric stop-loss price for the trade the order opens, or `NULL`.

- `tp`:

  The numeric take-profit price for the trade the order opens, or
  `NULL`.

- `tag`:

  Any value to recognise the order by, or `NULL`.

- `trade`:

  The `BacktestTrade` the order closes, or `NULL` for an order that
  opens a trade.

#### Details

Errors: signals `ValueError` when the stop-loss, the limit or stop
price, and the take-profit are not in rising order for a buy, or falling
order for a sell.

#### Returns

The new `BacktestOrder`.

------------------------------------------------------------------------

### `BacktestBroker$insert_order_first()`

Puts an order at the front of the queue, so it is processed first.

#### Usage

    BacktestBroker$insert_order_first(order)

#### Arguments

- `order`:

  The `BacktestOrder` to insert.

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BacktestBroker$remove_order()`

Takes an order out of the queue, if it is there.

#### Usage

    BacktestBroker$remove_order(order)

#### Arguments

- `order`:

  The `BacktestOrder` to remove.

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BacktestBroker$next_bar()`

Processes one candle: fills the orders it allows, then records the
equity.

#### Usage

    BacktestBroker$next_bar(bar)

#### Arguments

- `bar`:

  The integer number of the candle, counting from 1.

#### Returns

A logical that is `TRUE` when the equity fell to zero or below, which
ends the backtest.

------------------------------------------------------------------------

### `BacktestBroker$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestBroker$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
candles <- data.frame(
  datetime = as.POSIXct(
    c(
      "2025-01-01",
      "2025-01-02"
    ),
    tz = "Asia/Kolkata"
  ),
  Open = c(
    100,
    101
  ),
  High = c(
    102,
    103
  ),
  Low = c(
    99,
    100
  ),
  Close = c(
    101,
    102
  ),
  Volume = c(
    1000,
    1200
  )
)
broker <- BacktestBroker$new(
  candles = candles,
  cash = 10000,
  commission = 0.001,
  margin = 1,
  trade_on_close = FALSE,
  hedging = FALSE,
  exclusive_orders = FALSE
)
broker$current_bar <- 1
broker$new_order(10)
broker$next_bar(2)
print(broker$trades[[1]])
} # }
```
