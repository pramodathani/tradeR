#' Link a temporary contents basket to NIFTYBEES, measure it, and remove it.
#'
#' UBI stores no fund holdings, so a fund's `constituents` are whatever basket was saved in MongoDB with the fund as its linked instrument. The program saves a five-share basket weighted roughly like the top of the NIFTY, reads it back through the fund, prints its weights, live prices and day change next to the fund's own, and deletes the basket again, whatever happens in between.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/exchange_traded_fund/temporary_contents_basket.R

library(tradeR)

BASKET_NAME <- "EXAMPLE_NIFTYBEES_TOP_FIVE"

#' A short-lived contents basket for one exchange traded fund.
#'
#' @field fund The `ExchangeTradedFund` the basket is linked to.
#' @field store The `BasketStore` the basket is saved in.
#' @field weights A named numeric vector mapping each nse symbol to its weight.
TemporaryContentsBasket <- R6::R6Class(
  "TemporaryContentsBasket",
  public = list(
    fund = NULL,
    store = NULL,
    weights = NULL,

    #' @description
    #' Looks NIFTYBEES up and opens the basket store.
    #' @return A new `TemporaryContentsBasket` object.
    #' @details Errors: signals `ExchangeTradedFundError` when UBI has no such fund, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$fund <- ExchangeTradedFund$new(
        exchange = "nse",
        symbol = "NIFTYBEES"
      )
      self$store <- BasketStore$new()
      self$weights <- c(
        HDFCBANK = 0.30,
        RELIANCE = 0.25,
        ICICIBANK = 0.20,
        INFY = 0.15,
        BHARTIARTL = 0.10
      )
    },

    #' @description
    #' Saves the basket, reports on it through the fund, and deletes it whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a plain error from `mongolite` when MongoDB could not be reached, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      saved <- self$store$save(private$build_basket(), source = "example")
      cat(
        sprintf(
          "Saved %s for %s\n",
          BASKET_NAME,
          format(saved[["effective_date"]])
        )
      )
      tryCatch(
        private$report(),
        finally = {
          deleted <- self$store$delete(BASKET_NAME, saved[["effective_date"]])
          cat(sprintf("Deleted the basket again: %s\n", deleted))
        }
      )
      invisible(NULL)
    }
  ),
  private = list(
    # Builds the basket of the five shares, linked to the fund.
    # @return The `ExchangeTradedFundConstituents` basket.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    build_basket = function() {
      members <- list()
      for (symbol in names(self$weights)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        member <- BasketMember$new(
          instrument = share,
          weight = self$weights[[symbol]]
        )
        members[[length(members) + 1]] <- member
      }
      ExchangeTradedFundConstituents$new(
        name = BASKET_NAME,
        members = members,
        fund = self$fund
      )
    },

    # Reads the basket back through the fund and prints what it holds and how it moved.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    report = function() {
      contents <- self$fund$constituents
      if (is.null(contents)) {
        cat("The fund found no basket, so nothing was linked.\n")
        return(invisible(NULL))
      }
      print(contents)
      print(contents$weights)
      print(contents$last_prices)
      day_change <- contents$day_change_percent
      if (is.null(day_change)) {
        day_change <- "NULL"
      }
      cat(sprintf("Basket day change: %s per cent\n", day_change))
      quote <- self$fund$ohlc
      fund_change <- (quote[["last_price"]] / quote[["previous_close"]] - 1) *
        100
      cat(sprintf("NIFTYBEES day change: %.2f per cent\n", fund_change))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TemporaryContentsBasket$new()$run()
}
