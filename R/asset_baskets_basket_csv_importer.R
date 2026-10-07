ASSET_BASKETS_REQUIRED_COLUMN <- "symbol"
ASSET_BASKETS_NUMBER_COLUMNS <- c(
  "weight",
  "quantity"
)
ASSET_BASKETS_CSV_MISSING_VALUES <- c(
  "",
  "#N/A",
  "#N/A N/A",
  "#NA",
  "-1.#IND",
  "-1.#QNAN",
  "-NaN",
  "-nan",
  "1.#IND",
  "1.#QNAN",
  "<NA>",
  "N/A",
  "NA",
  "NULL",
  "NaN",
  "None",
  "n/a",
  "nan",
  "null"
)

#' A reader of CSV files into stored baskets
#'
#' @description
#' `import_file()` reads a CSV with a `symbol` column and, optionally, `exchange`, `segment`, `weight`, `quantity` and `instrument_id` columns, looks every row's instrument up in UBI in one list request, builds the basket as the class its `kind` names, and saves it through `BasketStore`. Column names are read without regard to case or surrounding spaces, so the constituent files the NSE publishes, whose header has `Symbol`, import as they are. A row without an exchange or a segment takes the ones given to `import_file()`.
#'
#' A file without a `weight` column makes an equally weighted index, recorded with `weighting` set to `"equal"`, because the NSE's free constituent files carry no weights. Weights may be fractions or percentages, since every basket normalises them. Scripts that download constituents and weights are meant to call this same importer.
#'
#' The file is read the way the Python library reads it with pandas: every value as text, leading spaces after a comma skipped, and the same words, such as `NA`, `N/A` and `null`, read as an empty cell.
#'
#' @examples
#' \dontrun{
#' importer <- BasketCsvImporter$new()
#' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
#' basket <- importer$import_file(
#'   "ind_nifty50list.csv",
#'   name = "NIFTY",
#'   kind = "index",
#'   linked_instrument = nifty,
#'   effective_date = "2026-09-30"
#' )
#' }
#' @export
BasketCsvImporter <- R6::R6Class(
  "BasketCsvImporter",
  public = list(
    #' @field store The `BasketStore` the imported baskets are saved to.
    store = NULL,

    #' @description
    #' Initialises the importer with the store it saves to.
    #' @param project_configuration The `Configuration` to read the MongoDB settings from, or `NULL` to build one that reads the environment and the `.env` file.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to look instruments up through, or `NULL` to share the one every instrument uses.
    #' @param collection A collection object with the methods of a `mongolite::mongo()` connection for the store to use instead of connecting, such as a stand-in for tests, or `NULL` to connect on first use.
    #' @return A new `BasketCsvImporter` object.
    initialize = function(
      project_configuration = NULL,
      unified_broker_interface = NULL,
      collection = NULL
    ) {
      self$store <- BasketStore$new(
        project_configuration = project_configuration,
        unified_broker_interface = unified_broker_interface,
        collection = collection
      )
    },

    #' @description
    #' Reads a CSV file, builds the basket it describes and saves it.
    #' @param path The character path of the CSV file.
    #' @param name The character name to store the basket under, such as `"NIFTY"`.
    #' @param kind The character kind of basket to build, such as `"index"`, `"portfolio"` or `"mutual_fund_constituents"`.
    #' @param exchange The character exchange of any row that does not give one.
    #' @param segment The character segment of any row that does not give one, such as `"equities"`.
    #' @param linked_instrument The `Instrument` whose contents the file describes, such as the NIFTY index, or `NULL`.
    #' @param effective_date The first day the basket is in effect as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @param unmapped_weight The numeric share of a fund, between 0 and 1, held outside the listed instruments.
    #' @param source The character name of where the file came from, stored with the basket.
    #' @return The `AssetBasket` that was built and saved.
    #' @details Errors: signals `BasketCsvImportError` when the file has no `symbol` column, has no rows, or gives a weight or quantity to only some rows; `ValueError` when a weight or quantity is not a number; `BasketMemberError` when UBI could not find one or more of the instruments, all of which the message lists; `AssetBasketError` when `kind` is not one the store knows; a plain error when the file cannot be read; and a plain error from mongolite when MongoDB could not be reached or refused the write.
    #' @examples
    #' \dontrun{
    #' importer <- BasketCsvImporter$new()
    #' directory <- tempfile()
    #' dir.create(directory)
    #' path <- file.path(directory, "it.csv")
    #' writeLines(
    #'   c(
    #'     "Symbol,Weight",
    #'     "INFY,50",
    #'     "TCS,30",
    #'     "HCLTECH,20"
    #'   ),
    #'   path
    #' )
    #' basket <- importer$import_file(
    #'   path,
    #'   name = "example-index-csv",
    #'   effective_date = "2026-09-01"
    #' )
    #' unlink(directory, recursive = TRUE)
    #' tryCatch(
    #'   {
    #'     cat(basket$format(), basket$weighting, "\n")
    #'     print(basket$weights)
    #'   },
    #'   finally = importer$store$delete("example-index-csv", "2026-09-01")
    #' )
    #'
    #' directory <- tempfile()
    #' dir.create(directory)
    #' path <- file.path(directory, "banks.csv")
    #' writeLines(
    #'   c(
    #'     "Symbol",
    #'     "HDFCBANK",
    #'     "ICICIBANK"
    #'   ),
    #'   path
    #' )
    #' basket <- importer$import_file(
    #'   path,
    #'   name = "example-index-csv-equal",
    #'   effective_date = "2026-09-01",
    #'   source = "example"
    #' )
    #' unlink(directory, recursive = TRUE)
    #' tryCatch(
    #'   {
    #'     print(basket$weighting)
    #'     print(basket$weights)
    #'   },
    #'   finally = importer$store$delete("example-index-csv-equal", "2026-09-01")
    #' )
    #'
    #' directory <- tempfile()
    #' dir.create(directory)
    #' path <- file.path(directory, "wrong.csv")
    #' writeLines(
    #'   c(
    #'     "Company,Weight",
    #'     "Infosys,100"
    #'   ),
    #'   path
    #' )
    #' tryCatch(
    #'   importer$import_file(path, name = "example-index-csv-wrong"),
    #'   BasketCsvImportError = function(error) print(conditionMessage(error))
    #' )
    #' unlink(directory, recursive = TRUE)
    #' }
    import_file = function(
      path,
      name,
      kind = "index",
      exchange = "nse",
      segment = "equities",
      linked_instrument = NULL,
      effective_date = NULL,
      unmapped_weight = 0,
      source = "csv"
    ) {
      frame <- private$read_file(path)
      if (!(ASSET_BASKETS_REQUIRED_COLUMN %in% names(frame)) &&
            !("instrument_id" %in% names(frame))) {
        ErrorCatalogue$raise(
          "BasketCsvImportError",
          sprintf(
            "The file has no %s column: %s",
            ASSET_BASKETS_REQUIRED_COLUMN,
            as.character(path)
          )
        )
      }
      rows <- private$rows_from(frame, exchange, segment, path)
      weighting <- ASSET_BASKETS_STATED_WEIGHTING
      if (is.null(rows[[1]][["weight"]])) {
        weighting <- ASSET_BASKETS_EQUAL_WEIGHTING
      }
      document <- list(
        name = name,
        kind = kind,
        unmapped_weight = unmapped_weight,
        weighting = weighting,
        members = rows
      )
      basket <- self$store$build(
        document,
        linked_instrument = linked_instrument
      )
      self$store$save(basket, effective_date = effective_date, source = source)
      basket
    }
  ),
  private = list(
    #' Reads a CSV file as text, the way pandas reads it with `dtype=str` and `skipinitialspace=True`.
    #' @param path The character path of the CSV file.
    #' @return A `data.frame` of character columns with lower-case, stripped column names, where a cell pandas reads as missing is `NA`.
    #' @details Errors: signals a plain error when the file cannot be read.
    read_file = function(path) {
      frame <- utils::read.csv(
        path,
        colClasses = "character",
        na.strings = character(0),
        check.names = FALSE,
        strip.white = FALSE,
        fileEncoding = "UTF-8-BOM"
      )
      names(frame) <- tolower(trimws(names(frame)))
      for (column in names(frame)) {
        values <- sub("^ +", "", frame[[column]])
        values[values %in% ASSET_BASKETS_CSV_MISSING_VALUES] <- NA_character_
        frame[[column]] <- values
      }
      frame
    },

    #' Turns the CSV's rows into rows that name instruments.
    #' @param frame The `data.frame` read from the file, with lower-case column names and every value as text.
    #' @param exchange The character exchange of any row that does not give one.
    #' @param segment The character segment of any row that does not give one.
    #' @param path The character path of the file, for error messages.
    #' @return A list of named lists, one per row with a symbol or an instrument id, each with `instrument_id` when the file gives one, then `symbol`, `exchange`, `segment`, `weight` and `quantity`, the last two numeric or `NULL`.
    #' @details Errors: signals `BasketCsvImportError` when the file has no rows, or gives a weight or quantity to only some rows; and `ValueError` when a weight or quantity is not a number.
    rows_from = function(frame, exchange, segment, path) {
      rows <- list()
      for (row_index in seq_len(nrow(frame))) {
        row <- list()
        symbol <- private$text(
          private$cell(frame, ASSET_BASKETS_REQUIRED_COLUMN, row_index)
        )
        instrument_id <- private$text(
          private$cell(frame, "instrument_id", row_index)
        )
        if (is.null(symbol) && is.null(instrument_id)) {
          next
        }
        if (!is.null(instrument_id)) {
          row[["instrument_id"]] <- instrument_id
        }
        row["symbol"] <- list(symbol)
        row_exchange <- private$text(private$cell(frame, "exchange", row_index))
        if (is.null(row_exchange)) {
          row_exchange <- exchange
        }
        row[["exchange"]] <- row_exchange
        row_segment <- private$text(private$cell(frame, "segment", row_index))
        if (is.null(row_segment)) {
          row_segment <- segment
        }
        row[["segment"]] <- row_segment
        for (column in ASSET_BASKETS_NUMBER_COLUMNS) {
          value <- private$text(private$cell(frame, column, row_index))
          if (is.null(value)) {
            row[column] <- list(NULL)
          } else {
            row[[column]] <- private$number(value)
          }
        }
        rows[[length(rows) + 1]] <- row
      }
      if (length(rows) == 0) {
        ErrorCatalogue$raise(
          "BasketCsvImportError",
          sprintf("The file has no rows: %s", as.character(path))
        )
      }
      for (column in ASSET_BASKETS_NUMBER_COLUMNS) {
        given_count <- 0
        for (row in rows) {
          if (!is.null(row[[column]])) {
            given_count <- given_count + 1
          }
        }
        if (given_count > 0 && given_count < length(rows)) {
          ErrorCatalogue$raise(
            "BasketCsvImportError",
            sprintf(
              "Only %d of %d rows give a %s: %s",
              given_count,
              length(rows),
              column,
              as.character(path)
            )
          )
        }
      }
      rows
    },

    #' Reads one cell of the file, treating a column the file lacks as an empty cell.
    #' @param frame The `data.frame` read from the file.
    #' @param column The character column name.
    #' @param row_index The integer row number.
    #' @return The character cell, or `NA` when the column is missing or the cell is empty.
    cell = function(frame, column, row_index) {
      if (!(column %in% names(frame))) {
        return(NA_character_)
      }
      frame[[column]][[row_index]]
    },

    #' Cleans one CSV value, treating an empty cell as missing.
    #' @param value The cell's value, a character value or `NA`.
    #' @return The character value without surrounding spaces, or `NULL` when the cell is empty.
    text = function(value) {
      if (is.null(value) || is.na(value)) {
        return(NULL)
      }
      cleaned <- trimws(as.character(value))
      if (cleaned == "") {
        return(NULL)
      }
      cleaned
    },

    #' Reads a weight or quantity, allowing thousands separators and a trailing percent sign.
    #' @param value The cleaned character cell.
    #' @return The numeric value.
    #' @details Errors: signals `ValueError` when the text is not a number.
    number = function(value) {
      cleaned <- gsub(",", "", value, fixed = TRUE)
      cleaned <- sub("%+$", "", cleaned)
      parsed <- suppressWarnings(as.numeric(cleaned))
      not_a_number_words <- c(
        "nan",
        "-nan",
        "+nan"
      )
      is_nan_word <- tolower(trimws(cleaned)) %in% not_a_number_words
      if (is.na(parsed) && !is_nan_word) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("could not convert string to float: '%s'", cleaned)
        )
      }
      parsed
    }
  )
)
