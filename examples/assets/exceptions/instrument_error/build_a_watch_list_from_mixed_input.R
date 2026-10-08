#' Build instruments of several families from typed input, catching InstrumentError once for all of them.
#'
#' Every family error, such as EquityError, CommodityFuturesError or MutualFundError, is a subclass of InstrumentError. The program builds a share, an index, a commodity and a mutual fund scheme from a list in which some names are wrong, and one handler for InstrumentError catches whichever family error each wrong name raises.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/instrument_error/build_a_watch_list_from_mixed_input.R

library(tradeR)

#' A watch list built from names of several asset families.
#'
#' @field requests The list of (character family, character exchange, character symbol) lists to build, as a person typed them.
#' @field built_instruments The list of `Instrument` that were found.
MixedWatchList <- R6::R6Class(
  "MixedWatchList",
  public = list(
    requests = NULL,
    built_instruments = NULL,

    #' @description
    #' Creates the watch list with the names to build.
    #' @return A new `MixedWatchList` object.
    initialize = function() {
      self$requests <- list(
        c(
          "share",
          "nse",
          "IDEA"
        ),
        c(
          "share",
          "nse",
          "VODAFONE"
        ),
        c(
          "index",
          "nse",
          "NIFTY"
        ),
        c(
          "commodity",
          "mcx",
          "GOLDMINI"
        ),
        c(
          "mutual fund",
          "nse",
          "ABSLFTTIDG"
        ),
        c(
          "mutual fund",
          "nse",
          "ABSL FLEXI"
        )
      )
      self$built_instruments <- list()
    },

    #' @description
    #' Builds one instrument of the named family.
    #' @param family The character family, `share`, `index`, `commodity` or `mutual fund`.
    #' @param exchange The character exchange the instrument is listed on.
    #' @param symbol The character symbol of the instrument.
    #' @return The `Instrument` of the family's own class.
    #' @details Errors: signals `InstrumentError` when UBI does not know the instrument, raised as the family's own subclass; `ValueError` when the family is not one this program knows; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the lookup.
    build = function(family, exchange, symbol) {
      if (family == "share") {
        return(Equity$new(exchange = exchange, symbol = symbol))
      }
      if (family == "index") {
        return(EquityIndex$new(exchange = exchange, symbol = symbol))
      }
      if (family == "commodity") {
        return(Commodity$new(exchange = exchange, symbol = symbol))
      }
      if (family == "mutual fund") {
        return(MutualFund$new(exchange = exchange, symbol = symbol))
      }
      ErrorCatalogue$raise(
        "ValueError",
        sprintf("Not a family this program knows: family='%s'", family)
      )
    },

    #' @description
    #' Builds every requested instrument and prints what was found and what was not.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when A request names a family this program does not know; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a lookup.
    run = function() {
      for (request in self$requests) {
        family <- request[[1]]
        exchange <- request[[2]]
        symbol <- request[[3]]
        instrument <- tryCatch(
          self$build(family, exchange, symbol),
          InstrumentError = function(error) {
            cat(
              sprintf(
                "Skipped %s '%s': %s: %s\n",
                family,
                symbol,
                class(error)[[1]],
                conditionMessage(error)
              )
            )
            NULL
          }
        )
        if (is.null(instrument)) {
          next
        }
        position <- length(self$built_instruments) + 1
        self$built_instruments[[position]] <- instrument
        cat(sprintf("Added %s\n", instrument$format()))
      }
      cat(
        sprintf(
          "The watch list holds %d of %d requested instruments.\n",
          length(self$built_instruments),
          length(self$requests)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MixedWatchList$new()$run()
}
