#' Place a limit bid that UBI's order engine holds, then cancel it.
#'
#' The program bids for one Vodafone Idea share three per cent below the last price. UBI's order engine holds a plain day limit order until the offer comes down to its price, so the answer carries a parent id rather than a broker order id. The program reads the held order back and cancels it at once, whatever happens in between.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/equities/equity/held_limit_order_round_trip.R

library(tradeR)

#' One limit bid for a share, held by the order engine and then cancelled.
#'
#' @field share The `Equity` the bid is for.
#' @field discount The numeric fraction below the last price at which to bid, such as 0.03.
HeldLimitOrderRoundTrip <- R6::R6Class(
  "HeldLimitOrderRoundTrip",
  public = list(
    share = NULL,
    discount = NULL,

    #' @description
    #' Looks the share up in UBI and stores how far below the market to bid.
    #' @param symbol The character nse symbol of the share, such as `"IDEA"`.
    #' @param discount The numeric fraction below the last price at which to bid.
    #' @return A new `HeldLimitOrderRoundTrip` object.
    #' @details Errors: signals `EquityError` when UBI has no nse share with that symbol.
    initialize = function(symbol = "IDEA", discount = 0.03) {
      self$share <- Equity$new(exchange = "nse", symbol = symbol)
      self$discount <- discount
    },

    #' @description
    #' Works out the bid price, rounded down to the share's tick size.
    #' @return The numeric price in rupees.
    #' @details Errors: signals `ServiceUnavailableError` when UBI has no quote for the share.
    bid_price = function() {
      tick_size <- as.numeric(self$share$tick_size)
      target <- self$share$last_price * (1 - self$discount)
      ticks <- trunc(target / tick_size)
      round(ticks * tick_size, 2)
    },

    #' @description
    #' Places the bid, prints what the engine holds, and cancels it whatever happens.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused a request.
    run = function() {
      price <- self$bid_price()
      cat(sprintf("Last price %s, bidding %s\n", self$share$last_price, price))
      answer <- self$share$buy_at_limit_price(
        price = price,
        quantity = 1,
        product = "mis",
        tag = "exampleheldbid"
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
          if (!is.null(parent_id)) {
            parent <- self$share$parent(parent_id)
            cat(sprintf("The engine holds it in state %s\n", parent[["state"]]))
          }
        },
        finally = {
          if (!is.null(parent_id)) {
            cancelled <- self$share$cancel_parent(parent_id)
            cat(sprintf("After cancelling: %s\n", cancelled[["state"]]))
          }
        }
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HeldLimitOrderRoundTrip$new()$run()
}
