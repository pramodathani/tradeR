# _pkgdown.yml

This file configures the pkgdown site at https://pramodathani.github.io/tradeR/, which `.github/workflows/pkgdown.yaml` rebuilds on every push to `main`.

The reference index groups the 200 public help pages into sections that follow the package's layers and the Python documentation's own grouping: connecting to UBI, instruments, each asset family, option pricing, analysis, the backtesting engine, synthetic orders, plans and plan parts, baskets, the account, errors and utilities. pkgdown refuses to build when a help page is missing from the index, so a new exported class must be added to its section. `tradeR-package` is left out because it carries `@keywords internal`. The section list was generated from the `% Please edit documentation in R/...` line at the top of each `.Rd` file, so a page sits in the section of the file it comes from.

The descriptions are quoted because several contain a colon, which YAML otherwise reads as a nested mapping.

pkgdown renders every Markdown file at the repository root as a page, apart from `README.md`, `LICENSE.md` and `NEWS.md`. That is why the project instructions for Claude Code live in `.claude/CLAUDE.md` rather than `CLAUDE.md`: at the root they would have been published as a page of the site.

The built site goes to `docs/`, which `.gitignore` and `.Rbuildignore` both exclude, because the workflow publishes it to the `gh-pages` branch instead of committing it to `main`.
