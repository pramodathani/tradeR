# vignettes/articles/

These 40 articles are the guides of the pkgdown site, translated on 2026-10-07 from the Python library's MkDocs pages in `/home/pramod/Projects/tradingmachine/docs/` by seven parallel helpers working from one brief. Each MkDocs page maps to one article: `get-started/<page>.md` becomes `get-started-<page>.Rmd`, `python-api/<page>.md` becomes `guide-<page>.Rmd` (the index becomes `guide.Rmd`, titled "Using tradeR"), and `asset-classes`, `analysis`, `architecture` and `project` follow the same pattern. The MkDocs home page is not translated, because the README is the site's home page.

They live in `vignettes/articles/` rather than `vignettes/` so that pkgdown builds them as articles but R does not build them as vignettes; `.Rbuildignore` keeps the folder out of the built package, and R CMD check never knits them.

## Conventions

- Every article starts with a setup chunk that sets `knitr::opts_chunk$set(eval = FALSE)`, because every example needs the live UBI and many place real orders. A few chunks that draw a chart from hard-coded numbers set `eval = TRUE, echo = FALSE`; none of them contacts UBI. Turning on evaluation for the read-only examples later, against a live UBI, would let the site show real R output.
- The Python pages show output captured from Python. It is left out, because R prints differently and showing it as R output would mislead; where the prose relied on a captured value, the value is kept in prose and attributed to the Python capture and its date.
- Mermaid diagrams are written as raw `<pre class="mermaid">` blocks with `<`, `>` and `&` escaped; `_pkgdown.yml` loads Mermaid 11 from jsDelivr in every page's header.
- MkDocs admonitions became Bootstrap alerts (`::: {.alert .alert-warning}` and so on) with a bold first line, because pkgdown 2.2.1's `callout-*` classes rendered as a bare heading without a box.
- Vega-Lite charts, which pkgdown cannot draw, became tables or static SVG charts. The MkDocs SVG diagrams were copied into `diagrams/` with the light-mode rules from MkDocs' `extra.css` inlined into each SVG, and Python labels changed to R ones.
- Links between articles use the bare file name (`guide-orders.html#place_order`); links to the reference use `../reference/<Class>.html`, with method anchors of the form `#method-<Class>-<method>`. pandoc drops a leading number from a heading's anchor, unlike MkDocs.

## Corrections found while translating

The helpers checked every class, method and argument against `R/`. Their work turned up five mistakes in the Python pages (corrected in tradingmachine pull request #27), out-of-date `ValueError` and "a second client would log the instruments out" wording in `R/accounts_account.R` and `R/asset_baskets_member_resolver.R`, and `Signals` documentation that said a plain error where the code signals `KeyError`; those R files were corrected in the same session.

## Measured values that will go stale

`project-structure.Rmd` and `architecture-design-choices.Rmd` quote file counts, line counts and site sizes measured on 2026-10-07.
