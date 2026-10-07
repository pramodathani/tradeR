# An order described as a tree of parts, which can combine the other synthetic order types

The `plan` synthetic order type: an order described as a tree of parts
rather than one fixed type.

A plan combines the existing synthetic order types and their building
blocks in one order. Its orders can wait for a trigger, protect or close
a position, be priced and capped, be sent in pieces over time, end on
their own and trade other instruments, set either by presets named after
the existing types or by slot values, and they are joined with
`ThenPart`, `EitherPart`, `TogetherPart`, `SequencePart`, `RepeatPart`
and `UsingPart`. The parts are the plan part classes, such as
`OrderPart`, `PriceCrosses` and `TrailPricing`, and the order template,
the instrument, side, quantity, product and validity, is the same as
every other type's. An order inside a join is sized by the join, and
only the plan's main order carries the template's `tag`.

UBI checks the whole plan before recording or sending anything and
refuses a plan with any problem with HTTP 400, listing every problem
with the `path` where the caller wrote the value it is about, its `rule`
and a `message`. A problem inside something UBI builds from what the
caller wrote, a preset that stands for a join such as a `bracket`, a
repeat's copies or a using's pieces, also gives `part`, the part as it
runs: a bad stop price in a bracket preset is reported at
`root.presets.0` with a `part` such as `root.each_fill.children.0`, and
the message may still name the setting the preset becomes, such as
`trigger_price` for the bracket's `stop_price`. A dry run makes the
checks placing makes, so it can be refused with HTTP 409 and the rule
`protect_needs_position`, or with HTTP 400 for a price off the tick,
just as placing would. A plan that places nothing at once answers HTTP
202 with an `outcome` of `armed`. UBI holds each order that would rest
at the broker at a fixed limit price in its virtual order book until the
other side of the book reaches it, while UBI's
`UNIFIED_BROKER_INTERFACE_API_ORDER_HOLD_LIMITS` switch is on and the
plan does not say otherwise; follow-on orders in a Then join's child,
such as exits, and orders on the `protect` side rest at the broker
unless their own `OrderPart` asks to be held. When a plan is refused
after some of its orders have reached a broker, the refused order is
listed in the answer's `legs` with its reason and the others stay
watched.

A plan that traded but whose order meant to follow the trade was
refused, such as a hedge, a spread's second leg or a strategy stop's
close, ends `failed` rather than `completed`, because a position may be
left without it, and the parent's message names the part.

After `place()`, each part of the plan is named by its path, such as
`root.first` for a bracket's entry or `root.each_fill.children.0` for
its stop. `parts` lists them, and `cancel_part()` and `modify_part()`
act on one part while the rest of the plan carries on.

The order template's attributes are described on `SyntheticOrder`.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `PlanOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `plan`:

  The `PlanPart` at the root of the tree, an `OrderPart`, a `ThenPart`
  or an `EitherPart`.

## Active bindings

- `parts`:

  The parts of the placed plan as UBI's order engine holds them now, as
  a `data.frame` with one row per part sorted by path, or `NULL` when
  UBI holds no parts, read from UBI on every access. Each row has the
  part's `path`, such as `root.each_fill.children.0`, and the fields of
  UBI's record for it: `state`, which is `pending`, `waiting`, `working`
  or `done`, and, when UBI has set them, `reason`, `target`, `memory`,
  `fired_at` and others. A done part's `reason` is `filled`,
  `partly_filled`, `refused` or `cancelled`, or `expired` when a
  lifetime or a pre-open ended it, `closed` when a lifetime's end closed
  what it traded, and `nothing_held` when a close found nothing to
  close. The parent ends once every part is done: `failed` when
  something traded but an order meant to follow it was refused,
  `completed` when anything traded, `rejected` when a broker refused an
  order and nothing traded, and `cancelled` otherwise. A parent
  cancelled whole with `cancel()` ends `cancelled` with every part
  marked done. Reading it signals `ValueError` when the order has not
  been placed, `NotFoundError` when the engine holds no parent with this
  id, and another `UnifiedBrokerInterfaceError` subclass for any other
  failure reported by, or on the way to, UBI. Read-only.

## Methods

### Public methods

