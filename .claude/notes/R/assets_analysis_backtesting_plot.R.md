# R/assets_analysis_backtesting_plot.R

`BacktestPlot` stands in for backtesting.py's `Backtest.plot()`, which draws an interactive Bokeh chart. Bokeh has no R counterpart, and adding a plotting package was ruled out, so this class writes one self-contained HTML file with no scripts and no network requests:

- an SVG line of the closes, with a green dot at each closed trade's entry and a red dot at its exit;
- an SVG line of the equity;
- the statistics as a table, leaving out `_strategy`, `_equity_curve` and `_trades`;
- the closed trades as a table.

Colours follow the user's diagram palette, with a dark version under `prefers-color-scheme: dark`. The page is a convenience for looking at a run, not a reproduction of the Bokeh chart. As in Python, `run_backtest()` writes it only when `plot_filename` is given and never opens it.

The x and y positions are worked out as whole vectors before drawing rather than through small nested functions, because the user's style avoids nested functions.
