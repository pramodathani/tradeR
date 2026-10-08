#' Work out the basis of futures in several families, catching InstrumentError where there is no underlying.
#'
#' The basis is a future's price minus its underlying's price. It can be worked out for a NIFTY future, whose underlying is the NIFTY index, but not for a USDINR currency future or a government bond future, whose cash underlyings have no price in UBI. Those raise UnderlyingError, which the program catches through its base class InstrumentError.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/exceptions/underlying_error/basis_of_futures_across_families.R

library(tradeR)

#' A report of the basis of the nearest future in three families.
#'
#' @field contracts The list of `Futures` to report on.
BasisReport <- R6::R6Class(
  "BasisReport",
  public = list(
    contracts = NULL,

    #' @description
    #' Creates the report with no contracts yet.
    #' @return A new `BasisReport` object.
    initialize = function() {
      self$contracts <- list()
    },

    #' @description
    #' Builds the nearest NIFTY, USDINR and 6.33% 2035 bond futures.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the contracts; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    collect_contracts = function() {
      nifty_expiry <- EquityIndexFutures$expiries("nse", "NIFTY")[1]
      self$contracts[[length(self$contracts) + 1]] <- EquityIndexFutures$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = nifty_expiry
      )
      dollar_expiry <- CurrencyFutures$expiries("nse", "USDINR")[1]
      self$contracts[[length(self$contracts) + 1]] <- CurrencyFutures$new(
        exchange = "nse",
        underlying_symbol = "USDINR",
        expiry_date = dollar_expiry
      )
      bond_expiry <- FixedIncomeFutures$expiries("nse", "633GS2035")[1]
      self$contracts[[length(self$contracts) + 1]] <- FixedIncomeFutures$new(
        exchange = "nse",
        underlying_symbol = "633GS2035",
        expiry_date = bond_expiry
      )
      invisible(NULL)
    },

    #' @description
    #' Works out one contract's basis and describes it.
    #' @param contract The `Futures` to describe.
    #' @return A character line with the basis, or with the reason there is none.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    describe_basis = function(contract) {
      label <- sprintf(
        "%s %s",
        contract$underlying_symbol,
        format(contract$expiry_date)
      )
      tryCatch(
        {
          basis <- contract$basis
          if (is.null(basis)) {
            basis <- "NULL"
          }
          sprintf("%s: basis %s", label, format(basis))
        },
        InstrumentError = function(error) {
          sprintf("%s: no basis, %s", label, class(error)[[1]])
        }
      )
    },

    #' @description
    #' Builds the contracts and prints the basis of each.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `InstrumentError` when UBI does not know one of the contracts; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      self$collect_contracts()
      for (contract in self$contracts) {
        cat(self$describe_basis(contract), "\n", sep = "")
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BasisReport$new()$run()
}
