# R/assets_analysis_price_analysis.R

Port of `src/tradingmachine/assets/analysis/price_analysis.py`, the root of the analysis chain. In Python every analysis class inherits `PriceAnalysis` directly and `Instrument` inherits all of them; in R they form one chain from this root to `PerformanceMeasures`, as `.claude/notes/R/assets_instruments.R.md` explains. Python raises `NotImplementedError`; R signals a plain error with the same message, because R has no counterpart of that class and nothing catches it.
