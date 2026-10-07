ASSET_BASKETS_DETAILS_PATH <- "/api/instruments/details"
ASSET_BASKETS_IDENTITY_FIELDS <- c(
  "exchange",
  "segment",
  "symbol",
  "underlying_symbol",
  "expiry_date",
  "strike_price",
  "option_type"
)

#' A builder of basket members from rows that name their instruments
#'
#' @description
#' A stored basket, a CSV file and the account's holdings all describe their instruments as plain rows, each naming an instrument by `instrument_id` or by exchange, segment and identity fields, beside a weight or a quantity. `resolve()` sends every row to `POST /api/instruments/details` at once and builds each member's instrument from its entry of the answer, so a basket of five hundred instruments costs one request rather than five hundred.
#'
#' A row is a named list, such as `list(exchange = "nse", segment = "equities", symbol = "INFY", weight = 0.6)`.
#'
#' @examples
#' \dontrun{
#' resolver <- MemberResolver$new()
#' members <- resolver$resolve(
#'   list(
#'     list(exchange = "nse", segment = "equities", symbol = "INFY", weight = 0.6),
#'     list(exchange = "nse", segment = "equities", symbol = "TCS", weight = 0.4)
#'   )
#' )
#' }
#' @export
MemberResolver <- R6::R6Class(
  "MemberResolver",
  public = list(
    #' @field unified_broker_interface The `UnifiedBrokerInterface` the details request is sent through.
    unified_broker_interface = NULL,

    #' @description
    #' Initialises the resolver with the client it sends requests through.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to use, or `NULL` to share the one every instrument uses.
    #' @return A new `MemberResolver` object.
    #' @details Errors: signals a plain error when no client was given and the shared client's base url or MongoDB credentials are not configured.
    initialize = function(unified_broker_interface = NULL) {
      if (is.null(unified_broker_interface)) {
        unified_broker_interface <- Instrument$shared_unified_broker_interface()
      }
      self$unified_broker_interface <- unified_broker_interface
    },

    #' @description
    #' Looks every row's instrument up in UBI and returns one member per row.
    #'
    #' An index becomes a `NonTradeableInstrument` and anything else a `TradeableInstrument`. A row that names its instrument by `instrument_id` is looked up by that alone, and any other row by the identity fields it has.
    #' @param rows A list of named lists, each with `instrument_id` or `exchange`, `segment` and the identity fields its shape needs, and optionally `weight`, `quantity` and `average_price`.
    #' @return A list of `BasketMember` objects, in the order of `rows`.
    #' @details Errors: signals `BasketMemberError` when `rows` is empty, a row names no instrument, or UBI could not find one or more of the instruments, all of which the message lists; and a `UnifiedBrokerInterfaceError` subclass when the whole request was refused by, or failed on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' rows <- list(
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equities",
    #'     symbol = "INFY",
    #'     weight = 0.5
    #'   ),
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equities",
    #'     symbol = "TCS",
    #'     weight = 0.3
    #'   ),
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equity_indices",
    #'     symbol = "NIFTY",
    #'     weight = 0.2
    #'   )
    #' )
    #' for (member in MemberResolver$new()$resolve(rows)) {
    #'   cat(member$format(), class(member$instrument)[[1]], "\n")
    #' }
    #'
    #' rows <- list(
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equities",
    #'     symbol = "INFY"
    #'   ),
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equities",
    #'     symbol = "NOSUCHSHARE"
    #'   )
    #' )
    #' tryCatch(
    #'   MemberResolver$new()$resolve(rows),
    #'   BasketMemberError = function(error) print(conditionMessage(error))
    #' )
    #' }
    resolve = function(rows) {
      if (length(rows) == 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          "There are no rows to resolve"
        )
      }
      instrument_lookups <- list()
      for (row in rows) {
        instrument_lookups[[length(instrument_lookups) + 1]] <-
          private$lookup_for(row)
      }
      response <- self$unified_broker_interface$post(
        ASSET_BASKETS_DETAILS_PATH,
        body = list(
          instruments = instrument_lookups
        )
      )
      results <- response[["results"]]
      members <- list()
      failures <- character(0)
      for (row_index in seq_along(rows)) {
        row <- rows[[row_index]]
        result <- results[[row_index]]
        if (result[["status"]] != ASSET_BASKETS_SUCCESS_STATUS) {
          lookup <- instrument_lookups[[result[["request_index"]] + 1]]
          failures <- c(
            failures,
            sprintf(
              "%s: %s",
              private$python_repr(lookup),
              private$python_text(result[["error"]])
            )
          )
          next
        }
        instrument <- private$instrument_from(result[["data"]])
        members[[length(members) + 1]] <- BasketMember$new(
          instrument,
          weight = row[["weight"]],
          quantity = row[["quantity"]],
          average_price = row[["average_price"]]
        )
      }
      if (length(failures) > 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "UBI could not find %d of %d instruments: %s",
            length(failures),
            length(rows),
            paste(failures, collapse = "; ")
          )
        )
      }
      members
    },

    #' @description
    #' Looks one row's instrument up in UBI.
    #' @param row A named list with `instrument_id` or `exchange`, `segment` and the identity fields its shape needs.
    #' @return The `NonTradeableInstrument` for an index, or the `TradeableInstrument` for anything else.
    #' @details Errors: signals `BasketMemberError` when UBI could not find the instrument; and a `UnifiedBrokerInterfaceError` subclass when the request was refused by, or failed on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' resolver <- MemberResolver$new()
    #' idea <- resolver$resolve_one(
    #'   list(
    #'     exchange = "nse",
    #'     segment = "equities",
    #'     symbol = "IDEA"
    #'   )
    #' )
    #' cat(idea$instrument_id, idea$last_price, "\n")
    #'
    #' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
    #' same_index <- resolver$resolve_one(
    #'   list(
    #'     instrument_id = nifty$instrument_id
    #'   )
    #' )
    #' cat(class(same_index)[[1]], same_index$symbol, "\n")
    #' }
    resolve_one = function(row) {
      members <- self$resolve(
        list(
          row
        )
      )
      members[[1]]$instrument
    }
  ),
  private = list(
    # Picks the fields of a row that name its instrument.
    # @param row A named list naming one instrument, possibly with other keys such as `weight`.
    # @return A named list holding only `instrument_id` when the row has one, and otherwise every identity field the row gives a value for.
    # @details Errors: signals `BasketMemberError` when the row has neither an `instrument_id` nor an `exchange` and a `segment`.
    lookup_for = function(row) {
      if (!is.null(row[["instrument_id"]])) {
        return(
          list(
            instrument_id = row[["instrument_id"]]
          )
        )
      }
      lookup <- list()
      for (field in ASSET_BASKETS_IDENTITY_FIELDS) {
        if (!is.null(row[[field]])) {
          lookup[[field]] <- row[[field]]
        }
      }
      if (!("exchange" %in% names(lookup)) || !("segment" %in% names(lookup))) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "A row must give an instrument_id, or an exchange and a segment: row=%s",
            private$python_repr(row)
          )
        )
      }
      lookup
    },

    # Builds an instrument object from its details without asking UBI again.
    # @param details The named list UBI returned for one instrument from `/api/instruments/details`.
    # @return A `NonTradeableInstrument` for an index, or a `TradeableInstrument` for anything else.
    instrument_from = function(details) {
      if (endsWith(details[["segment"]], INSTRUMENTS_INDEX_SEGMENT_SUFFIX)) {
        return(
          NonTradeableInstrument$new(
            unified_broker_interface = self$unified_broker_interface,
            details = details
          )
        )
      }
      TradeableInstrument$new(
        unified_broker_interface = self$unified_broker_interface,
        details = details
      )
    },

    # Writes a value the way a Python f-string would, with `NULL` as `None`.
    # @param value A scalar or `NULL`.
    # @return A character value.
    python_text = function(value) {
      if (is.null(value)) {
        return("None")
      }
      as.character(value)
    },

    # Writes a value the way Python's `repr` writes it, so a named list reads like a dictionary.
    # @param value A named list, a scalar, a `Date` or `NULL`.
    # @return A character value such as `"{'exchange': 'nse', 'symbol': 'INFY'}"`.
    python_repr = function(value) {
      if (is.null(value)) {
        return("None")
      }
      if (is.list(value)) {
        pieces <- character(0)
        for (name in names(value)) {
          pieces <- c(
            pieces,
            sprintf("'%s': %s", name, private$python_repr(value[[name]]))
          )
        }
        return(sprintf("{%s}", paste(pieces, collapse = ", ")))
      }
      if (inherits(value, "Date")) {
        return(sprintf("'%s'", format(value, "%Y-%m-%d")))
      }
      if (is.character(value)) {
        return(sprintf("'%s'", value))
      }
      if (is.logical(value)) {
        if (isTRUE(value)) {
          return("True")
        }
        return("False")
      }
      if (is.integer(value)) {
        return(as.character(value))
      }
      if (is.numeric(value) && is.finite(value) && value == round(value) &&
            abs(value) < 1e16) {
        return(sprintf("%.1f", value))
      }
      format(value, digits = 15)
    }
  )
)
