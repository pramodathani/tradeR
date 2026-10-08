#' List the days the Nifty's RSI left oversold or overbought ground in the last two years.
#'
#' The program adds the 14-day relative strength index to two years of Nifty candles, adds constant columns for the levels 30 and 70, and uses `is_cross_over` to find the days the index rose out of oversold ground and `is_cross_under` to find the days it fell out of overbought ground.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/analysis/signals/signals/relative_strength_alerts.R

library(tradeR)

#' A list of the RSI threshold crossings of one index.
#'
#' @field index The `EquityIndex` to read.
#' @field oversold_level The integer RSI level below which the index counts as oversold.
#' @field overbought_level The integer RSI level above which the index counts as overbought.
RelativeStrengthAlerts <- R6::R6Class(
  "RelativeStrengthAlerts",
  public = list(
    index = NULL,
    oversold_level = NULL,
    overbought_level = NULL,

    #' @description
    #' Creates the alerts over the Nifty with the usual levels of 30 and 70.
    #' @return A new `RelativeStrengthAlerts` object.
    initialize = function() {
      self$index <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
      self$oversold_level <- 30
      self$overbought_level <- 70
    },

    #' @description
    #' Prints the date, close and RSI of each event.
    #' @param label The character description of the kind of event.
    #' @param events The `data.frame` of the marked rows.
    #' @return `NULL`, invisibly.
    print_events = function(label, events) {
      cat(sprintf("%s: %d\n", label, nrow(events)))
      for (position in seq_len(nrow(events))) {
        row <- events[position, ]
        event_date <- format(row$datetime, "%Y-%m-%d")
        cat(
          sprintf(
            "  %s  close %.2f  RSI %.1f\n",
            event_date,
            row$close,
            row$rsi_14
          )
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Finds and prints both kinds of crossing.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      frame <- self$index$relative_strength_index(window = 14, days = 730)
      if (is.null(frame)) {
        cat("UBI has no Nifty candles for the last two years.\n")
        return(invisible(NULL))
      }
      frame$oversold_level <- self$oversold_level
      frame$overbought_level <- self$overbought_level
      rises <- self$index$is_cross_over(frame, "rsi_14", "oversold_level")
      falls <- self$index$is_cross_under(frame, "rsi_14", "overbought_level")
      self$print_events(
        "Rose out of oversold ground",
        rises[rises$cross_over, ]
      )
      self$print_events(
        "Fell out of overbought ground",
        falls[falls$cross_under, ]
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  RelativeStrengthAlerts$new()$run()
}
