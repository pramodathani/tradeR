# One named preset and its settings

A preset in a plan: one of the existing synthetic order types used as an
ingredient of an order.

A preset stands for slot values, or for a whole join, and takes the
settings of the type it is named after, so
`Preset$new("bracket", stop_price = 990.0, stop_limit_price = 988.0, target_price = 1010.0)`
makes an order a bracket. The preset names and their settings are UBI's,
and UBI refuses a name it does not offer yet, so new presets work here
as soon as UBI adds them.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `Preset`

## Public fields

- `name`:

  The character name of the preset, such as `bracket`, `trailing_stop`
  or `scheduled`.

- `settings`:

  The named list of the preset's settings, keyed by UBI's field names.

## Methods

### Public methods

- [`Preset$new()`](#method-Preset-initialize)

- [`Preset$document()`](#method-Preset-document)

- [`Preset$clone()`](#method-Preset-clone)

------------------------------------------------------------------------

### `Preset$new()`

Initialises the preset with its name and settings.

#### Usage

    Preset$new(name, ...)

#### Arguments

- `name`:

  The character name of the preset, as UBI names the synthetic order
  type, such as `bracket`, `oto` or `hidden_stop`.

- `...`:

  The preset's settings as named arguments by UBI's field names, such as
  `trigger_price = 995.0`. A setting UBI reads as a list, such as a list
  of prices, is given as a [`list()`](https://rdrr.io/r/base/list.html),
  because a vector of length one is sent as a single value.

#### Returns

A new `Preset` object.

------------------------------------------------------------------------

### `Preset$document()`

Builds the preset object UBI reads.

#### Usage

    Preset$document()

#### Returns

A named list with the single key `name`, whose value is the named list
of settings.

#### Examples

    part <- Preset$new("market_if_touched", trigger_price = 995.0)
    print(part$document())

    part <- Preset$new(
      "bracket",
      stop_price = 990.0,
      stop_limit_price = 988.0,
      target_price = 1010.0
    )
    print(part$document())

    print(Preset$new("simple")$document())

------------------------------------------------------------------------

### `Preset$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Preset$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- Preset$new("market_if_touched", trigger_price = 995.0)
document <- part$document()
} # }

## ------------------------------------------------
## Method `Preset$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- Preset$new("market_if_touched", trigger_price = 995.0)
print(part$document())

part <- Preset$new(
  "bracket",
  stop_price = 990.0,
  stop_limit_price = 988.0,
  target_price = 1010.0
)
print(part$document())

print(Preset$new("simple")$document())
} # }
```
