# A pricing rule that sends a stop-limit order to rest at the broker

The `native_stop` pricing rule of a plan: a stop-limit order resting at
the broker.

Because the stop rests at the broker, it still fires if UBI's order
engine is down, unlike a stop made from a `PriceCrosses` or `Trails`
trigger. With `exit_if_gapped`, a stop whose trigger the last price has
already passed when it is sent goes as a limit two ticks past the other
side's touch instead, because the broker would refuse such a stop or
fill it wherever the gap left the price.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `NativeStopPricing`

## Public fields

- `trigger_price`:

  The numeric trigger of the stop in rupees.

- `limit_price`:

  The numeric limit of the stop in rupees.

- `exit_if_gapped`:

  A logical that is `TRUE` to send a stop the price has already passed
  as a marketable limit instead.

## Methods

### Public methods

- [`NativeStopPricing$new()`](#method-NativeStopPricing-initialize)

- [`NativeStopPricing$document()`](#method-NativeStopPricing-document)

- [`NativeStopPricing$clone()`](#method-NativeStopPricing-clone)

------------------------------------------------------------------------

### `NativeStopPricing$new()`

Initialises the rule with the stop's trigger and limit.

#### Usage

    NativeStopPricing$new(trigger_price, limit_price, exit_if_gapped = FALSE)

#### Arguments

- `trigger_price`:

  The numeric trigger of the stop in rupees.

- `limit_price`:

  The numeric limit of the stop in rupees.

- `exit_if_gapped`:

  A logical that is `TRUE` to send a stop whose trigger the last price
  has already passed as a limit two ticks past the other side's touch,
  rather than a stop the broker would refuse or fill wherever the gap
  left the price.

#### Returns

A new `NativeStopPricing` object.

------------------------------------------------------------------------

### `NativeStopPricing$document()`

Builds the `native_stop` pricing object UBI reads.

#### Usage

    NativeStopPricing$document()

#### Returns

A named list with the single key `native_stop`, whose value holds
`trigger_price` and `limit_price`, and `exit_if_gapped` when it is
`TRUE`.

#### Examples

    pricing <- NativeStopPricing$new(
      trigger_price = 990.0,
      limit_price = 988.0
    )
    print(pricing$document())

    part <- OrderPart$new(
      side = "protect",
      pricing = NativeStopPricing$new(
        trigger_price = 990.0,
        limit_price = 988.0
      )
    )
    print(part$document())

    pricing <- NativeStopPricing$new(
      trigger_price = 990.0,
      limit_price = 988.0,
      exit_if_gapped = TRUE
    )
    print(pricing$document())

------------------------------------------------------------------------

### `NativeStopPricing$clone()`

The objects of this class are cloneable with this method.

#### Usage

    NativeStopPricing$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
pricing <- NativeStopPricing$new(
  trigger_price = 990.0,
  limit_price = 988.0
)
document <- pricing$document()
} # }

## ------------------------------------------------
## Method `NativeStopPricing$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
pricing <- NativeStopPricing$new(
  trigger_price = 990.0,
  limit_price = 988.0
)
print(pricing$document())

part <- OrderPart$new(
  side = "protect",
  pricing = NativeStopPricing$new(
    trigger_price = 990.0,
    limit_price = 988.0
  )
)
print(part$document())

pricing <- NativeStopPricing$new(
  trigger_price = 990.0,
  limit_price = 988.0,
  exit_if_gapped = TRUE
)
print(pricing$document())
} # }
```
