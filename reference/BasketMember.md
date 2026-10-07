# One instrument held in a basket

A basket that describes an allocation, such as an index or a fund's
contents, gives each member a `weight`. A portfolio gives each member a
`quantity` and, when it is known, the `average_price` it was bought at.
A watchlist gives neither.

## Public fields

- `instrument`:

  The `Instrument` this member is.

- `weight`:

  The numeric share of the basket this member is meant to be, in any
  units such as fractions or percentages because the basket normalises
  them, or `NULL` when the basket is not weighted.

- `quantity`:

  The integer or numeric number of units held, negative for a short
  position, or `NULL` when the basket is not counted in units.

- `average_price`:

  The numeric average price in rupees the quantity was bought at, or
  `NULL` when it is not known.

## Active bindings

- `label`:

  The character readable name of the member, such as `"nse:INFY"` or
  `"nse:NIFTY 2026-10-27 25000.0CE"`.

## Methods

### Public methods

- [`BasketMember$new()`](#method-BasketMember-initialize)

- [`BasketMember$document()`](#method-BasketMember-document)

- [`BasketMember$format()`](#method-BasketMember-format)

- [`BasketMember$print()`](#method-BasketMember-print)

- [`BasketMember$clone()`](#method-BasketMember-clone)

------------------------------------------------------------------------

### `BasketMember$new()`

Initialises the member.

#### Usage

    BasketMember$new(
      instrument,
      weight = NULL,
      quantity = NULL,
      average_price = NULL
    )

#### Arguments

- `instrument`:

  The `Instrument` this member is.

- `weight`:

  The numeric share of the basket, or `NULL`.

- `quantity`:

  The integer or numeric number of units held, or `NULL`.

- `average_price`:

  The numeric average price in rupees the quantity was bought at, or
  `NULL`.

#### Returns

A new `BasketMember` object.

------------------------------------------------------------------------

### `BasketMember$document()`

Describes the member as a named list for storing in MongoDB.

#### Usage

    BasketMember$document()

#### Returns

A named list with the instrument's `instrument_id`, `exchange`,
`segment`, `symbol`, `underlying_symbol`, `expiry_date` as
`"YYYY-MM-DD"` text, `strike_price` and `option_type`, and the member's
`weight`, `quantity` and `average_price`, where a missing value is
`NULL`.

#### Examples

    infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    str(BasketMember$new(infosys, weight = 0.05)$document())

    idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    member <- BasketMember$new(idea, quantity = 100, average_price = 12.5)
    document <- member$document()
    cat(document$symbol, document$quantity, document$average_price, "\n")

------------------------------------------------------------------------

### `BasketMember$format()`

Describes the member by its label and whichever of weight, quantity and
average price it has.

#### Usage

    BasketMember$format(...)

#### Arguments

- `...`:

  Ignored, accepted so that
  [`format()`](https://rdrr.io/r/base/format.html) works.

#### Returns

A character value such as `"BasketMember('nse:INFY', weight=0.05)"`.

------------------------------------------------------------------------

### `BasketMember$print()`

Prints the description [`format()`](https://rdrr.io/r/base/format.html)
gives.

#### Usage

    BasketMember$print(...)

#### Arguments

- `...`:

  Ignored.

#### Returns

The member, invisibly.

------------------------------------------------------------------------

### `BasketMember$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BasketMember$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
member <- BasketMember$new(infosys, weight = 0.05)
held <- BasketMember$new(infosys, quantity = 10, average_price = 1450)

print(BasketMember$new(infosys, weight = 0.05)$label)

for (exchange in c(
  "nse",
  "bse"
)) {
  share <- Equity$new(exchange = exchange, symbol = "TCS")
  print(BasketMember$new(share)$label)
}
} # }

## ------------------------------------------------
## Method `BasketMember$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
infosys <- Equity$new(exchange = "nse", symbol = "INFY")
str(BasketMember$new(infosys, weight = 0.05)$document())

idea <- Equity$new(exchange = "nse", symbol = "IDEA")
member <- BasketMember$new(idea, quantity = 100, average_price = 12.5)
document <- member$document()
cat(document$symbol, document$quantity, document$average_price, "\n")
} # }
```
