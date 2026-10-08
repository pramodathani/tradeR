#' Build a cover order by hand: an entry whose every fill gets a stop resting at the broker.
#'
#' This is what the `cover` preset stands for, written out as a then join. The program builds the entry, then a protecting order priced by a native stop at 990 with its limit at 988, sized to each fill, and prints it beside the preset form. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/native_stop_pricing/native_stop_pricing/cover_order_written_out.R

library(tradeR)

#' A cover order written as a then join beside the preset that stands for it.
#'
#' @field stop_price The numeric trigger of the stop in rupees.
#' @field stop_limit_price The numeric limit of the stop in rupees.
CoverByHand <- R6::R6Class(
  "CoverByHand",
  public = list(
    stop_price = NULL,
    stop_limit_price = NULL,

    #' @description
    #' Sets the stop's prices.
    #' @return A new `CoverByHand` object.
    initialize = function() {
      self$stop_price <- 990.0
      self$stop_limit_price <- 988.0
    },

    #' @description
    #' Prints the written-out cover order and the preset form.
    #' @return `NULL`, invisibly.
    run = function() {
      by_hand <- ThenPart$new(
        first = OrderPart$new(),
        each_fill = OrderPart$new(
          side = "protect",
          pricing = NativeStopPricing$new(
            trigger_price = self$stop_price,
            limit_price = self$stop_limit_price
          )
        )
      )
      by_preset <- OrderPart$new(
        presets = list(
          Preset$new(
            "cover",
            stop_price = self$stop_price,
            stop_limit_price = self$stop_limit_price
          )
        )
      )
      cat("Written out as a then join:\n")
      cat(
        jsonlite::toJSON(
          by_hand$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      cat("The same order as a preset:\n")
      cat(
        jsonlite::toJSON(
          by_preset$document(),
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
  CoverByHand$new()$run()
}
