#' Print the preset objects for four ways of getting out of a position, each named after an existing synthetic order type.
#'
#' The program builds `trailing_stop`, `cover`, `hidden_stop` and `oto` presets with typical settings for a position bought near 1000, and prints the name and settings object of each, which is what goes into an order's `presets` list. A preset's settings are those of the type it is named after. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/preset/preset/catalogue_of_exit_presets.R

library(tradeR)

#' A catalogue of exit presets with a description of each.
#'
#' @field entries A list of entries, each a named list holding `description`, a character description, and `preset`, a `Preset`.
ExitPresetCatalogue <- R6::R6Class(
  "ExitPresetCatalogue",
  public = list(
    entries = NULL,

    #' @description
    #' Builds the presets.
    #' @return A new `ExitPresetCatalogue` object.
    initialize = function() {
      self$entries <- list(
        list(
          description = "a stop that trails 5 rupees behind the best price",
          preset = Preset$new(
            "trailing_stop",
            trail_points = 5.0,
            stop_limit_offset = 1.0
          )
        ),
        list(
          description = "a compulsory stop placed with every fill",
          preset = Preset$new(
            "cover",
            stop_price = 990.0,
            stop_limit_price = 988.0
          )
        ),
        list(
          description = "a stop kept inside UBI with a real backstop behind it",
          preset = Preset$new(
            "hidden_stop",
            trigger_price = 992.0,
            backstop_price = 985.0,
            backstop_limit_price = 983.0
          )
        ),
        list(
          description = "a limit sell sized to whatever the entry filled",
          preset = Preset$new(
            "oto",
            then = list(
              transaction_type = "SELL",
              order_type = "LIMIT",
              price = 1015.0
            )
          )
        )
      )
    },

    #' @description
    #' Prints each preset's description, name and object.
    #' @return `NULL`, invisibly.
    run = function() {
      for (entry in self$entries) {
        exit_preset <- entry[["preset"]]
        cat(sprintf("%s: %s\n", exit_preset$name, entry[["description"]]))
        cat(
          jsonlite::toJSON(
            exit_preset$document(),
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
  ExitPresetCatalogue$new()$run()
}
