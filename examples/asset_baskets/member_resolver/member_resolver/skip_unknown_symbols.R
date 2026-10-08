#' Resolve a list of symbols, report the ones UBI does not know, and keep the rest.
#'
#' The program tries to resolve a watch list typed by hand, which contains one misspelt symbol and one that was renamed. `MemberResolver$resolve()` refuses the whole list and names every failure in one error, so the program then resolves each symbol on its own with `resolve_one()`, keeps the ones UBI knows, and prints both groups.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/member_resolver/member_resolver/skip_unknown_symbols.R

library(tradeR)

SYMBOLS <- c(
  "INFY",
  "TCS",
  "INFOSYS",
  "SBIN",
  "HDFC"
)

#' A resolver run that separates the symbols UBI knows from the ones it does not.
#'
#' @field resolver The `MemberResolver` that looks the symbols up.
SkipUnknownSymbols <- R6::R6Class(
  "SkipUnknownSymbols",
  public = list(
    resolver = NULL,

    #' @description
    #' Creates the resolver on the shared UBI client.
    #' @return A new `SkipUnknownSymbols` object.
    #' @details Errors: signals a plain error when the shared UBI client is not configured.
    initialize = function() {
      self$resolver <- MemberResolver$new()
    },

    #' @description
    #' Describes one NSE share as a row.
    #' @param symbol The character NSE symbol.
    #' @return A named list with `exchange`, `segment` and `symbol`.
    row_for = function(symbol) {
      list(
        exchange = "nse",
        segment = "equities",
        symbol = symbol
      )
    },

    #' @description
    #' Tries the whole list, then each symbol alone, and prints what was found.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      rows <- list()
      for (symbol in SYMBOLS) {
        rows[[length(rows) + 1]] <- self$row_for(symbol)
      }
      outcome <- tryCatch(
        self$resolver$resolve(rows),
        BasketMemberError = function(error) error
      )
      if (!inherits(outcome, "BasketMemberError")) {
        cat("Every symbol is known.\n")
        return(invisible(NULL))
      }
      cat(
        sprintf("The whole list was refused: %s\n", conditionMessage(outcome))
      )
      known <- character(0)
      unknown <- character(0)
      for (symbol in SYMBOLS) {
        instrument <- tryCatch(
          self$resolver$resolve_one(self$row_for(symbol)),
          BasketMemberError = function(error) error
        )
        if (inherits(instrument, "BasketMemberError")) {
          unknown <- c(unknown, symbol)
          next
        }
        known <- c(known, instrument$symbol)
      }
      cat(sprintf("Known: %s\n", jsonlite::toJSON(known)))
      cat(sprintf("Unknown: %s\n", jsonlite::toJSON(unknown)))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SkipUnknownSymbols$new()$run()
}
