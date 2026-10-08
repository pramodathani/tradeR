#' Check a list of commodity index symbols and report every one UBI does not know.
#'
#' The program builds a CommodityIndex for each symbol in a list, as a program reading symbols from a file or a form would. It catches InstrumentError, the base class of every instrument error, so one handler covers CommodityIndexError and anything else the lookup raises about the instrument, and it prints the chain of errors behind each symbol that was not found.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/commodity_index_error/check_a_list_of_symbols.R

library(tradeR)

#' A check of a list of commodity index symbols against UBI.
#'
#' @field exchange The character exchange the symbols are looked up on.
#' @field symbols The character vector of symbols to check.
SymbolListCheck <- R6::R6Class(
  "SymbolListCheck",
  public = list(
    exchange = NULL,
    symbols = NULL,

    #' @description
    #' Creates the check with the symbols to look up.
    #' @return A new `SymbolListCheck` object.
    initialize = function() {
      self$exchange <- "mcx"
      self$symbols <- c(
        "MCXBULLDEX",
        "MCXMETLDEX",
        "MCXGOLDINDEX"
      )
    },

    #' @description
    #' Names an error and every error it was raised from.
    #' @param error The condition to describe.
    #' @return A character value such as `CommodityIndexError <- InstrumentError <- NotFoundError`.
    describe_error_chain = function(error) {
      class_names <- class(error)[[1]]
      cause <- error$parent
      while (!is.null(cause)) {
        class_names <- c(
          class_names,
          class(cause)[[1]]
        )
        cause <- cause$parent
      }
      paste(class_names, collapse = " <- ")
    },

    #' @description
    #' Looks one symbol up and describes the outcome.
    #' @param symbol The character symbol to look up.
    #' @return A character line saying whether UBI knows the symbol, and why not when it does not.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup for a reason other than an unknown symbol.
    check_symbol = function(symbol) {
      tryCatch(
        {
          instrument <- CommodityIndex$new(
            exchange = self$exchange,
            symbol = symbol
          )
          sprintf(
            "%s: found in %s as %s",
            symbol,
            instrument$segment,
            instrument$instrument_id
          )
        },
        InstrumentError = function(error) {
          chain <- self$describe_error_chain(error)
          sprintf(
            "%s: not found (%s): %s",
            symbol,
            chain,
            conditionMessage(error)
          )
        }
      )
    },

    #' @description
    #' Checks every symbol and prints one line for each, then a count.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    run = function() {
      found_count <- 0
      for (symbol in self$symbols) {
        line <- self$check_symbol(symbol)
        cat(line, "\n", sep = "")
        if (grepl(": found in ", line, fixed = TRUE)) {
          found_count <- found_count + 1
        }
      }
      cat(
        sprintf(
          "UBI knows %d of the %d symbols.\n",
          found_count,
          length(self$symbols)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SymbolListCheck$new()$run()
}
