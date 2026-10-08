#' Keep only the index futures among several futures contracts, catching InstrumentError.
#'
#' The program builds an IndexFutures for the nearest NIFTY future, the nearest MCXBULLDEX future, the nearest GOLDM gold future and a NIFTY future on a day nothing expires. The gold future raises IndexFuturesError because gold is not an index, and the missing contract raises the base InstrumentError; one handler for the base class catches both.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/index_futures_error/keep_only_index_futures.R

library(tradeR)

#' A filter that keeps only futures written on an index.
#'
#' @field lookups The list of (character exchange, character segment, character underlying symbol, `Date` expiry) lists to try.
IndexFuturesFilter <- R6::R6Class(
  "IndexFuturesFilter",
  public = list(
    lookups = NULL,

    #' @description
    #' Creates the filter with no lookups yet.
    #' @return A new `IndexFuturesFilter` object.
    initialize = function() {
      self$lookups <- list()
    },

    #' @description
    #' Reads the nearest expiry of each underlying and records the lookups to try.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    collect_lookups = function() {
      nifty_expiry <- EquityIndexFutures$expiries("nse", "NIFTY")[1]
      bullion_expiry <- CommodityIndexFutures$expiries(
        "mcx",
        "MCXBULLDEX"
      )[1]
      gold_expiry <- CommodityFutures$expiries("mcx", "GOLDM")[1]
      self$lookups[[length(self$lookups) + 1]] <- list(
        "nse",
        "equity_index_futures",
        "NIFTY",
        nifty_expiry
      )
      self$lookups[[length(self$lookups) + 1]] <- list(
        "mcx",
        "commodity_index_futures",
        "MCXBULLDEX",
        bullion_expiry
      )
      self$lookups[[length(self$lookups) + 1]] <- list(
        "mcx",
        "commodity_futures",
        "GOLDM",
        gold_expiry
      )
      self$lookups[[length(self$lookups) + 1]] <- list(
        "nse",
        "equity_index_futures",
        "NIFTY",
        as.Date("2026-12-25")
      )
      invisible(NULL)
    },

    #' @description
    #' Builds every lookup as an index future and prints which ones are kept.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      self$collect_lookups()
      for (lookup in self$lookups) {
        exchange <- lookup[[1]]
        segment <- lookup[[2]]
        underlying_symbol <- lookup[[3]]
        expiry_date <- lookup[[4]]
        label <- sprintf("%s %s", underlying_symbol, format(expiry_date))
        line <- tryCatch(
          {
            contract <- IndexFutures$new(
              exchange = exchange,
              segment = segment,
              underlying_symbol = underlying_symbol,
              expiry_date = expiry_date
            )
            sprintf("Kept %s: lot size %s", label, format(contract$lot_size))
          },
          InstrumentError = function(error) {
            sprintf("Dropped %s: %s", label, class(error)[[1]])
          }
        )
        cat(line, "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  IndexFuturesFilter$new()$run()
}
