#' Place a held limit order for one NIFTYBEES unit and cancel it straight away.
#'
#' The program bids for one unit, for delivery, at a limit 3 per cent below the last price, rounded to the tick. UBI's order engine holds such an order rather than sending it, and answers with a `parent_id`. The program then shows the held order among the fund's parents and cancels it, whatever happens in between, so nothing is left behind.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/funds/exchange_traded_fund/held_limit_order_round_trip.R

library(tradeR)

#' One held limit order placed and cancelled on an exchange traded fund.
#'
#' @field fund The `ExchangeTradedFund` the order is placed on.
#' @field discount The numeric fraction below the last price the bid is placed at.
HeldLimitOrderRoundTrip <- R6::R6Class(
  "HeldLimitOrderRoundTrip",
  public = list(
    fund = NULL,
    discount = NULL,

    #' @description
    #' Looks NIFTYBEES up in UBI.
    #' @return A new `HeldLimitOrderRoundTrip` object.
    #' @details Errors: signals `ExchangeTradedFundError` when UBI has no such fund, and a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    initialize = function() {
      self$fund <- ExchangeTradedFund$new(
        exchange = "nse",
        symbol = "NIFTYBEES"
      )
      self$discount <- 0.03
    },

    #' @description
    #' Places the bid, shows the held order, and cancels it whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      last_price <- self$fund$last_price
      limit_price <- private$round_to_tick(last_price * (1 - self$discount))
      cat(
        sprintf(
          "Last price %s, bidding %s for one unit\n",
          last_price,
          limit_price
        )
      )
      answer <- self$fund$buy_at_limit_price(
        price = limit_price,
        quantity = 1,
        product = "cnc",
        tag = "exampleetf"
      )
      parent_text <- answer[["parent_id"]]
      if (is.null(parent_text)) {
        parent_text <- "NULL"
      }
      cat(
        sprintf(
          "Outcome: %s, parent: %s\n",
          answer[["outcome"]],
          parent_text
        )
      )
      tryCatch(
        private$show_parent(answer[["parent_id"]]),
        finally = {
          cancelled <- self$fund$cancel_parent(answer[["parent_id"]])
          cat(sprintf("Cancelled: state %s\n", cancelled[["state"]]))
        }
      )
      invisible(NULL)
    }
  ),
  private = list(
    # Prints the held order as the order engine keeps it.
    # @param parent_id The character id of the held order.
    # @return `NULL`, invisibly.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    show_parent = function(parent_id) {
      parent <- self$fund$parent(parent_id)
      cat(sprintf("Held order %s\n", parent[["parent_order_id"]]))
      cat(
        sprintf(
          "  type %s, state %s\n",
          parent[["synthetic_type"]],
          parent[["state"]]
        )
      )
      cat(
        sprintf(
          "  body %s\n",
          jsonlite::toJSON(parent[["body"]], auto_unbox = TRUE, null = "null")
        )
      )
      invisible(NULL)
    },

    # Rounds a price to the nearest multiple of the fund's tick size.
    # @param price The numeric price to round.
    # @return The numeric price on the tick grid.
    round_to_tick = function(price) {
      tick_size <- as.numeric(self$fund$tick_size)
      ticks <- round(price / tick_size)
      round(ticks * tick_size, 2)
    }
  )
)

if (sys.nframe() == 0) {
  HeldLimitOrderRoundTrip$new()$run()
}
