#' Turn rows naming shares, a fund and an index into basket members with one request.
#'
#' The program describes a small allocation as plain rows, the way a stored basket or a CSV file does: two shares and a gold fund by exchange, segment and symbol, and the NIFTY index by the instrument id a previous lookup gave. It resolves every row in one request to UBI and prints each member with the class of instrument it became and its last price.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/member_resolver/member_resolver/resolve_mixed_rows.R

library(tradeR)

#' A resolver run over rows of several kinds.
#'
#' @field resolver The `MemberResolver` that looks the rows up.
ResolveMixedRows <- R6::R6Class(
  "ResolveMixedRows",
  public = list(
    resolver = NULL,

    #' @description
    #' Creates the resolver on the shared UBI client.
    #' @return A new `ResolveMixedRows` object.
    #' @details Errors: signals a plain error when the shared UBI client is not configured.
    initialize = function() {
      self$resolver <- MemberResolver$new()
    },

    #' @description
    #' Builds the rows, looking the NIFTY index up first to name it by its id.
    #' @return A list of named lists, each naming one instrument and giving its weight.
    #' @details Errors: signals `BasketMemberError` when UBI could not find the NIFTY index.
    rows = function() {
      nifty <- self$resolver$resolve_one(
        list(
          exchange = "nse",
          segment = "equity_indices",
          symbol = "NIFTY"
        )
      )
      list(
        list(
          exchange = "nse",
          segment = "equities",
          symbol = "INFY",
          weight = 40
        ),
        list(
          exchange = "nse",
          segment = "equities",
          symbol = "HDFCBANK",
          weight = 30
        ),
        list(
          exchange = "nse",
          segment = "exchange_traded_funds",
          symbol = "GOLDBEES",
          weight = 20
        ),
        list(
          instrument_id = nifty$instrument_id,
          weight = 10
        )
      )
    },

    #' @description
    #' Resolves the rows and prints each member.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when UBI could not find one of the instruments, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      members <- self$resolver$resolve(self$rows())
      for (member in members) {
        kind <- class(member$instrument)[[1]]
        cat(
          sprintf(
            "%-16s %-24s weight %3s  last %s\n",
            member$label,
            kind,
            member$weight,
            toString(member$instrument$last_price)
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ResolveMixedRows$new()$run()
}
