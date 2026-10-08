#' Bid for one lot of a Nifty call far below its offer, then cancel the bid.
#'
#' The program picks the Nifty call about two per cent out of the money on the soonest expiry after today, bids for one lot at half its best offer, and cancels the bid at once. UBI's order engine holds a plain day limit order until the offer comes down to its price, so the bid never reaches the exchange.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity_index_option/nifty_option_held_limit_order.R

library(tradeR)

#' One far-away bid for a Nifty call, held by the order engine and then cancelled.
#'
#' @field option The `EquityIndexOption` the bid is for.
NiftyOptionHeldLimitOrder <- R6::R6Class(
  "NiftyOptionHeldLimitOrder",
  public = list(
    option = NULL,

    #' @description
    #' Chooses the call nearest two per cent above the index on the soonest expiry after today, and looks it up in UBI.
    #' @return A new `NiftyOptionHeldLimitOrder` object.
    #' @details Errors: signals `ValueError` when no options are listed on the Nifty; `EquityIndexOptionError` when UBI has no such option; and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    initialize = function() {
      index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      if (length(expiries) == 0) {
        ErrorCatalogue$raise("ValueError", "No options are listed on the Nifty")
      }
      expiry_date <- expiries[[1]]
      today <- TimeConverter$new()$today()
      for (expiry_index in seq_along(expiries)) {
        expiry <- expiries[[expiry_index]]
        if (expiry > today) {
          expiry_date <- expiry
          break
        }
      }
      target <- index$last_price * 1.02
      strikes <- EquityIndexOption$strikes(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date
      )
      strike_price <- strikes[[1]]
      for (strike in strikes) {
        if (abs(strike - target) < abs(strike_price - target)) {
          strike_price <- strike
        }
      }
      self$option <- EquityIndexOption$new(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = "CE",
        underlying = index
      )
    },

    #' @description
    #' Works out a bid at half the best offer, or half the last price when nobody is offering, rounded down to the tick.
    #' @return The numeric price in rupees, never below one tick.
    #' @details Errors: signals `ServiceUnavailableError` when UBI has no quote for the option.
    bid_price = function() {
      offer <- self$option$best_offer
      if (is.null(offer)) {
        reference <- self$option$last_price
      } else {
        reference <- offer[["price"]]
      }
      tick_size <- as.numeric(self$option$tick_size)
      ticks <- trunc(reference * 0.5 / tick_size)
      if (ticks < 1) {
        ticks <- 1
      }
      round(ticks * tick_size, 2)
    },

    #' @description
    #' Places the bid for one lot, prints the engine's answer and cancels it whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      price <- self$bid_price()
      cat(
        sprintf(
          "NIFTY %s CE expiring %s: last %s\n",
          self$option$strike_price,
          format(self$option$expiry_date),
          self$option$last_price
        )
      )
      cat(
        sprintf(
          "Bidding %s for one lot of %s\n",
          price,
          self$option$lot_size
        )
      )
      answer <- self$option$buy_at_limit_price(
        price = price,
        quantity = self$option$lot_size,
        product = "nrml",
        tag = "exampleoptionbid"
      )
      parent_id <- answer[["parent_id"]]
      tryCatch(
        {
          parent_text <- parent_id
          if (is.null(parent_text)) {
            parent_text <- "NULL"
          }
          cat(
            sprintf(
              "Outcome: %s, parent id: %s\n",
              answer[["outcome"]],
              parent_text
            )
          )
        },
        finally = {
          if (!is.null(parent_id)) {
            cancelled <- self$option$cancel_parent(parent_id)
            cat(sprintf("After cancelling: %s\n", cancelled[["state"]]))
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NiftyOptionHeldLimitOrder$new()$run()
}
