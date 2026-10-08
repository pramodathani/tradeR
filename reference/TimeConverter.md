# A converter between UBI's date and time text and R's date and time types

UBI writes dates as `YYYY-MM-DD` text and moments as ISO 8601 text with
an offset, such as `2026-09-29T09:15:00+05:30` or
`2026-09-29T03:45:00.123Z`, and some moments as seconds since 1970. This
class turns them into `Date` and `POSIXct` values in India time, the R
counterparts of the Python library's `datetime.date` and timezone-aware
`datetime` values, and gives today's date and the current moment in
India time.

## Methods

### Public methods

- [`TimeConverter$date()`](#method-TimeConverter-date)

- [`TimeConverter$dates()`](#method-TimeConverter-dates)

- [`TimeConverter$moments()`](#method-TimeConverter-moments)

- [`TimeConverter$from_epoch()`](#method-TimeConverter-from_epoch)

- [`TimeConverter$today()`](#method-TimeConverter-today)

- [`TimeConverter$now()`](#method-TimeConverter-now)

- [`TimeConverter$moment_on()`](#method-TimeConverter-moment_on)

- [`TimeConverter$iso_date()`](#method-TimeConverter-iso_date)

- [`TimeConverter$clone()`](#method-TimeConverter-clone)

------------------------------------------------------------------------

### `TimeConverter$date()`

Turns one ISO date into a `Date`.

#### Usage

    TimeConverter$date(value)

#### Arguments

- `value`:

  A `"YYYY-MM-DD"` character value, a `Date`, or `NULL`.

#### Details

Errors: signals a plain error when `value` is text that is not a valid
ISO date.

#### Returns

The `Date`, or `NULL` when `value` is `NULL` or empty.

------------------------------------------------------------------------

### `TimeConverter$dates()`

Turns ISO dates into a `Date` vector, keeping missing values missing.

#### Usage

    TimeConverter$dates(values)

#### Arguments

- `values`:

  A character vector of `"YYYY-MM-DD"` values, with `NA` or `""` for
  missing ones.

#### Returns

A `Date` vector the same length as `values`.

------------------------------------------------------------------------

### `TimeConverter$moments()`

Turns ISO 8601 moments with an offset into `POSIXct` values in India
time.

#### Usage

    TimeConverter$moments(values)

#### Arguments

- `values`:

  A character vector such as `"2026-09-29T09:15:00+05:30"` or
  `"2026-09-29T03:45:00.5Z"`, with `NA` for missing values. A value
  without an offset is read as India time.

#### Returns

A `POSIXct` vector in the `Asia/Kolkata` time zone, the same length as
`values`.

------------------------------------------------------------------------

### `TimeConverter$from_epoch()`

Turns seconds since 1970 into `POSIXct` values in India time.

#### Usage

    TimeConverter$from_epoch(seconds)

#### Arguments

- `seconds`:

  A numeric vector of seconds since 1970-01-01 UTC, with `NA` for
  missing values.

#### Returns

A `POSIXct` vector in the `Asia/Kolkata` time zone.

------------------------------------------------------------------------

### `TimeConverter$today()`

Gives today's date in India time.

#### Usage

    TimeConverter$today()

#### Returns

A `Date`.

------------------------------------------------------------------------

### `TimeConverter$now()`

Gives the current moment in India time.

#### Usage

    TimeConverter$now()

#### Returns

A `POSIXct` in the `Asia/Kolkata` time zone.

------------------------------------------------------------------------

### `TimeConverter$moment_on()`

Builds one moment from a date and a time of day in India time.

#### Usage

    TimeConverter$moment_on(date, time_of_day)

#### Arguments

- `date`:

  A `Date`.

- `time_of_day`:

  A `"HH:MM"` character value, such as `"15:30"`.

#### Returns

A `POSIXct` in the `Asia/Kolkata` time zone.

------------------------------------------------------------------------

### `TimeConverter$iso_date()`

Writes a date the way UBI and the Python library write it.

#### Usage

    TimeConverter$iso_date(value)

#### Arguments

- `value`:

  A `Date`, or `NULL`.

#### Returns

A `"YYYY-MM-DD"` character value, or `NULL` when `value` is `NULL`.

------------------------------------------------------------------------

### `TimeConverter$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TimeConverter$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
converter <- TimeConverter$new()
converter$date("2026-09-29")
#> [1] "2026-09-29"
converter$moments(c("2026-09-29T09:15:00+05:30", "2026-09-29T03:45:00Z"))
#> [1] "2026-09-29 09:15:00 IST" "2026-09-29 09:15:00 IST"
converter$today()
#> [1] "2026-10-08"
```
