# The settings for one R session, read from the environment on first use

Reads the address of the Unified Broker Interface and the MongoDB
connection details from environment variables. The first read loads an
environment file, `.env` in the working directory unless another is
named, so that a variable already set in the environment is kept and one
set only in the file is added. Nothing is read when the object is
created.

The variable names are the ones the Python library `tradingmachine`
uses, so both projects can share one `.env` file and one MongoDB.

## Public fields

- `environment_file`:

  The character path of the environment file to load, or `NULL` for
  `.env` in the working directory.

## Active bindings

- `ubi_base_url`:

  The character address of the Unified Broker Interface, or `NULL` if it
  is not set.

- `mongodb_host`:

  The character host MongoDB is reachable on, or `NULL` if it is not
  set.

- `mongodb_port`:

  The character port MongoDB listens on, or `NULL` if it is not set.

- `mongodb_database_name`:

  The character name of the project's MongoDB database, or `NULL` if it
  is not set.

- `mongodb_username`:

  The character MongoDB user to authenticate as, or `NULL` if it is not
  set.

- `mongodb_password`:

  The character password for the MongoDB user, or `NULL` if it is not
  set.

- `mongodb_connection_string`:

  The character MongoDB URI built from the host, port, username and
  password, authenticating against the `admin` database.

## Methods

### Public methods

- [`Configuration$new()`](#method-Configuration-initialize)

- [`Configuration$reload()`](#method-Configuration-reload)

- [`Configuration$clone()`](#method-Configuration-clone)

------------------------------------------------------------------------

### `Configuration$new()`

Prepares the configuration without reading anything yet.

#### Usage

    Configuration$new(environment_file = NULL, load_environment_file = TRUE)

#### Arguments

- `environment_file`:

  A character path of the environment file to load, or `NULL` for `.env`
  in the working directory.

- `load_environment_file`:

  A logical that is `TRUE` to load the environment file on the first
  read, or `FALSE` to read only the environment.

#### Returns

A new `Configuration` object.

------------------------------------------------------------------------

### `Configuration$reload()`

Forgets that the environment file was loaded, so the next read loads it
again.

#### Usage

    Configuration$reload()

#### Returns

`NULL`, invisibly.

------------------------------------------------------------------------

### `Configuration$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Configuration$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
configuration <- Configuration$new()
configuration$ubi_base_url
configuration$mongodb_connection_string
} # }
```
