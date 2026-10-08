#' Price protective Nifty puts at several distances below the index.
#'
#' A protective put pays out if the index falls below its strike, like insurance on a portfolio. The program builds the puts on the next expiry at roughly 1, 2, 3 and 5 per cent below the index, through the base IndexOption class, and prints the premium of each as a percentage of the index and of one lot's notional value, with its delta.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/instruments/index_option/protective_put_cost.R

library(tradeR)

#' The cost of Nifty puts at several distances out of the money.
#'
#' @field distances_percent A numeric vector of distances below the index, in per cent.
ProtectivePutCost <- R6::R6Class(
  "ProtectivePutCost",
  public = list(
    distances_percent = NULL,

    #' @description
    #' Stores the distances to price.
    #' @return A new `ProtectivePutCost` object.
    initialize = function() {
      self$distances_percent <- c(
        1.0,
        2.0,
        3.0,
        5.0
      )
    },

    #' @description
    #' Chooses the first Nifty option expiry after today.
    #' @return The `Date` of the expiry.
    #' @details Errors: signals `ValueError` when no expiry after today is listed, and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    choose_expiry = function() {
      today <- TimeConverter$new()$today()
      expiries <- EquityIndexOption$expiries(
        exchange = "nse",
        underlying_symbol = "NIFTY"
      )
      for (expiry_index in seq_along(expiries)) {
        expiry_date <- expiries[[expiry_index]]
        if (expiry_date > today) {
          return(expiry_date)
        }
      }
      ErrorCatalogue$raise(
        "ValueError",
        sprintf(
          "No Nifty option expiry after today is listed: today=%s",
          today
        )
      )
    },

    #' @description
    #' Prints one line per distance.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `ValueError` when no expiry after today is listed, and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      expiry_date <- self$choose_expiry()
      chain <- EquityIndexOption$chain(
        exchange = "nse",
        underlying_symbol = "NIFTY",
        expiry_date = expiry_date
      )
      puts <- chain[chain$option_type == "PE", , drop = FALSE]
      level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
      cat(sprintf(
        "NIFTY at %s, puts expiring %s\n",
        format(level),
        format(expiry_date)
      ))
      for (distance in self$distances_percent) {
        target <- level * (1 - distance / 100)
        distances <- abs(puts$strike_price - target)
        nearest_row <- which.min(distances)
        put_instrument_id <- puts$instrument_id[[nearest_row]]
        put <- IndexOption$new(instrument_id = put_instrument_id)
        premium <- put$last_price
        greeks <- put$greeks()
        delta_text <- "-"
        if (!is.null(greeks)) {
          delta_text <- sprintf("%.3f", greeks[["delta"]])
        }
        lot_premium <- formatC(
          put$premium_per_lot,
          format = "f",
          digits = 0,
          big.mark = ","
        )
        lot_notional <- formatC(
          put$notional_value,
          format = "f",
          digits = 0,
          big.mark = ","
        )
        cat(sprintf(
          paste0(
            "  %.0f%% below: strike %.0f, premium %s, %.2f%% of the index, ",
            "Rs %s a lot on Rs %s, delta %s\n"
          ),
          distance,
          put$strike_price,
          format(premium),
          premium / level * 100,
          lot_premium,
          lot_notional,
          delta_text
        ))
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  ProtectivePutCost$new()$run()
}