- [`PlanOrder$new()`](#method-PlanOrder-initialize)

- [`PlanOrder$synthetic_fields()`](#method-PlanOrder-synthetic_fields)

- [`PlanOrder$cancel_part()`](#method-PlanOrder-cancel_part)

- [`PlanOrder$modify_part()`](#method-PlanOrder-modify_part)

- [`PlanOrder$clone()`](#method-PlanOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `PlanOrder$new()`

Initialises the order template and the plan.

#### Usage

    PlanOrder$new(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      plan,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      price_reference = NULL,
      quantity_reference = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    )

#### Arguments

- `instrument`:

  The `TradeableInstrument` to place the order in.

- `transaction_type`:

  The character side of the order, `buy` or `sell`, which is also the
  side a `protect` order trades against.

- `product`:

  The character product, `cnc` for delivery, `mis` for intraday or
  `nrml` for carry forward.

- `order_type`:

  The character kind of order, `market`, `limit`, `sl` or `sl-m`.

- `quantity`:

  The integer quantity in underlying units, not lots, or `NULL` when a
  quantity reference supplies it.

- `plan`:

  The `PlanPart` at the root of the tree, an `OrderPart`, a `ThenPart`
  or an `EitherPart`.

- `price`:

  The numeric limit price in rupees, or `NULL` for an order type that
  takes no price or when a price reference supplies it.

- `trigger_price`:

  The numeric trigger price in rupees of the order itself, or `NULL` for
  an order type that takes no trigger.

- `validity`:

  The character validity, `day` or `ioc`, or `NULL` to let UBI use
  `day`.

- `disclosed_quantity`:

  The integer quantity to show on the exchange, or `NULL` to disclose
  the whole order.

- `after_market`:

  A logical that is `TRUE` to send the order as an after-market order.

- `tag`:

  A character of up to twenty letters and digits to label the plan's
  main order with, or `NULL`.

- `price_reference`:

  A named list describing the price for UBI to work out, such as
  `list(kind = "mid")`, or `NULL`.

- `quantity_reference`:

  A named list describing the quantity for UBI to work out, such as
  `list(kind = "liquidate_position")`, or `NULL`.

- `closes_position`:

  A logical that is `TRUE` when every order this plan sends closes a
  position, so it may use the share of a broker's daily order cap kept
  for exits.

- `reduce_only`:

  A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg
  that is not on the closing side of the net position held when it is
  sent or is bigger than that position.

- `hold_limits`:

  A logical that is `TRUE` to have UBI hold each order of the plan that
  would rest at the broker at a fixed limit price until the other side
  of the book reaches it, `FALSE` to send them as they come, or `NULL`
  to follow UBI's `UNIFIED_BROKER_INTERFACE_API_ORDER_HOLD_LIMITS`
  switch. An `OrderPart`'s own `hold_limits` decides for that order.

- `dry_run`:

  A logical that is `TRUE` to have UBI build the first broker request
  and return it, with the plan as it would run, without recording or
  sending anything. UBI makes the checks placing makes, so a dry run is
  refused with HTTP 409 or 400 wherever placing would be, and in the
  plan each order shows `own_values`, the values it gives over the
  template's such as another `instrument_id` or `transaction_type`, its
  own side, and where its quantity comes from.

#### Returns

A new `PlanOrder` object.

------------------------------------------------------------------------

### `PlanOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    PlanOrder$synthetic_fields()

#### Returns

A named list with the single key `plan`, whose value is the object the
plan's root part builds.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 13.0,
      plan = ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = TrailPricing$new(points = 0.3, limit_offset = 0.05)
        )
      )
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = 12.9,
      plan = OrderPart$new(
        presets = list(
          Preset$new("market_if_touched", trigger_price = 12.9),
          Preset$new(
            "bracket",
            stop_price = 12.5,
            stop_limit_price = 12.45,
            target_price = 13.6
          )
        )
      )
    )
    print(order$synthetic)

------------------------------------------------------------------------

### `PlanOrder$cancel_part()`

Cancels one part of the placed plan, leaving the rest of it running.

A part whose turn has not come is never sent, a part waiting on its
trigger is ended at once, and a part that has sent orders sends no more
pieces and has each of its resting orders cancelled. The plan then
reacts as it does to that part finishing, so a bracket whose entry is
cancelled before it fills drops its exits.

Cancelling one of the plan's broker orders by its `order_id` through
`TradeableInstrument$cancel_order()` instead cancels that order alone,
and the plan does not send it again: for an order sent whole, its
unfilled quantity comes off what its part trades, so a later fill of the
entry is still protected for the new quantity only, and a bracket's stop
cancelled this way stays cancelled.

#### Usage

    PlanOrder$cancel_part(part, dry_run = FALSE)

#### Arguments

- `part`:

  The character path of the part, such as `root.each_fill.children.0`,
  as `parts` lists it.

- `dry_run`:

  A logical that is `TRUE` to have UBI list the part's resting `orders`
  without cancelling anything.

#### Details

Errors: signals `ValueError` when the order has not been placed, so
there is no parent to act on; `BadRequestError` when the part path is
malformed; `NotFoundError` when the engine holds no parent with this id,
or the plan has no part at this path; `ConflictError` when the part has
already finished, or is kept whole and has not started, or the plan has
finished; `ServiceUnavailableError` when the order engine is not
running; and another `UnifiedBrokerInterfaceError` subclass for any
other failure reported by, or on the way to, UBI.

#### Returns

The named list `TradeableInstrument$cancel_parent()` returns for a part,
with `parent_id`, `synthetic_type`, `part`, its `state`, `outcome`,
`status_message`, `intent_id` and `orders`, where each order's
`cancel_accepted` says whether its broker accepted the cancel. HTTP 207
with an `outcome` of `partial` or `rejected` is returned rather than
signalled.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    limit_price <- round(share$last_price * 0.97, 2)
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = limit_price,
      plan = OrderPart$new(
        presets = list(
          Preset$new(
            "bracket",
            stop_price = round(limit_price * 0.97, 2),
            stop_limit_price = round(limit_price * 0.96, 2),
            target_price = round(limit_price * 1.05, 2)
          )
        )
      )
    )
    order$place()
    tryCatch(
      {
        answer <- order$cancel_part("root.each_fill.children.1")
        print(c(answer[["state"]], answer[["status_message"]]))
        print(order$parts[, c("path", "state")])
      },
      finally = order$cancel()
    )

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    limit_price <- round(share$last_price * 0.97, 2)
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = limit_price,
      plan = OrderPart$new(
        presets = list(
          Preset$new(
            "cover",
            stop_price = round(limit_price * 0.97, 2),
            stop_limit_price = round(limit_price * 0.96, 2)
          )
        )
      )
    )
    order$place()
    tryCatch(
      print(order$cancel_part("root.first", dry_run = TRUE)),
      finally = order$cancel()
    )

