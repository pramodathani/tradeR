# A standing instruction to trade one hedge instrument whenever the watched instruments' net exposure leaves a band

The instrument it is built on is the hedge, which is what it trades. UBI
works out the side and the quantity of each hedge from the exposure, so
the template carries placeholders for them. It answers HTTP 202 with an
`outcome` of `armed` and sends nothing until the exposure leaves the
band, so keep the `parent_id` from the answer. Each hedge is a whole
number of lots of the hedge instrument, rounded down, that brings the
total back towards the middle of the band. A hedge already sent counts
at once, so it is not sent again while the positions catch up: a resting
hedge counts for its whole quantity, and a finished one for what it
filled. UBI measures nothing while its positions document is missing,
more than a minute old, or marks a broker `stale` or `unreadable`, and
prices nothing from a quote marked stale, so the hedge waits rather than
trading on old numbers. When a hedge is refused, UBI stops watching and
cancels any hedge still resting, and the parent ends `failed` when
anything traded, or `rejected` when nothing did. When the hedge
instrument is also watched, UBI measures nothing after a hedge fills
until the positions document shows that broker's positions observed
after the fill, so a slow positions feed delays the next hedge rather
than undoing the last one.

The order template's attributes are described on `SyntheticOrder`, where
`instrument` is the hedge instrument.

## Super class

[`SyntheticOrder`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.md)
-\> `ExposureHedgeOrder`

## Public fields

- `SYNTHETIC_TYPE`:

  The character name UBI gives this synthetic type, sent as the `type`
  of the `synthetic` object.

- `watched`:

  The list of `ExposureWatch` whose positions are added up.

- `lower_band`:

  The numeric lowest net exposure allowed before a hedge is traded.

- `upper_band`:

  The numeric highest net exposure allowed before a hedge is traded.

- `hedge_exposure_per_unit`:

  The numeric exposure one unit of the hedge carries, or `NULL` to let
  UBI count 1.

## Methods

### Public methods

- [`ExposureHedgeOrder$new()`](#method-ExposureHedgeOrder-initialize)

- [`ExposureHedgeOrder$synthetic_fields()`](#method-ExposureHedgeOrder-synthetic_fields)

- [`ExposureHedgeOrder$clone()`](#method-ExposureHedgeOrder-clone)

Inherited methods

- [`SyntheticOrder$cancel()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-cancel)
- [`SyntheticOrder$place()`](https://pramodathani.github.io/tradeR/reference/SyntheticOrder.html#method-place)

------------------------------------------------------------------------

### `ExposureHedgeOrder$new()`

Initialises the hedge.

#### Usage

    ExposureHedgeOrder$new(
      hedge_instrument,
      watched,
      lower_band,
      upper_band,
      product,
      hedge_exposure_per_unit = NULL,
      validity = NULL,
      tag = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    )

#### Arguments

- `hedge_instrument`:

  The `TradeableInstrument` traded to bring the exposure back inside the
  band.

- `watched`:

  The list of `ExposureWatch` whose positions are added up.

- `lower_band`:

  The numeric lowest net exposure allowed, below `upper_band`.

- `upper_band`:

  The numeric highest net exposure allowed, above `lower_band`.

- `product`:

  The character product of the hedge orders, `"cnc"`, `"mis"` or
  `"nrml"`.

- `hedge_exposure_per_unit`:

  The numeric exposure one unit of the hedge carries, which must not be
  zero, or `NULL` to let UBI count 1.

- `validity`:

  The character validity of the hedge orders, `"day"` or `"ioc"`, or
  `NULL` to let UBI use `"day"`.

- `tag`:

  A character label of up to twenty letters and digits to label the
  request with, or `NULL`.

- `closes_position`:

  A logical that is `TRUE` when every hedge closes a position, so it may
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

  A logical that is `TRUE` to have UBI check the request and return it
  without recording or sending anything.

#### Returns

A new `ExposureHedgeOrder` object.

------------------------------------------------------------------------

### `ExposureHedgeOrder$synthetic_fields()`

Gives this type's own settings, the fields of the `synthetic` object
besides `type`.

#### Usage

    ExposureHedgeOrder$synthetic_fields()

#### Returns

A named list of UBI field names to values, holding the watched
instruments as UBI reads them and the hedge instrument's id, where a
value of `NULL` means the field is left out.

#### Examples

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- ExposureHedgeOrder$new(
      second_share,
      watched = list(
        ExposureWatch$new(share)
      ),
      lower_band = -5,
      upper_band = 5,
      product = "mis"
    )
    print(order$synthetic_fields())

    share <- Equity$new(exchange = "nse", symbol = "IDEA")
    second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    order <- ExposureHedgeOrder$new(
      second_share,
      watched = list(
        ExposureWatch$new(share, exposure_per_unit = 0.5)
      ),
      lower_band = -10,
      upper_band = 10,
      product = "mis",
      hedge_exposure_per_unit = 2.0
    )
    fields <- order$synthetic_fields()
    print(fields[["hedge_instrument_id"]] == second_share$instrument_id)
    print(fields[["watched"]])

------------------------------------------------------------------------

### `ExposureHedgeOrder$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ExposureHedgeOrder$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
order <- ExposureHedgeOrder$new(
  nifty_future,
  watched = list(
    ExposureWatch$new(nifty_call, exposure_per_unit = 0.5),
    ExposureWatch$new(nifty_put, exposure_per_unit = -0.4)
  ),
  lower_band = -75.0,
  upper_band = 75.0,
  product = "nrml",
  dry_run = TRUE
)
answer <- order$place()
} # }

## ------------------------------------------------
## Method `ExposureHedgeOrder$synthetic_fields()`
## ------------------------------------------------

if (FALSE) { # \dontrun{
share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- ExposureHedgeOrder$new(
  second_share,
  watched = list(
    ExposureWatch$new(share)
  ),
  lower_band = -5,
  upper_band = 5,
  product = "mis"
)
print(order$synthetic_fields())

share <- Equity$new(exchange = "nse", symbol = "IDEA")
second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
order <- ExposureHedgeOrder$new(
  second_share,
  watched = list(
    ExposureWatch$new(share, exposure_per_unit = 0.5)
  ),
  lower_band = -10,
  upper_band = 10,
  product = "mis",
  hedge_exposure_per_unit = 2.0
)
fields <- order$synthetic_fields()
print(fields[["hedge_instrument_id"]] == second_share$instrument_id)
print(fields[["watched"]])
} # }
```
