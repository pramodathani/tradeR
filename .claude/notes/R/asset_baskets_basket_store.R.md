# R/asset_baskets_basket_store.R

Port of `src/tradingmachine/asset_baskets/basket_store.py`, written on 2026-10-07.

The Python library chose MongoDB on 2026-09-28: `Configuration` already builds `mongodb_connection_string`, and one basket, a name with a list of members, fits naturally in one document. The R port uses the same database (from `TRADINGMACHINE_MONGODB_DB`), the same collection `asset_baskets`, the same field names and the same document shape, because both libraries share one MongoDB: a basket saved from Python must load in R and the other way round.

## One document per version

A document is identified by `name` and `effective_date`, with a unique index on the pair, because an index is rebalanced and a fund's holdings change, and the user may want to know what a basket held on a past day. `load()` finds the latest version on or before `as_of`. `save()` replaces a version stored for the same date, so importing a corrected file for the same day overwrites the mistake. The indexes are created on every `save()`, which MongoDB treats as a no-op when they exist.

`build()` reads `kind` and picks the class with a plain `if` chain. Every member is rebuilt in one `POST /api/instruments/details` through `MemberResolver`. The linked instrument is looked up separately unless the caller already has it, which is what `constituents` passes.

## How values are stored, checked against pymongo

| Field | What pymongo writes | What the R port writes |
|---|---|---|
| `effective_date`, `base_date`, a member's `expiry_date` | Text `"YYYY-MM-DD"` (the Python code calls `isoformat()` before storing) | The same text, so `$lte` compares them as strings in both |
| `updated_at` | `datetime.datetime.now(datetime.UTC)`, stored as a BSON date | `Sys.time()` in UTC, written as extended JSON `{"$date": <milliseconds>}`, which libbson stores as a BSON date. Checked offline with `mongolite:::bson_or_json()` and `mongolite:::bson_to_list()`: it comes back as `POSIXct` |
| A Python `float`, such as a weight, `base_value` or `unmapped_weight` | BSON double | BSON double, because the JSON is written with `always_decimal = TRUE` (`50` becomes `50.0`) and 17 significant digits, so a double survives exactly (`0.1 + 0.2` stays `0.30000000000000004`) |
| A Python `int`, such as a holding's quantity | BSON int32 or int64 | An R integer is written without a decimal point and stored as int32 |
| `None` | BSON null | `NULL` written as `null` |

Reading back, mongolite's `iterate()$one()` gives `NULL` for null, an unnamed list for an array, `integer` for int32, `numeric` for a double and `POSIXct` for a date, all confirmed with the offline BSON round trip above. Its default `fields = '{"_id":0}'` leaves `_id` out, where pymongo's `find_one` includes it; nothing reads `_id`.

## pymongo and mongolite calls

Python opens a fresh `MongoClient` in a `with` block for every operation. The R store makes one `mongolite::mongo()` connection on first use and keeps it, because mongolite holds a pooled client and reconnects by itself. The calls correspond as below; the mongolite signatures were read from the installed mongolite 4.1.0 (`mongolite:::mongo_object`).

| Python (pymongo) | R (mongolite) |
|---|---|
| `pymongo.MongoClient(uri)[database][collection]` | `mongolite::mongo(collection = "asset_baskets", db = database, url = uri)` |
| `collection.create_index([("name", 1), ("effective_date", 1)], unique=True)` and `create_index("linked_instrument_id")` | `collection$run('{"createIndexes": "asset_baskets", "indexes": [...]}')`, naming the indexes `name_1_effective_date_1` and `linked_instrument_id_1`, the names pymongo's `_gen_index_name` makes. mongolite's `index(add = ...)` cannot make a unique index, and an index made under a different name with the same keys would make MongoDB refuse the command |
| `collection.replace_one(filter, document, upsert=True)` | `collection$replace(query, update, upsert = TRUE)` |
| `collection.find_one(query, sort=[("effective_date", -1)])` | `collection$iterate(query, sort = '{"effective_date":-1}', limit = 1)$one()` |
| `collection.find({"name": name}, sort=[("effective_date", 1)])` | `collection$iterate(query, sort = '{"effective_date":1}')`, calling `$one()` until it gives `NULL` |
| `collection.distinct("name", query)` | `collection$distinct("name", query)` |
| `collection.delete_one(filter).deleted_count == 1` | `collection$count(query)`, then `collection$remove(query, just_one = TRUE)` when it is above zero |

`delete()` counts first because mongolite's `remove()` does not report how many documents it deleted: the disassembly of `R_mongo_collection_remove` in the installed `mongolite.so` shows it calls `mongoc_collection_remove` and returns `Rf_ScalarLogical(TRUE)`, so its answer is always `TRUE`. Counting and then removing could disagree only if another client deleted the same version in between, which this single-user project does not do.

## Testing without MongoDB

The constructor takes a third argument, `collection`, which Python does not have: any object with the mongolite methods above. Tests pass `FakeMongoCollection` from `tests/testthat/helper-fake_mongo_collection.R`, which keeps documents in memory, parses the JSON it is sent (turning `{"$date": ...}` into `POSIXct` as mongolite would), answers equality and `$lte` queries and a one-key sort, and records every call in `calls` so a test can check the exact JSON sent. `BasketCsvImporter` passes the same argument through. When `collection` is `NULL`, nothing connects until the first read or write, and a missing database name signals `ValueError` with Python's message.

## Other differences from Python

| Python | R | Why |
|---|---|---|
| `names()` returns a sorted Python list | A character vector sorted with `method = "radix"` | Radix sorting compares bytes, which matches Python's `sorted` on strings in any locale |
| `history()`'s `updated_at` column holds naive UTC datetimes | A `POSIXct` column in UTC, `NA` when a document has none | pymongo returns naive datetimes by default |
| Errors from MongoDB are `pymongo.errors.PyMongoError` | Plain errors from mongolite | mongolite signals ordinary R errors |
| `document.get("x") or default` | A private `is_given()` that treats `NULL`, `NA`, `""`, `0` and `FALSE` as not given | The same values Python's `or` skips |
| `_date_text(None)` is `datetime.date.today()` | `Sys.Date()` | Both use the machine's local date |

`save()` returns the stored document as a named list with `source` and `updated_at` added, like Python.
