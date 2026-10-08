#' Import a weighted index from a CSV file and compare it with the official index.
#'
#' The program writes a temporary CSV file in the style of an index factsheet, with `Symbol` and `Weight` columns for five IT shares, imports it as an index linked to the NSE's NIFTY IT index under the temporary name `example-index-csv-weighted`, prints the imported weights and today's move of the basket beside the official index's, and deletes the stored copy before it ends, whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_csv_importer/basket_csv_importer/import_weighted_index.R

library(tradeR)

NAME <- "example-index-csv-weighted"

EFFECTIVE_DATE <- "2026-09-01"

ROWS <- c(
  "Symbol,Weight",
  "INFY,28.5%",
  "TCS,24.0%",
  "HCLTECH,11.5%",
  "TECHM,9.0%",
  "WIPRO,7.0%"
)

#' A weighted index read from a CSV file and linked to the index it describes.
#'
#' @field importer The `BasketCsvImporter` that reads and stores the file.
#' @field nifty_it The `EquityIndex` for NIFTY IT, which the basket is linked to.
ImportWeightedIndex <- R6::R6Class(
  "ImportWeightedIndex",
  public = list(
    importer = NULL,
    nifty_it = NULL,

    #' @description
    #' Creates the importer and looks the official index up in UBI.
    #' @return A new `ImportWeightedIndex` object.
    #' @details Errors: signals `EquityIndexError` when UBI does not know the index.
    initialize = function() {
      self$importer <- BasketCsvImporter$new()
      self$nifty_it <- EquityIndex$new(exchange = "nse", symbol = "NIFTYIT")
    },

    #' @description
    #' Writes the rows to a temporary CSV file and imports it.
    #' @return The `AssetBasket` built from the file and stored, which is an `Index`.
    #' @details Errors: signals an `AssetBasketError` subclass when the file could not be turned into a basket, and a mongolite error when MongoDB could not be reached.
    import_rows = function() {
      directory <- tempfile("import_weighted_index_")
      dir.create(directory)
      on.exit(unlink(directory, recursive = TRUE), add = TRUE)
      path <- file.path(directory, "nifty_it_weights.csv")
      writeLines(ROWS, path)
      self$importer$import_file(
        path,
        name = NAME,
        kind = "index",
        linked_instrument = self$nifty_it,
        effective_date = EFFECTIVE_DATE,
        source = "example"
      )
    },

    #' @description
    #' Imports the file, prints the weights and today's moves, and deletes the stored copy.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals an `AssetBasketError` subclass when the file could not be turned into a basket, a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      basket <- self$import_rows()
      tryCatch(
        {
          cat(
            sprintf(
              "Imported %s with %s weights:\n",
              basket$format(),
              basket$weighting
            )
          )
          print(round(basket$weights, 3))
          cat(sprintf("Basket today: %+.2f%%\n", basket$day_change_percent))
          linked <- basket$linked_instrument
          cat(
            sprintf(
              "Linked index %s last at %s\n",
              linked$symbol,
              toString(linked$last_price)
            )
          )
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
  ImportWeightedIndex$new()$run()
}
