#' Print the order book of the overnight MIBOR future with the most time left this quarter.
#'
#' The program builds the overnight MIBOR future expiring next month on the nse and prints its best prices, its depth on each side, its volume and its open interest. Thinly traded contracts often have an empty book, which the program reports rather than failing on.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/fixed_income/fixed_income_index_futures/mibor_futures_order_book.R

library(tradeR)

#' The order book of one fixed income index future.
#'
#' @field contract The `FixedIncomeIndexFutures` whose book to print.
MiborFuturesOrderBook <- R6::R6Class(
  "MiborFuturesOrderBook",
  public = list(
    contract = NULL,

    #' @description
    #' Builds the contract with the second expiry listed, or the only one.
    #' @param underlying_symbol The character symbol of the index, such as `"ONMIBOR"`.
    #' @return A new `MiborFuturesOrderBook` object.
    #' @details Errors: signals `ValueError` when no futures are listed on the index, and `FixedIncomeIndexFuturesError` when UBI has no such contract.
    initialize = function(underlying_symbol = "ONMIBOR") {
      expiries <- FixedIncomeIndexFutures$expiries(
        exchange = "nse",
        underlying_symbol = underlying_symbol
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("No futures are listed on %s", underlying_symbol)
        )
      }
      expiry_date <- expiries[[1]]
      if (length(expiries) > 1) {
        expiry_date <- expiries[[2]]
      }
      self$contract <- FixedIncomeIndexFutures$new(
        exchange = "nse",
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date
      )
    },

    #' @description
    #' Turns a value UBI may not know into text for printing, writing `NULL` for an unknown one.
    #' @param value The value to print, or `NULL`.
    #' @return A character string.
    display_text = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      as.character(value)
    },

    #' @description
    #' Prints the book and the day's activity.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      contract <- self$contract
      cat(
        sprintf(
          "%s future expiring %s\n",
          contract$underlying_symbol,
          format(contract$expiry_date)
        )
      )
      cat(sprintf("Last price: %s\n", self$display_text(contract$last_price)))
      bids <- contract$bids
      offers <- contract$offers
      if (length(bids) == 0 && length(offers) == 0) {
        cat("The order book is empty.\n")
      }
      for (bid in bids) {
        cat(sprintf("Bid %s for %s\n", bid[["price"]], bid[["quantity"]]))
      }
      for (offer in offers) {
        cat(
          sprintf("Offer %s for %s\n", offer[["price"]], offer[["quantity"]])
        )
      }
      cat(
        sprintf("Spread: %s\n", self$display_text(contract$bid_offer_spread))
      )
      cat(
        sprintf(
          "Volume: %s\n",
          self$display_text(contract$total_traded_volume)
        )
      )
      cat(
        sprintf(
          "Open interest: %s\n",
          self$display_text(contract$open_interest)
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MiborFuturesOrderBook$new()$run()
}
