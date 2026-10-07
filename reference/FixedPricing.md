# A pricing rule that sends the order at a set price, or at market

The `fixed` pricing rule of a plan: a limit at a given price, or a
market order.

It is the rule an order in a plan uses when it names none, taking the
template's own order type and price. UBI writes its order type in
capitals here, `LIMIT` or `MARKET`, unlike the template's lower-case
`limit` and `market`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `FixedPricing`

## Public fields

- `price`:

  The numeric limit price in rupees, or `NULL` to use the template's
  price.

- `order_type`:

  The character order type, `LIMIT` or `MARKET`, or `NULL` to use the
  template's.

## Methods

### Public methods

- [`FixedPricing$new()`](#method-FixedPricing-initialize)

- [`FixedPricing$document()`](#method-FixedPricing-document)

- [`FixedPricing$clone()`](#method-FixedPricing-clone)

------------------------------------------------------------------------

### `FixedPricing$new()`

Initialises the rule with its price and order type.

#### Usage

    FixedPricing$new(price = NULL, order_type = NULL)

#### Arguments

- `price`:

  The numeric limit price in rupees, or `NULL` to use the template's
  price.

- `order_type`:

  The character order type in capitals, `LIMIT` or `MARKET`, or `NULL`
  to use the template's.

#### Returns

A new `FixedPricing` object.

------------------------------------------------------------------------

### `FixedPricing$document()`

Builds the `fixed` pricing object UBI reads.

#### Usage

    FixedPricing$document()

#### Returns

A named list with the single key `fixed`, whose value holds `price` and
`order_type` when each is set.

#### Examples

    pricing <- FixedPricing$new(price = 1010.0, order_type = "LIMIT")
    print(pricing$document())

    print(FixedPricing$new(order_type = "MARKET")$document())
    print(FixedPricing$new()$document())

------------------------------------------------------------------------

### `FixedPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FixedPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- FixedPricing$new(price = 1010.0, order_type = "LIMIT")
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `FixedPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- FixedPricing$new(price = 1010.0, order_type = "LIMIT")
print(pricing$document())

print(FixedPricing$new(order_type = "MARKET")$document())
print(FixedPricing$new()$document())
} # }
```
