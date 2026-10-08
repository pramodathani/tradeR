#' Build a buy of Vodafone Idea that is hedged by selling Yes Bank, half as many shares as each fill of the buy.
#'
#' The hedge is a `then` join's child, which a `parent_fill` quantity must be. Every time the buy fills more, UBI resizes the hedge to half of what has filled in all, so a buy that fills 600 and then 400 more ends with a hedge of 500. It prints the plan. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/parent_fill_quantity/parent_fill_quantity/hedge_half_of_each_fill.R

library(tradeR)

#' A buy in one share and a hedge in another sized to half its fills.
#'
#' @field hedge_share The `Equity` sold as the hedge.
#' @field hedge_ratio The numeric share of each fill the hedge sells.
HalfHedgedBuy <- R6::R6Class(
  "HalfHedgedBuy",
  public = list(
    hedge_share = NULL,
    hedge_ratio = NULL,

    #' @description
    #' Looks the hedge share up.
    #' @return A new `HalfHedgedBuy` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$hedge_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
      self$hedge_ratio <- 0.5
    },

    #' @description
    #' Prints the plan.
    #' @return `NULL`, invisibly.
    run = function() {
      plan <- ThenPart$new(
        first = OrderPart$new(
          pricing = MarketablePricing$new()
        ),
        each_fill = OrderPart$new(
          instrument = self$hedge_share,
          transaction_type = "sell",
          product = "mis",
          pricing = MarketablePricing$new(),
          quantity = ParentFillQuantity$new(
            ratio = self$hedge_ratio
          )
        )
      )
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
  HalfHedgedBuy$new()$run()
}
