#' Follow a watchlist of bank shares and report what moved today.
#'
#' The program builds a watchlist of five bank shares, adds a sixth, and prints the members ranked by today's move, the breadth of the list, the biggest gainer and loser, and the plain average move, since every member of a watchlist counts equally.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/watchlist/watchlist/bank_movers.R

library(tradeR)

SYMBOLS <- c(
  "HDFCBANK",
  "ICICIBANK",
  "AXISBANK",
  "KOTAKBANK",
  "SBIN"
)

ADDED_SYMBOL <- "INDUSINDBK"

#' A day's movers report on a watchlist of bank shares.
#'
#' @field followed The `Watchlist` of bank shares.
BankMovers <- R6::R6Class(
  "BankMovers",
  public = list(
    followed = NULL,

    #' @description
    #' Looks the shares up in UBI, builds the watchlist and adds one more share.
    #' @return A new `BankMovers` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      banks <- list()
      for (symbol in SYMBOLS) {
        banks[[length(banks) + 1]] <- Equity$new(
          exchange = "nse",
          symbol = symbol
        )
      }
      self$followed <- Watchlist$new(name = "banks", instruments = banks)
      self$followed$add(Equity$new(exchange = "nse", symbol = ADDED_SYMBOL))
    },

    #' @description
    #' Prints the ranking, the breadth, the extremes and the average move.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      ranked <- self$followed$rank_by("change_percent")
      columns <- c(
        "label",
        "last_price",
        "change_percent"
      )
      print(ranked[, columns])
      breadth <- self$followed$breadth
      cat(
        sprintf(
          "Up %d, down %d, unchanged %d\n",
          breadth[["advancers"]],
          breadth[["decliners"]],
          breadth[["unchanged"]]
        )
      )
      gainer <- self$followed$top_gainers(count = 1)
      loser <- self$followed$top_losers(count = 1)
      if (nrow(gainer) > 0 && nrow(loser) > 0) {
        cat(
          sprintf(
            "Best %s, worst %s\n",
            gainer$label[[1]],
            loser$label[[1]]
          )
        )
      }
      average <- self$followed$day_change_percent
      if (is.null(average)) {
        cat("A member has no quote, so the average move is unknown.\n")
      } else {
        cat(sprintf("Average move: %+.2f%%\n", average))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BankMovers$new()$run()
}
