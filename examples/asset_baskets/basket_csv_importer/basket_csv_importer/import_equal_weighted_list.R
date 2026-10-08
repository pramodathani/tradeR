#' Import a plain list of symbols, as the NSE publishes it, into an equally weighted index.
#'
#' The program writes a temporary CSV file shaped like the NSE's free constituent lists, with a `Symbol` column and no weights, imports it under the temporary name `example-index-csv-equal`, shows that it was stored with equal weights, loads it back from MongoDB, prints its level of 100 over the last month, and deletes the stored copy before it ends, whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_csv_importer/basket_csv_importer/import_equal_weighted_list.R

library(tradeR)

NAME <- "example-index-csv-equal"

EFFECTIVE_DATE <- "2026-09-01"

ROWS <- c(
  "Company Name,Industry,Symbol,Series,ISIN Code",
  "HDFC Bank Ltd.,Financial Services,HDFCBANK,EQ,INE040A01034",
  "ICICI Bank Ltd.,Financial Services,ICICIBANK,EQ,INE090A01021",
  "Axis Bank Ltd.,Financial Services,AXISBANK,EQ,INE238A01034",
  "State Bank of India,Financial Services,SBIN,EQ,INE062A01020"
)

#' An equally weighted index read from a list of symbols without weights.
#'
#' @field importer The `BasketCsvImporter` that reads and stores the file.
ImportEqualWeightedList <- R6::R6Class(
  "ImportEqualWeightedList",
  public = list(
    importer = NULL,

    #' @description
    #' Creates the importer.
    #' @return A new `ImportEqualWeightedList` object.
    #' @details Errors: signals a plain error when the shared UBI client is not configured.
    initialize = function() {
      self$importer <- BasketCsvImporter$new()
    },

    #' @description
    #' Writes the rows to a CSV file.
    #' @param directory The character path of the directory to write the file in.
    #' @return The character path of the file written.
    #' @details Errors: signals a plain error when the file could not be written.
    write_file = function(directory) {
      path <- file.path(directory, "ind_banks_list.csv")
      writeLines(ROWS, path)
      path
    },

    #' @description
    #' Imports the file, loads it back, prints its level, and deletes the stored copy.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals an `AssetBasketError` subclass when the file could not be turned into a basket, a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      directory <- tempfile("import_equal_weighted_list_")
      dir.create(directory)
      tryCatch(
        {
          path <- self$write_file(directory)
          basket <- self$importer$import_file(
            path,
            name = NAME,
            effective_date = EFFECTIVE_DATE,
            source = "example"
          )
        },
        finally = {
          unlink(directory, recursive = TRUE)
        }
      )
      tryCatch(
        {
          cat(
            sprintf(
              "Imported %s with %s weights\n",
              basket$format(),
              basket$weighting
            )
          )
          loaded <- self$importer$store$load(NAME)
          rounded_weights <- as.list(round(loaded$weights, 2))
          cat(
            sprintf(
              "Loaded back: %s, weights %s\n",
              loaded$format(),
              jsonlite::toJSON(rounded_weights, auto_unbox = TRUE)
            )
          )
          frame <- loaded$prices(days = 30)
          columns <- c(
            "datetime",
            "close"
          )
          recent <- utils::tail(frame[, columns])
          recent$close <- round(recent$close, 2)
          print(recent)
        },
        finally = {
          self$importer$store$delete(NAME, EFFECTIVE_DATE)
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ImportEqualWeightedList$new()$run()
}
