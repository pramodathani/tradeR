#' Report how a weighted basket of IT shares is doing today.
#'
#' The program builds a basket of five IT shares with their own weights, then prints its weights and concentration, the weighted move since yesterday's close, how many members are up and down, and the biggest gainer and loser, reading every member's prices from UBI in one request per table.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/asset_basket/asset_basket/sector_day_report.R

library(tradeR)

WEIGHTS <- c(
  INFY = 30,
  TCS = 30,
  HCLTECH = 20,
  WIPRO = 10,
  TECHM = 10
)

#' A day report on a weighted basket of IT shares.
#'
#' @field basket The `AssetBasket` being reported.
SectorDayReport <- R6::R6Class(
  "SectorDayReport",
  public = list(
    basket = NULL,

    #' @description
    #' Looks every share up in UBI and builds the basket.
    #' @return A new `SectorDayReport` object.
    #' @details Errors: signals `EquityError` when UBI does not know one of the shares.
    initialize = function() {
      members <- list()
      for (symbol in names(WEIGHTS)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(
          share,
          weight = WEIGHTS[[symbol]]
        )
      }
      self$basket <- AssetBasket$new(name = "IT shares", members = members)
    },

    #' @description
    #' Prints each member's weight and how concentrated the basket is.
    #' @return `NULL`, invisibly.
    print_weights = function() {
      cat(sprintf("%s: %d members\n", self$basket$name, self$basket$size))
      weights <- self$basket$weights
      for (label in names(weights)) {
        cat(sprintf("  %-12s %.0f%%\n", label, weights[[label]] * 100))
      }
      effective <- self$basket$effective_number_of_members
      cat(sprintf("Acts like %.1f equal members\n", effective))
      invisible(NULL)
    },

    #' @description
    #' Prints the basket's move, its breadth and its biggest movers.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    print_day = function() {
      change <- self$basket$day_change_percent
      if (is.null(change)) {
        cat("A member has no quote, so the day's move is unknown.\n")
      } else {
        cat(sprintf("Weighted move today: %+.2f%%\n", change))
      }
      breadth <- self$basket$breadth
      cat(
        sprintf(
          "Up %d, down %d\n",
          breadth[["advancers"]],
          breadth[["decliners"]]
        )
      )
      gainers <- self$basket$top_gainers(count = 1)
      losers <- self$basket$top_losers(count = 1)
      if (nrow(gainers) > 0) {
        cat(
          sprintf(
            "Best:  %s %+.2f%%\n",
            gainers$label[[1]],
            gainers$change_percent[[1]]
          )
        )
      }
      if (nrow(losers) > 0) {
        cat(
          sprintf(
            "Worst: %s %+.2f%%\n",
            losers$label[[1]],
            losers$change_percent[[1]]
          )
        )
      }
      invisible(NULL)
    },

    #' @description
    #' Prints the whole report.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      self$print_weights()
      self$print_day()
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  SectorDayReport$new()$run()
}
