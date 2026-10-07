# Orders on several instruments placed in one request, each reported on its own

Each candidate is one order on its own instrument, and the template's
fields are the defaults each candidate may override. UBI places every
candidate and does nothing afterwards. It never resolves price or
quantity references for a basket, so give real numbers. The first
candidate's instrument anchors the request, and a dry run prepares only
that first candidate. A refused leg does not stop the legs after it, and
a leg UBI refuses after another was placed, even for a reason that might
pass later such as a contract size the brokers disagree on, answers HTTP
207 with the placed legs still watched. The same instrument may not
appear twice.

The order template's attributes are described on `SyntheticOrder`, where
`instrument` is the first candidate's.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `BasketOrder`

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

## Methods

### Public methods

- [`BasketOrder$new()`](#method-BasketOrder-initialize)

- [`BasketOrder$synthetic_fields()`](#method-BasketOrder-synthetic_fields)

- [`BasketOrder$clone()`](#method-BasketOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `BasketOrder$new()`

Initialises the candidates, the template they default to and this type's
own settings.

#### Usage

    BasketOrder$new(
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

- `hedge_benefit`:

  A logical that is `TRUE` to have UBI price options and futures on one
  underlying and expiry together, as a hedged whole, when it checks that
  the broker can afford the legs, rather than adding every leg's margin
  up.

#### Details

Errors: signals `ValueError` when no candidate was given, so there is no
instrument to anchor the request.

#### Returns

A new `BasketOrder` object.

------------------------------------------------------------------------

### `BasketOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    BasketOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, holding the candidates as UBI
reads them, where a value of `NULL` means the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- BasketOrder$new(
      candidates = list(
        OrderCandidate$new(share, price = 13.0),
        OrderCandidate$new(second_share, price = 19.0)
      ),
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- BasketOrder$new(
      candidates = list(
        OrderCandidate$new(share, price = 13.0),
        OrderCandidate$new(
          second_share,
          transaction_type = "sell",
          quantity = 2,
          price = 21.0
        )
      ),
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1
    )
    candidates <- order$synthetic_fields()[["candidates"]]
    cat(length(candidates), "legs\n")
    for (candidate in candidates) {
      print(candidate)
    }

------------------------------------------------------------------------

### `BasketOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BasketOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- BasketOrder$new(
  candidates = list(
    OrderCandidate$new(reliance, price = 1450.0),
    OrderCandidate$new(infosys, price = 1500.0)
  ),
  transaction_type = "buy",
  product = "cnc",
  order_type = "limit",
  quantity = 1,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `BasketOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- BasketOrder$new(
  candidates = list(
    OrderCandidate$new(share, price = 13.0),
    OrderCandidate$new(second_share, price = 19.0)
  ),
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- BasketOrder$new(
  candidates = list(
    OrderCandidate$new(share, price = 13.0),
    OrderCandidate$new(
      second_share,
      transaction_type = "sell",
      quantity = 2,
      price = 21.0
    )
  ),
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1
)
candidates <- order$synthetic_fields()[["candidates"]]
cat(length(candidates), "legs\n")
for (candidate in candidates) {
  print(candidate)
}
} # }
```
