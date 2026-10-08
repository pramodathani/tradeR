#' Build a protected trade in Vodafone Idea followed, once it is over, by a second entry after two in the afternoon.
#'
#' The first child of the sequence is a then join: a buy whose every fill is protected by a stop and a target that reduce each other. The second child, a buy at two in the afternoon, is only considered once the whole first trade is done, which shows that a sequence can hold joins as well as orders. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/sequence_part/sequence_part/protected_trade_then_afternoon_reentry.R

library(tradeR)

#' A bracketed trade, and a second entry started only after it.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
TradeThenReentry <- R6::R6Class(
  "TradeThenReentry",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `TradeThenReentry` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Builds the first trade, a buy protected by a stop 3% below and a target 3% above.
    #' @param last_price The numeric last price the levels are measured from.
    #' @return The `ThenPart` holding the entry and its two exits.
    protected_trade = function(last_price) {
      stop_trigger <- round(last_price * 0.97, 2)
      target_price <- round(last_price * 1.03, 2)
      ThenPart$new(
        first = OrderPart$new(
          pricing = MarketablePricing$new()
        ),
        each_fill = EitherPart$new(
          children = list(
            OrderPart$new(
              side = "protect",
              pricing = NativeStopPricing$new(
                trigger_price = stop_trigger,
                limit_price = round(stop_trigger - 0.05, 2)
              )
            ),
            OrderPart$new(
              side = "protect",
              pricing = FixedPricing$new(
                price = target_price,
                order_type = "LIMIT"
              )
            )
          ),
          sibling_rule = "reduce"
        )
      )
    },

    #' @description
    #' Prints the plan.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when UBI has no last price for the share.
    run = function() {
      last_price <- self$share$last_price
      if (is.null(last_price)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("UBI has no last price for %s", self$share$format())
        )
      }
      plan <- SequencePart$new(
        children = list(
          self$protected_trade(last_price),
          OrderPart$new(
            trigger = TimeAt$new("14:00"),
            pricing = MarketablePricing$new()
          )
        )
      )
      cat(sprintf("Last price of %s: %s\n", self$share$symbol, last_price))
      cat(
        jsonlite::toJSON(
          plan$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TradeThenReentry$new()$run()
}
