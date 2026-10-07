# The pre-open session, with the time the order is sent into it

The `pre_open` venue of a plan: an order sent in the pre-open session so
it trades at the opening auction's price.

UBI sends the order at `at_time`, 09:00:30 by default, through a
`time_from` trigger of its own, so an order with this venue takes no
trigger (`pre_open_sets_its_time`). The pre-open takes only `LIMIT` and
`MARKET` orders, on NSE and BSE cash until 09:10, market orders until
09:05, and on NSE stock and index futures until 09:07; anything else, or
an order sent after collection has closed, is refused with HTTP 400.
Unlike most parts, a venue is an entry of the order's `venue` list
rather than a one-key object.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `PreOpenVenue`

## Public fields

- `at_time`:

  The character time of day the order is sent, such as `09:02`, or
  `NULL` for UBI's default of `09:00:30`.

## Methods

### Public methods

- [`PreOpenVenue$new()`](#method-PreOpenVenue-initialize)

- [`PreOpenVenue$document()`](#method-PreOpenVenue-document)

- [`PreOpenVenue$clone()`](#method-PreOpenVenue-clone)

------------------------------------------------------------------------

### `PreOpenVenue$new()`

Initialises the venue with the time the order is sent.

#### Usage

    PreOpenVenue$new(at_time = NULL)

#### Arguments

- `at_time`:

  The character time of day in India while the pre-open takes orders,
  such as `09:02` or `09:00:30`, or `NULL` for UBI's default of
  `09:00:30`.

#### Returns

A new `PreOpenVenue` object.

------------------------------------------------------------------------

### `PreOpenVenue$document()`

Builds the venue entry UBI reads.

#### Usage

    PreOpenVenue$document()

#### Returns

A named list holding `session` set to `pre_open`, and `at_time` when it
is not `NULL`. `OrderPart` puts it in a list of one under `venue`.

#### Examples

    print(PreOpenVenue$new()$document())

    part <- OrderPart$new(
      pricing = FixedPricing$new(price = 1000.0, order_type = "LIMIT"),
      venue = PreOpenVenue$new(at_time = "09:02")
    )
    print(part$document())

------------------------------------------------------------------------

### `PreOpenVenue$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PreOpenVenue$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- OrderPart$new(venue = PreOpenVenue$new(at_time = "09:02"))
document <- part$document()
} # }

## ------------------------------------------------
## Method `PreOpenVenue$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
print(PreOpenVenue$new()$document())

part <- OrderPart$new(
  pricing = FixedPricing$new(price = 1000.0, order_type = "LIMIT"),
  venue = PreOpenVenue$new(at_time = "09:02")
)
print(part$document())
} # }
```
