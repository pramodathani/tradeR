#' Preview a plan whose entry and profit target are both held until the market reaches them, and one whose entry rests at the broker.
#'
#' The program reads Vodafone Idea's last price and builds a buy 3% below it, followed on each fill by a sell 3% above it. UBI holds the entry by default, but a profit target is a follow-on order that rests at the broker unless its own order asks to be held, so the target's `OrderPart` gives `hold_limits = TRUE`. A second plan gives its entry `hold_limits = FALSE`, so the entry would rest at the broker at once. Both are sent as dry runs, so UBI checks them and answers with the plan it would run, and nothing is recorded or sent.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/order_part/order_part/held_entry_and_held_target.R

library(tradeR)

#' Two previews of an entry with a profit target, differing only in what UBI holds.
#'
#' @field share The `Equity` both plans trade.
#' @field entry_price The numeric price in rupees of the buy, 3% below the last price.
#' @field target_price The numeric price in rupees of the sell, 3% above the last price.
HeldEntryAndTarget <- R6::R6Class(
  "HeldEntryAndTarget",
  public = list(
    share = NULL,
    entry_price = NULL,
    target_price = NULL,

    #' @description
    #' Looks the share up and works out both prices from its last price.
    #' @return A new `HeldEntryAndTarget` object.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not look the share up or quote it.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
      last_price <- self$share$last_price
      self$entry_price <- round(last_price * 0.97, 2)
      self$target_price <- round(last_price * 1.03, 2)
    },

    #' @description
    #' Builds the entry and its target as a dry-run plan.
    #' @param entry_hold_limits A logical or `NULL` given to the entry's `OrderPart` as its `hold_limits`.
    #' @return A `PlanOrder` that buys at the entry price and sells each fill at the target price.
    plan_order = function(entry_hold_limits) {
      target <- OrderPart$new(
        side = "protect",
        pricing = FixedPricing$new(price = self$target_price),
        hold_limits = TRUE
      )
      PlanOrder$new(
        self$share,
        transaction_type = "buy",
        product = "mis",
        order_type = "limit",
        quantity = 1,
        price = self$entry_price,
        plan = ThenPart$new(
          first = OrderPart$new(hold_limits = entry_hold_limits),
          each_fill = target
        ),
        dry_run = TRUE
      )
    },

    #' @description
    #' Previews both plans and prints what UBI would hold.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a plan or could not be reached.
    run = function() {
      cat(
        sprintf(
          "Entry at %s, target at %s\n",
          self$entry_price,
          self$target_price
        )
      )
      choices <- list(
        list(
          description = "entry held by default",
          entry_hold_limits = NULL
        ),
        list(
          description = "entry resting at the broker",
          entry_hold_limits = FALSE
        )
      )
      for (choice in choices) {
        order <- self$plan_order(choice[["entry_hold_limits"]])
        cat(sprintf("Plan with the %s:\n", choice[["description"]]))
        cat(
          jsonlite::toJSON(
            order$synthetic[["plan"]],
            auto_unbox = TRUE,
            null = "null",
            pretty = TRUE,
            digits = NA
          ),
          "\n",
          sep = ""
        )
        answer <- order$place()
        cat(
          jsonlite::toJSON(
            answer[["plan"]],
            auto_unbox = TRUE,
            null = "null",
            pretty = TRUE,
            digits = NA
          ),
          "\n",
          sep = ""
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  HeldEntryAndTarget$new()$run()
}