------------------------------------------------------------------------

### `PlanOrder$modify_part()`

Changes one part of the placed plan that has not sent anything yet, such
as a bracket's stop before the entry fills.

The part keeps the new values and sends them when its turn comes, and
nothing is sent to a broker now. Only a part with a fixed price, a plain
limit or a native stop, takes a price, and only a stop takes a trigger
price. A part that has already sent its order is changed through
`TradeableInstrument$modify_order()` with that order's id instead.

#### Usage

    PlanOrder$modify_part(
      part,
      price = NULL,
      trigger_price = NULL,
      quantity = NULL,
      dry_run = FALSE
    )

#### Arguments

- `part`:

  The character path of the part, such as `root.each_fill.children.0`,
  as `parts` lists it.

- `price`:

  The numeric new limit price in rupees, or `NULL` to leave it.

- `trigger_price`:

  The numeric new trigger price in rupees of a stop, or `NULL` to leave
  it.

- `quantity`:

  The integer new total quantity, or `NULL` to leave it. An order that
  closes a position can only be reduced.

- `dry_run`:

  A logical that is `TRUE` to have UBI check the change without making
  it.

#### Details

Errors: signals `ValueError` when the order has not been placed, so
there is no parent to act on; `BadRequestError` when no value was given,
the part works its price out from the market, the part is not a stop and
was given a trigger price, or a value is off the tick or lot;
`NotFoundError` when the engine holds no parent with this id, or the
plan has no part at this path; `ConflictError` when the part has already
sent its order (the detail then lists its `orders`), is sized by an
earlier part's fills, is kept whole, closes a position and was asked to
grow, or the plan has finished; `ServiceUnavailableError` when the order
engine is not running; and another `UnifiedBrokerInterfaceError`
subclass for any other failure reported by, or on the way to, UBI.

#### Returns

The named list `TradeableInstrument$modify_order()` returns for a part,
with `parent_id`, `synthetic_type`, `part`, its `state`, the new
`price`, `trigger_price` and `quantity`, `outcome`, `status_message` and
`intent_id`.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    limit_price <- round(share$last_price * 0.97, 2)
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = limit_price,
      plan = OrderPart$new(
        presets = list(
          Preset$new(
            "bracket",
            stop_price = round(limit_price * 0.97, 2),
            stop_limit_price = round(limit_price * 0.96, 2),
            target_price = round(limit_price * 1.05, 2)
          )
        )
      )
    )
    order$place()
    tryCatch(
      {
        answer <- order$modify_part(
          "root.each_fill.children.0",
          trigger_price = round(limit_price * 0.95, 2),
          price = round(limit_price * 0.94, 2)
        )
        print(
          c(
            answer[["trigger_price"]],
            answer[["price"]],
            answer[["status_message"]]
          )
        )
      },
      finally = order$cancel()
    )

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    limit_price <- round(share$last_price * 0.97, 2)
    order <- PlanOrder$new(
      share,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1,
      price = limit_price,
      plan = OrderPart$new(
        presets = list(
          Preset$new(
            "bracket",
            stop_price = round(limit_price * 0.97, 2),
            stop_limit_price = round(limit_price * 0.96, 2),
            target_price = round(limit_price * 1.05, 2)
          )
        )
      )
    )
    order$place()
    tryCatch(
      {
        answer <- order$modify_part(
          "root.each_fill.children.1",
          price = round(limit_price * 1.08, 2),
          dry_run = TRUE
        )
        print(answer)
      },
      finally = order$cancel()
    )

