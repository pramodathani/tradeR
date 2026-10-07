# R/assets_option_pricing.R

Port of `src/tradingmachine/assets/option_pricing.py`.

## Checked against Python

On 2026-10-07 the R and Python models were run on the same inputs, a call at 24000 and 24100 with seven days left and a Black-76 put at 9125 and 9100 with twenty days left. Price, delta, gamma, theta, vega and rho of both, and both implied volatilities, agreed to ten decimal places.

## Differences from the Python version

- The cumulative normal is `stats::pnorm()` rather than the Python code's `(1 + erf(x / sqrt(2))) / 2`. They are the same function, and `pnorm` is the idiomatic R spelling.
- Python's `implied_volatility` is a class method that builds a model at each trial volatility through `cls(...)`. Here the search, `search_volatility()`, is an instance method on the shared base that clones the model with a new volatility, which works for any model keeping its volatility in a `volatility` field. `BlackScholes$implied_volatility()` and `Black76$implied_volatility()` on the generators keep the Python call shape and check the premium before building anything, as Python does, so a premium of zero returns `NULL` rather than failing on the other inputs.
