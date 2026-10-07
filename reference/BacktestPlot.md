# A standalone HTML page showing one backtest

Stands in for `Backtest.plot()` of the Python `backtesting` package,
which draws an interactive Bokeh chart. Bokeh has no R counterpart
without new dependencies, so this class writes a plain HTML file
instead, with no scripts and nothing fetched from the internet: a line
chart of the closes with a green mark at each trade's entry and a red
mark at its exit, a line chart of the equity, the statistics as a table,
and the list of trades.

## Public fields

- `candles`:

  The `data.frame` of candles with `datetime` and `Close` columns.

- `results`:

  The named list of statistics from `Backtest$run()`.

## Methods

### Public methods

- [`BacktestPlot$new()`](#method-BacktestPlot-initialize)

- [`BacktestPlot$write()`](#method-BacktestPlot-write)

- [`BacktestPlot$html()`](#method-BacktestPlot-html)

- [`BacktestPlot$clone()`](#method-BacktestPlot-clone)

------------------------------------------------------------------------

### `BacktestPlot$new()`

Collects what the page shows.

#### Usage

    BacktestPlot$new(candles, results)

#### Arguments

- `candles`:

  The `data.frame` of candles with `datetime` and `Close` columns.

- `results`:

  The named list of statistics from `Backtest$run()`.

#### Returns

A new `BacktestPlot` object.

------------------------------------------------------------------------

### `BacktestPlot$write()`

Builds the page and writes it to a file, without opening it.

#### Usage

    BacktestPlot$write(filename)

#### Arguments

- `filename`:

  The character path of the HTML file to write.

#### Returns

The character `filename`, invisibly.

------------------------------------------------------------------------

### `BacktestPlot$html()`

Builds the page.

#### Usage

    BacktestPlot$html()

#### Returns

A character value holding the whole HTML document.

------------------------------------------------------------------------

### `BacktestPlot$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BacktestPlot$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
statistics <- backtest$run()
BacktestPlot$new(backtest$candles, statistics)$write(file.path(tempdir(), "backtest.html"))
} # }
```
