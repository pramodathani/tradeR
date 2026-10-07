# One trade opened by a filled order in a backtest

The R counterpart of `backtesting.Trade` from the Python `backtesting`
package (version 0.6.5). A trade records the size, entry price and entry
candle of a filled order, and gains an exit price and exit candle when
it is closed. A strategy reads its open trades through
`BacktestStrategy$trades` and its finished ones through
`BacktestStrategy$closed_trades`.

Assigning a price to `sl` or `tp` places a contingent stop-loss or
take-profit order that closes the trade, and assigning `NULL` cancels
it.

Candle numbers count from 1, as R rows do, where Python counts from 0.

## Public fields

- `size`:

  The numeric number of units: positive for a long trade and negative
  for a short one.

- `entry_price`:

  The numeric price the trade was opened at.

- `exit_price`:

  The numeric price the trade was closed at, or `NULL` while it is open.

- `entry_bar`:

  The integer candle number the trade was opened on, counting from 1.

- `exit_bar`:

  The integer candle number the trade was closed on, counting from 1, or
  `NULL` while it is open.

- `sl_order`:

  The contingent stop-loss `BacktestOrder`, or `NULL`.

- `tp_order`:

  The contingent take-profit `BacktestOrder`, or `NULL`.

- `tag`:

  Any value copied from the order that opened the trade, or `NULL`.

- `commissions`:

  The numeric commission paid on opening and closing the trade, filled
  in when it closes and zero until then.

## Active bindings

- `entry_time`:

  The `POSIXct` time of the candle the trade opened on.

- `exit_time`:

  The `POSIXct` time of the candle the trade closed on, or `NULL` while
  it is open.

- `is_long`:

  A logical that is `TRUE` for a long trade.

- `is_short`:

  A logical that is `TRUE` for a short trade.

- `pl`:

  The numeric profit, positive, or loss, negative, in cash, at the exit
  price or else the latest close. Commissions count only once the trade
  has closed.

- `pl_pct`:

  The numeric profit or loss as a fraction of the entry value, such as
  0.05 for five percent, after any commissions recorded.

- `value`:

  The numeric value of the trade in cash, its number of units times the
  exit price or else the latest close.

- `sl`:

  The numeric stop-loss price, or `NULL` when there is none. Assigning a
  price places or replaces the stop-loss order, and assigning `NULL`
  cancels it.

- `tp`:

  The numeric take-profit price, or `NULL` when there is none. Assigning
  a price places or replaces the take-profit order, and assigning `NULL`
  cancels it.

## Methods

### Public methods

- [`BacktestTrade$new()`](#method-BacktestTrade-initialize)

- [`BacktestTrade$close()`](#method-BacktestTrade-close)

- [`BacktestTrade$format()`](#method-BacktestTrade-format)

- [`BacktestTrade$print()`](#method-BacktestTrade-print)

- [`BacktestTrade$clone()`](#method-BacktestTrade-clone)

------------------------------------------------------------------------

### `BacktestTrade$new()`

Creates a trade; `BacktestBroker` does this when an order fills.

#### Usage

    BacktestTrade$new(broker, size, entry_price, entry_bar, tag)

#### Arguments

- `broker`:

  The `BacktestBroker` the trade belongs to.

- `size`:

  The numeric number of units, positive for long and negative for short.

- `entry_price`:

  The numeric price the trade opened at.

- `entry_bar`:

  The integer candle number the trade opened on.

- `tag`:

  Any value to recognise the trade by, or `NULL`.

#### Returns

A new `BacktestTrade` object.

------------------------------------------------------------------------

### `BacktestTrade$close()`

Places a market order that closes all or part of the trade on the next
fill.

#### Usage

    BacktestTrade$close(portion = 1)

#### Arguments

- `portion`:

  The numeric fraction of the trade to close, above 0 and at most 1.

#### Details

Errors: signals `ValueError` when `portion` is not above 0 and at most
1.

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `BacktestTrade$format()`

Describes the trade in one line, as Python's `repr` does.

#### Usage

    BacktestTrade$format(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`format()`](https://rdrr.io/r/base/format.html).

#### Returns

A character value such as
`"<Trade size=10 time=31-45 price=980-1012 pl=320>"`.

------------------------------------------------------------------------

### `BacktestTrade$print()`

Prints the one-line description of the trade.

#### Usage

    BacktestTrade$print(...)

#### Arguments

- `...`:

  Ignored; present for compatibility with
  [`print()`](https://rdrr.io/r/base/print.html).

#### Returns

The trade, invisibly.

------------------------------------------------------------------------

### `BacktestTrade$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestTrade$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
TrailingStop <- R6::R6Class(
  "TrailingStop",
  inherit = BacktestStrategy,
  public = list(
    initialize_strategy = function() {
      invisible(NULL)
    },
    next_candle = function() {
      latest_close <- tail(self$data$Close, 1)
      if (self$position$size == 0) {
        self$buy()
      }
      for (trade in self$trades) {
        trade$sl <- latest_close * 0.95
      }
    }
  )
)
} # }
```
