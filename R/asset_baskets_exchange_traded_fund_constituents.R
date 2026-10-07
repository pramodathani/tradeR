#' The instruments an exchange traded fund holds, with their weights
#'
#' @description
#' An exchange traded fund is two things. The fund's units trade on the exchange at their own price, which `ExchangeTradedFund` reads, and the fund holds a basket of other instruments, which this class describes. `ExchangeTradedFund$constituents` returns the stored basket, and the basket's `fund` is the fund again.
#'
#' Comparing the two says how well the fund does its job. `tracking_difference()` is the fund's return minus its holdings' return over a range, which is mostly its fees, and the inherited `tracking_error(benchmark = basket$fund)` is how unevenly it follows them. `premium_or_discount` compares the fund's price now with its indicative net asset value, which the exchange publishes as an index row such as `NIFTYBEES-NAV` when one is stored with the basket.
#'
#' The generator carries `ExchangeTradedFundConstituents$KIND`, `"exchange_traded_fund_constituents"`.
#'
#' @examples
#' \dontrun{
#' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
#' holdings <- fund$constituents
#' gap <- holdings$tracking_difference(days = 365)
#' premium <- holdings$premium_or_discount
#'
#' weights <- c(
#'   HDFCBANK = 13,
#'   ICICIBANK = 9,
#'   RELIANCE = 8.5,
#'   INFY = 5,
#'   BHARTIARTL = 4.5
#' )
#' members <- list()
#' for (symbol in names(weights)) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   members[[length(members) + 1]] <- BasketMember$new(
#'     share,
#'     weight = weights[[symbol]]
#'   )
#' }
#' holdings <- ExchangeTradedFundConstituents$new(
#'   name = "NIFTYBEES",
#'   members = members,
#'   fund = fund
#' )
#'
#' cat(holdings$fund$symbol, holdings$fund$last_price, "\n")
#' unlinked <- ExchangeTradedFundConstituents$new(
#'   name = "unlinked",
#'   members = members
#' )
#' print(unlinked$fund)
#'
#' print(holdings$premium_or_discount)
#' premium <- holdings$premium_or_discount
#' if (is.null(premium)) {
#'   symbol <- holdings$fund$symbol
#'   cat(sprintf("No indicative value is known for %s.\n", symbol))
#' } else {
#'   cat(sprintf(
#'     "%s trades at %+.2f%% to its value\n",
#'     holdings$fund$symbol,
#'     premium
#'   ))
#' }
#' }
#' @export
ExchangeTradedFundConstituents <- R6::R6Class(
  "ExchangeTradedFundConstituents",
  inherit = AssetBasket,
  public = list(
    #' @field KIND The character kind stored with the basket, `"exchange_traded_fund_constituents"`.
    KIND = "exchange_traded_fund_constituents",
    #' @field indicative_net_asset_value The `Instrument` that carries the fund's indicative net asset value, such as the index row `NIFTYBEES-NAV`, or `NULL` when none is known.
    indicative_net_asset_value = NULL,

    #' @description
    #' Initialises the fund's holdings.
    #' @param name The character name of the basket, usually the fund's symbol, such as `"NIFTYBEES"`.
    #' @param members A list of `BasketMember` objects, one per holding, each a different instrument, with a weight on every member or on none.
    #' @param fund The `Instrument` of the fund itself, or `NULL`.
    #' @param indicative_net_asset_value The `Instrument` carrying the fund's indicative net asset value, or `NULL`.
    #' @param unmapped_weight The numeric share of the fund, between 0 and 1, held in things UBI cannot price, such as cash.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `ExchangeTradedFundConstituents` object.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or gives weights to only some members; and `ValueError` when `unmapped_weight` is not between 0 and 1.
    initialize = function(
      name,
      members,
      fund = NULL,
      indicative_net_asset_value = NULL,
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
      self$indicative_net_asset_value <- indicative_net_asset_value
    },

    #' @description
    #' Calculates the fund's return minus its holdings' return over a range.
    #'
    #' A small negative number is normal, since the fund pays fees its holdings do not. The holdings' return is the return of today's weights held through the range, so it drifts from the fund's real history when the holdings changed during it.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric difference of the two cumulative returns, such as -0.001 for a tenth of a percent behind, or `NULL` when no fund is linked or either has too few candles.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   HDFCBANK = 13,
    #'   ICICIBANK = 9,
    #'   RELIANCE = 8.5,
    #'   INFY = 5,
    #'   BHARTIARTL = 4.5
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    #' holdings <- ExchangeTradedFundConstituents$new(
    #'   name = "NIFTYBEES",
    #'   members = members,
    #'   fund = fund
    #' )
    #' difference <- holdings$tracking_difference(days = 365)
    #' cat(sprintf("Tracking difference: %+.4f\n", difference))
    #'
    #' for (days in c(
    #'   90,
    #'   365
    #' )) {
    #'   print(c(
    #'     days,
    #'     holdings$tracking_difference(days = days)
    #'   ))
    #' }
    #' }
    tracking_difference = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      if (is.null(self$fund)) {
        return(NULL)
      }
      fund_return <- self$fund$cumulative_return(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      holdings_return <- self$cumulative_return(
        interval = interval,
        from_date = from_date,
        to_date = to_date,
        days = days,
        adjusted = adjusted
      )
      if (is.null(fund_return) || is.null(holdings_return)) {
        return(NULL)
      }
      fund_return - holdings_return
    },

    #' @description
    #' Describes the fund's holdings as a named list for storing in MongoDB.
    #' @param effective_date The first day the holdings are in effect as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @return The named list `AssetBasket$document()` gives, with `indicative_net_asset_value_instrument_id` added, which is `NULL` when no indicative value is linked.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   HDFCBANK = 13,
    #'   ICICIBANK = 9,
    #'   RELIANCE = 8.5,
    #'   INFY = 5,
    #'   BHARTIARTL = 4.5
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    #' holdings <- ExchangeTradedFundConstituents$new(
    #'   name = "NIFTYBEES",
    #'   members = members,
    #'   fund = fund
    #' )
    #' document <- holdings$document(effective_date = "2026-09-01")
    #' cat(document$kind, document$linked_instrument_id, "\n")
    #' print(document$indicative_net_asset_value_instrument_id)
    #'
    #' for (member_document in holdings$document()$members) {
    #'   cat(member_document$symbol, member_document$weight, "\n")
    #' }
    #' }
    document = function(effective_date = NULL) {
      document <- super$document(effective_date)
      if (is.null(self$indicative_net_asset_value)) {
        document["indicative_net_asset_value_instrument_id"] <- list(NULL)
      } else {
        document[["indicative_net_asset_value_instrument_id"]] <-
          self$indicative_net_asset_value$instrument_id
      }
      document
    }
  ),
  active = list(
    #' @field fund The `Instrument` of the fund these are the holdings of, or `NULL` when none is linked.
    fund = function(value) {
      if (!missing(value)) {
        stop("fund is read-only", call. = FALSE)
      }
      self$linked_instrument
    },

    #' @field premium_or_discount The numeric percent by which the fund's last price is above its indicative net asset value, negative for a discount, or `NULL` when the fund, the indicative value or either price is missing, read from UBI in one request on every access.
    premium_or_discount = function(value) {
      if (!missing(value)) {
        stop("premium_or_discount is read-only", call. = FALSE)
      }
      if (is.null(self$fund) || is.null(self$indicative_net_asset_value)) {
        return(NULL)
      }
      results <- private$post_for_instruments(
        ASSET_BASKETS_LAST_PRICE_PATH,
        list(
          self$fund,
          self$indicative_net_asset_value
        )
      )
      fund_data <- results[[1]][["data"]]
      value_data <- results[[2]][["data"]]
      fund_price <- fund_data[["last_price"]]
      net_asset_value <- value_data[["last_price"]]
      if (is.null(fund_price) || is.null(net_asset_value) ||
            net_asset_value == 0) {
        return(NULL)
      }
      (as.numeric(fund_price) / as.numeric(net_asset_value) - 1) * 100
    }
  )
)

ExchangeTradedFundConstituents$KIND <- "exchange_traded_fund_constituents"
