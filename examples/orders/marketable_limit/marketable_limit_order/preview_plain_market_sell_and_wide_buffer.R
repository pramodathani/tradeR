#' Preview a plain market sell and a marketable limit sell with a wider buffer, and compare the plans UBI would run.
#'
#' The program asks UBI for two dry runs of selling one Vodafone Idea share intraday. The first is an ordinary `sell_at_market_price()`, which UBI's order engine turns into a `marketable_limit` order with its default buffer of two ticks and its default thirty seconds. The second names the type itself with a buffer of five ticks and a minute to fill. It prints the pricing and lifetime of each plan. A dry run records and sends nothing.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/marketable_limit/marketable_limit_order/preview_plain_market_sell_and_wide_buffer.R

library(tradeR)

#' Two previews of a one-share market sell, one plain and one with its own buffer and time.
#'
#' @field share The `Equity` for Vodafone Idea on the NSE.
MarketSellPreviews <- R6::R6Class(
  "MarketSellPreviews",
  public = list(
    share = NULL,

    #' @description
    #' Looks up the share the program previews.
    #' @return A new `MarketSellPreviews` object.
    #' @details Errors: signals `InstrumentError` when the share could not be found in UBI.
    initialize = function() {
      self$share <- Equity$new(exchange = "nse", symbol = "IDEA")
    },

    #' @description
    #' Writes a value UBI returned as text for printing, the way Python's f-strings print it.
    #'
    #' A list is written as one line of JSON, `NULL` as `"NULL"` and anything else with `format()`, so a missing field still prints rather than emptying the whole line.
    #' @param value Any value, such as a character, a number, a named list or `NULL`.
    #' @return A character value.
    text_of = function(value) {
      if (is.null(value)) {
        return("NULL")
      }
      if (is.list(value)) {
        json <- jsonlite::toJSON(
          value,
          auto_unbox = TRUE,
          null = "null"
        )
        return(as.character(json))
      }
      paste(format(value), collapse = ", ")
    },

    #' @description
    #' Asks UBI for a dry run of an ordinary market sell.
    #' @return The named list dry run answer, holding the `request` as written and the `plan` UBI would run.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the order or could not be reached.
    plain_market_sell = function() {
      self$share$place_order(
        transaction_type = "sell",
        order_type = "market",
        quantity = 1,
        product = "mis",
        dry_run = TRUE
      )
    },

    #' @description
    #' Asks UBI for a dry run of a marketable limit sell five ticks through the bid that works for a minute.
    #' @return The named list dry run answer, holding the `request` as written and the `plan` UBI would run.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused the order or could not be reached.
    wide_buffer_sell = function() {
      order <- MarketableLimitOrder$new(
        self$share,
        transaction_type = "sell",
        product = "mis",
        order_type = "market",
        quantity = 1,
        buffer_ticks = 5,
        fill_within_seconds = 60,
        dry_run = TRUE
      )
      order$place()
    },

    #' @description
    #' Prints the order type the request was written as, and the presets, pricing and lifetime of the plan UBI would run.
    #' @param title The character heading to print above the plan.
    #' @param answer The named list dry run answer.
    #' @return `NULL`, invisibly.
    print_plan = function(title, answer) {
      order <- answer[["plan"]][["order"]]
      slots <- order[["slots"]]
      cat(title, "\n", sep = "")
      cat(sprintf(
        "  written as: %s\n",
        self$text_of(answer[["request"]][["form"]][["prctyp"]])
      ))
      cat(sprintf("  presets: %s\n", self$text_of(order[["presets"]])))
      cat(sprintf("  pricing: %s\n", self$text_of(slots[["pricing"]])))
      cat(sprintf("  lifetime: %s\n", self$text_of(slots[["lifetime"]])))
      invisible(NULL)
    },

    #' @description
    #' Previews both sells and prints their plans.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `UnifiedBrokerInterfaceError` when UBI refused an order or could not be reached.
    run = function() {
      self$print_plan("A plain market sell:", self$plain_market_sell())
      self$print_plan(
        "A marketable limit sell named in full:",
        self$wide_buffer_sell()
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  MarketSellPreviews$new()$run()
}
