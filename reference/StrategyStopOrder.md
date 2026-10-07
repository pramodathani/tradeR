# A basket whose every leg is closed when the whole strategy's profit or loss crosses a line

It places its candidates the way a basket does, then marks every leg to
its last traded price on each tick and closes every leg when the total
falls to `loss_limit` or below or rises to `profit_target` or above.
Give at least one of the two. A quote marked stale marks nothing, so the
stop waits for a live one. When the stop acts, the basket's orders still
resting are cancelled, and whatever they fill before the cancel lands is
closed too, so the parent completes only once nothing of the basket
rests and every close has finished. A close the broker refuses is not
sent again, and the parent ends `failed`, because that leg is left open.
UBI never resolves references for this type. The first candidate's
instrument anchors the request.

The order template's attributes are described on `SyntheticOrder`, where
`instrument` is the first candidate's.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `StrategyStopOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `candidates`:

  The list of `OrderCandidate`, one per instrument.

- `hedge_benefit`:

  A logical that is `TRUE` to have UBI price options and futures on one
  underlying and expiry together, as a hedged whole, when it checks that
  the broker can afford the legs.

- `loss_limit`:

  The numeric loss in rupees for the whole strategy at or below which
  every leg is closed, below zero, or `NULL`.

- `profit_target`:

  The numeric profit in rupees for the whole strategy at or above which
  every leg is closed, above zero, or `NULL`.

## Methods

### Public methods

- [`StrategyStopOrder$new()`](#method-StrategyStopOrder-initialize)

- [`StrategyStopOrder$synthetic_fields()`](#method-StrategyStopOrder-synthetic_fields)

- [`StrategyStopOrder$clone()`](#method-StrategyStopOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `StrategyStopOrder$new()`

Initialises the candidates, the template they default to and this type's
own settings.

#### Usage

    StrategyStopOrder$new(
      candidates,
      transaction_type,
      product,
      order_type,
      quantity,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE,
      loss_limit = NULL,
      profit_target = NULL,
      hedge_benefit = FALSE
    )

#### Arguments

- `candidates`:

  The list of `OrderCandidate`, from 1 to 25, each on a different
  instrument.

- `transaction_type`:

  The character default side for every candidate, `"buy"` or `"sell"`.

- `product`:

  The character default product for every candidate, `"cnc"`, `"mis"` or
  `"nrml"`.

- `order_type`:

  The character default kind of order for every candidate, `"market"`,
  `"limit"`, `"sl"` or `"sl-m"`.

- `quantity`:

  The integer default quantity in underlying units for every candidate.

- `price`:

  The numeric default limit price in rupees for every candidate, or
  `NULL`. It is carried into a candidate that sets `order_type` to
  `market` unless that candidate sets its own price.

- `trigger_price`:

  The numeric default trigger price in rupees for every candidate, or
  `NULL`.

- `validity`:

  The character default validity, `"day"` or `"ioc"`, or `NULL` to let
  UBI use `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the orders as after-market orders.

- `tag`:

  A character default label of up to twenty letters and digits, or
  `NULL`.

- `closes_position`:

  A logical that is `TRUE` when every order this type sends closes a
  position, so it may use the share of a broker's daily order cap kept
  for exits.

- `reduce_only`:

  A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg
  that is not on the closing side of the net position held when it is
  sent or is bigger than that position.

- `hold_limits`:

  A logical that is `TRUE` to have UBI hold each order that would rest
  at the broker at a fixed limit price until the other side of the book
  reaches it, `FALSE` to send them as they come, or `NULL` to let UBI
  use the type's default.

- `dry_run`:

  A logical that is `TRUE` to have UBI check the order and answer with
  the `plan` it would run, without recording or sending anything; the
  answer's `request` is the template as a broker would receive it, which
  for a stop is not the stop.

- `loss_limit`:

  The numeric loss in rupees for the whole strategy at or below which
  every leg is closed, below zero, or `NULL`.

- `profit_target`:

  The numeric profit in rupees for the whole strategy at or above which
  every leg is closed, above zero, or `NULL`.

- `hedge_benefit`:

  A logical that is `TRUE` to have UBI price options and futures on one
  underlying and expiry together, as a hedged whole, when it checks that
  the broker can afford the legs, rather than adding every leg's margin
  up.

#### Details

Errors: signals `ValueError` when no candidate was given, so there is no
instrument to anchor the request.

#### Returns

A new `StrategyStopOrder` object.

------------------------------------------------------------------------

### `StrategyStopOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    StrategyStopOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, holding the candidates as UBI
reads them, where a value of `NULL` means the field is left out.

------------------------------------------------------------------------

### `StrategyStopOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    StrategyStopOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- StrategyStopOrder$new(
  candidates = list(
    OrderCandidate$new(reliance, price = 1450.0),
    OrderCandidate$new(infosys, price = 1500.0)
  ),
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 1,
  loss_limit = -5000.0,
  dry_run = TRUE
)
answer <- order$place()
} # }
```
