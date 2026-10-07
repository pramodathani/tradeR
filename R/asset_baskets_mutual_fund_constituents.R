#' The instruments a mutual fund holds, with their weights
#'
#' @description
#' UBI has no price of any kind for a mutual fund: no quote, no candles and no net asset value history, so `MutualFund` cannot measure its own performance and its inherited `sharpe_ratio()` returns `NULL`. Its holdings can be measured instead, because they are ordinary shares and bonds that UBI does price. `MutualFund$constituents` returns this basket, and every analysis and performance method works on it.
#'
#' The basket is an estimate of the fund, not the fund. Its weights come from the fund's monthly portfolio disclosure, so they are up to a month old, and the fund's cash, fees and anything else UBI cannot price are left out; `unmapped_weight` records how much of the fund that is. `estimated_day_change_percent` scales the holdings' day move down by that share, which is the usual way to guess today's change in the net asset value before the fund publishes it.
#'
#' The generator carries `MutualFundConstituents$KIND`, `"mutual_fund_constituents"`.
#'
#' @examples
#' \dontrun{
#' weights <- c(
#'   HDFCBANK = 9,
#'   ICICIBANK = 7.5,
#'   INFY = 6,
#'   RELIANCE = 5.5
#' )
#' members <- list()
#' for (symbol in names(weights)) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   members[[length(members) + 1]] <- BasketMember$new(
#'     share,
#'     weight = weights[[symbol]]
#'   )
#' }
#' scheme <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
#' holdings <- MutualFundConstituents$new(
#'   name = "ABSLFTTIDG",
#'   members = members,
#'   fund = scheme,
#'   unmapped_weight = 0.05
#' )
#' guess <- holdings$estimated_day_change_percent
#' ratio <- holdings$sharpe_ratio(risk_free_rate = 0.065, days = 365)
#'
#' cat(holdings$fund$symbol, holdings$fund$segment, "\n")
#'
#' print(holdings$fund$prices(days = 30))
#' print(holdings$sharpe_ratio(risk_free_rate = 0.065, days = 365))
#'
#' change <- holdings$estimated_day_change_percent
#' cat(sprintf("Estimated move: %+.3f%%\n", change))
#'
#' print(holdings$day_change_percent)
#' print(holdings$estimated_day_change_percent)
#' }
#' @export
MutualFundConstituents <- R6::R6Class(
  "MutualFundConstituents",
  inherit = AssetBasket,
  public = list(
    #' @field KIND The character kind stored with the basket, `"mutual_fund_constituents"`.
    KIND = "mutual_fund_constituents",

    #' @description
    #' Initialises the fund's holdings.
    #' @param name The character name of the basket, usually the scheme's code, such as `"ABSLFTTIDG"`.
    #' @param members A list of `BasketMember` objects, one per holding, each a different instrument, with a weight on every member or on none.
    #' @param fund The `Instrument` of the scheme itself, or `NULL`.
    #' @param unmapped_weight The numeric share of the fund, between 0 and 1, held in things UBI cannot price, such as cash and money market instruments.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `MutualFundConstituents` object.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or gives weights to only some members; and `ValueError` when `unmapped_weight` is not between 0 and 1.
    initialize = function(
      name,
      members,
      fund = NULL,
      unmapped_weight = 0,
      unified_broker_interface = NULL
    ) {
      super$initialize(
        name = name,
        members = members,
        linked_instrument = fund,
        unmapped_weight = unmapped_weight,
        unified_broker_interface = unified_broker_interface
      )
    },

    #' @description
    #' Estimates today's net asset value from the last published one and the holdings' moves.
    #' @param previous_net_asset_value The numeric net asset value in rupees the fund last published.
    #' @return The numeric estimated net asset value in rupees, or `NULL` when any holding has no quote.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   HDFCBANK = 9,
    #'   ICICIBANK = 7.5,
    #'   INFY = 6,
    #'   RELIANCE = 5.5
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' scheme <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    #' holdings <- MutualFundConstituents$new(
    #'   name = "ABSLFTTIDG",
    #'   members = members,
    #'   fund = scheme,
    #'   unmapped_weight = 0.05
    #' )
    #' estimate <- holdings$estimated_net_asset_value(
    #'   previous_net_asset_value = 45.62
    #' )
    #' cat(sprintf("Estimated net asset value: Rs %.4f\n", estimate))
    #'
    #' cat(sprintf("1,000 units: Rs %.2f\n", estimate * 1000))
    #' }
    estimated_net_asset_value = function(previous_net_asset_value) {
      change <- self$estimated_day_change_percent
      if (is.null(change)) {
        return(NULL)
      }
      previous_net_asset_value * (1 + change / 100)
    }
  ),
  active = list(
    #' @field fund The `Instrument` of the scheme these are the holdings of, or `NULL` when none is linked.
    fund = function(value) {
      if (!missing(value)) {
        stop("fund is read-only", call. = FALSE)
      }
      self$linked_instrument
    },

    #' @field estimated_day_change_percent The numeric estimated move of the fund's net asset value today, in percent: the holdings' weighted move scaled down by the share UBI cannot price, or `NULL` when any holding has no quote, read from UBI on every access.
    estimated_day_change_percent = function(value) {
      if (!missing(value)) {
        stop("estimated_day_change_percent is read-only", call. = FALSE)
      }
      holdings_change <- self$day_change_percent
      if (is.null(holdings_change)) {
        return(NULL)
      }
      holdings_change * (1 - self$unmapped_weight)
    }
  )
)

MutualFundConstituents$KIND <- "mutual_fund_constituents"
