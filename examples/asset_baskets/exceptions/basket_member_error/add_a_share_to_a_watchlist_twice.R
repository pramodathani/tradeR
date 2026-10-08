#' Build a watchlist that names one share twice and handle the BasketMemberError.
#'
#' A basket may hold each instrument only once. The program builds a watchlist from a list of shares in which IDEA appears twice, catches BasketMemberError, removes the repeat and builds the watchlist again.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_member_error/add_a_share_to_a_watchlist_twice.R

library(tradeR)

#' A watchlist built from a list of shares that repeats one.
#'
#' @field shares A list of `Equity` objects, with IDEA twice.
DuplicateWatchlist <- R6::R6Class(
  "DuplicateWatchlist",
  public = list(
    shares = NULL,

    #' @description
    #' Looks the shares up.
    #' @return A new `DuplicateWatchlist` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    initialize = function() {
      symbols <- c(
        "IDEA",
        "BHARTIARTL",
        "IDEA"
      )
      self$shares <- list()
      for (symbol in symbols) {
        self$shares[[length(self$shares) + 1]] <- Equity$new(
          exchange = "nse",
          symbol = symbol
        )
      }
    },

    #' @description
    #' Keeps the first of each share.
    #' @return A list of `Equity` objects with each instrument once.
    without_repeats = function() {
      seen_instrument_ids <- character(0)
      unique_shares <- list()
      for (share in self$shares) {
        if (share$instrument_id %in% seen_instrument_ids) {
          next
        }
        seen_instrument_ids <- c(seen_instrument_ids, share$instrument_id)
        unique_shares[[length(unique_shares) + 1]] <- share
      }
      unique_shares
    },

    #' @description
    #' Builds the watchlist, recovers from the repeat and prints the members.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when the watchlist without repeats is still refused.
    run = function() {
      telecom_watchlist <- tryCatch(
        Watchlist$new(
          name = "Telecom example",
          instruments = self$shares
        ),
        BasketMemberError = function(error) error
      )
      if (inherits(telecom_watchlist, "BasketMemberError")) {
        cat(
          sprintf(
            "BasketMemberError: %s\n",
            conditionMessage(telecom_watchlist)
          )
        )
        telecom_watchlist <- Watchlist$new(
          name = "Telecom example",
          instruments = self$without_repeats()
        )
      }
      cat(sprintf("Built %s\n", telecom_watchlist$format()))
      for (label in telecom_watchlist$labels) {
        cat(sprintf("  %s\n", label))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  DuplicateWatchlist$new()$run()
}
