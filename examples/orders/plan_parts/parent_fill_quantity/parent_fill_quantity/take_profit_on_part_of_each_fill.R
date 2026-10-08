#' Build a buy of Vodafone Idea whose profit target sells only a third of what fills, leaving the rest to run.
#'
#' The program reads the share's last price and follows the buy with a protecting limit 4% above it, sized by a `parent_fill` quantity with ratio one third rather than to the whole fill. It prints the plan, and then the same quantity with `whole_lots` on, which would round each size to whole lots of the instrument; for a share a lot is one share, so the rounding matters for futures and options. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/parent_fill_quantity/parent_fill_quantity/take_profit_on_part_of_each_fill.R

library(tradeR)

#' A buy whose target takes a third of each fill off.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
PartialTakeProfit <- R6::R6Class(
  "PartialTakeProfit",
  public = list(
    share = NULL,

    #' @description
    #' Looks the share up.
    #' @return A new `PartialTakeProfit` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Prints the plan and the rounded quantity.
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
      plan <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = FixedPricing$new(
            price = round(last_price * 1.04, 2),
            order_type = "LIMIT"
          ),
          quantity = ParentFillQuantity$new(ratio = 0.33)
        )
      )
      rounded <- ParentFillQuantity$new(
        ratio = 0.33,
        whole_lots = TRUE
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
      cat("The same quantity rounded to whole lots:\n")
      cat(
        jsonlite::toJSON(
          rounded$document(),
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
  PartialTakeProfit$new()$run()
}
