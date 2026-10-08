#' Validate several CSV files by importing them, catching AssetBasketError for every file that is refused.
#'
#' The program writes three small files that are each wrong in a different way: one gives a weight to only some rows, one has only a header, and one has no symbol column. Importing each signals BasketCsvImportError, which is caught through its base class AssetBasketError, and the program prints the reason for each file. The files are removed at the end, and nothing is saved to MongoDB, because each import stops before the basket is built.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_csv_import_error/validate_several_files_before_importing.R

library(tradeR)

#' A check of several CSV files against what the importer accepts.
#'
#' @field importer The `BasketCsvImporter` that reads the files.
#' @field files A named list mapping each character description to a character vector of the lines its file holds.
#' @field directory The character path of the temporary directory the files are written to, or `NULL` before `run()`.
CsvFileValidation <- R6::R6Class(
  "CsvFileValidation",
  public = list(
    importer = NULL,
    files = NULL,
    directory = NULL,

    #' @description
    #' Creates the importer and the contents of the files.
    #' @return A new `CsvFileValidation` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$importer <- BasketCsvImporter$new()
      self$files <- list(
        "partial weights" = c(
          "symbol,weight",
          "IDEA,0.6",
          "BHARTIARTL,"
        ),
        "header only" = c(
          "symbol,weight"
        ),
        "no symbol column" = c(
          "name,weight",
          "Vodafone Idea,1.0"
        )
      )
      self$directory <- NULL
    },

    #' @description
    #' Writes one file, imports it and prints the outcome.
    #' @param description The character description of what is wrong with the file.
    #' @param lines A character vector of the lines the file holds.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when the file could not be written.
    check = function(description, lines) {
      file_name <- sprintf("%s.csv", gsub(" ", "_", description, fixed = TRUE))
      path <- file.path(self$directory, file_name)
      writeLines(lines, path)
      outcome <- tryCatch(
        self$importer$import_file(path, name = "Never saved example basket"),
        AssetBasketError = function(error) error
      )
      if (inherits(outcome, "AssetBasketError")) {
        cat(
          sprintf(
            "%s: %s: %s\n",
            description,
            ErrorCatalogue$name_of(outcome),
            conditionMessage(outcome)
          )
        )
        return(invisible(NULL))
      }
      cat(sprintf("%s: unexpectedly imported\n", description))
      invisible(NULL)
    },

    #' @description
    #' Checks every file in a temporary directory that is removed at the end.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error when a file could not be written.
    run = function() {
      self$directory <- tempfile("csv_file_validation_")
      dir.create(self$directory)
      tryCatch(
        {
          for (description in names(self$files)) {
            self$check(description, self$files[[description]])
          }
        },
        finally = {
          unlink(self$directory, recursive = TRUE)
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CsvFileValidation$new()$run()
}
