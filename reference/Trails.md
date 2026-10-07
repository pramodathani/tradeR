# A condition that holds once the last price has pulled back from its best by a distance

The `trails` trigger of a plan: the last price pulling back from its
best by a distance.

For an order sent as a sell, the best is the highest price seen and the
pullback a fall; for a buy, the lowest price seen and a rise. It is a
trailing stop kept inside UBI's order engine, so the order it fires can
be priced any way, but it does nothing while the engine is down. Give
exactly one of `points` and `percent`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `Trails`

## Public fields

- `points`:

  The numeric distance in rupees, or `NULL` when `percent` is given.

- `percent`:

  The numeric distance as a percentage of the price, or `NULL` when
  `points` is given.

## Methods

### Public methods

- [`Trails$new()`](#method-Trails-initialize)

- [`Trails$document()`](#method-Trails-document)

- [`Trails$clone()`](#method-Trails-clone)

------------------------------------------------------------------------

### `Trails$new()`

Initialises the condition with its distance.

#### Usage

    Trails$new(points = NULL, percent = NULL)

#### Arguments

- `points`:

  The numeric distance in rupees, or `NULL` when `percent` is given.

- `percent`:

  The numeric distance as a percentage of the price, or `NULL` when
  `points` is given.

#### Returns

A new `Trails` object.

------------------------------------------------------------------------

### `Trails$document()`

Builds the `trails` condition UBI reads.

#### Usage

    Trails$document()

#### Returns

A named list with the single key `trails`, whose value holds whichever
of `points` and `percent` is set.

#### Examples

    print(Trails$new(points = 5.0)$document())

    print(Trails$new(percent = 1.5)$document())

------------------------------------------------------------------------

### `Trails$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Trails$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
condition <- Trails$new(points = 5.0)
document <- condition$document()
} # }

## ------------------------------------------------
## Method `Trails$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(Trails$new(points = 5.0)$document())

print(Trails$new(percent = 1.5)$document())
} # }
```
