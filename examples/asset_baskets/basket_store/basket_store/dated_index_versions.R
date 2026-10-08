#' Keep two dated versions of an index and load the one in effect on a given day.
#'
#' The program stores two versions of an equal-weighted index under the temporary name `example-index-versions`: one from 1 January 2026 with two shares and one from 1 July 2026 with a third share added. It prints the stored history, loads the version in effect on 1 March and on today, and deletes both versions before it ends, whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_store/basket_store/dated_index_versions.R

library(tradeR)

NAME <- "example-index-versions"

FIRST_DATE <- "2026-01-01"

SECOND_DATE <- "2026-07-01"

#' Two stored versions of one index, as after a rebalance.
#'
#' @field store The `BasketStore` the versions are saved in.
DatedIndexVersions <- R6::R6Class(
  "DatedIndexVersions",
  public = list(
    store = NULL,

    #' @description
    #' Creates the store.
    #' @return A new `DatedIndexVersions` object.
    #' @details Errors: signals a plain error when the shared UBI client is not configured.
    initialize = function() {
      self$store <- BasketStore$new()
    },

    #' @description
    #' Builds an equal-weighted index of NSE shares.
    #' @param symbols A character vector of the NSE symbols to include.
    #' @return The `Index` of those shares.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    build_index = function(symbols) {
      members <- list()
      for (symbol in symbols) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(share)
      }
      Index$new(name = NAME, members = members, weighting = "equal")
    },

    #' @description
    #' Saves both versions, prints the history and two loads, then deletes both.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      first_version <- self$build_index(
        c(
          "INFY",
          "TCS"
        )
      )
      second_version <- self$build_index(
        c(
          "INFY",
          "TCS",
          "HCLTECH"
        )
      )
      tryCatch(
        {
          self$store$save(
            first_version,
            effective_date = FIRST_DATE,
            source = "example"
          )
          self$store$save(
            second_version,
            effective_date = SECOND_DATE,
            source = "example"
          )
          history <- self$store$history(NAME)
          columns <- c(
            "name",
            "kind",
            "effective_date",
            "size"
          )
          print(history[, columns])
          in_march <- self$store$load(NAME, as_of = "2026-03-01")
          cat(
            sprintf(
              "In effect on 2026-03-01: %s\n",
              jsonlite::toJSON(in_march$labels)
            )
          )
          today <- self$store$load(NAME)
          cat(
            sprintf("In effect today: %s\n", jsonlite::toJSON(today$labels))
          )
        },
        finally = {
          effective_dates <- c(
            FIRST_DATE,
            SECOND_DATE
          )
          for (effective_date in effective_dates) {
            self$store$delete(NAME, effective_date)
          }
          cat("History after deleting:\n")
          print(self$store$history(NAME))
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DatedIndexVersions$new()$run()
}
