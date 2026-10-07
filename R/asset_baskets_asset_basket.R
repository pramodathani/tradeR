ASSET_BASKETS_LAST_PRICE_PATH <- "/api/instruments/ltp"
ASSET_BASKETS_OHLC_PATH <- "/api/instruments/ohlc"
ASSET_BASKETS_QUOTE_PATH <- "/api/instruments/quote"
ASSET_BASKETS_PRICES_PATH <- "/api/instruments/prices"
ASSET_BASKETS_SUCCESS_STATUS <- 200
ASSET_BASKETS_DEFAULT_BASE_VALUE <- 100
ASSET_BASKETS_CANDLE_COLUMNS <- c(
  "open",
  "high",
  "low",
  "close"
)
ASSET_BASKETS_IDENTITY_COLUMNS <- c(
  "instrument_id",
  "exchange",
  "segment",
  "symbol",
  "underlying_symbol",
  "expiry_date",
  "strike_price",
  "option_type"
)

#' A named group of instruments that is priced, analysed and stored as one
#'
#' @description
#' `AssetBasket` holds a list of `BasketMember` objects and reads what it needs about all of them in one list request to UBI: `POST /api/instruments/ltp`, `/ohlc`, `/quote` and `/prices` each take the whole basket at once and answer one entry per member. The live members report the basket as it stands now, such as its weights, its day move, its breadth and its biggest movers. The history members line up the members' candles and measure how they move together, such as the correlation matrix and each member's share of the risk.
#'
#' `prices()` gives candles for the basket as a whole, the sum over members of a fixed quantity times each member's candle, so the basket inherits every analysis class an instrument does, from moving averages to `sharpe_ratio()` and `run_backtest()`. A weighted basket turns its weights into quantities at the first candle of the range, starting from `base_value`, which is how a price index moves between rebalances. The open and close are exact. The high and low are the sums of the members' highs and lows, an approximation, because the members do not all reach their highs at the same moment. Volume and open interest have no meaning for a basket and are left empty.
#'
#' A weight vector, such as `weights`, is a named numeric vector whose names are the member labels. A table indexed by time, such as `member_closes()`, is a `data.frame` whose first column is `datetime` followed by one column per member label. A table indexed by member, such as `covariance_matrix()`, is a `data.frame` whose row names are the member labels.
#'
#' The generator carries `AssetBasket$KIND`, the kind stored with the basket, `"basket"`.
#'
#' @examples
#' \dontrun{
#' weights <- c(
#'   INFY = 0.5,
#'   TCS = 0.3,
#'   HCLTECH = 0.2
#' )
#' members <- list()
#' for (symbol in names(weights)) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   members[[length(members) + 1]] <- BasketMember$new(
#'     share,
#'     weight = weights[[symbol]]
#'   )
#' }
#' basket <- AssetBasket$new(name = "IT shares", members = members)
#'
#' bank_symbols <- c(
#'   "HDFCBANK",
#'   "ICICIBANK",
#'   "AXISBANK",
#'   "KOTAKBANK",
#'   "SBIN"
#' )
#' bank_members <- list()
#' for (symbol in bank_symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
#' }
#' banks <- AssetBasket$new(name = "banks", members = bank_members)
#'
#' for (instrument in basket$instruments) {
#'   cat(instrument$symbol, instrument$segment, "\n")
#' }
#' first_instrument <- basket$instruments[[1]]
#' cat(first_instrument$symbol, first_instrument$last_price, "\n")
#'
#' cat(sprintf("%s holds %d shares\n", banks$name, banks$size))
#' banks$add_member(
#'   BasketMember$new(Equity$new(exchange = "nse", symbol = "INDUSINDBK"))
#' )
#' print(banks$size)
#'
#' print(basket$labels)
#' for (label in basket$labels) {
#'   cat(sprintf("%s: %.0f%%\n", label, basket$weights[[label]] * 100))
#' }
#'
#' print(basket$weights)
#' print(banks$weights)
#' cat(sprintf("Total: %s\n", sum(banks$weights)))
#'
#' print(basket$last_prices[, c("label", "last_price")])
#' frame <- banks$last_prices
#' missing <- frame[!is.na(frame$error), ]
#' if (nrow(missing) == 0) {
#'   cat("Every member has a last price.\n")
#' } else {
#'   print(missing[, c("label", "error")])
#' }
#'
#' print(basket$ohlc[, c("label", "open", "high", "low", "last_price")])
#' frame <- banks$ohlc
#' frame$range_percent <- (frame$high - frame$low) / frame$previous_close * 100
#' print(round(frame$range_percent, 2))
#'
#' print(banks$quotes[, c("label", "last_price", "volume")])
#' print(basket$quotes[, c("label", "stale", "source")])
#'
#' change <- basket$day_change_percent
#' if (is.null(change)) {
#'   cat("A member has no quote.\n")
#' } else {
#'   cat(sprintf("%s: %+.2f%%\n", basket$name, change))
#' }
#' equal_members <- list()
#' for (member in basket$members) {
#'   equal_members[[length(equal_members) + 1]] <- BasketMember$new(
#'     member$instrument
#'   )
#' }
#' equal_basket <- AssetBasket$new(
#'   name = "IT shares, equal",
#'   members = equal_members
#' )
#' print(c(
#'   basket$day_change_percent,
#'   equal_basket$day_change_percent
#' ))
#'
#' cat(sprintf("%d of %d banks are up\n", banks$advancers, banks$size))
#' if (banks$advancers > banks$size / 2) {
#'   cat("Most banks are up.\n")
#' } else {
#'   cat("Most banks are not up.\n")
#' }
#' cat(sprintf("%d of %d banks are down\n", banks$decliners, banks$size))
#' cat(sprintf("up %d, down %d\n", basket$advancers, basket$decliners))
#'
#' str(banks$breadth)
#' ratio <- banks$breadth$advance_decline_ratio
#' if (is.null(ratio)) {
#'   cat("No member declined.\n")
#' } else {
#'   cat(sprintf("Advance-decline ratio: %.2f\n", ratio))
#' }
#'
#' mixed <- AssetBasket$new(
#'   name = "shares and gold",
#'   members = list(
#'     BasketMember$new(
#'       Equity$new(exchange = "nse", symbol = "INFY"),
#'       weight = 60
#'     ),
#'     BasketMember$new(
#'       ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES"),
#'       weight = 40
#'     )
#'   )
#' )
#' print(mixed$exposure_by_segment)
#' print(basket$exposure_by_segment)
#'
#' two_exchanges <- AssetBasket$new(
#'   name = "two exchanges",
#'   members = list(
#'     BasketMember$new(
#'       Equity$new(exchange = "nse", symbol = "INFY"),
#'       weight = 0.7
#'     ),
#'     BasketMember$new(
#'       Equity$new(exchange = "bse", symbol = "TCS"),
#'       weight = 0.3
#'     )
#'   )
#' )
#' print(two_exchanges$exposure_by_exchange)
#' exposure <- basket$exposure_by_exchange
#' cat(names(exposure)[[1]], exposure[[1]], "\n")
#'
#' cat(sprintf("Concentration: %.3f\n", basket$concentration))
#' print(c(
#'   banks$concentration,
#'   1 / banks$size
#' ))
#'
#' effective <- basket$effective_number_of_members
#' cat(sprintf("%d members act like %.1f equal ones\n", basket$size, effective))
#' if (basket$effective_number_of_members < basket$size * 0.9) {
#'   cat("The weights are lopsided.\n")
#' } else {
#'   cat("The weights are close to equal.\n")
#' }
#'
#' cat(sprintf("Largest weight: %.0f%%\n", basket$largest_weight * 100))
#' if (basket$largest_weight > 0.4) {
#'   cat("One member is above the 40% limit.\n")
#' } else {
#'   cat("Every member is within the limit.\n")
#' }
#'
#' basket$sharpe_ratio(risk_free_rate = 0.065, days = 365)
#' }
#' @export
AssetBasket <- R6::R6Class(
  "AssetBasket",
  inherit = PerformanceMeasures,
  public = list(
    #' @field KIND The character kind of basket a class is, such as `"index"`, stored with the basket so that it is rebuilt as the same class.
    KIND = "basket",
    #' @field name The character name of the basket, such as `"NIFTY"` or `"my long-term portfolio"`.
    name = NULL,
    #' @field members The list of `BasketMember` objects the basket holds, in order.
    members = NULL,
    #' @field linked_instrument The `Instrument` the basket describes the contents of, such as the NIFTY index or an exchange traded fund, or `NULL` when it describes no single instrument.
    linked_instrument = NULL,
    #' @field unmapped_weight The numeric share of the whole, between 0 and 1, held in things UBI cannot price, such as a fund's cash, which the members' weights leave out.
    unmapped_weight = NULL,
    #' @field base_value The numeric value the basket's candles start from at the first candle of a range when its members are weighted rather than counted.
    base_value = NULL,

    #' @description
    #' Initialises the basket and checks its members.
    #' @param name The character name of the basket.
    #' @param members A list of `BasketMember` objects with at least one member, each a different instrument, and either every member or no member given a weight.
    #' @param linked_instrument The `Instrument` whose contents the basket describes, or `NULL`.
    #' @param unmapped_weight The numeric share of the whole, between 0 and 1, held outside the members.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `AssetBasket` object.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or gives weights to only some members; and `ValueError` when `unmapped_weight` is not between 0 and 1.
    initialize = function(
      name,
      members,
      linked_instrument = NULL,
      unmapped_weight = 0,
      unified_broker_interface = NULL
    ) {
      if (!(unmapped_weight >= 0 && unmapped_weight < 1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "Not a share between 0 and 1: unmapped_weight=%s",
            private$python_number_text(unmapped_weight)
          )
        )
      }
      if (is.null(unified_broker_interface)) {
        unified_broker_interface <- Instrument$shared_unified_broker_interface()
      }
      private$unified_broker_interface <- unified_broker_interface
      self$name <- name
      self$members <- as.list(members)
      self$linked_instrument <- linked_instrument
      self$unmapped_weight <- unmapped_weight
      self$base_value <- ASSET_BASKETS_DEFAULT_BASE_VALUE
      private$check_members(self$members)
    },

    #' @description
    #' Describes the basket by its class, name and size.
    #' @param ... Ignored, accepted so that `format()` works.
    #' @return A character value such as `"Index(name='NIFTY', size=50)"`.
    format = function(...) {
      sprintf(
        "%s(name='%s', size=%d)",
        class(self)[[1]],
        self$name,
        self$size
      )
    },

    #' @description
    #' Prints the description `format()` gives.
    #' @param ... Ignored.
    #' @return The basket, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    },

    #' @description
    #' Fetches every member's candles for a range in one request.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with one row per member and candle, sorted by label and time, holding `label`, `instrument_id`, `exchange`, `segment`, `interval`, `datetime` in India time, `open`, `high`, `low`, `close`, `volume` and `oi`, plus any other column UBI sends such as `price_factor`, or `NULL` when no member has a candle in the range. A member with no candles has no rows.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members, all of which the message lists; `BadRequestError` when the range or interval is invalid; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' frame <- basket$member_prices(days = 10)
    #' print(tail(frame[, c("label", "datetime", "close")], 6))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' frame <- banks$member_prices(
    #'   interval = "day",
    #'   from_date = "2026-06-01",
    #'   to_date = "2026-09-25"
    #' )
    #' print(table(frame$label))
    #' }
    member_prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      shared_parameters <- list(
        interval = interval,
        adjusted = isTRUE(as.logical(adjusted))
      )
      if (!is.null(from_date)) {
        shared_parameters[["from"]] <- private$date_text(from_date)
      }
      if (!is.null(to_date)) {
        shared_parameters[["to"]] <- private$date_text(to_date)
      }
      if (!is.null(days)) {
        shared_parameters[["days"]] <- days
      }
      results <- private$post_for_every_member(
        ASSET_BASKETS_PRICES_PATH,
        shared_parameters
      )
      private$raise_for_failed_members(results)
      rows <- list()
      for (member_index in seq_along(self$members)) {
        member <- self$members[[member_index]]
        data <- results[[member_index]][["data"]]
        candles <- data[["candles"]]
        if (length(candles) == 0) {
          next
        }
        column_names <- unlist(data[["columns"]])
        column_names[column_names == "time"] <- "datetime"
        for (candle in candles) {
          row <- list(
            label = member$label,
            instrument_id = member$instrument$instrument_id,
            exchange = member$instrument$exchange,
            segment = member$instrument$segment,
            interval = interval
          )
          for (column_index in seq_along(column_names)) {
            value <- candle[[column_index]]
            if (is.null(value)) {
              row[column_names[[column_index]]] <- list(NULL)
            } else {
              row[[column_names[[column_index]]]] <- value
            }
          }
          rows[[length(rows) + 1]] <- row
        }
      }
      if (length(rows) == 0) {
        return(NULL)
      }
      frame <- FrameBuilder$new()$frame(rows)
      frame$datetime <- TimeConverter$new()$moments(frame$datetime)
      sorted_order <- order(
        frame$label,
        as.numeric(frame$datetime),
        method = "radix"
      )
      frame <- frame[sorted_order, , drop = FALSE]
      rownames(frame) <- NULL
      frame
    },

    #' @description
    #' Lines up every member's closing prices by time.
    #'
    #' Only the candles every member has are kept, so a member listed during the range shortens it.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with a `datetime` column followed by one numeric column of closes per member label, in member order, or `NULL` when any member has no candles in the range or no candle is shared by all.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' closes <- basket$member_closes(days = 30)
    #' print(tail(closes))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' closes <- banks$member_closes(days = 90)
    #' for (label in banks$labels) {
    #'   normalised <- closes[[label]] / closes[[label]][[1]] * 100
    #'   cat(label, round(normalised[[length(normalised)]], 1), "\n")
    #' }
    #' }
    member_closes = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      aligned <- private$aligned_candles(
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(aligned)) {
        return(NULL)
      }
      private$time_frame(aligned[["datetime"]], aligned[["close"]])
    },

    #' @description
    #' Calculates every member's return from each shared candle to the next.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` with a `datetime` column followed by one numeric column of fractional returns per member label, or `NULL` when there are fewer than two shared candles.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' returns <- basket$member_returns(days = 14)
    #' print(returns)
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' returns <- banks$member_returns(days = 365)
    #' volatilities <- c()
    #' for (label in banks$labels) {
    #'   volatilities[[label]] <- sd(returns[[label]])
    #' }
    #' print(sort(volatilities))
    #' }
    member_returns = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      closes <- self$member_closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes) || nrow(closes) < 2) {
        return(NULL)
      }
      count <- nrow(closes)
      returns <- data.frame(
        datetime = closes$datetime[2:count]
      )
      for (label in self$labels) {
        values <- closes[[label]]
        returns[[label]] <- values[2:count] / values[1:(count - 1)] - 1
      }
      returns
    },

    #' @description
    #' Calculates the covariance of every pair of members' returns over one candle.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A square `data.frame` whose row names and column names are the member labels, or `NULL` when there are fewer than three shared candles.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' print(basket$covariance_matrix(days = 180))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' covariance <- banks$covariance_matrix(days = 365)
    #' print(round(covariance * 252, 4))
    #' }
    covariance_matrix = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$member_returns(interval, from_date, to_date, days, adjusted)
      if (is.null(returns) || nrow(returns) < 2) {
        return(NULL)
      }
      private$label_frame(stats::cov(private$label_matrix(returns)))
    },

    #' @description
    #' Calculates the Pearson correlation of every pair of members' returns.
    #'
    #' A value near 1 means two members rise and fall together and add little diversification to each other.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A square `data.frame` of values between -1 and 1, whose row names and column names are the member labels, or `NULL` when there are fewer than three shared candles.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' print(round(basket$correlation_matrix(days = 365), 2))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' correlation <- banks$correlation_matrix(days = 365)
    #' lowest_pair <- NULL
    #' lowest_value <- 2
    #' for (first in names(correlation)) {
    #'   for (second in names(correlation)) {
    #'     value <- correlation[first, second]
    #'     if (first < second && value < lowest_value) {
    #'       lowest_value <- value
    #'       lowest_pair <- sprintf("%s and %s", first, second)
    #'     }
    #'   }
    #' }
    #' cat(lowest_pair, round(lowest_value, 2), "\n")
    #' }
    correlation_matrix = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      returns <- self$member_returns(interval, from_date, to_date, days, adjusted)
      if (is.null(returns) || nrow(returns) < 2) {
        return(NULL)
      }
      private$label_frame(stats::cor(private$label_matrix(returns)))
    },

    #' @description
    #' Splits the basket's volatility into each member's share of it, at today's weights.
    #'
    #' A member's share is its weight times its covariance with the whole basket, divided by the basket's variance, so the shares add up to 1. A member whose share is far above its weight is where the basket's risk really sits.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` whose row names are the member labels, with numeric `weight` and `risk_contribution` columns, largest contribution first, or `NULL` when there are fewer than three shared candles or the basket never moved.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' print(round(basket$risk_contributions(days = 180), 3))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' contributions <- banks$risk_contributions(days = 365)
    #' for (label in rownames(contributions)) {
    #'   row <- contributions[label, ]
    #'   if (row$risk_contribution > row$weight * 1.1) {
    #'     cat(sprintf("%s carries more risk than its weight\n", label))
    #'   }
    #' }
    #' print(round(contributions, 3))
    #' }
    risk_contributions = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      covariance <- self$covariance_matrix(
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(covariance)) {
        return(NULL)
      }
      labels <- names(covariance)
      weights <- self$weights[labels]
      covariance_values <- as.matrix(covariance)
      covariance_with_basket <- as.vector(covariance_values %*% weights)
      basket_variance <- sum(weights * covariance_with_basket)
      if (basket_variance == 0) {
        return(NULL)
      }
      frame <- data.frame(
        weight = unname(weights),
        risk_contribution = unname(
          weights * covariance_with_basket / basket_variance
        ),
        row.names = labels
      )
      frame[order(frame$risk_contribution, decreasing = TRUE,
                  method = "radix"), , drop = FALSE]
    },

    #' @description
    #' Divides the weighted average of the members' volatilities by the basket's own volatility, at today's weights.
    #'
    #' It is 1 when every member moves in lockstep, and the further above 1 it is, the more the members' moves cancel out.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return The numeric diversification ratio, or `NULL` when there are fewer than three shared candles or the basket never moved.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' ratio <- banks$diversification_ratio(days = 365)
    #' cat(sprintf("Diversification ratio: %.2f\n", ratio))
    #'
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' short_ratio <- basket$diversification_ratio(days = 90)
    #' long_ratio <- basket$diversification_ratio(days = 730)
    #' cat(sprintf("90 days: %.2f, 730 days: %.2f\n", short_ratio, long_ratio))
    #' }
    diversification_ratio = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      covariance <- self$covariance_matrix(
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(covariance)) {
        return(NULL)
      }
      labels <- names(covariance)
      weights <- self$weights[labels]
      covariance_values <- as.matrix(covariance)
      member_volatilities <- sqrt(diag(covariance_values))
      basket_variance <- sum(
        weights * as.vector(covariance_values %*% weights)
      )
      if (basket_variance <= 0) {
        return(NULL)
      }
      sum(weights * member_volatilities) / sqrt(basket_variance)
    },

    #' @description
    #' Splits the basket's return over the range into what each member added.
    #'
    #' Each member's contribution is its share of the basket's value at the first candle times its own return, so the contributions add up to the basket's `cumulative_return()` over the same range.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` whose row names are the member labels, with numeric `starting_weight`, `member_return` and `contribution` columns, largest contribution first, or `NULL` when there are fewer than two shared candles.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' print(round(basket$return_contributions(days = 90), 4))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' contributions <- banks$return_contributions(days = 180)
    #' print(round(sum(contributions$contribution), 6))
    #' print(round(banks$cumulative_return(days = 180), 6))
    #' }
    return_contributions = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      closes <- self$member_closes(interval, from_date, to_date, days, adjusted)
      if (is.null(closes) || nrow(closes) < 2) {
        return(NULL)
      }
      labels <- self$labels
      first_closes <- private$row_values(closes, 1)
      last_closes <- private$row_values(closes, nrow(closes))
      quantities <- private$candle_quantities(first_closes)
      starting_values <- quantities * first_closes
      starting_weights <- starting_values / sum(starting_values)
      member_return <- last_closes / first_closes - 1
      frame <- data.frame(
        starting_weight = unname(starting_weights),
        member_return = unname(member_return),
        contribution = unname(starting_weights * member_return),
        row.names = labels
      )
      frame[order(frame$contribution, decreasing = TRUE,
                  method = "radix"), , drop = FALSE]
    },

    #' @description
    #' Finds the members that have risen most since the previous close.
    #' @param count The integer most members to return.
    #' @return A `data.frame` of `ohlc` rows, biggest rise first, leaving out members with no quote.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' print(banks$top_gainers(count = 2)[, c("label", "change_percent")])
    #'
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' best <- basket$top_gainers(count = 1)
    #' if (nrow(best) == 0) {
    #'   cat("No member has a quote.\n")
    #' } else {
    #'   cat(best$label[[1]], best$change_percent[[1]], "\n")
    #' }
    #' }
    top_gainers = function(count = 5) {
      private$top_movers(count, decreasing = TRUE)
    },

    #' @description
    #' Finds the members that have fallen most since the previous close.
    #' @param count The integer most members to return.
    #' @return A `data.frame` of `ohlc` rows, biggest fall first, leaving out members with no quote.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' print(banks$top_losers(count = 2)[, c("label", "change_percent")])
    #'
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' losers <- basket$top_losers(count = basket$size)
    #' print(losers[losers$change_percent < -0.5, c("label", "change_percent")])
    #' }
    top_losers = function(count = 5) {
      private$top_movers(count, decreasing = FALSE)
    },

    #' @description
    #' Measures how much of this basket's weight another basket also holds.
    #'
    #' The overlap is the sum, over the instruments both hold, of the smaller of the two weights. It is 1 for two identical baskets and 0 for two with nothing in common, and it is the usual way to tell whether two funds are really different.
    #' @param other The `AssetBasket` to compare with.
    #' @return The numeric overlap between 0 and 1.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when a basket whose weights come from live prices, such as a `Portfolio`, could not read them.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' broad_weights <- c(
    #'   INFY = 0.3,
    #'   RELIANCE = 0.4,
    #'   HDFCBANK = 0.3
    #' )
    #' broad_members <- list()
    #' for (symbol in names(broad_weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   broad_members[[length(broad_members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = broad_weights[[symbol]]
    #'   )
    #' }
    #' broad <- AssetBasket$new(name = "broad", members = broad_members)
    #' cat(sprintf("Overlap: %.0f%%\n", basket$overlap_with(broad) * 100))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' print(banks$overlap_with(banks))
    #' }
    overlap_with = function(other) {
      own_weights <- private$weights_by_instrument_id_of(self)
      other_weights <- private$weights_by_instrument_id_of(other)
      overlap <- 0
      for (instrument_id in names(own_weights)) {
        if (instrument_id %in% names(other_weights)) {
          overlap <- overlap + min(
            own_weights[[instrument_id]],
            other_weights[[instrument_id]]
          )
        }
      }
      overlap
    },

    #' @description
    #' Adds a member to the basket in memory, which `BasketStore$save()` then stores.
    #' @param member The `BasketMember` to add, weighted if and only if the other members are.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when the instrument is already in the basket, or the member's weight does not match the others'.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' wipro <- Equity$new(exchange = "nse", symbol = "WIPRO")
    #' basket$add_member(BasketMember$new(wipro, weight = 0.1))
    #' print(round(basket$weights, 3))
    #'
    #' tryCatch(
    #'   basket$add_member(BasketMember$new(wipro)),
    #'   BasketMemberError = function(error) print(conditionMessage(error))
    #' )
    #' }
    add_member = function(member) {
      candidate_members <- c(
        self$members,
        list(member)
      )
      private$check_members(candidate_members)
      self$members <- candidate_members
      invisible(NULL)
    },

    #' @description
    #' Removes an instrument from the basket in memory, which `BasketStore$save()` then stores.
    #' @param instrument The `Instrument` to remove.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when the instrument is not in the basket, or it is the only member.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' basket$remove_member(basket$instruments[[1]])
    #' print(basket$weights)
    #'
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' tryCatch(
    #'   basket$remove_member(infosys),
    #'   BasketMemberError = function(error) print(conditionMessage(error))
    #' )
    #' }
    remove_member = function(instrument) {
      remaining <- list()
      for (member in self$members) {
        if (!identical(member$instrument$instrument_id, instrument$instrument_id)) {
          remaining[[length(remaining) + 1]] <- member
        }
      }
      if (length(remaining) == length(self$members)) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf("The instrument is not in the basket: %s", instrument$format())
        )
      }
      private$check_members(remaining)
      self$members <- remaining
      invisible(NULL)
    },

    #' @description
    #' Describes the basket as a named list for storing in MongoDB.
    #'
    #' Subclasses add their own settings to the named list.
    #' @param effective_date The first day the basket is in effect as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @return A named list with `name`, `kind`, `effective_date` as `"YYYY-MM-DD"` text, `linked_instrument_id`, `unmapped_weight`, `base_value` and a `members` list of named lists.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' document <- basket$document(effective_date = "2026-10-01")
    #' cat(document$name, document$kind, document$effective_date, "\n")
    #' print(length(document$members))
    #'
    #' for (member_document in basket$document()$members) {
    #'   cat(member_document$symbol, member_document$instrument_id, "\n")
    #' }
    #' }
    document = function(effective_date = NULL) {
      if (is.null(effective_date)) {
        effective_date <- Sys.Date()
      }
      linked_instrument_id <- NULL
      if (!is.null(self$linked_instrument)) {
        linked_instrument_id <- self$linked_instrument$instrument_id
      }
      member_documents <- list()
      for (member in self$members) {
        member_documents[[length(member_documents) + 1]] <- member$document()
      }
      list(
        name = self$name,
        kind = self$KIND,
        effective_date = private$date_text(effective_date),
        linked_instrument_id = linked_instrument_id,
        unmapped_weight = self$unmapped_weight,
        base_value = self$base_value,
        members = member_documents
      )
    },

    #' @description
    #' Builds candles for the basket as a whole from its members' candles.
    #'
    #' Each candle is the sum over members of a fixed quantity times the member's candle. A weighted basket takes its quantities from its weights at the first candle of the range, so the first close equals `base_value`; a `Portfolio` uses the quantities it holds. The open and close are exact; the high and low are an approximation, because the members do not all reach their highs and lows at the same moment. `volume` and `oi` are empty.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` sorted by time with `exchange` set to `NA`, `segment` set to the basket's `KIND`, `interval`, `datetime`, `open`, `high`, `low`, `close`, `volume` and `oi` columns, the last two all `NA`, or `NULL` when any member has no candles in the range or no candle is shared by all.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' weights <- c(
    #'   INFY = 0.5,
    #'   TCS = 0.3,
    #'   HCLTECH = 0.2
    #' )
    #' members <- list()
    #' for (symbol in names(weights)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     weight = weights[[symbol]]
    #'   )
    #' }
    #' basket <- AssetBasket$new(name = "IT shares", members = members)
    #' frame <- basket$prices(days = 30)
    #' print(tail(frame[, c("datetime", "open", "high", "low", "close")]))
    #'
    #' bank_symbols <- c(
    #'   "HDFCBANK",
    #'   "ICICIBANK",
    #'   "AXISBANK",
    #'   "KOTAKBANK",
    #'   "SBIN"
    #' )
    #' bank_members <- list()
    #' for (symbol in bank_symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   bank_members[[length(bank_members) + 1]] <- BasketMember$new(share)
    #' }
    #' banks <- AssetBasket$new(name = "banks", members = bank_members)
    #' frame <- banks$prices(from_date = "2026-06-01", to_date = "2026-09-25")
    #' first_close <- frame$close[[1]]
    #' last_close <- frame$close[[nrow(frame)]]
    #' cat(sprintf("Return: %.2f%%\n", (last_close / first_close - 1) * 100))
    #'
    #' print(basket$sharpe_ratio(risk_free_rate = 0.065, days = 365))
    #' }
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      aligned <- private$aligned_candles(
        interval,
        from_date,
        to_date,
        days,
        adjusted
      )
      if (is.null(aligned)) {
        return(NULL)
      }
      first_closes <- aligned[["close"]][1, ]
      quantities <- private$candle_quantities(first_closes)
      candle_count <- length(aligned[["datetime"]])
      frame <- data.frame(
        exchange = rep(NA_character_, candle_count),
        segment = rep(self$KIND, candle_count),
        interval = rep(interval, candle_count)
      )
      frame$datetime <- aligned[["datetime"]]
      for (column in ASSET_BASKETS_CANDLE_COLUMNS) {
        values <- aligned[[column]]
        total <- rep(0, candle_count)
        for (label in colnames(values)) {
          contribution <- values[, label] * quantities[[label]]
          contribution[is.na(contribution)] <- 0
          total <- total + contribution
        }
        frame[[column]] <- total
      }
      frame$volume <- rep(NA_real_, candle_count)
      frame$oi <- rep(NA_real_, candle_count)
      frame
    }
  ),
  active = list(
    #' @field instruments The list of `Instrument` objects the basket holds, in member order.
    instruments = function(value) {
      if (!missing(value)) {
        stop("instruments is read-only", call. = FALSE)
      }
      held <- list()
      for (member in self$members) {
        held[[length(held) + 1]] <- member$instrument
      }
      held
    },

    #' @field size The integer number of members in the basket.
    size = function(value) {
      if (!missing(value)) {
        stop("size is read-only", call. = FALSE)
      }
      length(self$members)
    },

    #' @field labels A character vector of member labels, such as `"nse:INFY"`, in member order.
    labels = function(value) {
      if (!missing(value)) {
        stop("labels is read-only", call. = FALSE)
      }
      member_labels <- character(0)
      for (member in self$members) {
        member_labels <- c(
          member_labels,
          member$label
        )
      }
      member_labels
    },

    #' @field weights A named numeric vector of weights whose names are the member labels, normalised to sum to 1, or equal weights when no member has a weight.
    weights = function(value) {
      if (!missing(value)) {
        stop("weights is read-only", call. = FALSE)
      }
      if (is.null(self$members[[1]]$weight)) {
        equal_weights <- rep(1 / self$size, self$size)
        names(equal_weights) <- self$labels
        return(equal_weights)
      }
      stated <- numeric(0)
      for (member in self$members) {
        stated <- c(
          stated,
          as.numeric(member$weight)
        )
      }
      names(stated) <- self$labels
      stated / sum(stated)
    },

    #' @field last_prices A `data.frame` with one row per member, holding `label`, `instrument_id`, `last_price`, `last_trade_time` and an `error` that is `NA` unless UBI had no price for the member, read from UBI in one request on every access.
    last_prices = function(value) {
      if (!missing(value)) {
        stop("last_prices is read-only", call. = FALSE)
      }
      results <- private$post_for_every_member(ASSET_BASKETS_LAST_PRICE_PATH)
      rows <- list()
      for (member_index in seq_along(self$members)) {
        member <- self$members[[member_index]]
        result <- results[[member_index]]
        data <- result[["data"]]
        if (is.null(data)) {
          data <- list()
        }
        rows[[member_index]] <- list(
          label = member$label,
          instrument_id = member$instrument$instrument_id,
          last_price = data[["last_price"]],
          last_trade_time = data[["last_trade_time"]],
          error = private$error_of(result)
        )
      }
      FrameBuilder$new()$frame(rows)
    },

    #' @field ohlc A `data.frame` with one row per member, holding `label`, `instrument_id`, `open`, `high`, `low`, `last_price`, `previous_close`, `change_percent` and an `error` that is `NA` unless UBI had no quote for the member, read from UBI in one request on every access.
    ohlc = function(value) {
      if (!missing(value)) {
        stop("ohlc is read-only", call. = FALSE)
      }
      results <- private$post_for_every_member(ASSET_BASKETS_OHLC_PATH)
      rows <- list()
      for (member_index in seq_along(self$members)) {
        member <- self$members[[member_index]]
        result <- results[[member_index]]
        data <- result[["data"]]
        if (is.null(data)) {
          data <- list()
        }
        day <- data[["ohlc"]]
        if (is.null(day)) {
          day <- list()
        }
        rows[[member_index]] <- list(
          label = member$label,
          instrument_id = member$instrument$instrument_id,
          open = day[["open"]],
          high = day[["high"]],
          low = day[["low"]],
          last_price = data[["last_price"]],
          previous_close = data[["previous_close"]],
          change_percent = data[["change_percent"]],
          error = private$error_of(result)
        )
      }
      frame <- FrameBuilder$new()$frame(rows)
      numeric_columns <- c(
        "open",
        "high",
        "low",
        "last_price",
        "previous_close",
        "change_percent"
      )
      for (column in numeric_columns) {
        if (is.logical(frame[[column]])) {
          frame[[column]] <- as.numeric(frame[[column]])
        }
      }
      frame
    },

    #' @field quotes A `data.frame` with one row per member, holding `label`, `instrument_id`, every field of UBI's unified quote such as `last_price`, `volume`, `oi` and `depth`, and an `error` that is `NA` unless UBI had no quote for the member, read from UBI in one request on every access. A field whose values are not single values, such as `depth`, is a list column.
    quotes = function(value) {
      if (!missing(value)) {
        stop("quotes is read-only", call. = FALSE)
      }
      results <- private$post_for_every_member(ASSET_BASKETS_QUOTE_PATH)
      rows <- list()
      for (member_index in seq_along(self$members)) {
        member <- self$members[[member_index]]
        result <- results[[member_index]]
        row <- list(
          label = member$label,
          instrument_id = member$instrument$instrument_id
        )
        data <- result[["data"]]
        if (is.null(data)) {
          data <- list()
        }
        for (field in names(data)) {
          if (field %in% names(row)) {
            next
          }
          field_value <- data[[field]]
          if (is.null(field_value)) {
            row[field] <- list(NULL)
          } else {
            row[[field]] <- field_value
          }
        }
        row["error"] <- list(private$error_of(result))
        rows[[member_index]] <- row
      }
      FrameBuilder$new()$frame(rows)
    },

    #' @field day_change_percent The numeric weighted move of the basket since the previous close, in percent, such as 0.8, or `NULL` when any member has no quote, read from UBI on every access.
    day_change_percent = function(value) {
      if (!missing(value)) {
        stop("day_change_percent is read-only", call. = FALSE)
      }
      frame <- self$ohlc
      changes <- as.numeric(frame$change_percent)
      if (any(is.na(changes))) {
        return(NULL)
      }
      sum(changes * unname(self$weights))
    },

    #' @field advancers The integer number of members trading above their previous close, read from UBI on every access.
    advancers = function(value) {
      if (!missing(value)) {
        stop("advancers is read-only", call. = FALSE)
      }
      self$breadth[["advancers"]]
    },

    #' @field decliners The integer number of members trading below their previous close, read from UBI on every access.
    decliners = function(value) {
      if (!missing(value)) {
        stop("decliners is read-only", call. = FALSE)
      }
      self$breadth[["decliners"]]
    },

    #' @field breadth A named list counting the members that are `advancers`, `decliners`, `unchanged` and `unavailable` since the previous close, each an integer, with the numeric `advance_decline_ratio` of advancers to decliners or `NULL` when nothing declined, read from UBI on every access.
    breadth = function(value) {
      if (!missing(value)) {
        stop("breadth is read-only", call. = FALSE)
      }
      changes <- as.numeric(self$ohlc$change_percent)
      advancers <- sum(changes > 0, na.rm = TRUE)
      decliners <- sum(changes < 0, na.rm = TRUE)
      unchanged <- sum(changes == 0, na.rm = TRUE)
      unavailable <- sum(is.na(changes))
      ratio <- NULL
      if (decliners > 0) {
        ratio <- advancers / decliners
      }
      list(
        advancers = advancers,
        decliners = decliners,
        unchanged = unchanged,
        unavailable = unavailable,
        advance_decline_ratio = ratio
      )
    },

    #' @field exposure_by_segment A named numeric vector of the total weight in each segment, named by segment such as `"nse_equities"`, largest first.
    exposure_by_segment = function(value) {
      if (!missing(value)) {
        stop("exposure_by_segment is read-only", call. = FALSE)
      }
      private$weights_grouped_by("segment")
    },

    #' @field exposure_by_exchange A named numeric vector of the total weight on each exchange, named by exchange such as `"nse"`, largest first.
    exposure_by_exchange = function(value) {
      if (!missing(value)) {
        stop("exposure_by_exchange is read-only", call. = FALSE)
      }
      private$weights_grouped_by("exchange")
    },

    #' @field concentration The numeric Herfindahl index of the weights, the sum of their squares, which is 1 for a single holding and 1 divided by the size for equal weights.
    concentration = function(value) {
      if (!missing(value)) {
        stop("concentration is read-only", call. = FALSE)
      }
      sum(unname(self$weights)^2)
    },

    #' @field effective_number_of_members The numeric number of equal-weighted members that would be as concentrated as this basket, which is 1 divided by the Herfindahl index.
    effective_number_of_members = function(value) {
      if (!missing(value)) {
        stop("effective_number_of_members is read-only", call. = FALSE)
      }
      1 / self$concentration
    },

    #' @field largest_weight The numeric weight of the basket's biggest member.
    largest_weight = function(value) {
      if (!missing(value)) {
        stop("largest_weight is read-only", call. = FALSE)
      }
      max(unname(self$weights))
    }
  ),
  private = list(
    unified_broker_interface = NULL,

    #' Checks that members can form a basket.
    #' @param members The list of `BasketMember` objects to check.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or gives weights to only some members.
    check_members = function(members) {
      if (length(members) == 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          "A basket needs at least one member"
        )
      }
      seen_instrument_ids <- character(0)
      weighted_count <- 0
      for (member in members) {
        instrument_id <- member$instrument$instrument_id
        if (instrument_id %in% seen_instrument_ids) {
          ErrorCatalogue$raise(
            "BasketMemberError",
            sprintf(
              "An instrument is named twice in the basket: %s",
              member$label
            )
          )
        }
        seen_instrument_ids <- c(
          seen_instrument_ids,
          instrument_id
        )
        if (!is.null(member$weight)) {
          weighted_count <- weighted_count + 1
        }
      }
      if (weighted_count > 0 && weighted_count < length(members)) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "Only %d of %d members have a weight; give every member a weight or none",
            weighted_count,
            length(members)
          )
        )
      }
      invisible(NULL)
    },

    #' Works out the fixed quantity of each member that the basket's candles are built from.
    #'
    #' This base version spreads `base_value` across the members by weight at the first candle's closes. A `Portfolio` replaces it with the quantities it holds.
    #' @param first_closes A named numeric vector of each member's close at the first shared candle, named by member label.
    #' @return A named numeric vector of quantities, named by member label.
    candle_quantities = function(first_closes) {
      weights <- self$weights[names(first_closes)]
      self$base_value * weights / first_closes
    },

    #' Lines up the members' open, high, low and close by time, keeping only candles every member has.
    #' @param interval The character candle interval.
    #' @param from_date The first day of the range as a `Date` or character value, or `NULL`.
    #' @param to_date The last day of the range as a `Date` or character value, or `NULL`.
    #' @param days The integer number of days to count back from today, or `NULL`.
    #' @param adjusted A logical that is `TRUE` for adjusted prices.
    #' @return A named list with `datetime`, a `POSIXct` vector of the shared candle times in order, and `open`, `high`, `low` and `close`, each a numeric matrix with one row per shared time and one column per member label in member order, or `NULL` when any member has no candles or no candle is shared by all.
    #' @details Errors: signals `BasketMemberError` when UBI answered an error for one or more members, and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    aligned_candles = function(interval, from_date, to_date, days, adjusted) {
      frame <- self$member_prices(interval, from_date, to_date, days, adjusted)
      if (is.null(frame)) {
        return(NULL)
      }
      if (length(unique(frame$label)) < self$size) {
        return(NULL)
      }
      labels <- self$labels
      frame_seconds <- as.numeric(frame$datetime)
      times <- sort(unique(frame_seconds))
      aligned <- list()
      for (column in ASSET_BASKETS_CANDLE_COLUMNS) {
        wide <- matrix(
          NA_real_,
          nrow = length(times),
          ncol = length(labels),
          dimnames = list(
            NULL,
            labels
          )
        )
        for (label in labels) {
          is_member_row <- frame$label == label
          positions <- match(frame_seconds[is_member_row], times)
          wide[positions, label] <- as.numeric(frame[[column]][is_member_row])
        }
        aligned[[column]] <- wide
      }
      shared <- stats::complete.cases(aligned[["close"]])
      if (!any(shared)) {
        return(NULL)
      }
      for (column in ASSET_BASKETS_CANDLE_COLUMNS) {
        aligned[[column]] <- aligned[[column]][shared, , drop = FALSE]
      }
      aligned[["datetime"]] <- TimeConverter$new()$from_epoch(times[shared])
      aligned
    },

    #' Builds a table indexed by time from a matrix with one column per member label.
    #' @param datetime A `POSIXct` vector, one value per row of `values`.
    #' @param values A numeric matrix whose column names are member labels.
    #' @return A `data.frame` with a `datetime` column followed by one column per member label.
    time_frame = function(datetime, values) {
      frame <- data.frame(
        datetime = datetime
      )
      for (label in colnames(values)) {
        frame[[label]] <- unname(values[, label])
      }
      frame
    },

    #' Takes the member columns of a table indexed by time as a matrix.
    #' @param frame A `data.frame` with a `datetime` column followed by one column per member label.
    #' @return A numeric matrix with one column per member label.
    label_matrix = function(frame) {
      values <- as.matrix(frame[, self$labels, drop = FALSE])
      colnames(values) <- self$labels
      values
    },

    #' Turns a square matrix whose row and column names are member labels into a `data.frame`.
    #' @param values A numeric matrix with member labels as row and column names.
    #' @return A `data.frame` whose row names and column names are the member labels.
    label_frame = function(values) {
      as.data.frame(values, optional = TRUE)
    },

    #' Reads one row of a table indexed by time as a named vector.
    #' @param frame A `data.frame` with a `datetime` column followed by one column per member label.
    #' @param row_index The integer row number.
    #' @return A named numeric vector, named by member label.
    row_values = function(frame, row_index) {
      values <- numeric(0)
      for (label in self$labels) {
        values[[label]] <- frame[[label]][[row_index]]
      }
      values
    },

    #' Picks the members that moved most since the previous close.
    #' @param count The integer most members to return.
    #' @param decreasing A logical that is `TRUE` for the biggest rises first and `FALSE` for the biggest falls first.
    #' @return A `data.frame` of `ohlc` rows without the members that have no quote.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    top_movers = function(count, decreasing) {
      frame <- self$ohlc
      frame <- frame[!is.na(frame$change_percent), , drop = FALSE]
      frame <- frame[order(frame$change_percent, decreasing = decreasing,
                           method = "radix"), , drop = FALSE]
      frame <- utils::head(frame, count)
      rownames(frame) <- NULL
      frame
    },

    #' Sends one list request naming every member and returns its entries in member order.
    #' @param path The character path of a UBI route that takes a list of instruments, such as `"/api/instruments/ltp"`.
    #' @param shared_parameters A named list of parameters that apply to every member, such as the interval and range for `/api/instruments/prices`, or `NULL`.
    #' @return A list of named lists, one per member, each with `request_index`, `status` and either `data` or `error`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when the whole request was refused by, or failed on the way to, UBI.
    post_for_every_member = function(path, shared_parameters = NULL) {
      private$post_for_instruments(path, self$instruments, shared_parameters)
    },

    #' Sends one list request naming the given instruments and returns its entries in the same order.
    #' @param path The character path of a UBI route that takes a list of instruments.
    #' @param listed_instruments The list of `Instrument` objects to name, in order.
    #' @param shared_parameters A named list of parameters that apply to every instrument, or `NULL`.
    #' @return A list of named lists, one per instrument, each with `request_index`, `status` and either `data` or `error`.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when the whole request was refused by, or failed on the way to, UBI.
    post_for_instruments = function(
      path,
      listed_instruments,
      shared_parameters = NULL
    ) {
      named_instruments <- list()
      for (instrument in listed_instruments) {
        named_instruments[[length(named_instruments) + 1]] <- list(
          instrument_id = instrument$instrument_id
        )
      }
      body <- list(
        instruments = named_instruments
      )
      for (parameter_name in names(shared_parameters)) {
        body[[parameter_name]] <- shared_parameters[[parameter_name]]
      }
      response <- private$unified_broker_interface$post(path, body = body)
      results <- response[["results"]]
      request_indexes <- numeric(0)
      for (result in results) {
        request_indexes <- c(
          request_indexes,
          as.numeric(result[["request_index"]])
        )
      }
      results[order(request_indexes, method = "radix")]
    },

    #' Reads the last price of each of the given instruments in one request.
    #' @param listed_instruments The list of `Instrument` objects to price.
    #' @return A named list mapping each character `instrument_id` to its numeric last price.
    #' @details Errors: signals `BasketMemberError` when UBI had no price for one or more of the instruments, all of which the message lists; and a `UnifiedBrokerInterfaceError` subclass when the whole request was refused by, or failed on the way to, UBI.
    last_prices_by_instrument_id = function(listed_instruments) {
      results <- private$post_for_instruments(
        ASSET_BASKETS_LAST_PRICE_PATH,
        listed_instruments
      )
      failures <- character(0)
      prices <- list()
      for (instrument_index in seq_along(listed_instruments)) {
        instrument <- listed_instruments[[instrument_index]]
        result <- results[[instrument_index]]
        data <- result[["data"]]
        if (is.null(data)) {
          data <- list()
        }
        last_price <- data[["last_price"]]
        if (result[["status"]] != ASSET_BASKETS_SUCCESS_STATUS ||
              is.null(last_price)) {
          failures <- c(
            failures,
            sprintf(
              "%s: %s",
              instrument$format(),
              private$python_text(private$error_of(result))
            )
          )
          next
        }
        prices[[instrument$instrument_id]] <- as.numeric(last_price)
      }
      if (length(failures) > 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "UBI has no last price for %d instruments: %s",
            length(failures),
            paste(failures, collapse = "; ")
          )
        )
      }
      prices
    },

    #' Signals an error when any entry of a list answer is an error.
    #' @param results The list of entry named lists from a list answer, in member order.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals `BasketMemberError` when one or more entries are errors, all of which the message lists.
    raise_for_failed_members = function(results) {
      failures <- character(0)
      for (member_index in seq_along(self$members)) {
        result <- results[[member_index]]
        if (result[["status"]] != ASSET_BASKETS_SUCCESS_STATUS) {
          failures <- c(
            failures,
            sprintf(
              "%s: %s",
              self$members[[member_index]]$label,
              private$python_text(result[["error"]])
            )
          )
        }
      }
      if (length(failures) > 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "UBI answered an error for %d of %d members: %s",
            length(failures),
            self$size,
            paste(failures, collapse = "; ")
          )
        )
      }
      invisible(NULL)
    },

    #' Adds up the weights of the members sharing each value of an instrument attribute.
    #' @param attribute The character name of the instrument attribute to group by, `"segment"` or `"exchange"`.
    #' @return A named numeric vector of total weights, named by attribute value, largest first.
    weights_grouped_by = function(attribute) {
      weights <- self$weights
      totals <- numeric(0)
      for (member in self$members) {
        if (attribute == "segment") {
          key <- member$instrument$segment
        } else {
          key <- member$instrument$exchange
        }
        if (key %in% names(totals)) {
          totals[[key]] <- totals[[key]] + weights[[member$label]]
        } else {
          totals[[key]] <- weights[[member$label]]
        }
      }
      totals[order(totals, decreasing = TRUE, method = "radix")]
    },

    #' Maps each member of a basket to its weight by instrument id.
    #'
    #' Python's `_weights_by_instrument_id` is called on another basket by `overlap_with` and `Portfolio.rebalance_trades`; an R6 object cannot call another object's private method, so this reads the other basket's public `weights` and `members`, which is all the Python method reads.
    #' @param basket The `AssetBasket` whose weights to map, which may be this basket.
    #' @return A named list mapping each character `instrument_id` to its numeric weight.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when a basket whose weights come from live prices could not read them.
    weights_by_instrument_id_of = function(basket) {
      weights <- basket$weights
      by_instrument_id <- list()
      for (member in basket$members) {
        by_instrument_id[[member$instrument$instrument_id]] <- as.numeric(
          weights[[member$label]]
        )
      }
      by_instrument_id
    },

    #' Reads the error message of one entry of a list answer.
    #' @param result One entry named list of a list answer.
    #' @return The character error message, or `NULL` when the entry succeeded.
    error_of = function(result) {
      if (result[["status"]] == ASSET_BASKETS_SUCCESS_STATUS) {
        return(NULL)
      }
      message <- result[["error"]]
      if (is.null(message) || identical(message, "")) {
        message <- sprintf("HTTP %s", result[["status"]])
      }
      message
    },

    #' Turns a date or a date string into the `YYYY-MM-DD` form UBI and MongoDB use.
    #' @param value A `Date` or a `"YYYY-MM-DD"` character value.
    #' @return The character date in `YYYY-MM-DD` form, or `value` unchanged when it is not a `Date`.
    date_text = function(value) {
      if (inherits(value, "Date")) {
        return(format(value, "%Y-%m-%d"))
      }
      value
    },

    #' Writes a value the way a Python f-string would, with `NULL` as `None`.
    #' @param value A scalar or `NULL`.
    #' @return A character value.
    python_text = function(value) {
      if (is.null(value)) {
        return("None")
      }
      as.character(value)
    },

    #' Writes a number the way Python's `repr` writes it, so a whole double reads `1.0` and an integer reads `1`.
    #' @param value A numeric or integer scalar.
    #' @return A character value.
    python_number_text = function(value) {
      if (is.integer(value)) {
        return(as.character(value))
      }
      if (is.numeric(value) && is.finite(value) && value == round(value) &&
            abs(value) < 1e16) {
        return(sprintf("%.1f", value))
      }
      format(value, digits = 15)
    }
  )
)

AssetBasket$KIND <- "basket"