------------------------------------------------------------------------

### `PlanOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    PlanOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 10,
  price = 1000.0,
  plan = ThenPart$new(
    first = OrderPart$new(),
    each_fill = OrderPart$new(
      side = "protect",
      pricing = TrailPricing$new(points = 5.0, limit_offset = 1.0)
    )
  ),
  dry_run = TRUE
)
answer <- order$place()

share <- Equity$new(exchange = "nse", symbol = "IDEA")
limit_price <- round(share$last_price * 0.97, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = limit_price,
  plan = ThenPart$new(
    first = OrderPart$new(),
    each_fill = OrderPart$new(
      side = "protect",
      pricing = NativeStopPricing$new(
        trigger_price = round(limit_price * 0.97, 2),
        limit_price = round(limit_price * 0.96, 2)
      )
    )
  )
)
order$place()
tryCatch(
  print(order$parts[, c("path", "state")]),
  finally = order$cancel()
)

share <- Equity$new(exchange = "nse", symbol = "IDEA")
level <- round(share$last_price * 0.95, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "market",
  quantity = 1,
  plan = OrderPart$new(
    trigger = PriceCrosses$new(level = level)
  )
)
order$place()
tryCatch(
  {
    parts <- order$parts
    waiting <- parts[parts$state == "waiting", ]
    print(waiting$path)
  },
  finally = order$cancel()
)
} # }

## ------------------------------------------------
## Method `PlanOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 13.0,
  plan = ThenPart$new(
    first = OrderPart$new(),
    each_fill = OrderPart$new(
      side = "protect",
      pricing = TrailPricing$new(points = 0.3, limit_offset = 0.05)
    )
  )
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = 12.9,
  plan = OrderPart$new(
    presets = list(
      Preset$new("market_if_touched", trigger_price = 12.9),
      Preset$new(
        "bracket",
        stop_price = 12.5,
        stop_limit_price = 12.45,
        target_price = 13.6
      )
    )
  )
)
print(order$synthetic)
} # }

## ------------------------------------------------
## Method `PlanOrder$cancel_part()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
limit_price <- round(share$last_price * 0.97, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = limit_price,
  plan = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = round(limit_price * 0.97, 2),
        stop_limit_price = round(limit_price * 0.96, 2),
        target_price = round(limit_price * 1.05, 2)
      )
    )
  )
)
order$place()
tryCatch(
  {
    answer <- order$cancel_part("root.each_fill.children.1")
    print(c(answer[["state"]], answer[["status_message"]]))
    print(order$parts[, c("path", "state")])
  },
  finally = order$cancel()
)

share <- Equity$new(exchange = "nse", symbol = "IDEA")
limit_price <- round(share$last_price * 0.97, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = limit_price,
  plan = OrderPart$new(
    presets = list(
      Preset$new(
        "cover",
        stop_price = round(limit_price * 0.97, 2),
        stop_limit_price = round(limit_price * 0.96, 2)
      )
    )
  )
)
order$place()
tryCatch(
  print(order$cancel_part("root.first", dry_run = TRUE)),
  finally = order$cancel()
)
} # }

## ------------------------------------------------
## Method `PlanOrder$modify_part()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
limit_price <- round(share$last_price * 0.97, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = limit_price,
  plan = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = round(limit_price * 0.97, 2),
        stop_limit_price = round(limit_price * 0.96, 2),
        target_price = round(limit_price * 1.05, 2)
      )
    )
  )
)
order$place()
tryCatch(
  {
    answer <- order$modify_part(
      "root.each_fill.children.0",
      trigger_price = round(limit_price * 0.95, 2),
      price = round(limit_price * 0.94, 2)
    )
    print(
      c(
        answer[["trigger_price"]],
        answer[["price"]],
        answer[["status_message"]]
      )
    )
  },
  finally = order$cancel()
)

share <- Equity$new(exchange = "nse", symbol = "IDEA")
limit_price <- round(share$last_price * 0.97, 2)
order <- PlanOrder$new(
  share,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1,
  price = limit_price,
  plan = OrderPart$new(
    presets = list(
      Preset$new(
        "bracket",
        stop_price = round(limit_price * 0.97, 2),
        stop_limit_price = round(limit_price * 0.96, 2),
        target_price = round(limit_price * 1.05, 2)
      )
    )
  )
)
order$place()
tryCatch(
  {
    answer <- order$modify_part(
      "root.each_fill.children.1",
      price = round(limit_price * 1.08, 2),
      dry_run = TRUE
    )
    print(answer)
  },
  finally = order$cancel()
)
} # }
```
