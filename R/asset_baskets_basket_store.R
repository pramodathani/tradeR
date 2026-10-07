ASSET_BASKETS_COLLECTION_NAME <- "asset_baskets"
ASSET_BASKETS_HISTORY_COLUMNS <- c(
  "name",
  "kind",
  "effective_date",
  "source",
  "size",
  "linked_instrument_id",
  "updated_at"
)
ASSET_BASKETS_NAME_DATE_INDEX <- "name_1_effective_date_1"
ASSET_BASKETS_LINKED_INSTRUMENT_INDEX <- "linked_instrument_id_1"

#' The collection of baskets kept in the project's MongoDB
#'
#' @description
#' UBI knows nothing about what an index or a fund holds, so baskets are kept in this project's own MongoDB, in the `asset_baskets` collection of the database `Configuration` names. Each document is one version of one basket, identified by its `name` and the `effective_date` it takes effect, because an index is rebalanced and a fund's holdings change every month; `load()` finds the version in effect on a given day. A document names each member by its UBI `instrument_id` beside its readable identity fields, and `load()` rebuilds every member in one list request.
#'
#' The `kind` field of a document decides which class `load()` builds: `portfolio`, `watchlist`, `index`, `exchange_traded_fund_constituents`, `mutual_fund_constituents`, or `basket` for a plain `AssetBasket`. `load_for_instrument()` finds the basket whose `linked_instrument_id` is a given instrument, which is how `constituents` on an index or a fund finds its contents.
#'
#' The store shares its collection and document shape with the Python library `tradingmachine`, so a basket saved from Python loads here and the other way round. Dates are stored as `"YYYY-MM-DD"` text and `updated_at` as a MongoDB date, exactly as Python stores them.
#'
#' @examples
#' \dontrun{
#' store <- BasketStore$new()
#' store$save(my_index, effective_date = "2026-09-30", source = "csv")
#' nifty_basket <- store$load("NIFTY")
#' every_index <- store$names(kind = "index")
#' }
#' @export
BasketStore <- R6::R6Class(
  "BasketStore",
  public = list(
    #' @field unified_broker_interface The `UnifiedBrokerInterface` that rebuilt baskets send their requests through.
    unified_broker_interface = NULL,

    #' @description
    #' Initialises the store with the configuration it connects with.
    #'
    #' Nothing connects to MongoDB until the first read or write.
    #' @param project_configuration The `Configuration` to read the MongoDB settings from, or `NULL` to build one that reads the environment and the `.env` file.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` for rebuilt baskets, or `NULL` to share the one every instrument uses.
    #' @param collection A collection object with the methods of a `mongolite::mongo()` connection to use instead of connecting, such as a stand-in for tests, or `NULL` to connect to the `asset_baskets` collection of the configured database on first use.
    #' @return A new `BasketStore` object.
    initialize = function(
      project_configuration = NULL,
      unified_broker_interface = NULL,
      collection = NULL
    ) {
      if (is.null(project_configuration)) {
        project_configuration <- Configuration$new()
      }
      private$configuration <- project_configuration
      private$resolver <- MemberResolver$new(unified_broker_interface)
      self$unified_broker_interface <- private$resolver$unified_broker_interface
      private$mongo_collection <- collection
    },

    #' @description
    #' Stores a basket as the version of its name in effect from a date, replacing any version already stored for that date.
    #' @param basket The `AssetBasket` to store.
    #' @param effective_date The first day this version is in effect as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @param source The character name of where the members came from, such as `"user"`, `"csv"` or `"nse"`.
    #' @return The named list document that was stored, with `source` and `updated_at`, a `POSIXct` in UTC.
    #' @details Errors: signals `ValueError` when the project's MongoDB database name is not configured; and a plain error from mongolite when MongoDB could not be reached or refused the write.
    #' @examples
    #' \dontrun{
    #' shares <- list(
    #'   Equity$new(exchange = "nse", symbol = "IDEA"),
    #'   Equity$new(exchange = "nse", symbol = "INFY")
    #' )
    #' store <- BasketStore$new()
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-save",
    #'   instruments = shares
    #' )
    #' document <- store$save(followed, source = "example")
    #' tryCatch(
    #'   {
    #'     cat(document$name, document$kind, document$effective_date, "\n")
    #'     print(length(document$members))
    #'   },
    #'   finally = store$delete(document$name, document$effective_date)
    #' )
    #'
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-versions",
    #'   instruments = shares
    #' )
    #' dates <- c(
    #'   "2026-01-01",
    #'   "2026-07-01"
    #' )
    #' tryCatch(
    #'   {
    #'     for (effective_date in dates) {
    #'       store$save(followed, effective_date = effective_date)
    #'     }
    #'     print(store$history("example-watchlist-versions")$effective_date)
    #'   },
    #'   finally = {
    #'     for (effective_date in dates) {
    #'       store$delete("example-watchlist-versions", effective_date)
    #'     }
    #'   }
    #' )
    #' }
    save = function(basket, effective_date = NULL, source = "user") {
      document <- basket$document(effective_date)
      document[["source"]] <- source
      updated_at <- Sys.time()
      attr(updated_at, "tzone") <- "UTC"
      document[["updated_at"]] <- updated_at
      collection <- private$collection()
      collection$run(private$create_indexes_command())
      collection$replace(
        private$json_text(
          list(
            name = document[["name"]],
            effective_date = document[["effective_date"]]
          )
        ),
        private$json_text(document),
        upsert = TRUE
      )
      document
    },

    #' @description
    #' Rebuilds the version of a basket in effect on a day.
    #' @param name The character name of the basket.
    #' @param as_of The day as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @return The `AssetBasket` subclass the stored `kind` names, with its members rebuilt in one request.
    #' @details Errors: signals `BasketNotFoundError` when no version of the basket is in effect on that day; `BasketMemberError` when UBI could not find one or more of the stored instruments; `AssetBasketError` when the stored kind is not one this store knows; and a plain error from mongolite when MongoDB could not be reached.
    #' @examples
    #' \dontrun{
    #' shares <- list(
    #'   Equity$new(exchange = "nse", symbol = "IDEA"),
    #'   Equity$new(exchange = "nse", symbol = "INFY")
    #' )
    #' store <- BasketStore$new()
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-load",
    #'   instruments = shares
    #' )
    #' document <- store$save(followed)
    #' tryCatch(
    #'   {
    #'     loaded <- store$load("example-watchlist-load")
    #'     print(loaded)
    #'     print(loaded$labels)
    #'   },
    #'   finally = store$delete(document$name, document$effective_date)
    #' )
    #'
    #' tryCatch(
    #'   store$load("example-watchlist-never-saved"),
    #'   BasketNotFoundError = function(error) print(conditionMessage(error))
    #' )
    #' }
    load = function(name, as_of = NULL) {
      document <- private$find_document(
        list(
          name = name
        ),
        as_of
      )
      if (is.null(document)) {
        ErrorCatalogue$raise(
          "BasketNotFoundError",
          sprintf(
            "No basket named '%s' is in effect on %s",
            name,
            private$date_text(as_of)
          )
        )
      }
      self$build(document)
    },

    #' @description
    #' Rebuilds the basket that describes an instrument's contents, such as the members of an index.
    #' @param instrument The `Instrument` whose contents to find, which becomes the basket's `linked_instrument`.
    #' @param as_of The day as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @return The `AssetBasket` subclass the stored `kind` names, or `NULL` when no basket describes the instrument on that day.
    #' @details Errors: signals `BasketMemberError` when UBI could not find one or more of the stored instruments; `AssetBasketError` when the stored kind is not one this store knows; and a plain error from mongolite when MongoDB could not be reached.
    #' @examples
    #' \dontrun{
    #' nifty_it <- EquityIndex$new(exchange = "nse", symbol = "NIFTYIT")
    #' members <- list()
    #' for (symbol in c(
    #'   "INFY",
    #'   "TCS"
    #' )) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(share)
    #' }
    #' it_index <- Index$new(
    #'   name = "example-index-linked",
    #'   members = members,
    #'   weighting = "equal",
    #'   linked_instrument = nifty_it
    #' )
    #' store <- BasketStore$new()
    #' document <- store$save(it_index)
    #' tryCatch(
    #'   {
    #'     found <- store$load_for_instrument(nifty_it)
    #'     print(found)
    #'     print(found$linked_instrument$symbol)
    #'   },
    #'   finally = store$delete(document$name, document$effective_date)
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' print(BasketStore$new()$load_for_instrument(idea))
    #' }
    load_for_instrument = function(instrument, as_of = NULL) {
      document <- private$find_document(
        list(
          linked_instrument_id = instrument$instrument_id
        ),
        as_of
      )
      if (is.null(document)) {
        return(NULL)
      }
      self$build(document, linked_instrument = instrument)
    },

    #' @description
    #' Lists the names of the stored baskets.
    #' @param kind The character kind to list, such as `"index"`, or `NULL` for every kind.
    #' @return A sorted character vector of basket names.
    #' @details Errors: signals a plain error from mongolite when MongoDB could not be reached.
    #' @examples
    #' \dontrun{
    #' print(BasketStore$new()$names())
    #'
    #' shares <- list(
    #'   Equity$new(exchange = "nse", symbol = "IDEA"),
    #'   Equity$new(exchange = "nse", symbol = "INFY")
    #' )
    #' store <- BasketStore$new()
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-names",
    #'   instruments = shares
    #' )
    #' document <- store$save(followed)
    #' tryCatch(
    #'   print("example-watchlist-names" %in% store$names(kind = "watchlist")),
    #'   finally = store$delete(document$name, document$effective_date)
    #' )
    #' }
    names = function(kind = NULL) {
      query <- list()
      if (!is.null(kind)) {
        query[["kind"]] <- kind
      }
      found <- private$collection()$distinct("name", private$json_text(query))
      found <- as.character(unlist(found))
      sort(found, method = "radix")
    },

    #' @description
    #' Lists every stored version of a basket.
    #' @param name The character name of the basket.
    #' @return A `data.frame` with one row per version, oldest first, holding `name`, `kind`, `effective_date`, `source`, `size`, `linked_instrument_id` and `updated_at`, or `NULL` when no version is stored.
    #' @details Errors: signals a plain error from mongolite when MongoDB could not be reached.
    #' @examples
    #' \dontrun{
    #' shares <- list(
    #'   Equity$new(exchange = "nse", symbol = "IDEA"),
    #'   Equity$new(exchange = "nse", symbol = "INFY")
    #' )
    #' store <- BasketStore$new()
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-history",
    #'   instruments = shares
    #' )
    #' store$save(followed, effective_date = "2026-03-01", source = "example")
    #' store$save(followed, effective_date = "2026-06-01", source = "example")
    #' tryCatch(
    #'   {
    #'     history <- store$history("example-watchlist-history")
    #'     print(history[, c("name", "effective_date", "source", "size")])
    #'   },
    #'   finally = {
    #'     store$delete("example-watchlist-history", "2026-03-01")
    #'     store$delete("example-watchlist-history", "2026-06-01")
    #'   }
    #' )
    #'
    #' print(BasketStore$new()$history("example-watchlist-never-saved"))
    #' }
    history = function(name) {
      iterator <- private$collection()$iterate(
        private$json_text(
          list(
            name = name
          )
        ),
        sort = private$json_text(
          list(
            effective_date = 1L
          )
        )
      )
      names_column <- character(0)
      kinds <- character(0)
      effective_dates <- character(0)
      sources <- character(0)
      sizes <- integer(0)
      linked_instrument_ids <- character(0)
      updated_seconds <- numeric(0)
      document <- iterator$one()
      while (!is.null(document)) {
        names_column <- c(
          names_column,
          document[["name"]]
        )
        kinds <- c(
          kinds,
          private$text_or_missing(document[["kind"]])
        )
        effective_dates <- c(
          effective_dates,
          document[["effective_date"]]
        )
        sources <- c(
          sources,
          private$text_or_missing(document[["source"]])
        )
        sizes <- c(
          sizes,
          length(document[["members"]])
        )
        linked_instrument_ids <- c(
          linked_instrument_ids,
          private$text_or_missing(document[["linked_instrument_id"]])
        )
        updated_at <- document[["updated_at"]]
        if (is.null(updated_at)) {
          updated_seconds <- c(
            updated_seconds,
            NA_real_
          )
        } else {
          updated_seconds <- c(
            updated_seconds,
            as.numeric(updated_at)
          )
        }
        document <- iterator$one()
      }
      if (length(names_column) == 0) {
        return(NULL)
      }
      data.frame(
        name = names_column,
        kind = kinds,
        effective_date = effective_dates,
        source = sources,
        size = sizes,
        linked_instrument_id = linked_instrument_ids,
        updated_at = as.POSIXct(
          updated_seconds,
          origin = "1970-01-01",
          tz = "UTC"
        )
      )
    },

    #' @description
    #' Deletes one stored version of a basket.
    #' @param name The character name of the basket.
    #' @param effective_date The version's effective date as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @return A logical that is `TRUE` when a version was deleted and `FALSE` when none matched.
    #' @details Errors: signals a plain error from mongolite when MongoDB could not be reached.
    #' @examples
    #' \dontrun{
    #' shares <- list(
    #'   Equity$new(exchange = "nse", symbol = "IDEA"),
    #'   Equity$new(exchange = "nse", symbol = "INFY")
    #' )
    #' store <- BasketStore$new()
    #' followed <- Watchlist$new(
    #'   name = "example-watchlist-delete",
    #'   instruments = shares
    #' )
    #' document <- store$save(followed, effective_date = "2026-09-01")
    #' print(store$delete("example-watchlist-delete", "2026-09-01"))
    #'
    #' print(store$delete("example-watchlist-missing", as.Date("2026-09-01")))
    #' }
    delete = function(name, effective_date) {
      query <- private$json_text(
        list(
          name = name,
          effective_date = private$date_text(effective_date)
        )
      )
      collection <- private$collection()
      matching_count <- collection$count(query)
      if (matching_count == 0) {
        return(FALSE)
      }
      collection$remove(query, just_one = TRUE)
      TRUE
    },

    #' @description
    #' Builds the basket a stored document describes, as the class its `kind` names.
    #' @param document A named list in the form `AssetBasket$document()` gives, with a `members` list naming each instrument.
    #' @param linked_instrument The `Instrument` to link the basket to, or `NULL` to look up the document's `linked_instrument_id` when it has one.
    #' @return The `AssetBasket` subclass the document's `kind` names.
    #' @details Errors: signals `BasketMemberError` when the document has no members, or UBI could not find one or more of its instruments; and `AssetBasketError` when the document's kind is not one this store knows.
    #' @examples
    #' \dontrun{
    #' document <- list(
    #'   name = "two IT shares",
    #'   kind = "index",
    #'   weighting = "equal",
    #'   members = list(
    #'     list(
    #'       exchange = "nse",
    #'       segment = "equities",
    #'       symbol = "INFY"
    #'     ),
    #'     list(
    #'       exchange = "nse",
    #'       segment = "equities",
    #'       symbol = "TCS"
    #'     )
    #'   )
    #' )
    #' basket <- BasketStore$new()$build(document)
    #' print(basket)
    #' print(basket$weights)
    #'
    #' document <- list(
    #'   name = "mystery",
    #'   kind = "hedge_fund",
    #'   members = list(
    #'     list(
    #'       exchange = "nse",
    #'       segment = "equities",
    #'       symbol = "INFY"
    #'     )
    #'   )
    #' )
    #' tryCatch(
    #'   BasketStore$new()$build(document),
    #'   AssetBasketError = function(error) print(conditionMessage(error))
    #' )
    #' }
    build = function(document, linked_instrument = NULL) {
      member_rows <- document[["members"]]
      if (is.null(member_rows)) {
        member_rows <- list()
      }
      members <- private$resolver$resolve(member_rows)
      linked_instrument_id <- document[["linked_instrument_id"]]
      has_linked_id <- private$is_given(linked_instrument_id)
      if (is.null(linked_instrument) && has_linked_id) {
        linked_instrument <- private$resolver$resolve_one(
          list(
            instrument_id = linked_instrument_id
          )
        )
      }
      kind <- document[["kind"]]
      if (is.null(kind)) {
        kind <- AssetBasket$KIND
      }
      name <- document[["name"]]
      unmapped_weight <- document[["unmapped_weight"]]
      if (!private$is_given(unmapped_weight)) {
        unmapped_weight <- 0
      }
      if (kind == Portfolio$KIND) {
        return(
          Portfolio$new(
            name = name,
            members = members,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      if (kind == Watchlist$KIND) {
        held_instruments <- list()
        for (member in members) {
          held_instruments[[length(held_instruments) + 1]] <- member$instrument
        }
        return(
          Watchlist$new(
            name = name,
            instruments = held_instruments,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      if (kind == Index$KIND) {
        weighting <- document[["weighting"]]
        if (!private$is_given(weighting)) {
          weighting <- ASSET_BASKETS_STATED_WEIGHTING
        }
        base_value <- document[["base_value"]]
        if (!private$is_given(base_value)) {
          base_value <- ASSET_BASKETS_DEFAULT_BASE_VALUE
        }
        return(
          Index$new(
            name = name,
            members = members,
            weighting = weighting,
            base_value = base_value,
            base_date = document[["base_date"]],
            linked_instrument = linked_instrument,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      if (kind == ExchangeTradedFundConstituents$KIND) {
        indicative_net_asset_value <- NULL
        value_id <- document[["indicative_net_asset_value_instrument_id"]]
        if (private$is_given(value_id)) {
          indicative_net_asset_value <- private$resolver$resolve_one(
            list(
              instrument_id = value_id
            )
          )
        }
        return(
          ExchangeTradedFundConstituents$new(
            name = name,
            members = members,
            fund = linked_instrument,
            indicative_net_asset_value = indicative_net_asset_value,
            unmapped_weight = unmapped_weight,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      if (kind == MutualFundConstituents$KIND) {
        return(
          MutualFundConstituents$new(
            name = name,
            members = members,
            fund = linked_instrument,
            unmapped_weight = unmapped_weight,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      if (kind == AssetBasket$KIND) {
        return(
          AssetBasket$new(
            name = name,
            members = members,
            linked_instrument = linked_instrument,
            unmapped_weight = unmapped_weight,
            unified_broker_interface = self$unified_broker_interface
          )
        )
      }
      ErrorCatalogue$raise(
        "AssetBasketError",
        sprintf(
          "The basket '%s' is stored with a kind this store does not know: kind='%s'",
          name,
          kind
        )
      )
    }
  ),
  private = list(
    configuration = NULL,
    resolver = NULL,
    mongo_collection = NULL,

    # Finds the latest stored version matching a query that is in effect on a day.
    # @param query A named list MongoDB query, such as one on `name` or `linked_instrument_id`.
    # @param as_of The day as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    # @return The named list document, or `NULL` when no matching version is in effect on that day.
    # @details Errors: signals a plain error from mongolite when MongoDB could not be reached.
    find_document = function(query, as_of) {
      dated_query <- query
      dated_query[["effective_date"]] <- list(
        "$lte" = private$date_text(as_of)
      )
      iterator <- private$collection()$iterate(
        private$json_text(dated_query),
        sort = private$json_text(
          list(
            effective_date = -1L
          )
        ),
        limit = 1
      )
      iterator$one()
    },

    # Gives the baskets collection, connecting to MongoDB on first use unless a collection was given.
    # @return The collection object, a `mongolite::mongo()` connection unless one was given to the constructor.
    # @details Errors: signals `ValueError` when the project's MongoDB database name is not configured, and a plain error from mongolite when MongoDB could not be reached.
    collection = function() {
      if (!is.null(private$mongo_collection)) {
        return(private$mongo_collection)
      }
      database_name <- private$configuration$mongodb_database_name
      if (is.null(database_name) || identical(database_name, "")) {
        ErrorCatalogue$raise(
          "ValueError",
          "The project's MongoDB database name is not configured"
        )
      }
      private$mongo_collection <- mongolite::mongo(
        collection = ASSET_BASKETS_COLLECTION_NAME,
        db = database_name,
        url = private$configuration$mongodb_connection_string
      )
      private$mongo_collection
    },

    # Builds the `createIndexes` command that makes the two indexes Python's `create_index` calls make, under the same names.
    # @return A character JSON command.
    create_indexes_command = function() {
      command <- list(
        createIndexes = ASSET_BASKETS_COLLECTION_NAME,
        indexes = list(
          list(
            key = list(
              name = 1L,
              effective_date = 1L
            ),
            name = ASSET_BASKETS_NAME_DATE_INDEX,
            unique = TRUE
          ),
          list(
            key = list(
              linked_instrument_id = 1L
            ),
            name = ASSET_BASKETS_LINKED_INSTRUMENT_INDEX
          )
        )
      )
      private$json_text(command)
    },

    # Writes a named list as the extended JSON mongolite reads, with doubles kept as doubles and a `POSIXct` as a MongoDB date.
    # @param value A named list, possibly empty.
    # @return A character JSON object, `"{}"` for an empty list.
    json_text = function(value) {
      if (length(value) == 0) {
        return("{}")
      }
      as.character(
        jsonlite::toJSON(
          private$unboxed_dates(value),
          auto_unbox = TRUE,
          null = "null",
          na = "null",
          digits = I(17),
          always_decimal = TRUE,
          POSIXt = "mongo"
        )
      )
    },

    # Marks every single `POSIXct` value in a nested list as a scalar, so it is written as `{"$date": ...}` rather than inside an array.
    # @param value Any value.
    # @return The value with each single `POSIXct` wrapped by `jsonlite::unbox()`.
    unboxed_dates = function(value) {
      if (inherits(value, "POSIXct") && length(value) == 1) {
        return(jsonlite::unbox(value))
      }
      if (is.list(value)) {
        for (index in seq_along(value)) {
          element <- value[[index]]
          if (!is.null(element)) {
            value[[index]] <- private$unboxed_dates(element)
          }
        }
      }
      value
    },

    # Turns a day into the `YYYY-MM-DD` form the documents store, defaulting to today.
    # @param value A `Date`, a `"YYYY-MM-DD"` character value, or `NULL` for today.
    # @return The character date in `YYYY-MM-DD` form.
    date_text = function(value) {
      if (is.null(value)) {
        return(format(Sys.Date(), "%Y-%m-%d"))
      }
      if (inherits(value, "Date")) {
        return(format(value, "%Y-%m-%d"))
      }
      value
    },

    # Tells whether a stored value counts as given, the way Python's truth test does for the `or` defaults.
    # @param value A stored value or `NULL`.
    # @return A logical that is `FALSE` for `NULL`, `NA`, an empty string, zero and `FALSE`, and `TRUE` otherwise.
    is_given = function(value) {
      if (is.null(value) || length(value) == 0) {
        return(FALSE)
      }
      if (is.na(value)) {
        return(FALSE)
      }
      if (is.character(value)) {
        return(value != "")
      }
      if (is.numeric(value) || is.logical(value)) {
        return(value != 0)
      }
      TRUE
    },

    # Turns a stored text value into one cell of a character column.
    # @param value A character value or `NULL`.
    # @return The character value, or `NA` when `value` is `NULL`.
    text_or_missing = function(value) {
      if (is.null(value)) {
        return(NA_character_)
      }
      as.character(value)
    }
  )
)
