#' Store a watchlist in MongoDB, read it back, and remove it.
#'
#' The program builds a watchlist of three shares under the temporary name `example-watchlist-round-trip`, saves it through `BasketStore`, lists the stored watchlists, loads it back as a `Watchlist`, ranks its members by today's move, and deletes the stored copy before it ends, whatever happens.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/basket_store/basket_store/watchlist_round_trip.R

library(tradeR)

NAME <- "example-watchlist-round-trip"

SYMBOLS <- c(
  "IDEA",
  "INFY",
  "SBIN"
)

#' A watchlist saved to the basket store and loaded back.
#'
#' @field store The `BasketStore` the watchlist is saved in.
#' @field followed The `Watchlist` that is saved.
WatchlistRoundTrip <- R6::R6Class(
  "WatchlistRoundTrip",
  public = list(
    store = NULL,
    followed = NULL,

    #' @description
    #' Looks the shares up in UBI and builds the watchlist.
    #' @return A new `WatchlistRoundTrip` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      self$store <- BasketStore$new()
      shares <- list()
      for (symbol in SYMBOLS) {
        shares[[length(shares) + 1]] <- Equity$new(
          exchange = "nse",
          symbol = symbol
        )
      }
      self$followed <- Watchlist$new(name = NAME, instruments = shares)
    },

    #' @description
    #' Saves, lists, loads and ranks the watchlist, then deletes it.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      document <- self$store$save(self$followed, source = "example")
      cat(
        sprintf(
          "Saved %s for %s\n",
          document[["name"]],
          document[["effective_date"]]
        )
      )
      tryCatch(
        {
          cat(
            sprintf(
              "Stored watchlists: %s\n",
              jsonlite::toJSON(self$store$names(kind = "watchlist"))
            )
          )
          loaded <- self$store$load(NAME)
          cat(
            sprintf(
              "Loaded %s with %s\n",
              loaded$format(),
              jsonlite::toJSON(loaded$labels)
            )
          )
          ranked <- loaded$rank_by("change_percent")
          columns <- c(
            "label",
            "last_price",
            "change_percent"
          )
          print(ranked[, columns])
        },
        finally = {
          deleted <- self$store$delete(
            document[["name"]],
            document[["effective_date"]]
          )
          cat(sprintf("Deleted the stored copy: %s\n", deleted))
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  WatchlistRoundTrip$new()$run()
}
