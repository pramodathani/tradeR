# Project

This section is for people working on the package itself rather than
using it. It explains where everything lives in the repository, how to
add a new asset class the way the existing six family files were built,
and how to write and publish these documentation pages.

The flowchart below shows the order in which the three pages are usually
needed: first finding your way around, then adding code, then
documenting it.

``` mermaid

flowchart LR
    S["Repository structure<br/>where things live"] --> A["Adding an asset class<br/>the checklist"]
    A --> W["Writing these docs<br/>pages, build, publish"]
```

The list below names each page of this section and what it covers.

- **[Repository
  structure](https://pramodathani.github.io/tradeR/articles/project-structure.md)**
  is an annotated tree of the repository, how many files and lines each
  group of files in `R/` holds, and which group uses which.
- **[Adding an asset
  class](https://pramodathani.github.io/tradeR/articles/project-adding-an-asset-class.md)**
  is a numbered checklist for a new family file, from the segment
  constants and the error classes to the tests, the sidecar note and the
  site’s reference section.
- **[Writing these
  docs](https://pramodathani.github.io/tradeR/articles/project-writing-docs.md)**
  covers previewing and building the site, how it is published on GitHub
  Pages, how the reference is generated from roxygen2 comments, and the
  visual conventions every article uses.

Everything in this section follows the project’s standing rules for
code: every class, method and active binding has complete roxygen2
documentation, names are spelled out in full, source files carry no
explanatory comments, and the reasoning behind each file lives in a
sidecar note under `.claude/notes/` instead. The Python library
`tradingmachine` remains the specification, so a change in behaviour
starts there and is ported here.
