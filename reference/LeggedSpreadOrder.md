# A two-legged spread worked passively on the first leg and completed on the second at the price that makes the net

The template's fields are the defaults each leg may override, and the
first leg's instrument anchors the request. The second leg follows every
fill of the first with a new order, in whole lots of its own instrument
rounded to the nearest lot, so a first leg of 75 Nifty units is matched
by 80 Sensex units. Each new order is priced so that the second leg's
orders together average the price the net needs, rounded to the second
leg's tick in your favour, down for a buy and up for a sell, and the
second leg's own `quantity`, `price` and `order_type` are not used. UBI
reads the second leg's instrument when the order arrives, so one that is
not mapped is refused with HTTP 404 before anything is sent. When the
second leg is refused, UBI cancels the rest of the first and the parent
ends `failed`, because what filled is left one-legged.

The order template's attributes are described on `SyntheticOrder`, where
`instrument` is the first leg's.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `LeggedSpreadOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `first_leg`:

  The `OrderCandidate` worked passively first.

- `second_leg`:

  The `OrderCandidate` taken as the first fills, whose own quantity,
  price and order type are not used.

- `net_price`:

  The numeric net debit per unit in rupees, positive when the spread
  costs money and negative when it brings money in.

## Methods

### Public methods

- [`LeggedSpreadOrder$new()`](#method-LeggedSpreadOrder-initialize)

- [`LeggedSpreadOrder$synthetic_fields()`](#method-LeggedSpreadOrder-synthetic_fields)

- [`LeggedSpreadOrder$clone()`](#method-LeggedSpreadOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `LeggedSpreadOrder$new()`

Initialises the two legs, the template they default to and the net
price.

#### Usage

    LeggedSpreadOrder$new(
      first_leg,
      second_leg,
      net_price,
      transaction_type,
      product,
      order_type,
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    )

#### Arguments

- `first_leg`:

  The `OrderCandidate` worked passively first.

- `second_leg`:

  The `OrderCandidate` taken as the first fills, on a different
  instrument, whose own quantity, price and order type are not used.

- `net_price`:

  The numeric net debit per unit in rupees, positive when the spread
  costs money and negative when it brings money in.

- `transaction_type`:

  The character default side for both legs, `"buy"` or `"sell"`.

- `product`:

  The character default product for both legs, `"cnc"`, `"mis"` or
  `"nrml"`.

- `order_type`:

  The character default kind of order for both legs, `"market"`,
  `"limit"`, `"sl"` or `"sl-m"`.

- `quantity`:

  The integer default quantity in underlying units for both legs.

- `price`:

  The numeric default limit price in rupees for both legs, or `NULL`.

- `validity`:

  The character default validity, `"day"` or `"ioc"`, or `NULL` to let
  UBI use `"day"`.

- `after_market`:

  A logical that is `TRUE` to send the orders as after-market orders.

- `tag`:

  A character default label of up to twenty letters and digits, or
  `NULL`.

- `closes_position`:

  A logical that is `TRUE` when both legs close positions, so they may
  use the share of a broker's daily order cap kept for exits.

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

#### Returns

A new `LeggedSpreadOrder` object.

------------------------------------------------------------------------

### `LeggedSpreadOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    LeggedSpreadOrder$synthetic_fields()

#### Returns

A named list holding the two legs as UBI's `candidates`, first leg
first, and the `net_price`.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- LeggedSpreadOrder$new(
      first_leg = OrderCandidate$new(share, price = 13.0),
      second_leg = OrderCandidate$new(
        second_share,
        transaction_type = "sell"
      ),
      net_price = -6.0,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- LeggedSpreadOrder$new(
      first_leg = OrderCandidate$new(second_share, price = 19.0),
      second_leg = OrderCandidate$new(
        share,
        transaction_type = "sell"
      ),
      net_price = 5.0,
      transaction_type = "buy",
      product = "mis",
      order_type = "limit",
      quantity = 1
    )
    fields <- order$synthetic_fields()
    for (leg in fields[["candidates"]]) {
      print(leg)
    }
    cat("net price", fields[["net_price"]], "\n")

------------------------------------------------------------------------

### `LeggedSpreadOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    LeggedSpreadOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- LeggedSpreadOrder$new(
  first_leg = OrderCandidate$new(
    nifty_call,
    transaction_type = "buy",
    price = 120.0
  ),
  second_leg = OrderCandidate$new(
    nifty_higher_call,
    transaction_type = "sell"
  ),
  net_price = 40.0,
  transaction_type = "buy",
  product = "nrml",
  order_type = "limit",
  quantity = 75,
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `LeggedSpreadOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- LeggedSpreadOrder$new(
  first_leg = OrderCandidate$new(share, price = 13.0),
  second_leg = OrderCandidate$new(
    second_share,
    transaction_type = "sell"
  ),
  net_price = -6.0,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- LeggedSpreadOrder$new(
  first_leg = OrderCandidate$new(second_share, price = 19.0),
  second_leg = OrderCandidate$new(
    share,
    transaction_type = "sell"
  ),
  net_price = 5.0,
  transaction_type = "buy",
  product = "mis",
  order_type = "limit",
  quantity = 1
)
fields <- order$synthetic_fields()
for (leg in fields[["candidates"]]) {
  print(leg)
}
cat("net price", fields[["net_price"]], "\n")
} # }
```
