#' Resolve basket members from rows with a misspelt symbol, catching AssetBasketError.
#'
#' `MemberResolver` looks every row up in UBI in one request and signals BasketMemberError listing every row UBI could not find. The program resolves four rows, one of them misspelt, catches the error through its base class AssetBasketError, and resolves each row on its own to find which ones work.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exceptions/basket_member_error/resolve_members_with_a_misspelt_symbol.R

library(tradeR)

#' A resolution of basket rows, one of which names a share UBI does not know.
#'
#' @field resolver The `MemberResolver` that looks the rows up.
#' @field rows A list of the named list rows to resolve.
MisspeltMemberResolution <- R6::R6Class(
  "MisspeltMemberResolution",
  public = list(
    resolver = NULL,
    rows = NULL,

    #' @description
    #' Creates the resolver and the rows.
    #' @return A new `MisspeltMemberResolution` object.
    #' @details Errors: signals a plain error when the shared client is not configured.
    initialize = function() {
      self$resolver <- MemberResolver$new()
      symbols <- c(
        "IDEA",
        "BHARTIARTL",
        "INDUSTOWERS",
        "TATACOMM"
      )
      self$rows <- list()
      for (symbol in symbols) {
        self$rows[[length(self$rows) + 1]] <- list(
          exchange = "nse",
          segment = "equities",
          symbol = symbol
        )
      }
    },

    #' @description
    #' Resolves all rows at once, and one by one when that fails, printing the outcome.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      members <- tryCatch(
        self$resolver$resolve(self$rows),
        AssetBasketError = function(error) error
      )
      if (!inherits(members, "AssetBasketError")) {
        cat(sprintf("Resolved all %d members.\n", length(members)))
        return(invisible(NULL))
      }
      cat(
        sprintf(
          "%s: %s\n",
          ErrorCatalogue$name_of(members),
          conditionMessage(members)
        )
      )
      for (row in self$rows) {
        instrument <- tryCatch(
          self$resolver$resolve_one(row),
          AssetBasketError = function(error) error
        )
        if (inherits(instrument, "AssetBasketError")) {
          cat(sprintf("%s: not found\n", row[["symbol"]]))
          next
        }
        cat(sprintf("%s: %s\n", row[["symbol"]], instrument$instrument_id))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MisspeltMemberResolution$new()$run()
}
