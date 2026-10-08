#' Store an exchange traded fund's holdings linked to the fund and find them again through it.
#'
#' The program stores the holdings of the GOLDBEES fund under the temporary name `example-etf-goldbees`, linked to the fund, then finds them again with `BasketStore$load_for_instrument()` as `ExchangeTradedFund$constituents` does, prints what came back and the stored form's link fields, and deletes the stored copy before it ends, whatever happens. A gold fund holds gold, which UBI has no cash price for, so the basket stands in with the gold fund itself at a weight of 97% and 3% left unpriced as cash.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/exchange_traded_fund_constituents/exchange_traded_fund_constituents/stored_fund_holdings.R

library(tradeR)

NAME <- "example-etf-goldbees"

EFFECTIVE_DATE <- "2026-09-01"

#' A fund's holdings stored with a link to the fund.
#'
#' @field store The `BasketStore` the holdings are saved in.
#' @field fund The `ExchangeTradedFund` the holdings belong to.
StoredFundHoldings <- R6::R6Class(
  "StoredFundHoldings",
  public = list(
    store = NULL,
    fund = NULL,

    #' @description
    #' Creates the store and looks the fund up in UBI.
    #' @return A new `StoredFundHoldings` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know the fund.
    initialize = function() {
      self$store <- BasketStore$new()
      self$fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
    },

    #' @description
    #' Builds the holdings basket linked to the fund.
    #' @return The `ExchangeTradedFundConstituents` to store.
    build_holdings = function() {
      members <- list(
        BasketMember$new(self$fund, weight = 97)
      )
      ExchangeTradedFundConstituents$new(
        name = NAME,
        members = members,
        fund = self$fund,
        unmapped_weight = 0.03
      )
    },

    #' @description
    #' Saves the holdings, finds them through the fund, prints them, and deletes them.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a mongolite error when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      holdings <- self$build_holdings()
      document <- self$store$save(
        holdings,
        effective_date = EFFECTIVE_DATE,
        source = "example"
      )
      tryCatch(
        {
          cat(
            sprintf(
              "Stored %s linked to %s\n",
              document[["name"]],
              toString(document[["linked_instrument_id"]])
            )
          )
          cat(
            sprintf(
              "Indicative value stored: %s\n",
              toString(document[["indicative_net_asset_value_instrument_id"]])
            )
          )
          found <- self$store$load_for_instrument(self$fund)
          cat(sprintf("Found through the fund: %s\n", found$format()))
          cat(
            sprintf(
              "Its fund: %s, unmapped weight %s\n",
              found$fund$symbol,
              found$unmapped_weight
            )
          )
        },
        finally = {
          self$store$delete(NAME, EFFECTIVE_DATE)
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  StoredFundHoldings$new()$run()
}
