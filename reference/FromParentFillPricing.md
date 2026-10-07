# A pricing rule for a spread's second leg, priced from the first leg's fill to reach a net price

The `from_parent_fill` pricing rule of a plan: the second leg of a
spread priced from what the first leg filled at.

UBI works out the price that makes the two legs add up to `net_price`,
the net debit per unit, which is positive when the spread costs money
and negative for a credit. The first leg's side signs its average fill,
a buy costing and a sell bringing money in, and the second leg's price
is the net less that, signed by the second leg's own side. Each new
order of the second leg is priced so that it and the second leg's
earlier orders together average the price the net needs, and is rounded
to the second leg's tick in the caller's favour, down for a buy and up
for a sell. A price at or below zero cannot be sent, so the order waits.
The order must be the child of a `ThenPart` whose first plan is a single
order, or UBI refuses the plan with `from_parent_fill_needs_then`.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `FromParentFillPricing`

## Public fields

- `net_price`:

  The numeric net debit per unit in rupees, negative for a credit.

## Methods

### Public methods

- [`FromParentFillPricing$new()`](#method-FromParentFillPricing-initialize)

- [`FromParentFillPricing$document()`](#method-FromParentFillPricing-document)

- [`FromParentFillPricing$clone()`](#method-FromParentFillPricing-clone)

------------------------------------------------------------------------

### `FromParentFillPricing$new()`

Initialises the rule with the net price aimed at.

#### Usage

    FromParentFillPricing$new(net_price)

#### Arguments

- `net_price`:

  The numeric net debit per unit in rupees that the two legs should add
  up to, positive when the spread costs money and negative for a credit.

#### Returns

A new `FromParentFillPricing` object.

------------------------------------------------------------------------

### `FromParentFillPricing$document()`

Builds the `from_parent_fill` pricing object UBI reads.

#### Usage

    FromParentFillPricing$document()

#### Returns

A named list with the single key `from_parent_fill`, whose value holds
`net_price`.

#### Examples

    pricing <- FromParentFillPricing$new(net_price = 45.0)
    print(pricing$document())

    part <- ThenPart$new(
      first = OrderPart$new(transaction_type = "sell"),
      each_fill = OrderPart$new(
        transaction_type = "buy",
        pricing = FromParentFillPricing$new(
          net_price = -30.0
        )
      )
    )
    print(part$document())

------------------------------------------------------------------------

### `FromParentFillPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    FromParentFillPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- FromParentFillPricing$new(net_price = 45.0)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `FromParentFillPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- FromParentFillPricing$new(net_price = 45.0)
print(pricing$document())

part <- ThenPart$new(
  first = OrderPart$new(transaction_type = "sell"),
  each_fill = OrderPart$new(
    transaction_type = "buy",
    pricing = FromParentFillPricing$new(
      net_price = -30.0
    )
  )
)
print(part$document())
} # }
```
