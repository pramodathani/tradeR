# The catalogue of every error class the package signals

Builds R conditions that behave like the Python library's exception
classes. A condition's class vector is the error's own name followed by
each of its parents in turn, then `error` and `condition`, so a handler
for any ancestor catches it:

    tryCatch(
      Equity$new(exchange = "nse", symbol = "NOSUCHSHARE"),
      InstrumentError = function(error) conditionMessage(error)
    )

The parent of every error comes from `UTILITIES_LANGUAGE_ERROR_PARENTS`,
`UNIFIED_BROKER_INTERFACE_ERROR_PARENTS`, `ASSETS_ERROR_PARENTS` and
`ASSET_BASKETS_ERROR_PARENTS`. The functions `ErrorCatalogue$raise()`
and `ErrorCatalogue$name_of()` on the class generator are the usual way
in, so code never needs to create the object itself.

## Public fields

- `parents`:

  A named character vector mapping every error class name to its parent
  class name, with `error` as the parent of each root.

## Methods

### Public methods

- [`ErrorCatalogue$new()`](#method-ErrorCatalogue-initialize)

- [`ErrorCatalogue$class_vector()`](#method-ErrorCatalogue-class_vector)

- [`ErrorCatalogue$build()`](#method-ErrorCatalogue-build)

- [`ErrorCatalogue$raise()`](#method-ErrorCatalogue-raise)

- [`ErrorCatalogue$clone()`](#method-ErrorCatalogue-clone)

------------------------------------------------------------------------

### `ErrorCatalogue$new()`

Collects the parent of every error class the package defines.

#### Usage

    ErrorCatalogue$new()

#### Returns

A new `ErrorCatalogue` object.

------------------------------------------------------------------------

### `ErrorCatalogue$class_vector()`

Lists an error class with each of its ancestors, most specific first.

#### Usage

    ErrorCatalogue$class_vector(class_name)

#### Arguments

- `class_name`:

  A character name of an error class, such as `"NotFoundError"`.

#### Details

Errors: signals a plain error when `class_name` is not in the catalogue.

#### Returns

A character vector starting with `class_name` and ending with `"error"`
and `"condition"`.

------------------------------------------------------------------------

### `ErrorCatalogue$build()`

Builds one error condition without signalling it.

#### Usage

    ErrorCatalogue$build(
      class_name,
      message,
      status_code = NULL,
      detail = NULL,
      parent = NULL
    )

#### Arguments

- `class_name`:

  A character name of an error class, such as `"NotFoundError"`.

- `message`:

  A character message describing the failure.

- `status_code`:

  An integer HTTP status code, or `NULL` when no response arrived or
  none applies.

- `detail`:

  A named list holding the parsed body of UBI's answer, or `NULL` for an
  empty list.

- `parent`:

  A condition that caused this one, the R counterpart of Python's
  `raise ... from error`, or `NULL`.

#### Details

Errors: signals a plain error when `class_name` is not in the catalogue.

#### Returns

An R condition of class `class_vector(class_name)` with the fields
`message`, `call`, `status_code`, `detail` and `parent`.

------------------------------------------------------------------------

### `ErrorCatalogue$raise()`

Builds an error condition and signals it with
[`stop()`](https://rdrr.io/r/base/stop.html).

#### Usage

    ErrorCatalogue$raise(
      class_name,
      message,
      status_code = NULL,
      detail = NULL,
      parent = NULL
    )

#### Arguments

- `class_name`:

  A character name of an error class, such as `"NotFoundError"`.

- `message`:

  A character message describing the failure.

- `status_code`:

  An integer HTTP status code, or `NULL`.

- `detail`:

  A named list holding the parsed body of UBI's answer, or `NULL` for an
  empty list.

- `parent`:

  A condition that caused this one, or `NULL`.

#### Details

Errors: always signals the condition of class `class_name`.

#### Returns

Never returns.

------------------------------------------------------------------------

### `ErrorCatalogue$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ErrorCatalogue$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
