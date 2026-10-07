# One order waiting in a backtest's order queue

The R counterpart of `backtesting.Order` from the Python `backtesting`
package (version 0.6.5). A strategy creates one with
`BacktestStrategy$buy()` or `BacktestStrategy$sell()`, and a trade
creates one when it is closed or given a stop-loss or take-profit price.
The broker fills or drops it on a later candle.

An order with neither `limit` nor `stop` is a market order, filled at
the next candle's open, or at the current candle's close when the
backtest runs with `trade_on_close = TRUE`. An order with `stop` waits
until the price reaches the stop and then becomes a market or limit
order. An order with `limit` fills only at the limit price or better.

A stop-loss or take-profit order that belongs to a trade is called
contingent; it closes that trade when filled and is cancelled when the
trade closes another way.

## Public fields

- `size`:

  The numeric size: a positive number buys and a negative number sells.
  A size between -1 and 1 is a fraction of the available margin, and any
  other size is a whole number of units.

- `limit`:

  The numeric limit price, or `NULL` for a market or stop-market order.

- `stop`:

  The numeric stop price, or `NULL` when the order has no stop or its
  stop has already been reached.

- `sl`:

  The numeric stop-loss price to give the trade this order opens, or
  `NULL`.

- `tp`:

  The numeric take-profit price to give the trade this order opens, or
  `NULL`.

- `parent_trade`:

  The `BacktestTrade` this order closes, or `NULL` for an order that
  opens a trade.

- `tag`:

  Any value the strategy attached to the order to recognise it later, or
  `NULL`.

## Active bindings

- `is_long`:

  A logical that is `TRUE` when the order buys.

- `is_short`:

  A logical that is `TRUE` when the order sells.

- `is_contingent`:

  A logical that is `TRUE` when the order is the stop-loss or
  take-profit order of an open trade.

## Methods

### Public methods

- [`BacktestOrder$new()`](#method-BacktestOrder-initialize)

- [`BacktestOrder$cancel()`](#method-BacktestOrder-cancel)

- [`BacktestOrder$format()`](#method-BacktestOrder-format)

- [`BacktestOrder$print()`](#method-BacktestOrder-print)

- [`BacktestOrder$clone()`](#method-BacktestOrder-clone)

------------------------------------------------------------------------

### `BacktestOrder$new()`

Creates an order without placing it in the queue;
`BacktestBroker$new_order()` does both.

#### Usage

    BacktestOrder$new(
      broker,
      size,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      parent_trade = NULL,
      tag = NULL
    )

#### Arguments

- `broker`:

  The `BacktestBroker` that holds the order queue.

- `size`:

  The numeric size, positive to buy and negative to sell, never zero.

- `limit`:

  The numeric limit price, or `NULL`.

- `stop`:

  The numeric stop price, or `NULL`.

- `sl`:

  The numeric stop-loss price for the trade the order opens, or `NULL`.

- `tp`:

  The numeric take-profit price for the trade the order opens, or
  `NULL`.

- `parent_trade`:

  The `BacktestTrade` the order closes, or `NULL`.

- `tag`:

  Any value to recognise the order by, or `NULL`.

#### Details

Errors: signals `ValueError` when `size` is zero.

#### Returns

A new `BacktestOrder` object.

------------------------------------------------------------------------

### `BacktestOrder$cancel()`

Removes the order from the queue, and from its trade when it is the
trade's stop-loss or take-profit order.

#### Usage

    BacktestOrder$cancel()

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BacktestOrder$format()`

Describes the order in one line, as Python's `repr` does.

#### Usage

    BacktestOrder$format(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`format()`](https://rdrr.io/r/base/format.html).

#### Returns

A character value such as
`"<Order size=-10, stop=95, contingent=TRUE>"`.

------------------------------------------------------------------------

### `BacktestOrder$print()`

Prints the one-line description of the order.

#### Usage

    BacktestOrder$print(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`print()`](https://rdrr.io/r/base/print.html).

#### Returns

The order, invisibly.

------------------------------------------------------------------------

### `BacktestOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
LimitBuyer <- R6::R6Class(
  "LimitBuyer",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },
    next_candle = function() {
      if (length(self$orders) == 0 && self$position$size == 0) {
        latest_close <- tail(self$data$Close, 1)
        order <- self$buy(limit = latest_close * 0.98)
        cat(sprintf("Waiting to buy at %.2f\n", order$limit))
      }
    }
  )
)
} # }
```
