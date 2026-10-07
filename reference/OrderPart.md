# One order of a plan, with the presets and slot values that shape it

One order inside a plan, which may wait for a trigger, protect or close
a position, be priced, be sent in pieces and end on its own.

By default the order's instrument, side, quantity, product and validity
come from the `PlanOrder` it belongs to, and an order inside a join is
sized by the join. An order can also give its own instrument, quantity,
side, product, validity and tag, which is how one plan trades several
instruments, and say for itself whether UBI holds it until the market
reaches its price. An order with no presets and no settings is the
template as it stands, run as a `simple` order.

## Super class

[`PlanPart`](https://pramodathani.github.io/tradeR/reference/PlanPart.md)
-\> `OrderPart`

## Public fields

- `presets`:

  The list of `PlanPart` presets merged into the order first, in order,
  or `NULL` for none.

- `trigger`:

  The `PlanPart` condition the order waits for, or `NULL` to place it at
  once.

- `side`:

  The character side, `buy`, `sell`, `protect`, `close`, `same_as_first`
  or `against_delta`, or `NULL` to use the template's side.

- `pricing`:

  The `PlanPart` pricing rule that sets the price, or `NULL` to use the
  template's own order type and price.

- `cap`:

  The `PlanPart` `CapModifier` that bounds the price the rule sets, or
  `NULL` for no bound.

- `discretion`:

  The `PlanPart` `DiscretionModifier` that lets part of the order trade
  a little past its price, or `NULL`.

- `execution`:

  The `PlanPart` execution that sends the order, such as
  `TwapExecution`, or `NULL` to send it all at once.

- `inner_execution`:

  The `PlanPart` execution that sends each piece of `execution`, such as
  `IcebergExecution`, or `NULL`.

- `guard`:

  The `PlanPart` `PostOnlyGuard` that keeps the order from trading at
  once, or `NULL`.

- `lifetime`:

  The `PlanPart` `Lifetime` that ends the order, or `NULL` to let it run
  until it is done.

- `venue`:

  The `PlanPart` venue, `PreOpenVenue` or `PaperVenue`, or `NULL` for
  the normal market.

- `quantity`:

  The integer quantity, or a `PlanPart` quantity such as
  `PositionQuantity`, or `NULL` to use the template's or the join's
  quantity.

- `instrument`:

  The `TradeableInstrument` this order trades, or `NULL` for the plan's
  own instrument.

- `transaction_type`:

  The character side of the order's own body, `buy` or `sell`, or `NULL`
  for the template's.

- `product`:

  The character product of the order's own body, such as `mis`, or
  `NULL` for the template's.

- `validity`:

  The character validity of the order's own body, `day` or `ioc`, or
  `NULL` for the template's.

- `tag`:

  The character tag of the order's own body, or `NULL` for the
  template's.

- `hold_limits`:

  A logical that is `TRUE` to hold this order in UBI's virtual order
  book until the other side of the book reaches its price, `FALSE` to
  send it as it comes whatever the plan says, or `NULL` to follow the
  plan.

## Methods

### Public methods

- [`OrderPart$new()`](#method-OrderPart-initialize)

- [`OrderPart$document()`](#method-OrderPart-document)

- [`OrderPart$clone()`](#method-OrderPart-clone)

------------------------------------------------------------------------

### `OrderPart$new()`

Initialises the order with its presets and its own slot values.

UBI merges the presets first and the order's own values after them.
Triggers from several sources are joined so that all of them must hold,
a later pricing rule, cap, execution, guard or lifetime replaces an
earlier one with a warning, and two different sides are refused.

#### Usage

    OrderPart$new(
      presets = NULL,
      trigger = NULL,
      side = NULL,
      pricing = NULL,
      cap = NULL,
      discretion = NULL,
      execution = NULL,
      inner_execution = NULL,
      guard = NULL,
      lifetime = NULL,
      venue = NULL,
      quantity = NULL,
      instrument = NULL,
      transaction_type = NULL,
      product = NULL,
      validity = NULL,
      tag = NULL,
      hold_limits = NULL
    )

#### Arguments

- `presets`:

  A list of `PlanPart` presets, usually `Preset` objects, or `NULL` for
  none.

- `trigger`:

  A `PlanPart` condition, such as `PriceCrosses` or `AllConditions`, or
  `NULL` to place the order at once.

- `side`:

  The character side, `buy`, `sell`, `protect` to trade against the
  position the template's side opened, `close` to close the position a
  `PositionQuantity` names, `same_as_first` to trade, as a Then join's
  child, on the side the first plan filled on, or `against_delta` to
  hedge the delta of an option the plan traded, or `NULL` to use the
  template's side.

- `pricing`:

  A `PlanPart` pricing rule that sets the price, such as `FixedPricing`,
  `PegPricing` or `TrailPricing`, or `NULL` to use the template's own
  order type and price.

- `cap`:

  A `PlanPart` `CapModifier`, the worst price the rule may set, or
  `NULL`.

- `discretion`:

  A `PlanPart` `DiscretionModifier`, or `NULL`.

- `execution`:

  A `PlanPart` execution, such as `TwapExecution` or `IcebergExecution`,
  or `NULL` to send the order all at once.

- `inner_execution`:

  A `PlanPart` execution that works each piece `execution` releases,
  such as an `IcebergExecution` inside a `TwapExecution`, or `NULL`. It
  needs `execution`.

- `guard`:

  A `PlanPart` `PostOnlyGuard`, or `NULL`.

- `lifetime`:

  A `PlanPart` `Lifetime`, or `NULL`.

- `venue`:

  A `PlanPart` `PreOpenVenue` or `PaperVenue`, or `NULL`.

- `quantity`:

  An integer quantity, a `PlanPart` quantity such as `PositionQuantity`
  or `ParentFillQuantity`, or `NULL`.

- `instrument`:

  The `TradeableInstrument` this order trades instead of the plan's, or
  `NULL`.

- `transaction_type`:

  The character side of this order's own body, `buy` or `sell`, or
  `NULL`.

- `product`:

  The character product of this order's own body, `cnc`, `mis` or
  `nrml`, or `NULL`.

- `validity`:

  The character validity of this order's own body, `day` or `ioc`, or
  `NULL`.

- `tag`:

  The character tag of this order's own body, or `NULL`.

- `hold_limits`:

  A logical that is `TRUE` to hold this order until the other side of
  the book reaches its price, `FALSE` to send it as it comes, or `NULL`
  to follow the plan. UBI refuses `TRUE` with HTTP 400 and the rule
  `not_holdable` for an order that cannot be held, such as a market
  order or one priced by anything but `FixedPricing`.

#### Returns

A new `OrderPart` object.

------------------------------------------------------------------------

### `OrderPart$document()`

Builds the `order` node UBI reads, holding every setting that is not
`NULL`.

#### Usage

    OrderPart$document()

#### Returns

A named list with the single key `order`, whose value holds each setting
that is set. UBI takes `pricing`, `execution`, `guards`, `lifetime` and
`venue` as lists: the pricing rule, cap and discretion go in one
`pricing` list, the execution and inner execution in one `execution`
list, and the guard, lifetime and venue each in a list of one. An
instrument is sent as its `instrument_id`, and `hold_limits` is sent
only when it is not `NULL`.

#### Examples

    part <- OrderPart$new(
      trigger = PriceCrosses$new(level = 995.0),
      pricing = MarketablePricing$new(buffer_ticks = 2)
    )
    print(part$document())

    part <- OrderPart$new(
      presets = list(
        Preset$new("scheduled", at_time = "10:00"),
        Preset$new("market_if_touched", trigger_price = 995.0)
      )
    )
    print(part$document())

    part <- OrderPart$new(
      pricing = PegPricing$new(reference = "own_touch"),
      cap = CapModifier$new(worst_price = 1010.0),
      execution = TwapExecution$new(
        slices = 6,
        over_minutes = 60
      ),
      inner_execution = IcebergExecution$new(
        visible_quantity = 10
      ),
      lifetime = Lifetime$new(at_time = "14:30")
    )
    print(part$document())

------------------------------------------------------------------------

### `OrderPart$clone()`

The objects of this class are cloneable with this method.

#### Usage

    OrderPart$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
part <- OrderPart$new(
  presets = list(
    Preset$new("scheduled", at_time = "10:00")
  ),
  trigger = PriceCrosses$new(level = 995.0),
  pricing = MarketablePricing$new(buffer_ticks = 2)
)
document <- part$document()
} # }

## ------------------------------------------------
## Method `OrderPart$document()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
part <- OrderPart$new(
  trigger = PriceCrosses$new(level = 995.0),
  pricing = MarketablePricing$new(buffer_ticks = 2)
)
print(part$document())

part <- OrderPart$new(
  presets = list(
    Preset$new("scheduled", at_time = "10:00"),
    Preset$new("market_if_touched", trigger_price = 995.0)
  )
)
print(part$document())

part <- OrderPart$new(
  pricing = PegPricing$new(reference = "own_touch"),
  cap = CapModifier$new(worst_price = 1010.0),
  execution = TwapExecution$new(
    slices = 6,
    over_minutes = 60
  ),
  inner_execution = IcebergExecution$new(
    visible_quantity = 10
  ),
  lifetime = Lifetime$new(at_time = "14:30")
)
print(part$document())
} # }
```
