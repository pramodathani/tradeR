#' Build an equal-weighted IT index, follow its level and compare it with NIFTY IT.
#'
#' The program builds an index of five IT shares that starts at 1000 on the first trading day of 2026, linked to the NSE's NIFTY IT index, and prints its level today, its last few day candles, its return and its tracking error against NIFTY IT over the year so far, and the same members under a price weighting for comparison.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/index/index/custom_it_index.R

library(tradeR)

SYMBOLS <- c(
  "INFY",
  "TCS",
  "HCLTECH",
  "WIPRO",
  "TECHM"
)

BASE_DATE <- "2026-01-01"

#' An equal-weighted IT index linked to NIFTY IT.
#'
#' @field nifty_it The `EquityIndex` for NIFTY IT.
#' @field members The list of `BasketMember` objects in the index.
#' @field it_index The `Index` built from the members.
CustomItIndex <- R6::R6Class(
  "CustomItIndex",
  public = list(
    nifty_it = NULL,
    members = NULL,
    it_index = NULL,

    #' @description
    #' Looks the shares and NIFTY IT up in UBI and builds the index.
    #' @return A new `CustomItIndex` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know one of the instruments.
    initialize = function() {
      self$nifty_it <- EquityIndex$new(exchange = "nse", symbol = "NIFTYIT")
      self$members <- list()
      for (symbol in SYMBOLS) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        self$members[[length(self$members) + 1]] <- BasketMember$new(share)
      }
      self$it_index <- Index$new(
        name = "my IT index",
        members = self$members,
        weighting = "equal",
        base_value = 1000,
        base_date = BASE_DATE,
        linked_instrument = self$nifty_it
      )
    },

    #' @description
    #' Prints the level, the candles, the comparison and the price weighting.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when a member has no candle or no last price, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      today <- TimeConverter$new()$today()
      cat(
        sprintf(
          "%s level today: %.2f\n",
          self$it_index$name,
          self$it_index$level
        )
      )
      frame <- self$it_index$prices(from_date = BASE_DATE, to_date = today)
      columns <- c(
        "datetime",
        "close"
      )
      recent <- utils::tail(frame[, columns])
      recent$close <- round(recent$close, 2)
      print(recent)
      own_return <- self$it_index$cumulative_return(
        from_date = BASE_DATE,
        to_date = today
      )
      official_return <- self$nifty_it$cumulative_return(
        from_date = BASE_DATE,
        to_date = today
      )
      tracking <- self$it_index$tracking_error(
        benchmark = self$nifty_it,
        from_date = BASE_DATE,
        to_date = today
      )
      cat(
        sprintf(
          "Return this year: %+.2f%%, NIFTY IT %+.2f%%\n",
          own_return * 100,
          official_return * 100
        )
      )
      cat(
        sprintf("Tracking error against NIFTY IT: %.2f%%\n", tracking * 100)
      )
      price_weighted <- Index$new(
        name = "my IT index, price weighted",
        members = self$members,
        weighting = "price"
      )
      cat("Price weights:\n")
      print(round(price_weighted$weights, 3))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  CustomItIndex$new()$run()
}
