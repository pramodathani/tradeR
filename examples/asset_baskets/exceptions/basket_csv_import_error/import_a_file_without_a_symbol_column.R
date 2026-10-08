#' Import a CSV file that has no symbol column and handle the BasketCsvImportError.
#'
#' `BasketCsvImporter` needs a `symbol` column, or an `instrument_id` one, to know which instruments a file names. The program writes a small file whose column is called `ticker`, imports it, catches BasketCsvImportError, and prints the columns the file does have. The file is removed at the end, and nothing is saved to MongoDB, because the import stops before the basket is built.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_csv_import_error/import_a_file_without_a_symbol_column.R

library(tradeR)

#' An import of a CSV file whose instrument column has the wrong name.
#'
#' @field importer The `BasketCsvImporter` that reads the file.
#' @field lines A character vector of the lines the file holds.
MissingColumnImport <- R6::R6Class(
  "MissingColumnImport",
  public = list(
    importer = NULL,
    lines = NULL,

    #' @description
    #' Creates the importer and the file's lines.
    #' @return A new `MissingColumnImport` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$importer <- BasketCsvImporter$new()
      self$lines <- c(
        "ticker,weight",
        "IDEA,0.5",
        "BHARTIARTL,0.5"
      )
    },

    #' @description
    #' Writes the file, imports it and prints why it was refused.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the temporary file could not be written.
    run = function() {
      path <- tempfile(fileext = ".csv")
      writeLines(self$lines, path)
      basket <- tryCatch(
        self$importer$import_file(path, name = "Never saved example basket"),
        BasketCsvImportError = function(error) error,
        finally = {
          unlink(path)
        }
      )
      if (inherits(basket, "BasketCsvImportError")) {
        cat(sprintf("BasketCsvImportError: %s\n", conditionMessage(basket)))
        cat(sprintf("The file's columns are: %s\n", self$lines[[1]]))
        cat("Rename the ticker column to symbol and import it again.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Unexpectedly imported %s\n", basket$format()))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MissingColumnImport$new()$run()
}
