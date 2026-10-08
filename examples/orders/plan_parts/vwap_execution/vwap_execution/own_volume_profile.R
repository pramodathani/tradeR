#' Build a VWAP with a volume profile of its own, and show how its weights share out the slices.
#'
#' UBI's default profile is the NSE equity day's shape and is used only for equity; a currency or commodity order with no profile of its own gets even slices. The program builds a VWAP over the first two hours of a session with its own profile, four half-hour weights heavy at the open, and prints the order and each half hour's share of the weight. The half hours count from the segment's own open, 09:15 for equity and 09:00 for currency and MCX. Nothing is sent to UBI's order routes.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/vwap_execution/vwap_execution/own_volume_profile.R

library(tradeR)

#' A VWAP over two hours whose slices follow a profile given here.
#'
#' @field execution The `VwapExecution` with its own profile.
#' @field part The `OrderPart` the program prints.
OwnVolumeProfile <- R6::R6Class(
  "OwnVolumeProfile",
  public = list(
    execution = NULL,
    part = NULL,

    #' @description
    #' Builds the execution and the order.
    #' @return A new `OwnVolumeProfile` object.
    initialize = function() {
      self$execution <- VwapExecution$new(
        slices = 8,
        over_minutes = 120,
        volume_profile = c(
          4.0,
          2.5,
          2.0,
          1.5
        )
      )
      self$part <- OrderPart$new(
        pricing = MarketablePricing$new(buffer_ticks = 2),
        execution = self$execution
      )
    },

    #' @description
    #' Prints the order's object and each half hour's share of the profile.
    #' @return `NULL`, invisibly.
    run = function() {
      cat(
        jsonlite::toJSON(
          self$part$document(),
          auto_unbox = TRUE,
          null = "null",
          pretty = TRUE,
          digits = NA
        ),
        "\n",
        sep = ""
      )
      total <- sum(self$execution$volume_profile)
      half_hour <- 1
      for (weight in self$execution$volume_profile) {
        cat(
          sprintf(
            "Half hour %d after the open: %.0f%% of the weight\n",
            half_hour,
            weight / total * 100
          )
        )
        half_hour <- half_hour + 1
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  OwnVolumeProfile$new()$run()
}
