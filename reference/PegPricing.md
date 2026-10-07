# A pricing rule that keeps a limit at its reference in the book

The `peg` pricing rule of a plan: a limit kept at a named place in the
book and moved there as the book moves.

The reference is `own_touch`, the best price on the order's own side, so
a buy sits on the bid; `mid`, halfway between the bid and the offer; or
`opposite_touch`, the other side's best price, where the order fills at
once. A positive `offset_ticks` moves the order away from filling and a
negative one towards it. Every move passes UBI's repricing throttle, and
a move that changes nothing is not sent. When the book gives no price as
the order is sent, because nobody is on the side the reference reads, no
live quote has arrived or the quote is marked stale, `on_empty_book`
decides what happens: `wait`, UBI's default, keeps the order waiting for
a tick that does, and `refuse` ends it refused, which a plan with
nothing else placed answers with HTTP 409 and sends nothing.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `PegPricing`

## Public fields

- `reference`:

  The character place in the book, `own_touch`, `mid` or
  `opposite_touch`, or `NULL` for UBI's default of `own_touch`.

- `offset_ticks`:

  The integer number of ticks away from the reference, positive away
  from filling and negative towards it, or `NULL` for UBI's default of
  0.

- `follows`:

  A logical that is `FALSE` to price the order at its reference once
  when it is sent and leave it there, or `NULL` for UBI's default of
  `TRUE`.

- `within_body_price`:

  A logical that is `TRUE` to treat the template's limit price as the
  worst price the order takes.

- `on_empty_book`:

  The character `wait` or `refuse`, what to do when the book gives no
  price as the order is sent, or `NULL` for UBI's default of `wait`.

## Methods

### Public methods

- [`PegPricing$new()`](#method-PegPricing-initialize)

- [`PegPricing$document()`](#method-PegPricing-document)

- [`PegPricing$clone()`](#method-PegPricing-clone)

------------------------------------------------------------------------

### `PegPricing$new()`

Initialises the rule with its reference and settings.

#### Usage

    PegPricing$new(
      reference = NULL,
      offset_ticks = NULL,
      follows = NULL,
      within_body_price = FALSE,
      on_empty_book = NULL
    )

#### Arguments

- `reference`:

  The character place in the book, `own_touch` for the order's own side,
  `mid` for halfway between the bid and the offer, or `opposite_touch`
  for the other side, or `NULL` for UBI's default of `own_touch`.

- `offset_ticks`:

  The integer number of ticks away from the reference, positive away
  from filling and negative towards it, or `NULL` for UBI's default of
  0.

- `follows`:

  A logical that is `FALSE` to price the order at its reference once and
  leave it there, `TRUE` to move it whenever the reference moves, or
  `NULL` for UBI's default of `TRUE`.

- `within_body_price`:

  A logical that is `TRUE` to treat the template's limit price as the
  worst price the order takes, resting at that price when the book shows
  no reference. UBI refuses that price with HTTP 400 when it is not a
  whole number of ticks.

- `on_empty_book`:

  The character `wait` to keep the order waiting for a tick that carries
  its reference when the book gives no price as it is sent, or `refuse`
  to end it refused, which a plan with nothing else placed answers with
  HTTP 409, or `NULL` for UBI's default of `wait`.

#### Returns

A new `PegPricing` object.

------------------------------------------------------------------------

### `PegPricing$document()`

Builds the `peg` pricing object UBI reads, holding every setting that is
not `NULL`.

#### Usage

    PegPricing$document()

#### Returns

A named list with the single key `peg`, whose value holds `reference`,
`offset_ticks`, `follows` and `on_empty_book` when they are set and
`within_body_price` when it is `TRUE`.

#### Examples

    pricing <- PegPricing$new()
    print(pricing$document())

    pricing <- PegPricing$new(reference = "mid", offset_ticks = 1)
    print(pricing$document())

    pricing <- PegPricing$new(
      reference = "own_touch",
      follows = FALSE,
      within_body_price = TRUE
    )
    print(pricing$document())

    pricing <- PegPricing$new(
      reference = "opposite_touch",
      offset_ticks = -2,
      on_empty_book = "refuse"
    )
    print(pricing$document())

------------------------------------------------------------------------

### `PegPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PegPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- PegPricing$new(reference = "own_touch", offset_ticks = 1)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `PegPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- PegPricing$new()
print(pricing$document())

pricing <- PegPricing$new(reference = "mid", offset_ticks = 1)
print(pricing$document())

pricing <- PegPricing$new(
  reference = "own_touch",
  follows = FALSE,
  within_body_price = TRUE
)
print(pricing$document())

pricing <- PegPricing$new(
  reference = "opposite_touch",
  offset_ticks = -2,
  on_empty_book = "refuse"
)
print(pricing$document())
} # }
```
