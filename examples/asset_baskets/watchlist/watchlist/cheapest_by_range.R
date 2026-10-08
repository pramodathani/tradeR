#' Rank a watchlist by where each share trades within its day's range.
#'
#' The program follows six large NSE shares, reads their day's prices in one request, works out where each last price sits between the day's low and high, and prints the list from the share nearest its low to the one nearest its high, with the list also ranked by last price for comparison.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/watchlist/watchlist/cheapest_by_range.R

library(tradeR)

SYMBOLS <- c(
  "RELIANCE",
  "INFY",
  "HDFCBANK",
  "ITC",
  "LT",
  "BHARTIARTL"
)

#' A watchlist ranked by each share's position in its day's range.
#'
#' @field followed The `Watchlist` being ranked.
CheapestByRange <- R6::R6Class(
  "CheapestByRange",
  public = list(
    followed = NULL,

    #' @description
    #' Looks the shares up in UBI and builds the watchlist.
    #' @return A new `CheapestByRange` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      shares <- list()
      for (symbol in SYMBOLS) {
        shares[[length(shares) + 1]] <- Equity$new(
          exchange = "nse",
          symbol = symbol
        )
      }
      self$followed <- Watchlist$new(
        name = "large shares",
        instruments = shares
      )
    },

    #' @description
    #' Prints the members ranked by their place in the day's range and by last price. Members whose place cannot be worked out sort last, as pandas sorts missing values.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      frame <- self$followed$ohlc
      day_range <- frame$high - frame$low
      frame$place_in_range <- (frame$last_price - frame$low) / day_range
      frame <- frame[order(frame$place_in_range, na.last = TRUE), ]
      rownames(frame) <- NULL
      cat("Nearest the day's low first:\n")
      shown_columns <- c(
        "label",
        "low",
        "last_price",
        "high",
        "place_in_range"
      )
      rounded_columns <- c(
        "low",
        "last_price",
        "high",
        "place_in_range"
      )
      shown <- frame[, shown_columns]
      for (column in rounded_columns) {
        shown[[column]] <- round(shown[[column]], 3)
      }
      print(shown)
      cat("\n")
      cat("By last price, cheapest first:\n")
      ranked <- self$followed$rank_by("last_price", ascending = TRUE)
      columns <- c(
        "label",
        "last_price"
      )
      print(ranked[, columns])
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CheapestByRange$new()$run()
}
