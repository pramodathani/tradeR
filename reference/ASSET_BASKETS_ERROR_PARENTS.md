# The errors the asset basket classes signal

Each name is an error class and each value is its parent class.
`AssetBasketError` is the root.

## Usage

``` r
ASSET_BASKETS_ERROR_PARENTS
```

## Format

A named character vector, one entry per error class:

- `AssetBasketError`:

  A failure in building, reading, storing or trading an asset basket.

- `BasketNotFoundError`:

  No stored basket has the requested name, or none is in effect on the
  requested date.

- `BasketMemberError`:

  A basket's members are unusable, such as an instrument UBI cannot
  find, an instrument named twice, or weights given for only some
  members.

- `BasketCsvImportError`:

  A CSV file could not be turned into a basket, such as one without a
  `symbol` column.
