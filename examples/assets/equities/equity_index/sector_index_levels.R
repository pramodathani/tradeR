#' Print today's move of every nse sector index whose name matches a word.
#'
#' The program searches the nse's equity indices for a word, builds each index it finds, and prints its level and its change since the previous close, largest rise first.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index/sector_index_levels.R

library(tradeR)

#' Today's moves of the indices whose symbols contain one word.
#'
#' @field term The character text the index symbols must contain, such as `"BANK"`.
SectorIndexLevels <- R6::R6Class(
  "SectorIndexLevels",
  public = list(
    term = NULL,

    #' @description
    #' Stores the word to search for.
    #' @param term The character text the index symbols must contain.
    #' @return A new `SectorIndexLevels` object.
    initialize = function(term = "BANK") {
      self$term <- term
    },

    #' @description
    #' Searches, reads each index's quote and prints the moves, largest rise first and, on a tie, by symbol in reverse order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `EquityIndexError` when a matching index could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      matches <- EquityIndex$search(exchange = "nse", term = self$term)
      if (is.null(matches)) {
        cat(sprintf("No nse index contains %s.\n", self$term))
        return(invisible(NULL))
      }
      change_percents <- numeric(0)
      symbols <- character(0)
      index_levels <- numeric(0)
      for (symbol in matches$symbol) {
        index <- EquityIndex$new(exchange = "nse", symbol = symbol)
        quote <- index$quote
        change_percents <- c(
          change_percents,
          quote[["change_percent"]]
        )
        symbols <- c(
          symbols,
          symbol
        )
        index_levels <- c(
          index_levels,
          quote[["last_price"]]
        )
      }
      sort_order <- order(
        change_percents,
        symbols,
        index_levels,
        decreasing = TRUE
      )
      for (position in sort_order) {
        cat(
          sprintf(
            "%-20s %12s %7s%%\n",
            symbols[[position]],
            index_levels[[position]],
            change_percents[[position]]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SectorIndexLevels$new()$run()
}
