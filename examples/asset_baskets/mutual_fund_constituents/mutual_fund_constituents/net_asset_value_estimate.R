#' Estimate a mutual fund's net asset value today from its holdings' moves.
#'
#' The program describes a scheme by a few of its disclosed equity holdings with illustrative weights and 20% of the fund in cash and bonds that UBI cannot price, then estimates today's move and today's net asset value from the last published value, and prints what a holding of 2,500 units is worth on that estimate.
#'
#' Typical usage example:
#'
#'   Rscript examples/asset_baskets/mutual_fund_constituents/mutual_fund_constituents/net_asset_value_estimate.R

library(tradeR)

WEIGHTS <- c(
  HDFCBANK = 9.0,
  ICICIBANK = 7.5,
  INFY = 6.0,
  RELIANCE = 5.5,
  LT = 4.0,
  ITC = 3.5
)

UNMAPPED_WEIGHT <- 0.2

PREVIOUS_NET_ASSET_VALUE <- 45.62

UNITS_HELD <- 2500

#' An estimate of one scheme's net asset value from its holdings.
#'
#' @field holdings The `MutualFundConstituents` of the scheme.
NetAssetValueEstimate <- R6::R6Class(
  "NetAssetValueEstimate",
  public = list(
    holdings = NULL,

    #' @description
    #' Looks the scheme and its holdings up in UBI and builds the basket.
    #' @return A new `NetAssetValueEstimate` object.
    #' @details Errors: signals an `InstrumentError` subclass when UBI does not know one of the instruments.
    initialize = function() {
      members <- list()
      for (symbol in names(WEIGHTS)) {
        share <- Equity$new(exchange = "nse", symbol = symbol)
        members[[length(members) + 1]] <- BasketMember$new(
          share,
          weight = WEIGHTS[[symbol]]
        )
      }
      scheme <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
      self$holdings <- MutualFundConstituents$new(
        name = "ABSLFTTIDG",
        members = members,
        fund = scheme,
        unmapped_weight = UNMAPPED_WEIGHT
      )
    },

    #' @description
    #' Prints the holdings' move, the estimated move and value, and the units' worth.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    run = function() {
      cat(
        sprintf(
          "Scheme %s, %d priced holdings\n",
          self$holdings$fund$symbol,
          self$holdings$size
        )
      )
      holdings_change <- self$holdings$day_change_percent
      estimated_change <- self$holdings$estimated_day_change_percent
      if (is.null(holdings_change) || is.null(estimated_change)) {
        cat("A holding has no quote, so no estimate can be made.\n")
        return(invisible(NULL))
      }
      cat(sprintf("Holdings' move today: %+.3f%%\n", holdings_change))
      cat(
        sprintf(
          "Estimated move after %.0f%% unpriced: %+.3f%%\n",
          UNMAPPED_WEIGHT * 100,
          estimated_change
        )
      )
      estimate <- self$holdings$estimated_net_asset_value(
        PREVIOUS_NET_ASSET_VALUE
      )
      cat(
        sprintf(
          "Net asset value: last published %s, estimated %.4f\n",
          PREVIOUS_NET_ASSET_VALUE,
          estimate
        )
      )
      cat(
        sprintf(
          "%s units: about Rs %s\n",
          formatC(UNITS_HELD, format = "d", big.mark = ","),
          formatC(
            estimate * UNITS_HELD,
            format = "f",
            digits = 2,
            big.mark = ","
          )
        )
      )
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  NetAssetValueEstimate$new()$run()
}
