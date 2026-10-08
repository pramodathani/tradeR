#' Look a bond up by its ISIN and report what UBI knows about it.
#'
#' The program searches the nse's fixed income segment for the start of an ISIN, builds the first bond it finds, and prints its identity and the brokers that carry it. It then shows the two gaps in UBI's coverage of bonds: there is no quote, which is reported as an error the program catches, and there are no candles.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income/bond_lookup_report.R

library(tradeR)

#' A report on one bond found by the start of its ISIN.
#'
#' @field isin_prefix The character text the bond's ISIN must contain, such as `"IN0001"`.
BondLookupReport <- R6::R6Class(
  "BondLookupReport",
  public = list(
    isin_prefix = NULL,

    #' @description
    #' Stores the part of the ISIN to search for.
    #' @param isin_prefix The character text the bond's ISIN must contain.
    #' @return A new `BondLookupReport` object.
    initialize = function(isin_prefix = "IN0001") {
      self$isin_prefix <- isin_prefix
    },

    #' @description
    #' Finds the bond and prints the report.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `FixedIncomeError` when the bond found could not be built, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      matches <- FixedIncome$search(
        exchange = "nse",
        term = self$isin_prefix
      )
      if (is.null(matches)) {
        cat(
          sprintf(
            "No nse bond has an ISIN containing %s.\n",
            self$isin_prefix
          )
        )
        return(invisible(NULL))
      }
      isin <- matches$symbol[[1]]
      bond <- FixedIncome$new(exchange = "nse", symbol = isin)
      cat(sprintf("ISIN: %s\n", bond$symbol))
      cat(sprintf("Instrument id: %s\n", bond$instrument_id))
      cat(sprintf("Segment: %s\n", bond$segment))
      lot_size <- bond$lot_size
      if (is.null(lot_size)) {
        lot_size <- "NULL"
      }
      cat(sprintf("Lot size: %s\n", lot_size))
      brokers <- character(0)
      for (mapping in bond$carried_by) {
        brokers <- c(
          brokers,
          mapping[["broker"]]
        )
      }
      cat(sprintf("Carried by: %s\n", paste(brokers, collapse = ", ")))
      tryCatch(
        {
          last_price <- bond$last_price
          if (is.null(last_price)) {
            last_price <- "NULL"
          }
          cat(sprintf("Last price: %s\n", last_price))
        },
        ServiceUnavailableError = function(error) {
          cat(sprintf("No quote: %s\n", conditionMessage(error)))
        }
      )
      cat("Candles for the last month: ")
      print(bond$prices(days = 30))
      holding <- bond$holdings
      if (is.null(holding)) {
        cat("The account holds none of this bond.\n")
      } else {
        cat(sprintf("Held: %s units\n", holding[["quantity"]]))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  BondLookupReport$new()$run()
}
