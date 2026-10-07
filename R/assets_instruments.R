INSTRUMENTS_INDEX_SEGMENT_SUFFIX <- "_indices"
INSTRUMENTS_INDEX_FUTURES_SEGMENT_SUFFIX <- "_index_futures"
INSTRUMENTS_INDEX_OPTIONS_SEGMENT_SUFFIX <- "_index_options"
INSTRUMENTS_FUTURE_SHAPE <- "future"
INSTRUMENTS_FUTURES_SEGMENT_SUFFIX <- "_futures"
INSTRUMENTS_OPTION_SHAPE <- "option"
INSTRUMENTS_DERIVATIVE_SHAPES <- c(
  "future",
  "option"
)
INSTRUMENTS_CALL_OPTION_TYPE <- "CE"
INSTRUMENTS_PUT_OPTION_TYPE <- "PE"
INSTRUMENTS_WEEKLY_EXPIRY_KIND <- "weekly"
INSTRUMENTS_MONTHLY_EXPIRY_KIND <- "monthly"
INSTRUMENTS_EXPIRY_TIME <- "15:30"
INSTRUMENTS_DAYS_PER_YEAR <- 365
INSTRUMENTS_SECONDS_PER_YEAR <- 365 * 24 * 60 * 60
INSTRUMENTS_PERCENT <- 100
INSTRUMENTS_BLACK_76_MODEL <- "black_76"
INSTRUMENTS_BLACK_SCHOLES_MODEL <- "black_scholes"
INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT <- list(
  equity_futures = "equities",
  equity_options = "equities",
  equity_index_futures = "equity_indices",
  equity_index_options = "equity_indices",
  fixed_income_futures = NULL,
  fixed_income_options = "fixed_income_futures",
  fixed_income_index_futures = NULL,
  fixed_income_index_options = "fixed_income_index_futures",
  commodity_futures = NULL,
  commodity_options = "commodity_futures",
  commodity_index_futures = NULL,
  commodity_index_options = "commodity_index_futures",
  currency_futures = NULL,
  currency_options = "currency_futures",
  currency_index_futures = NULL,
  currency_index_options = "currency_index_futures"
)
INSTRUMENTS_DETAILS_PATH <- "/api/instruments/details"
INSTRUMENTS_PRICES_PATH <- "/api/instruments/prices"
INSTRUMENTS_TICKS_PATH <- "/api/instruments/ticks"
INSTRUMENTS_QUOTE_PATH <- "/api/instruments/quote"
INSTRUMENTS_OHLC_PATH <- "/api/instruments/ohlc"
INSTRUMENTS_SEARCH_PATH <- "/api/instruments/search"
INSTRUMENTS_LAST_PRICE_PATH <- "/api/instruments/ltp"
INSTRUMENTS_MASTER_PATH <- "/api/instruments/master"
INSTRUMENTS_ORDER_DETAILS_PATH <- "/api/orders/details"
INSTRUMENTS_ORDER_TRADES_PATH <- "/api/orders/trades"
INSTRUMENTS_ORDER_PLACE_PATH <- "/api/orders/place"
INSTRUMENTS_ORDER_MODIFY_PATH <- "/api/orders/modify"
INSTRUMENTS_ORDER_CANCEL_PATH <- "/api/orders/cancel"
INSTRUMENTS_ORDER_PARENTS_PATH <- "/api/orders/parents"
INSTRUMENTS_POSITIONS_PATH <- "/api/portfolio/positions"
INSTRUMENTS_OPEN_ORDER_STATUSES <- c(
  "PENDING",
  "OPEN"
)
INSTRUMENTS_COMPLETED_ORDER_STATUSES <- "COMPLETE"
INSTRUMENTS_REJECTED_ORDER_STATUSES <- "REJECTED"
INSTRUMENTS_CANCELLED_ORDER_STATUSES <- "CANCELLED"
INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT <- c(
  cnc = "delivery",
  mis = "intraday",
  nrml = "carry"
)
INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT <- c(
  delivery = "cnc",
  intraday = "mis",
  carry = "nrml"
)
INSTRUMENTS_TICK_DEPTH_LEVELS <- 5

.trade_r_state <- new.env(parent = emptyenv())

#' One instrument in UBI's unified instrument universe
#'
#' @description
#' An instrument is looked up once, when it is created, through UBI's `/api/instruments/details` route, and keeps only its identity, lot size and tick size. Every candle, quote and price after that is read from UBI at the moment it is asked for, with no caching here, because UBI runs on the same machine and caches in its own Redis.
#'
#' `Instrument` inherits every analysis class, from `PriceStatistics` to `PerformanceMeasures`, so each of the analysis methods is available on every instrument and fetches its own candles through `prices()`.
#'
#' Code normally creates one of the family classes, such as `Equity` or `EquityIndexOption`, rather than this class, because the family class asks only for the fields that identify one of its own contracts.
#'
#' The examples below start with a short tour of the class, then show its properties and the functions on its class generator, in this order:
#'
#' * For `Instrument$shared_unified_broker_interface()`, show that every instrument built without a client of its own shares the one client, and ask it whether the session is connected.
#' * For `Instrument$shared_unified_broker_interface()`, send a raw request to a UBI route that has no method of its own, here the last price of Infosys, through the shared client.
#' * For `Instrument$shared_unified_broker_interface()`, hand the shared client to an instrument explicitly, as code that manages its own clients would.
#' * For `quote`, print the headline fields of the full quote for Infosys.
#' * For `quote`, check whether the quote is stale before trusting it, which UBI reports in the quote itself.
#' * For `last_price`, print the last traded price of Infosys.
#' * For `last_price`, print the last price of three indices side by side.
#' * For `last_price`, value a hypothetical holding of 25 Infosys shares at the last price.
#' * For `ohlc`, print the day's range of the Nifty index so far.
#' * For `ohlc`, say whether Infosys opened with a gap up or a gap down against the previous close.
#'
#' @examples
#' \dontrun{
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' print(infosys)
#' infosys$last_price
#' tail(infosys$prices(days = 10))
#'
#' shared_client <- Instrument$shared_unified_broker_interface()
#' again <- Instrument$shared_unified_broker_interface()
#' print(identical(shared_client, again))
#' print(shared_client$status())
#'
#' shared_client <- Instrument$shared_unified_broker_interface()
#' answer <- shared_client$get(
#'   "/api/instruments/ltp",
#'   params = list(
#'     exchange = "nse",
#'     segment = "equities",
#'     symbol = "INFY"
#'   )
#' )
#' print(answer[["last_price"]])
#'
#' shared_client <- Instrument$shared_unified_broker_interface()
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY",
#'   unified_broker_interface = shared_client
#' )
#' cat(format(infosys), infosys$last_price, "\n")
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' quote <- infosys$quote
#' cat("Last price:", quote[["last_price"]], "\n")
#' cat("Previous close:", quote[["previous_close"]], "\n")
#' cat("Change percent:", quote[["change_percent"]], "\n")
#' cat("Volume:", quote[["volume"]], "\n")
#' cat("Served by:", quote[["broker"]], "from", quote[["source"]], "\n")
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#' quote <- reliance$quote
#' if (quote[["stale"]]) {
#'   cat("The quote has been stale since", quote[["stale_since"]], "\n")
#' } else {
#'   cat("The quote is fresh:", quote[["last_price"]], "\n")
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' print(infosys$last_price)
#'
#' symbols <- c(
#'   "NIFTY",
#'   "BANKNIFTY",
#'   "FINNIFTY"
#' )
#' for (symbol in symbols) {
#'   index <- NonTradeableInstrument$new(
#'     exchange = "nse",
#'     segment = "equity_indices",
#'     symbol = symbol
#'   )
#'   cat(sprintf("%s: %s", symbol, index$last_price), "\n")
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' share_count <- 25
#' last_price <- infosys$last_price
#' if (is.null(last_price)) {
#'   cat("UBI has no last price for Infosys.", "\n")
#' } else {
#'   cat(
#'     sprintf(
#'       "%s shares are worth Rs %.2f",
#'       share_count,
#'       share_count * last_price
#'     ),
#'     "\n"
#'   )
#' }
#'
#' nifty <- NonTradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equity_indices",
#'   symbol = "NIFTY"
#' )
#' day <- nifty$ohlc
#' cat("Open:", day[["ohlc"]][["open"]], "\n")
#' cat("High:", day[["ohlc"]][["high"]], "\n")
#' cat("Low:", day[["ohlc"]][["low"]], "\n")
#' cat("Last:", day[["last_price"]], "\n")
#' cat("Previous close:", day[["previous_close"]], "\n")
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' day <- infosys$ohlc
#' opening_price <- day[["ohlc"]][["open"]]
#' previous_close <- day[["previous_close"]]
#' gap_percent <- (opening_price - previous_close) / previous_close * 100
#' if (gap_percent > 0) {
#'   cat(sprintf("Gap up of %.2f%%", gap_percent), "\n")
#' } else {
#'   cat(sprintf("Gap down of %.2f%%", -gap_percent), "\n")
#' }
#' }
#' @export
Instrument <- R6::R6Class(
  "Instrument",
  inherit = PerformanceMeasures,
  public = list(
    #' @field instrument_id The character UUID UBI computes for the instrument, the same at every broker.
    instrument_id = NULL,
    #' @field exchange The character lower-case exchange, such as `"nse"` or `"mcx"`.
    exchange = NULL,
    #' @field segment The character exchange-prefixed segment, such as `"nse_equities"`.
    segment = NULL,
    #' @field shape The character shape of the segment: `"security"`, `"future"` or `"option"`.
    shape = NULL,
    #' @field symbol The character symbol of a security, or `NULL` for a future or option.
    symbol = NULL,
    #' @field underlying_symbol The character symbol of a future's or option's underlying, or `NULL` for a security.
    underlying_symbol = NULL,
    #' @field expiry_date The `Date` a future or option expires, or `NULL` for a security.
    expiry_date = NULL,
    #' @field strike_price The numeric strike price of an option, or `NULL` for anything else.
    strike_price = NULL,
    #' @field option_type The character option type, `"CE"` or `"PE"`, or `NULL` for anything else.
    option_type = NULL,
    #' @field underlying_instrument_id The character UUID UBI gives for the instrument a future or option is written on, or `NULL` for a security or when UBI does not say.
    underlying_instrument_id = NULL,
    #' @field mapping_date The `Date` of the UBI mapping the details were read from.
    mapping_date = NULL,
    #' @field first_seen_date The `Date` UBI first saw the instrument, or `NULL` when unknown.
    first_seen_date = NULL,
    #' @field last_seen_date The `Date` UBI last saw the instrument, or `NULL` when unknown.
    last_seen_date = NULL,
    #' @field lot_size The integer number of underlying units in one lot, or `NULL` when UBI's brokers do not agree.
    lot_size = NULL,
    #' @field tick_size The numeric smallest price step in rupees, or `NULL` when UBI's brokers do not agree.
    tick_size = NULL,
    #' @field carried_by A list of named lists, one per broker carrying the instrument, each with that broker's own token, order symbol, lot size and tick size.
    carried_by = NULL,

    #' @description
    #' Looks the instrument up in UBI and keeps its details.
    #'
    #' Give either `instrument_id`, or `exchange`, `segment` and the identity fields the segment's shape needs: `symbol` for a security, `underlying_symbol` and `expiry_date` for a future, and all four of `underlying_symbol`, `expiry_date`, `strike_price` and `option_type` for an option.
    #' @param instrument_id The character UUID of the instrument, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, bare such as `"equities"` or prefixed such as `"nse_equities"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol of a security, or `NULL`.
    #' @param underlying_symbol The character symbol of a future's or option's underlying, or `NULL`.
    #' @param expiry_date The expiry of a future or option as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price The numeric strike price of an option, or `NULL`.
    #' @param option_type The character option type of an option, `"CE"` or `"PE"`, or `NULL`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @param details The named list UBI returned for this instrument from `/api/instruments/details`, such as one entry of a list request, which is used instead of looking the instrument up again, or `NULL` to look it up from the other arguments.
    #' @return A new `Instrument` object.
    #' @details Errors: signals `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed, such as a future without an `expiry_date`; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      unified_broker_interface = NULL,
      details = NULL
    ) {
      if (is.null(unified_broker_interface)) {
        unified_broker_interface <- Instrument$shared_unified_broker_interface()
      }
      private$unified_broker_interface <- unified_broker_interface
      lookup <- list(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type
      )
      if (is.null(details)) {
        details <- private$fetch_details(lookup)
      }
      private$apply_details(details)
    },

    #' @description
    #' Describes the instrument by exchange, segment and identity fields.
    #' @param ... Ignored, accepted so that `format()` works.
    #' @return A character value such as `"Equity(exchange='nse', segment='nse_equities', symbol='INFY')"`.
    format = function(...) {
      described_fields <- c(
        sprintf("exchange='%s'", self$exchange),
        sprintf("segment='%s'", self$segment)
      )
      identity <- list(
        symbol = self$symbol,
        underlying_symbol = self$underlying_symbol,
        expiry_date = self$expiry_date,
        strike_price = self$strike_price,
        option_type = self$option_type
      )
      for (field in names(identity)) {
        value <- identity[[field]]
        if (is.null(value)) {
          next
        }
        if (inherits(value, "Date")) {
          text <- sprintf("'%s'", format(value, "%Y-%m-%d"))
        } else if (is.character(value)) {
          text <- sprintf("'%s'", value)
        } else {
          text <- format(value)
        }
        described_fields <- c(
          described_fields,
          sprintf("%s=%s", field, text)
        )
      }
      sprintf(
        "%s(%s)",
        class(self)[[1]],
        paste(described_fields, collapse = ", ")
      )
    },

    #' @description
    #' Prints the description `format()` gives.
    #' @param ... Ignored.
    #' @return The instrument, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    },

    #' @description
    #' Compares two instruments by their UBI instrument id.
    #' @param other The object to compare with, of any type.
    #' @return A logical that is `TRUE` when `other` is an `Instrument` with the same `instrument_id`, and `FALSE` otherwise.
    equals = function(other) {
      if (!inherits(other, "Instrument")) {
        return(FALSE)
      }
      identical(self$instrument_id, other$instrument_id)
    },

    #' @description
    #' Fetches the instrument's candles for a range from UBI.
    #'
    #' Give either `from_date` and `to_date`, or `days`. UBI serves any range in one request.
    #'
    #' The examples below, in order:
    #'
    #' * Print the last five daily candles of Infosys.
    #' * Work out the Nifty index's return over a fixed range of dates from its first and last close.
    #' * Compare adjusted and unadjusted closes of Reliance over five years, where a split or bonus shows up as a price factor below 1.
    #' @param interval The character candle interval, such as `"day"` or `"5minute"`.
    #' @param from_date The first day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param to_date The last day of the range as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` when `days` is given.
    #' @param days The integer number of days to count back from today, or `NULL` when `from_date` and `to_date` are given.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` sorted by time, with `exchange`, `segment`, `interval`, `datetime` in India time, `open`, `high`, `low`, `close`, `volume` and `oi` columns, plus `price_factor` when the prices are adjusted, or `NULL` when UBI has no candles for the range.
    #' @details Errors: signals `BadRequestError` when the range or interval is invalid, such as both `days` and `from_date` given; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' infosys <- TradeableInstrument$new(
    #'   exchange = "nse",
    #'   segment = "equities",
    #'   symbol = "INFY"
    #' )
    #' candles <- infosys$prices(interval = "day", days = 10)
    #' columns <- c(
    #'   "datetime",
    #'   "open",
    #'   "high",
    #'   "low",
    #'   "close",
    #'   "volume"
    #' )
    #' print(tail(candles[, columns], 5))
    #'
    #' nifty <- NonTradeableInstrument$new(
    #'   exchange = "nse",
    #'   segment = "equity_indices",
    #'   symbol = "NIFTY"
    #' )
    #' candles <- nifty$prices(
    #'   interval = "day",
    #'   from_date = "2026-01-01",
    #'   to_date = "2026-06-30"
    #' )
    #' first_close <- candles$close[[1]]
    #' last_close <- candles$close[[nrow(candles)]]
    #' change_percent <- (last_close - first_close) / first_close * 100
    #' cat(
    #'   sprintf(
    #'     "Nifty from %s to %s: %.2f%%",
    #'     first_close,
    #'     last_close,
    #'     change_percent
    #'   ),
    #'   "\n"
    #' )
    #'
    #' reliance <- TradeableInstrument$new(
    #'   exchange = "nse",
    #'   segment = "equities",
    #'   symbol = "RELIANCE"
    #' )
    #' adjusted <- reliance$prices(days = 1825, adjusted = TRUE)
    #' unadjusted <- reliance$prices(days = 1825, adjusted = FALSE)
    #' cat("First adjusted close:", adjusted$close[[1]], "\n")
    #' cat("First unadjusted close:", unadjusted$close[[1]], "\n")
    #' cat("Smallest price factor:", min(adjusted$price_factor), "\n")
    #' }
    prices = function(
      interval = "day",
      from_date = NULL,
      to_date = NULL,
      days = NULL,
      adjusted = TRUE
    ) {
      parameters <- list(
        instrument_id = self$instrument_id,
        interval = interval
      )
      if (adjusted) {
        parameters[["adjusted"]] <- "true"
      } else {
        parameters[["adjusted"]] <- "false"
      }
      parameters[["from"]] <- from_date
      parameters[["to"]] <- to_date
      parameters[["days"]] <- days
      response <- private$unified_broker_interface$get(
        INSTRUMENTS_PRICES_PATH,
        params = parameters
      )
      candles <- response[["candles"]]
      if (length(candles) == 0) {
        return(NULL)
      }
      column_names <- unlist(response[["columns"]])
      rows <- list()
      for (candle_index in seq_along(candles)) {
        candle <- candles[[candle_index]]
        row <- list()
        for (column_index in seq_along(column_names)) {
          value <- candle[[column_index]]
          if (is.null(value)) {
            row[column_names[[column_index]]] <- list(NULL)
          } else {
            row[[column_names[[column_index]]]] <- value
          }
        }
        rows[[candle_index]] <- row
      }
      candle_frame <- FrameBuilder$new()$frame(rows)
      names(candle_frame)[names(candle_frame) == "time"] <- "datetime"
      candle_frame$datetime <- TimeConverter$new()$moments(candle_frame$datetime)
      frame <- data.frame(
        exchange = rep(self$exchange, nrow(candle_frame)),
        segment = rep(self$segment, nrow(candle_frame)),
        interval = rep(interval, nrow(candle_frame))
      )
      frame <- cbind(frame, candle_frame)
      frame <- frame[order(frame$datetime), , drop = FALSE]
      rownames(frame) <- NULL
      frame
    },

    #' @description
    #' Fetches every tick UBI's unified live feed recorded for the instrument in a period.
    #'
    #' The period includes `start` and leaves out `end`. A value without an offset is read as India time, and a bare date means midnight at the start of that day. A busy instrument records many ticks a second, so ask for short periods.
    #'
    #' The examples below, in order:
    #'
    #' * Print the best bid and offer of Vodafone Idea for the first minute of a session.
    #' * Work out the share of ticks in an hour at which the spread was a single tick.
    #' @param start The first instant to include, as a `POSIXct` or a character value such as `"2026-09-29 10:00"`.
    #' @param end The first instant to leave out, as a `POSIXct` or a character value such as `"2026-09-29 15:30"`.
    #' @param adjusted A logical that is `TRUE` for prices adjusted for splits and bonuses.
    #' @return A `data.frame` sorted by time, with `exchange`, `segment`, `datetime` (when the tick was received), `exchange_time` and `last_trade_time`, all in India time, then `broker`, `last_price`, `last_quantity`, `average_price`, `volume`, `buy_quantity`, `sell_quantity`, `oi` and the order book flattened into `bid1_price` to `bid5_orders` and `offer1_price` to `offer5_orders`, or `NULL` when no tick was recorded in the period.
    #' @details Errors: signals `BadRequestError` when the period is invalid, such as an end that is not after the start; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' vodafone_idea <- TradeableInstrument$new(
    #'   exchange = "nse",
    #'   segment = "equities",
    #'   symbol = "IDEA"
    #' )
    #' ticks <- vodafone_idea$ticks(
    #'   start = "2026-09-29 09:15",
    #'   end = "2026-09-29 09:16"
    #' )
    #' columns <- c(
    #'   "datetime",
    #'   "bid1_price",
    #'   "offer1_price"
    #' )
    #' print(head(ticks[, columns], 10))
    #'
    #' vodafone_idea <- TradeableInstrument$new(
    #'   exchange = "nse",
    #'   segment = "equities",
    #'   symbol = "IDEA"
    #' )
    #' ticks <- vodafone_idea$ticks(
    #'   start = "2026-09-29 10:00",
    #'   end = "2026-09-29 11:00"
    #' )
    #' spread <- ticks$offer1_price - ticks$bid1_price
    #' tick_size <- as.numeric(vodafone_idea$tick_size)
    #' one_tick <- abs(spread - tick_size) < 1e-9
    #' cat(
    #'   sprintf(
    #'     "%s ticks, %.1f%% at one tick",
    #'     nrow(ticks),
    #'     mean(one_tick) * 100
    #'   ),
    #'   "\n"
    #' )
    #' }
    ticks = function(start, end, adjusted = TRUE) {
      parameters <- list(
        instrument_id = self$instrument_id,
        start = private$instant_text(start),
        end = private$instant_text(end)
      )
      if (adjusted) {
        parameters[["adjusted"]] <- "true"
      } else {
        parameters[["adjusted"]] <- "false"
      }
      response <- private$unified_broker_interface$get(
        INSTRUMENTS_TICKS_PATH,
        params = parameters
      )
      if (length(response) == 0) {
        return(NULL)
      }
      rows <- list()
      for (tick_index in seq_along(response)) {
        rows[[tick_index]] <- private$flatten_tick(response[[tick_index]])
      }
      tick_frame <- FrameBuilder$new()$frame(rows)
      converter <- TimeConverter$new()
      time_columns <- c(
        "datetime",
        "exchange_time",
        "last_trade_time"
      )
      for (column in time_columns) {
        tick_frame[[column]] <- converter$moments(tick_frame[[column]])
      }
      frame <- data.frame(
        exchange = rep(self$exchange, nrow(tick_frame)),
        segment = rep(self$segment, nrow(tick_frame))
      )
      frame <- cbind(frame, tick_frame)
      frame <- frame[order(frame$datetime, method = "radix"), , drop = FALSE]
      rownames(frame) <- NULL
      frame
    }
  ),
  active = list(
    #' @field quote The instrument's full unified quote as a named list, read from UBI on every access.
    quote = function(value) {
      if (!missing(value)) {
        stop("quote is read-only", call. = FALSE)
      }
      private$unified_broker_interface$get(
        INSTRUMENTS_QUOTE_PATH,
        params = list(
          instrument_id = self$instrument_id
        )
      )
    },

    #' @field last_price The instrument's last traded price as a numeric value, or `NULL` when UBI has none, read from UBI on every access.
    last_price = function(value) {
      if (!missing(value)) {
        stop("last_price is read-only", call. = FALSE)
      }
      response <- private$unified_broker_interface$get(
        INSTRUMENTS_LAST_PRICE_PATH,
        params = list(
          instrument_id = self$instrument_id
        )
      )
      response[["last_price"]]
    },

    #' @field ohlc The day's open, high and low with the last and previous close prices, as a named list read from UBI on every access.
    ohlc = function(value) {
      if (!missing(value)) {
        stop("ohlc is read-only", call. = FALSE)
      }
      private$unified_broker_interface$get(
        INSTRUMENTS_OHLC_PATH,
        params = list(
          instrument_id = self$instrument_id
        )
      )
    }
  ),
  private = list(
    unified_broker_interface = NULL,

    #' Copies the instrument's identity, lot size and tick size from UBI's details.
    #' @param details The named list UBI returns from `/api/instruments/details` for this instrument.
    #' @return `NULL`, invisibly.
    apply_details = function(details) {
      converter <- TimeConverter$new()
      self$instrument_id <- details[["instrument_id"]]
      self$exchange <- details[["exchange"]]
      self$segment <- details[["segment"]]
      self$shape <- details[["shape"]]
      self$symbol <- details[["symbol"]]
      self$underlying_symbol <- details[["underlying_symbol"]]
      self$expiry_date <- converter$date(details[["expiry_date"]])
      self$strike_price <- details[["strike_price"]]
      self$option_type <- details[["option_type"]]
      self$underlying_instrument_id <- details[["underlying_instrument_id"]]
      self$mapping_date <- converter$date(details[["mapping_date"]])
      self$first_seen_date <- converter$date(details[["first_seen_date"]])
      self$last_seen_date <- converter$date(details[["last_seen_date"]])
      self$lot_size <- details[["lot_size"]]
      tick_size <- details[["tick_size"]]
      if (!is.null(tick_size)) {
        tick_size <- as.numeric(tick_size)
      }
      self$tick_size <- tick_size
      self$carried_by <- details[["carried_by"]]
      invisible(NULL)
    },

    #' Reads the instrument's details from UBI.
    #' @param lookup A named list of the constructor's lookup arguments, where `NULL` means not given.
    #' @return The named list UBI returns from `/api/instruments/details`.
    #' @details Errors: signals `InstrumentError` when UBI has no instrument matching the lookup, and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    fetch_details = function(lookup) {
      parameters <- list()
      if (!is.null(lookup[["instrument_id"]])) {
        parameters[["instrument_id"]] <- lookup[["instrument_id"]]
      } else {
        for (name in names(lookup)) {
          parameters[[name]] <- lookup[[name]]
        }
      }
      tryCatch(
        private$unified_broker_interface$get(
          INSTRUMENTS_DETAILS_PATH,
          params = parameters
        ),
        NotFoundError = function(error) {
          ErrorCatalogue$raise(
            "InstrumentError",
            sprintf(
              "UBI has no instrument matching %s: %s",
              private$lookup_text(parameters),
              conditionMessage(error)
            ),
            parent = error
          )
        }
      )
    },

    #' Describes lookup parameters the way Python prints a dictionary.
    #' @param parameters A named list of lookup values.
    #' @return A character value such as `"{'exchange': 'nse', 'symbol': 'INFY'}"`.
    lookup_text = function(parameters) {
      pieces <- character(0)
      for (name in names(parameters)) {
        value <- parameters[[name]]
        if (inherits(value, "Date")) {
          value <- format(value, "%Y-%m-%d")
        }
        if (is.character(value)) {
          text <- sprintf("'%s'", value)
        } else {
          text <- format(value)
        }
        pieces <- c(
          pieces,
          sprintf("'%s': %s", name, text)
        )
      }
      sprintf("{%s}", paste(pieces, collapse = ", "))
    },

    #' Writes a tick period boundary the way the Python library sends it.
    #' @param value A `POSIXct` or a character value.
    #' @return A character value, with a `POSIXct` written in India time with its offset.
    instant_text = function(value) {
      if (inherits(value, "POSIXct")) {
        return(
          format(
            value,
            "%Y-%m-%d %H:%M:%S%z",
            tz = TIME_CONVERTER_INDIA_TIME_ZONE
          )
        )
      }
      as.character(value)
    },

    #' Turns one recorded tick from UBI into one flat row.
    #' @param tick The named list of one tick as UBI's ticks route serves it.
    #' @return A named list with the tick's scalar fields and five numbered levels of `price`, `quantity` and `orders` on each side, with `NULL` for an empty level.
    flatten_tick = function(tick) {
      row <- list()
      scalar_fields <- list(
        datetime = "time",
        exchange_time = "exchange_time",
        last_trade_time = "last_trade_time",
        broker = "broker",
        last_price = "last_price",
        last_quantity = "last_quantity",
        average_price = "average_price",
        volume = "volume",
        buy_quantity = "buy_quantity",
        sell_quantity = "sell_quantity",
        oi = "oi"
      )
      for (column in names(scalar_fields)) {
        value <- tick[[scalar_fields[[column]]]]
        if (is.null(value)) {
          row[column] <- list(NULL)
        } else {
          row[[column]] <- value
        }
      }
      depth <- tick[["depth"]]
      if (is.null(depth)) {
        depth <- list()
      }
      sides <- list(
        bid = depth[["buy"]],
        offer = depth[["sell"]]
      )
      level_fields <- c(
        "price",
        "quantity",
        "orders"
      )
      for (side_name in names(sides)) {
        levels <- sides[[side_name]]
        for (level_number in seq_len(INSTRUMENTS_TICK_DEPTH_LEVELS)) {
          level <- list()
          if (level_number <= length(levels)) {
            level <- levels[[level_number]]
          }
          for (field in level_fields) {
            column <- sprintf("%s%d_%s", side_name, level_number, field)
            value <- level[[field]]
            if (is.null(value)) {
              row[column] <- list(NULL)
            } else {
              row[[column]] <- value
            }
          }
        }
      }
      row
    }
  )
)

Instrument$shared_unified_broker_interface <- function() {
  if (is.null(.trade_r_state$shared_unified_broker_interface)) {
    .trade_r_state$shared_unified_broker_interface <-
      UnifiedBrokerInterface$new()
  }
  .trade_r_state$shared_unified_broker_interface
}

Instrument$set_shared_unified_broker_interface <- function(
  unified_broker_interface
) {
  .trade_r_state$shared_unified_broker_interface <- unified_broker_interface
  invisible(unified_broker_interface)
}

#' Discovery of instruments in UBI's catalogue
#'
#' @description
#' The R home of the Python library's protected class methods `Instrument._search_catalogue`, `_master_catalogue`, `_contracts_for`, `_expiry_dates` and `_identity_frame`, which every family class's discovery functions, such as `Equity$search()` and `EquityOption$chain()`, call.
#'
#' UBI's search route ranks an exact match first, then names starting with the term, then names containing it, and returns at most 200 rows in expiry order, so it is the right way to look for a security by name and the wrong way to look for a contract. The master route returns a whole segment with no limit, which is the only way to reach a live expiry, so contracts are found by fetching the segment and narrowing it here.
#'
#' @export
InstrumentCatalogue <- R6::R6Class(
  "InstrumentCatalogue",
  public = list(
    #' @description
    #' Prepares a catalogue reader that sends its requests through one client.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `InstrumentCatalogue` object.
    initialize = function(unified_broker_interface = NULL) {
      if (is.null(unified_broker_interface)) {
        unified_broker_interface <- Instrument$shared_unified_broker_interface()
      }
      private$unified_broker_interface <- unified_broker_interface
    },

    #' @description
    #' Finds instruments in one segment whose name contains a term.
    #' @param exchange The character exchange to search, such as `"nse"`.
    #' @param segment The character segment to search, bare such as `"equities"` or prefixed such as `"nse_equities"`.
    #' @param term The character text the name must contain, matched without regard to case.
    #' @param limit The integer most rows to return, which UBI caps at 200.
    #' @return A `data.frame` of identities, with `instrument_id`, `exchange`, `segment`, `shape`, `symbol`, `underlying_symbol`, `expiry_date`, `strike_price` and `option_type`, or `NULL` when nothing matches.
    #' @details Errors: signals `BadRequestError` when the exchange or segment is not one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    search = function(exchange, segment, term, limit) {
      answer <- private$unified_broker_interface$get(
        INSTRUMENTS_SEARCH_PATH,
        params = list(
          exchange = exchange,
          segment = segment,
          q = term,
          limit = limit
        )
      )
      self$identity_frame(answer[["instruments"]])
    },

    #' @description
    #' Fetches every instrument UBI holds in one segment.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @param segment The character segment, bare such as `"equity_options"` or prefixed such as `"nse_equity_options"`.
    #' @return A `data.frame` of every identity in the segment, shaped as `search()` returns, or `NULL` when the segment holds nothing.
    #' @details Errors: signals `BadRequestError` when the exchange or segment is not one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    master = function(exchange, segment) {
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_MASTER_PATH,
        params = list(
          exchange = exchange,
          segment = segment
        )
      )
      self$identity_frame(rows)
    },

    #' @description
    #' Finds the contracts in one segment, narrowed by underlying and expiry.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @param segment The character segment of the contracts, such as `"equity_options"`.
    #' @param underlying_symbol The character symbol of the underlying to keep, or `NULL` to keep every underlying.
    #' @param expiry_date The expiry to keep, as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` to keep every expiry.
    #' @param include_expired A logical that is `TRUE` to keep contracts whose expiry has passed.
    #' @return A `data.frame` of the matching identities, sorted by expiry, strike price and option type, or `NULL` when nothing matches.
    #' @details Errors: signals `BadRequestError` when the exchange or segment is not one UBI knows; a plain error when `expiry_date` is text that is not a valid ISO date; and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    contracts_for = function(
      exchange,
      segment,
      underlying_symbol,
      expiry_date,
      include_expired
    ) {
      frame <- self$master(exchange, segment)
      if (is.null(frame)) {
        return(NULL)
      }
      converter <- TimeConverter$new()
      wanted_expiry <- converter$date(expiry_date)
      today <- converter$today()
      keep <- rep(TRUE, nrow(frame))
      for (row_index in seq_len(nrow(frame))) {
        row_expiry <- frame$expiry_date[[row_index]]
        if (!is.null(underlying_symbol)) {
          row_underlying <- frame$underlying_symbol[[row_index]]
          if (is.na(row_underlying) || row_underlying != toupper(underlying_symbol)) {
            keep[[row_index]] <- FALSE
            next
          }
        }
        if (is.na(row_expiry)) {
          keep[[row_index]] <- FALSE
          next
        }
        if (!is.null(wanted_expiry) && row_expiry != wanted_expiry) {
          keep[[row_index]] <- FALSE
          next
        }
        if (!include_expired && row_expiry < today) {
          keep[[row_index]] <- FALSE
        }
      }
      if (!any(keep)) {
        return(NULL)
      }
      kept_frame <- frame[keep, , drop = FALSE]
      sort_order <- order(
        kept_frame$expiry_date,
        private$sortable_column(kept_frame, "strike_price"),
        private$sortable_column(kept_frame, "option_type"),
        na.last = FALSE,
        method = "radix"
      )
      sorted_frame <- kept_frame[sort_order, , drop = FALSE]
      rownames(sorted_frame) <- NULL
      sorted_frame
    },

    #' @description
    #' Lists the expiries one underlying has contracts for in a segment.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @param segment The character segment of the contracts, such as `"equity_futures"`.
    #' @param underlying_symbol The character symbol of the underlying, such as `"RELIANCE"`.
    #' @param include_expired A logical that is `TRUE` to include expiries that have passed.
    #' @return A `Date` vector, soonest first, which is empty when the underlying has no contracts.
    #' @details Errors: signals `BadRequestError` when the exchange or segment is not one UBI knows, and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    expiry_dates = function(
      exchange,
      segment,
      underlying_symbol,
      include_expired
    ) {
      frame <- self$contracts_for(
        exchange,
        segment,
        underlying_symbol,
        NULL,
        include_expired
      )
      if (is.null(frame)) {
        return(as.Date(character(0)))
      }
      sort(unique(frame$expiry_date))
    },

    #' @description
    #' Lists the strike prices listed on one underlying for one expiry in a segment.
    #' @param exchange The character exchange, such as `"nse"`.
    #' @param segment The character segment of the options, such as `"equity_options"`.
    #' @param underlying_symbol The character symbol of the underlying, such as `"RELIANCE"`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param include_expired A logical that is `TRUE` to allow an expiry that has already passed.
    #' @return A numeric vector of strike prices, lowest first, which is empty when nothing is listed for that expiry.
    #' @details Errors: signals `BadRequestError` when the exchange or segment is not one UBI knows; a plain error when `expiry_date` is text that is not a valid ISO date; and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    strikes = function(
      exchange,
      segment,
      underlying_symbol,
      expiry_date,
      include_expired
    ) {
      frame <- self$contracts_for(
        exchange,
        segment,
        underlying_symbol,
        expiry_date,
        include_expired
      )
      if (is.null(frame)) {
        return(numeric(0))
      }
      sort(unique(frame$strike_price))
    },

    #' @description
    #' Turns UBI's identity rows into a frame, with real dates in it.
    #' @param rows A list of named lists as UBI's search and master routes return them.
    #' @return A `data.frame` of the rows, with `expiry_date` as a `Date` column, or `NULL` when there are no rows.
    #' @details Errors: signals a plain error when an expiry date is not a valid ISO date.
    identity_frame = function(rows) {
      frame <- FrameBuilder$new()$frame(rows)
      if (is.null(frame)) {
        return(NULL)
      }
      expiry_text <- frame$expiry_date
      if (is.null(expiry_text)) {
        expiry_text <- rep(NA_character_, nrow(frame))
      }
      frame$expiry_date <- TimeConverter$new()$dates(as.character(expiry_text))
      frame
    }
  ),
  private = list(
    unified_broker_interface = NULL,

    #' Gives a column to sort by, or a column of missing values when the frame lacks it.
    #' @param frame A `data.frame`.
    #' @param column A character column name.
    #' @return The column, or an `NA` vector as long as the frame.
    sortable_column = function(frame, column) {
      if (column %in% names(frame)) {
        return(frame[[column]])
      }
      rep(NA, nrow(frame))
    }
  )
)

#' An instrument that can be traded, which is anything except an index
#'
#' @description
#' Adds the order book, orders, positions and the price wrappers to `Instrument`. Every order goes through UBI's order engine, and the values are sent exactly as given, without rounding the price to the tick size or checking the quantity against the lot size, because UBI and the broker behind it hold those rules.
#'
#' The members that read orders, trades and positions read the whole account's document from UBI and keep this instrument's own rows, because UBI has no route for one instrument.
#'
#' The examples below start with a short tour of the class, then show its properties, in this order:
#'
#' * For `bids`, print every level on the buy side of the Infosys order book, best first.
#' * For `bids`, add up how many shares are bid for across the visible levels of the Reliance book.
#' * For `offers`, print every level on the sell side of the Infosys order book, best first.
#' * For `offers`, compare the quantity offered with the quantity bid in the visible book, a rough measure of selling pressure.
#' * For `best_bid`, print the highest bid for Infosys, or say that nobody is bidding.
#' * For `best_bid`, measure how far the best bid is below the last traded price.
#' * For `best_offer`, print the lowest offer for Infosys, or say that nobody is offering.
#' * For `best_offer`, work out what buying 10 shares at the best offer would cost, when that level holds enough.
#' * For `bid_offer_spread`, print the spread of Infosys in rupees.
#' * For `bid_offer_spread`, express the spread in ticks, which says how liquid the book is.
#' * For `bid_offer_spread`, rank three shares by their spread as a percentage of the last price.
#' * For `mid_price`, print the mid price of Infosys.
#' * For `mid_price`, compare the mid price with the last traded price to see which side traded last.
#' * For `volume_weighted_average_price`, print today's volume weighted average price of Infosys.
#' * For `volume_weighted_average_price`, say whether Reliance is trading above or below its average price for the day, a common intraday bias check.
#' * For `last_quantity`, print the size of the last Infosys trade.
#' * For `last_quantity`, show the value of the last Reliance trade in rupees.
#' * For `total_traded_volume`, print how many Infosys shares have traded today.
#' * For `total_traded_volume`, compare today's volume with the average daily volume of the last month.
#' * For `open_interest`, print the open interest of the nearest Nifty future.
#' * For `open_interest`, express the open interest of the nearest Nifty future in lots rather than units.
#' * For `open_interest`, show that a share has no open interest, so the property is `NULL`.
#' * For `last_trade_time`, print when Infosys last traded, in India time.
#' * For `last_trade_time`, work out how many seconds ago Reliance last traded, a quick check that the feed is alive.
#' * For `parents`, print the parents UBI's order engine is still working in Vodafone Idea.
#' * For `parents`, hold a buy limit order 3 per cent below the market, find it among the parents, and cancel it.
#' * For `orders`, print today's Vodafone Idea orders with their status, or `NULL` when there are none.
#' * For `orders`, count today's orders in Vodafone Idea by status, which is how an order whose status has no property of its own, such as `EXPIRED`, is found.
#' * For `orders`, split today's Vodafone Idea orders by whether UBI's order engine placed them for a parent.
#' * For `open_orders`, print the Vodafone Idea orders still waiting in the market.
#' * For `open_orders`, add up the quantity still waiting to fill on each side of the Infosys book from this account's open orders.
#' * For `completed_orders`, print the Vodafone Idea orders that filled in full today.
#' * For `completed_orders`, work out the average buying and selling prices of today's filled Vodafone Idea orders.
#' * For `rejected_orders`, print why each of today's refused Vodafone Idea orders was refused.
#' * For `rejected_orders`, count today's refusals in Vodafone Idea by broker.
#' * For `cancelled_orders`, print today's cancelled Vodafone Idea orders.
#' * For `cancelled_orders`, count how many of today's cancelled Vodafone Idea orders had partly filled first.
#' * For `trades`, print today's Vodafone Idea trades.
#' * For `trades`, add up the value bought and sold in Vodafone Idea today from its trades.
#' * For `net_positions`, print the positions open in Vodafone Idea, or `NULL` when nothing is held.
#' * For `net_positions`, say whether each Reliance position is long or short, and under which product.
#' * For `day_positions`, print today's own positions in Vodafone Idea.
#' * For `day_positions`, compare how many rows the day bucket and the net bucket report for Vodafone Idea.
#' * For `positions_value`, print what the Vodafone Idea positions are worth now, or `NULL` when nothing is held.
#' * For `positions_value`, add up the value of the positions in three shares, counting a short as negative.
#' * For `positions_pnl`, print the profit or loss on the Vodafone Idea positions, or `NULL` when nothing is held.
#' * For `positions_pnl`, say whether the Reliance positions are making or losing money overall.
#'
#' @examples
#' \dontrun{
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#' infosys$best_bid
#' infosys$bid_offer_spread
#' answer <- infosys$buy_at_best_bid_price(quantity = 1, product = "mis")
#' infosys$cancel_open_orders()
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' for (level in infosys$bids) {
#'   cat(level[["price"]], level[["quantity"]], level[["orders"]], "\n")
#' }
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' total_quantity <- 0
#' for (level in reliance$bids) {
#'   total_quantity <- total_quantity + level[["quantity"]]
#' }
#' cat(
#'   sprintf(
#'     "%s levels bid for %s shares",
#'     length(reliance$bids),
#'     total_quantity
#'   ),
#'   "\n"
#' )
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' for (level in infosys$offers) {
#'   cat(level[["price"]], level[["quantity"]], level[["orders"]], "\n")
#' }
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' offered <- 0
#' for (level in reliance$offers) {
#'   offered <- offered + level[["quantity"]]
#' }
#' bid <- 0
#' for (level in reliance$bids) {
#'   bid <- bid + level[["quantity"]]
#' }
#' cat(sprintf("Offered %s against bid %s", offered, bid), "\n")
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' best_bid <- infosys$best_bid
#' if (is.null(best_bid)) {
#'   cat("Nobody is bidding.", "\n")
#' } else {
#'   cat(
#'     sprintf(
#'       "%s shares bid at %s",
#'       best_bid[["quantity"]],
#'       best_bid[["price"]]
#'     ),
#'     "\n"
#'   )
#' }
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' best_bid <- reliance$best_bid
#' last_price <- reliance$last_price
#' if (is.null(best_bid) || is.null(last_price)) {
#'   cat("The book or the last price is empty.", "\n")
#' } else {
#'   cat(
#'     sprintf(
#'       "The best bid is %.2f below",
#'       last_price - best_bid[["price"]]
#'     ),
#'     "\n"
#'   )
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' best_offer <- infosys$best_offer
#' if (is.null(best_offer)) {
#'   cat("Nobody is offering.", "\n")
#' } else {
#'   cat(
#'     sprintf(
#'       "%s shares offered at %s",
#'       best_offer[["quantity"]],
#'       best_offer[["price"]]
#'     ),
#'     "\n"
#'   )
#' }
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' wanted_quantity <- 10
#' best_offer <- reliance$best_offer
#' if (is.null(best_offer)) {
#'   cat("Nobody is offering.", "\n")
#' } else if (best_offer[["quantity"]] < wanted_quantity) {
#'   cat("The best offer is too small for 10 shares.", "\n")
#' } else {
#'   cat(
#'     sprintf("Cost: Rs %.2f", best_offer[["price"]] * wanted_quantity),
#'     "\n"
#'   )
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$bid_offer_spread)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' spread <- reliance$bid_offer_spread
#' if (is.null(spread)) {
#'   cat("One side of the book is empty.", "\n")
#' } else {
#'   ticks <- round(spread / as.numeric(reliance$tick_size))
#'   cat(
#'     sprintf("The spread is %.2f rupees, or %s ticks", spread, ticks),
#'     "\n"
#'   )
#' }
#'
#' symbols <- c(
#'   "INFY",
#'   "TCS",
#'   "HDFCBANK"
#' )
#' for (symbol in symbols) {
#'   share <- TradeableInstrument$new(
#'     exchange = "nse",
#'     segment = "equities",
#'     symbol = symbol
#'   )
#'   spread <- share$bid_offer_spread
#'   last_price <- share$last_price
#'   if (is.null(spread) || is.null(last_price)) {
#'     cat(sprintf("%s: no two-sided book", symbol), "\n")
#'   } else {
#'     cat(sprintf("%s: %.4f%%", symbol, spread / last_price * 100), "\n")
#'   }
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$mid_price)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' mid_price <- reliance$mid_price
#' last_price <- reliance$last_price
#' if (is.null(mid_price) || is.null(last_price)) {
#'   cat("The book is one-sided or there is no last price.", "\n")
#' } else if (last_price >= mid_price) {
#'   cat(
#'     sprintf("Last %s is at or above mid %s", last_price, mid_price),
#'     "\n"
#'   )
#' } else {
#'   cat(sprintf("Last %s is below mid %s", last_price, mid_price), "\n")
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$volume_weighted_average_price)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' average_price <- reliance$volume_weighted_average_price
#' last_price <- reliance$last_price
#' if (is.null(average_price) || is.null(last_price)) {
#'   cat("The average price or the last price is unknown.", "\n")
#' } else if (last_price > average_price) {
#'   cat(
#'     sprintf("Above the average: %s > %s", last_price, average_price),
#'     "\n"
#'   )
#' } else {
#'   cat(
#'     sprintf(
#'       "At or below the average: %s <= %s",
#'       last_price,
#'       average_price
#'     ),
#'     "\n"
#'   )
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$last_quantity)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' last_quantity <- reliance$last_quantity
#' last_price <- reliance$last_price
#' if (is.null(last_quantity) || is.null(last_price)) {
#'   cat("The last trade is unknown.", "\n")
#' } else {
#'   cat(
#'     sprintf("Rs %.2f changed hands last", last_quantity * last_price),
#'     "\n"
#'   )
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$total_traded_volume)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#'
#' candles <- reliance$prices(days = 30)
#' average_volume <- mean(candles$volume)
#' today_volume <- reliance$total_traded_volume
#' if (is.null(today_volume)) {
#'   cat("Today's volume is unknown.", "\n")
#' } else {
#'   cat(
#'     sprintf("Today is %.2f times average", today_volume / average_volume),
#'     "\n"
#'   )
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(format(nifty_future), nifty_future$open_interest, "\n")
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' open_interest <- nifty_future$open_interest
#' if (is.null(open_interest) || is.null(nifty_future$lot_size)) {
#'   cat("The open interest or the lot size is unknown.", "\n")
#' } else {
#'   cat(
#'     sprintf("%s lots are open", open_interest %/% nifty_future$lot_size),
#'     "\n"
#'   )
#' }
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$open_interest)
#'
#' infosys <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "INFY"
#' )
#'
#' print(infosys$last_trade_time)
#'
#' reliance <- TradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equities",
#'   symbol = "RELIANCE"
#' )
#' last_trade_time <- reliance$last_trade_time
#' if (is.null(last_trade_time)) {
#'   cat("The broker does not report the last trade time.", "\n")
#' } else {
#'   now <- Sys.time()
#'   seconds <- as.numeric(difftime(now, last_trade_time, units = "secs"))
#'   cat(sprintf("Last traded %.0f seconds ago", seconds), "\n")
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' parents <- idea$parents
#' if (is.null(parents)) {
#'   cat("No parent is open in IDEA.", "\n")
#' } else {
#'   print(parents[, c(
#'     "parent_order_id",
#'     "synthetic_type",
#'     "state"
#'   )])
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' price <- round(idea$last_price * 0.97, 2)
#' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
#' tryCatch(
#'   {
#'     parents <- idea$parents
#'     mine <- parents[parents$parent_order_id == answer[["parent_id"]], , drop = FALSE]
#'     print(mine[, c(
#'       "parent_order_id",
#'       "synthetic_type",
#'       "state"
#'     )])
#'   },
#'   finally = {
#'     print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
#'   }
#' )
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' orders <- idea$orders
#' if (is.null(orders)) {
#'   cat("No orders in IDEA today.", "\n")
#' } else {
#'   columns <- c(
#'     "order_id",
#'     "status",
#'     "transaction_type",
#'     "quantity",
#'     "price"
#'   )
#'   print(orders[, columns])
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' orders <- idea$orders
#' if (is.null(orders)) {
#'   cat("No orders in IDEA today.", "\n")
#' } else {
#'   print(sort(table(orders$status), decreasing = TRUE))
#'   expired <- orders[orders$status == "EXPIRED", , drop = FALSE]
#'   cat(nrow(expired), "expired", "\n")
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' orders <- idea$orders
#' if (is.null(orders)) {
#'   cat("No orders in IDEA today.", "\n")
#' } else {
#'   from_engine <- orders[!is.na(orders$engine_parent_id), , drop = FALSE]
#'   cat(
#'     nrow(from_engine),
#'     "of",
#'     nrow(orders),
#'     "orders came from a parent",
#'     "\n"
#'   )
#'   print(sort(table(from_engine$leg_role), decreasing = TRUE))
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' print(idea$open_orders)
#'
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' open_orders <- infosys$open_orders
#' if (is.null(open_orders)) {
#'   cat("Nothing is waiting in the market for INFY.", "\n")
#' } else {
#'   open_orders$remaining <- open_orders$quantity - open_orders$filled_quantity
#'   print(tapply(open_orders$remaining, open_orders$transaction_type, sum))
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' completed <- idea$completed_orders
#' if (is.null(completed)) {
#'   cat("Nothing filled in IDEA today.", "\n")
#' } else {
#'   print(completed[, c(
#'     "order_id",
#'     "transaction_type",
#'     "average_price"
#'   )])
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' completed <- idea$completed_orders
#' if (is.null(completed)) {
#'   cat("Nothing filled in IDEA today.", "\n")
#' } else {
#'   for (side in c(
#'     "BUY",
#'     "SELL"
#'   )) {
#'     rows <- completed[toupper(completed$transaction_type) == side, , drop = FALSE]
#'     if (nrow(rows) == 0) {
#'       next
#'     }
#'     spent <- sum(rows$average_price * rows$filled_quantity)
#'     quantity <- sum(rows$filled_quantity)
#'     cat(side, quantity, "at", round(spent / quantity, 4), "\n")
#'   }
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' rejected <- idea$rejected_orders
#' if (is.null(rejected)) {
#'   cat("Nothing was refused in IDEA today.", "\n")
#' } else {
#'   for (row in FrameBuilder$new()$rows(rejected)) {
#'     cat(row[["order_id"]], row[["broker"]], row[["status_message"]], "\n")
#'   }
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' rejected <- idea$rejected_orders
#' if (is.null(rejected)) {
#'   cat("Nothing was refused in IDEA today.", "\n")
#' } else {
#'   print(sort(table(rejected$broker), decreasing = TRUE))
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' cancelled <- idea$cancelled_orders
#' if (is.null(cancelled)) {
#'   cat("Nothing was cancelled in IDEA today.", "\n")
#' } else {
#'   print(cancelled[, c(
#'     "order_id",
#'     "broker",
#'     "price",
#'     "order_timestamp"
#'   )])
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' cancelled <- idea$cancelled_orders
#' if (is.null(cancelled)) {
#'   cat("Nothing was cancelled in IDEA today.", "\n")
#' } else {
#'   partly_filled <- cancelled[cancelled$filled_quantity > 0, , drop = FALSE]
#'   cat(
#'     nrow(partly_filled),
#'     "of",
#'     nrow(cancelled),
#'     "had partly filled",
#'     "\n"
#'   )
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' trades <- idea$trades
#' if (is.null(trades)) {
#'   cat("No trades in IDEA today.", "\n")
#' } else {
#'   columns <- c(
#'     "trade_id",
#'     "order_id",
#'     "transaction_type",
#'     "quantity",
#'     "price"
#'   )
#'   print(trades[, columns])
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' trades <- idea$trades
#' if (is.null(trades)) {
#'   cat("No trades in IDEA today.", "\n")
#' } else {
#'   totals <- tapply(trades$value, trades$transaction_type, sum)
#'   print(totals)
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' positions <- idea$net_positions
#' if (is.null(positions)) {
#'   cat("Nothing is held in IDEA.", "\n")
#' } else {
#'   print(positions[, c(
#'     "product",
#'     "quantity",
#'     "average_price",
#'     "last_price"
#'   )])
#' }
#'
#' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' positions <- reliance$net_positions
#' if (is.null(positions)) {
#'   cat("Nothing is held in RELIANCE.", "\n")
#' } else {
#'   for (row in FrameBuilder$new()$rows(positions)) {
#'     if (row[["quantity"]] > 0) {
#'       cat(row[["product"]], "long", row[["quantity"]], "\n")
#'     } else if (row[["quantity"]] < 0) {
#'       cat(row[["product"]], "short", -row[["quantity"]], "\n")
#'     } else {
#'       cat(row[["product"]], "flat, closed today", "\n")
#'     }
#'   }
#' }
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' print(idea$day_positions)
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' day_positions <- idea$day_positions
#' net_positions <- idea$net_positions
#' day_count <- 0
#' if (!is.null(day_positions)) {
#'   day_count <- nrow(day_positions)
#' }
#' net_count <- 0
#' if (!is.null(net_positions)) {
#'   net_count <- nrow(net_positions)
#' }
#' cat(
#'   sprintf("%s day rows and %s net rows", day_count, net_count),
#'   "\n"
#' )
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' print(idea$positions_value)
#'
#' symbols <- c(
#'   "IDEA",
#'   "RELIANCE",
#'   "INFY"
#' )
#' total <- 0.0
#' for (symbol in symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   value <- share$positions_value
#'   cat(symbol, value, "\n")
#'   if (!is.null(value)) {
#'     total <- total + value
#'   }
#' }
#' cat(sprintf("Total: Rs %.2f", total), "\n")
#'
#' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
#'
#' print(idea$positions_pnl)
#'
#' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' pnl <- reliance$positions_pnl
#' if (is.null(pnl)) {
#'   cat("Nothing is held in RELIANCE.", "\n")
#' } else if (pnl[["total"]] >= 0) {
#'   cat(
#'     sprintf(
#'       "Up Rs %s, of which Rs %s is booked",
#'       pnl[["total"]],
#'       pnl[["realized"]]
#'     ),
#'     "\n"
#'   )
#' } else {
#'   cat(
#'     sprintf(
#'       "Down Rs %s, of which Rs %s is booked",
#'       -pnl[["total"]],
#'       pnl[["realized"]]
#'     ),
#'     "\n"
#'   )
#' }
#' }
#' @export
TradeableInstrument <- R6::R6Class(
  "TradeableInstrument",
  inherit = Instrument,
  public = list(
    #' @description
    #' Looks the instrument up in UBI and checks that it is not an index.
    #' @param instrument_id The character UUID of the instrument, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, bare such as `"equities"` or prefixed such as `"nse_equities"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol of a security, or `NULL`.
    #' @param underlying_symbol The character symbol of a future's or option's underlying, or `NULL`.
    #' @param expiry_date The expiry of a future or option as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price The numeric strike price of an option, or `NULL`.
    #' @param option_type The character option type of an option, `"CE"` or `"PE"`, or `NULL`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @param details The named list UBI returned for this instrument from `/api/instruments/details`, used instead of looking the instrument up again, or `NULL` to look it up from the other arguments.
    #' @return A new `TradeableInstrument` object.
    #' @details Errors: signals `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      unified_broker_interface = NULL,
      details = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        unified_broker_interface = unified_broker_interface,
        details = details
      )
      if (endsWith(self$segment, INSTRUMENTS_INDEX_SEGMENT_SUFFIX)) {
        ErrorCatalogue$raise(
          "TradeableInstrumentError",
          sprintf(
            "An index cannot be traded, so it is not a TradeableInstrument: %s",
            self$format()
          )
        )
      }
    },

    #' @description
    #' Places one order in this instrument through UBI.
    #'
    #' UBI chooses the broker itself, so no broker is named here. The values are sent exactly as given, without rounding the price to the tick size or checking the quantity against the lot size, because UBI and the broker behind it hold those rules.
    #'
    #' UBI couples the price fields to the order type and answers HTTP 400 when they do not agree: a `limit` or `sl` order needs a price, an `sl` or `sl-m` order needs a trigger price, and a `market` or `sl-m` order must carry no price at all. A `price_reference` stands in for the price and a `quantity_reference` for the quantity.
    #'
    #' An outcome of `accepted` means the broker took the order, not that the order survived. The exchange can still refuse it afterwards, which is what happens to an ordinary order sent while the market is closed, so the order's real fate is read from `orders` rather than from this answer. Neither this class nor UBI checks the market's hours, so use `after_market` to queue an order for the next session.
    #'
    #' Every order goes through UBI's order engine, which is the only way UBI places orders. A plain `limit` order with a price of its own, `day` validity, no `synthetic` object and `after_market` `FALSE` is not sent to a broker straight away: the engine holds it as a `virtual_limit` order and sends it only once the other side of the book reaches its price, answering HTTP 202 with an outcome of `armed`, a `parent_id` and no `order_id`. Such a held order is changed with `modify_order(parent_id = ...)` and cancelled with `cancel_parent()`, and it never appears in `orders` until it has been sent. Pass `synthetic = list(type = "simple")` to send a limit order at once, which matters for an instrument that has no live quote, because the engine would hold its order for the whole day without ever sending it.
    #'
    #' A plain `market` order with no `synthetic` object and `after_market` `FALSE` is not sent as a market order either. The engine runs it as a `marketable_limit` order: a `limit` two ticks past the other side's best price, moved after that price until it fills, with whatever is left cancelled 30 seconds after it was placed. Such an order is refused with HTTP 409, and nothing is sent, when nobody is on the other side of the book, no live quote has arrived or the quote is marked stale. Pass `synthetic = list(type = "simple")` to send a real market order, which an instrument with no live quote needs.
    #'
    #' The examples below, in order:
    #'
    #' * Have UBI build a limit buy for one Vodafone Idea share without sending it, and print the request it would send.
    #' * Place a plain limit buy 3 per cent below the market, which the order engine holds until a seller reaches the price, and cancel it.
    #' * Describe the price rather than state it, here the third best bid, and see the price UBI works out in a dry run.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`. UBI overrides it for a quantity reference that reduces or closes a position.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param price The numeric limit price in rupees, or `NULL` for an order type that takes no price or when a price reference supplies it.
    #' @param trigger_price The numeric trigger price in rupees, or `NULL` for an order type that takes no trigger.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param disclosed_quantity The integer quantity to show on the exchange, or `NULL` to disclose the whole order.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @param dry_run A logical that is `TRUE` to have UBI build the broker's request and return it without sending it.
    #' @param price_reference A named list that describes the price instead of stating it, such as `list(kind = "offer_level", level = 2)`, which UBI resolves from the live quote and rounds to the tick, or `NULL`. Its `kind` is `absolute`, `bid_level`, `offer_level`, `mid`, `vwap`, `last` or `marketable`, and it may carry `price`, `level`, `buffer_percent`, `offset_percent` and `offset_ticks`.
    #' @param quantity_reference A named list that describes the quantity instead of stating it, such as `list(kind = "liquidate_position", product = "intraday")`, which UBI resolves from the positions, or `NULL`. Its `kind` is `add_to_position`, `reduce_position` or `liquidate_position`, and its optional `product` is spelled the positions' way.
    #' @param synthetic A named list that makes the order one of UBI's synthetic order types, such as `list(type = "bracket", stop_price = 990, stop_limit_price = 988, target_price = 1010)`, or `NULL` for a plain order. The synthetic order classes, such as `BracketOrder`, build it.
    #' @return A named list with `broker`, `instrument_id`, `order_id`, `outcome`, `status_message`, `broker_response`, `skipped`, `timing_ms` and `intent_id`, and `parent_id` for an order the engine recorded, or, for a dry run, a named list with `dry_run` and the `request` UBI would have sent. The `order_id` is `NULL` unless the outcome is `accepted`. A held limit order, and a synthetic order that is waiting for a price or a time, answers with an outcome of `armed` and a `broker` and `order_id` of `NULL`. The types that send several orders at once add a `legs` list, one entry per order with its plan `path`, `instrument_id`, `outcome`, `order_id` and `status_message`, and their `outcome` is `partial` when some of those orders were accepted and some were not.
    #' @details Errors: signals `BadRequestError` when a field is invalid, the price fields do not fit the order type, or a synthetic order's own fields are wrong; `LossLockoutError` when the day's loss is past UBI's daily loss limit; `NotFoundError` when no broker has a mapping for this instrument; `ConflictError` when a quantity reference asked to reduce or close a position that is not held, a market order sent as a marketable limit found nobody on the other side of the book or no fresh quote, a reduce-only order would not reduce the position, or the engine read the order too late or had already started it before a restart; `OrderRejectedError` when the broker refused the order, and the detail holds its answer; `RateLimitError` when the broker's daily order cap has no room for this order; `ServiceUnavailableError` when no broker could take the order, the order engine is not running, or a price reference could not be resolved; `OrderOutcomeUnknownError` when the order was sent but its outcome is unknown, so read the order book, or `Account$intent()` with the detail's `intent_id`, before sending it again; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #'
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$place_order(
    #'   transaction_type = "buy",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   product = "cnc",
    #'   price = price,
    #'   dry_run = TRUE
    #' )
    #' print(answer)
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #'
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$place_order(
    #'   transaction_type = "buy",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   product = "cnc",
    #'   price = price
    #' )
    #' tryCatch(
    #'   {
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["parent_id"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'   },
    #'   finally = {
    #'     print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #'
    #' answer <- idea$place_order(
    #'   transaction_type = "buy",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   product = "mis",
    #'   price_reference = list(
    #'     kind = "bid_level",
    #'     level = 3
    #'   ),
    #'   dry_run = TRUE
    #' )
    #' print(answer)
    #' }
    place_order = function(
      transaction_type,
      order_type,
      quantity,
      product,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      dry_run = FALSE,
      price_reference = NULL,
      quantity_reference = NULL,
      synthetic = NULL
    ) {
      body <- list(
        instrument_id = self$instrument_id,
        transaction_type = transaction_type,
        order_type = order_type,
        product = product,
        after_market = after_market,
        dry_run = dry_run
      )
      optional_fields <- list(
        quantity = quantity,
        price = price,
        trigger_price = trigger_price,
        validity = validity,
        disclosed_quantity = disclosed_quantity,
        tag = tag,
        price_reference = price_reference,
        quantity_reference = quantity_reference,
        synthetic = synthetic
      )
      for (field in names(optional_fields)) {
        body[[field]] <- optional_fields[[field]]
      }
      private$unified_broker_interface$post(
        INSTRUMENTS_ORDER_PLACE_PATH,
        body = body
      )
    },

    #' @description
    #' Changes one pending order through UBI.
    #'
    #' UBI finds the order by its id in the brokers' order books, so this does not check that the order belongs to this instrument. Give at least one field to change; every field left as `NULL` keeps the value the order already has.
    #'
    #' Those order books are copies that UBI's own collectors refresh every few seconds, so an order placed a moment ago is not in them yet and signals `NotFoundError`. Wait for the order to appear in `orders` before changing it.
    #'
    #' An order that is a leg of one of UBI's synthetic orders is handed to the engine, which lets the order type carry on from the change, so a trailing stop trails from the new trigger. Only its `price`, `trigger_price` and `quantity` can change, and anything else signals `ConflictError`.
    #'
    #' An order the engine is still holding, such as a plain limit order waiting for the other side to reach its price, has no broker order id yet. Name it by the `parent_id` that `place_order()` answered with instead of `order_id`; only its `price` and `quantity` can change, and nothing is sent to a broker.
    #'
    #' A part of a `plan` order that has not sent anything yet, such as a bracket's stop before the entry fills, is named by the plan's `parent_id` and the part's path in `part`, such as `"root.each_fill.children.0"`, as the parent's `parameters.parts` lists it. Its `price`, `trigger_price` and `quantity` can change, and it keeps the new values until its turn comes, without anything being sent to a broker. Only a part with a fixed price, a plain limit or a native stop, takes a price, and only a stop takes a trigger price.
    #'
    #' The examples below, in order:
    #'
    #' * Lower the price of a held limit buy from 3 to 4 per cent below the market, naming it by its parent id, then cancel it.
    #' * Send a limit buy 3 per cent below the market to the broker at once, wait for it to reach the order book, lower its price by a tick, and cancel it.
    #' @param order_id The character id the broker gave the order, as `place_order()` returned it, or `NULL` when naming a held order by `parent_id`.
    #' @param quantity The integer new total quantity in underlying units, counting what is already filled, or `NULL` to leave it.
    #' @param price The numeric new limit price in rupees, or `NULL` to leave it.
    #' @param trigger_price The numeric new trigger price in rupees, or `NULL` to leave it.
    #' @param order_type The character new kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`, or `NULL` to leave it.
    #' @param validity The character new validity, `"day"` or `"ioc"`, or `NULL` to leave it.
    #' @param disclosed_quantity The integer new quantity to show on the exchange, or `NULL` to leave it.
    #' @param broker The character name of the broker holding the order, which is needed only after a `ConflictError` reporting that two brokers share the id, or `NULL`.
    #' @param dry_run A logical that is `TRUE` to have UBI build the broker's request and return it without sending it.
    #' @param parent_id The character id of an order the engine is still holding, or of the plan that holds `part`, as `place_order()` returned it, or `NULL` when naming a broker order by `order_id`.
    #' @param part The character path of a part of a plan that has not been sent, such as `"root.each_fill.children.0"`, given with `parent_id`, or `NULL`.
    #' @return A named list with `broker`, `order_id`, `instrument_id`, `status_before_modify`, `outcome`, `status_message`, `broker_response` and `timing_ms`, and `parent_id` and `synthetic_type` for a leg of a synthetic order, or, for a dry run, a named list with `dry_run` and the `request` UBI would have sent. A held order answers with `parent_id`, `synthetic_type`, `held` set to `TRUE`, the new `price` and `quantity`, and an `outcome` of `accepted`. A part of a plan answers with `parent_id`, `synthetic_type`, `part`, its `state`, the new `price`, `trigger_price` and `quantity`, and an `outcome` of `accepted`.
    #' @details Errors: signals `BadRequestError` when no field was given to change, a field is invalid or is one this broker cannot change, or a plan part works its price out from the market or is not a stop and was given a price or trigger price it cannot take; `NotFoundError` when no broker's order book holds this order id, the engine holds no parent with this parent id, or the plan has no part at this path; `ConflictError` when the order is already complete, cancelled, rejected or expired, two brokers hold the id and the detail lists them under `brokers`, a leg of a synthetic order was asked to change a field other than its price, trigger price or quantity, a held order or plan part has already been sent, when the detail names its `broker` and `order_id`, or a plan part is sized by an earlier part's fills, is kept whole, or closes a position and was asked to grow; `OrderRejectedError` when the broker refused the change, and the detail holds its answer; `ServiceUnavailableError` when the broker's order rate budget was full, so the change was not sent; `OrderOutcomeUnknownError` when the change was sent but its outcome is unknown; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' tryCatch(
    #'   {
    #'     new_price <- round(idea$last_price * 0.96, 2)
    #'     changed <- idea$modify_order(parent_id = parent_id, price = new_price)
    #'     cat(changed[["outcome"]], changed[["price"]], changed[["held"]], "\n")
    #'   },
    #'   finally = {
    #'     print(idea$cancel_parent(parent_id)[["state"]])
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 0.97, 2)
    #'     answer <- idea$buy_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     changed <- idea$modify_order(
    #'       order_id = order_id,
    #'       price = round(price - 0.01, 2)
    #'     )
    #'     cat(changed[["broker"]], changed[["outcome"]], "\n")
    #'     print(idea$cancel_order(order_id)[["outcome"]])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    modify_order = function(
      order_id = NULL,
      quantity = NULL,
      price = NULL,
      trigger_price = NULL,
      order_type = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      broker = NULL,
      dry_run = FALSE,
      parent_id = NULL,
      part = NULL
    ) {
      body <- list(
        dry_run = dry_run
      )
      changeable_fields <- list(
        order_id = order_id,
        parent_id = parent_id,
        part = part,
        quantity = quantity,
        price = price,
        trigger_price = trigger_price,
        order_type = order_type,
        validity = validity,
        disclosed_quantity = disclosed_quantity,
        broker = broker
      )
      for (field in names(changeable_fields)) {
        body[[field]] <- changeable_fields[[field]]
      }
      private$unified_broker_interface$put(
        INSTRUMENTS_ORDER_MODIFY_PATH,
        body = body
      )
    },

    #' @description
    #' Cancels one pending order through UBI.
    #'
    #' UBI finds the order by its id in the brokers' order books, so this does not check that the order belongs to this instrument.
    #'
    #' Those order books are copies that UBI's own collectors refresh every few seconds, so an order placed a moment ago is not in them yet and signals `NotFoundError`. Wait for the order to appear in `orders` before cancelling it.
    #'
    #' An order that is a leg of one of UBI's synthetic orders is cancelled through the engine, so the order type knows about it, but the synthetic order itself carries on. Use `cancel_parent()` to stop a synthetic order, or to cancel an order the engine is still holding, which has no broker order id.
    #'
    #' The examples below, in order:
    #'
    #' * Send a limit buy 3 per cent below the market to the broker at once, wait for it to reach the order book, and cancel it.
    #' * Look at the cancel request UBI would send in a dry run first, then cancel a resting sell 3 per cent above the market for real.
    #' @param order_id The character id the broker gave the order, as `place_order()` returned it.
    #' @param broker The character name of the broker holding the order, which is needed only after a `ConflictError` reporting that two brokers share the id, or `NULL`.
    #' @param dry_run A logical that is `TRUE` to have UBI build the broker's request and return it without sending it.
    #' @return A named list with `broker`, `order_id`, `status_before_cancel`, `outcome`, `status_message`, `broker_response` and `timing_ms`, and `parent_id` and `synthetic_type` for a leg of a synthetic order, or, for a dry run, a named list with `dry_run` and the `request` UBI would have sent.
    #' @details Errors: signals `BadRequestError` when the order id, broker or dry run flag is malformed; `NotFoundError` when no broker's order book holds this order id; `ConflictError` when the order is already complete, cancelled, rejected or expired, or two brokers hold the id and the detail lists them under `brokers`; `OrderRejectedError` when the broker refused the cancellation, and the detail holds its answer; `ServiceUnavailableError` when the broker's order rate budget was full, so the cancellation was not sent; `OrderOutcomeUnknownError` when the cancellation was sent but its outcome is unknown; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 0.97, 2)
    #'     answer <- idea$buy_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     cancelled <- idea$cancel_order(order_id)
    #'     cat(cancelled[["broker"]], cancelled[["outcome"]], "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 1.03, 2)
    #'     answer <- idea$sell_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     print(idea$cancel_order(order_id, dry_run = TRUE))
    #'     print(idea$cancel_order(order_id)[["outcome"]])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    cancel_order = function(order_id, broker = NULL, dry_run = FALSE) {
      body <- list(
        order_id = order_id,
        dry_run = dry_run
      )
      body[["broker"]] <- broker
      private$unified_broker_interface$delete(
        INSTRUMENTS_ORDER_CANCEL_PATH,
        body = body
      )
    },

    #' @description
    #' Cancels every order in this instrument that is still waiting, whether at a broker or held in UBI's order engine.
    #'
    #' The engine's open parents in this instrument are cancelled first, each with the orders it has resting at a broker, because a synthetic order left running could place a new order after its old ones were cancelled. Then every open order in the order book that did not belong to one of those parents is cancelled in one request. Every order and parent is attempted even when an earlier one fails, and a failure is reported in the returned frame rather than signalled, so one order that can no longer be cancelled does not leave the rest of them open.
    #'
    #' The examples below, in order:
    #'
    #' * Place a held limit buy and a limit buy sent to the broker, then cancel everything still waiting in Vodafone Idea in one call.
    #' * Place two held limit orders on either side of the market, cancel them together, and check that no parent is left open.
    #' @return A `data.frame` with one row per parent or order, holding `parent_id`, `order_id`, `broker`, `cancelled` and `error`, where `parent_id` is `NA` for an order cancelled on its own, `order_id` and `broker` are `NA` for a parent, and `error` is `NA` for a cancel that was accepted and the status and message of the failure otherwise, or `NULL` when nothing in this instrument is waiting.
    #' @details Errors: signals `BrokerError` when no broker's order book could be read; `ServiceUnavailableError` when UBI's order book document is missing or too old to serve, or UBI's parents could not be read; and another `UnifiedBrokerInterfaceError` subclass when the order book or the parents could not be read for any other reason, or the list of cancels was refused whole. A failure to cancel one order or parent is reported in the frame instead.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     held <- idea$buy_at_limit_price(
    #'       price = round(idea$last_price * 0.97, 2),
    #'       quantity = 1,
    #'       product = "cnc"
    #'     )
    #'     answers[[length(answers) + 1]] <- held
    #'     price <- round(idea$last_price * 0.96, 2)
    #'     answer <- idea$buy_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     outcomes <- idea$cancel_open_orders()
    #'     print(outcomes[, c(
    #'       "parent_id",
    #'       "order_id",
    #'       "cancelled",
    #'       "error"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #'
    #' last_price <- idea$last_price
    #' idea$buy_at_limit_price(
    #'   price = round(last_price * 0.97, 2),
    #'   quantity = 1,
    #'   product = "mis"
    #' )
    #' idea$sell_at_limit_price(
    #'   price = round(last_price * 1.03, 2),
    #'   quantity = 1,
    #'   product = "mis"
    #' )
    #' outcomes <- idea$cancel_open_orders()
    #' cat(nrow(outcomes), "cancelled:", outcomes$cancelled, "\n")
    #' cat("Open parents left:", "\n")
    #' print(idea$parents)
    #' }
    cancel_open_orders = function() {
      outcomes <- list()
      cancelled_parent_ids <- character(0)
      open_parents <- self$parents
      if (!is.null(open_parents)) {
        for (parent_id in open_parents$parent_order_id) {
          result <- private$cancel_one_parent(parent_id)
          if (result$engine_answered) {
            cancelled_parent_ids <- c(
              cancelled_parent_ids,
              parent_id
            )
          }
          outcomes[[length(outcomes) + 1]] <- result$outcome
        }
      }
      open_orders <- self$open_orders
      if (!is.null(open_orders)) {
        orders_to_cancel <- list()
        builder <- FrameBuilder$new()
        for (row in builder$rows(open_orders)) {
          engine_parent_id <- row[["engine_parent_id"]]
          belongs_to_cancelled_parent <- !is.null(engine_parent_id) &&
            !is.na(engine_parent_id) &&
            engine_parent_id %in% cancelled_parent_ids
          if (belongs_to_cancelled_parent) {
            next
          }
          orders_to_cancel[[length(orders_to_cancel) + 1]] <- list(
            order_id = row[["order_id"]],
            broker = row[["broker"]]
          )
        }
        for (outcome in private$cancel_order_list(orders_to_cancel)) {
          outcomes[[length(outcomes) + 1]] <- outcome
        }
      }
      if (length(outcomes) == 0) {
        return(NULL)
      }
      FrameBuilder$new()$frame(outcomes)
    },

    #' @description
    #' Reads one of the order engine's parents, whether or not it has finished.
    #'
    #' UBI finds the parent by its id alone, so this does not check that it belongs to this instrument.
    #'
    #' The examples below, in order:
    #'
    #' * Read a held limit buy back from the order engine, then cancel it.
    #' * Read a parent again after cancelling it, which works because the engine keeps finished parents too.
    #' @param parent_id The character `parent_id` that `place_order()` answered with.
    #' @return A named list holding the parent as the engine keeps it, with `parent_order_id`, `synthetic_type`, `state`, `instrument_id`, the caller's `body`, the type's `parameters` and one entry per leg under `legs`.
    #' @details Errors: signals `NotFoundError` when the order engine holds no parent with this id; `ServiceUnavailableError` when UBI's parents could not be read; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' tryCatch(
    #'   {
    #'     held <- idea$parent(parent_id)
    #'     cat(held[["synthetic_type"]], held[["state"]], "\n")
    #'     print(held[["body"]])
    #'   },
    #'   finally = {
    #'     idea$cancel_parent(parent_id)
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' idea$cancel_parent(parent_id)
    #' print(idea$parent(parent_id)[["state"]])
    #' }
    parent = function(parent_id) {
      private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_PARENTS_PATH,
        params = list(
          parent_id = parent_id
        )
      )
    },

    #' @description
    #' Cancels one of the order engine's parents, with every leg it still has resting at a broker, or one part of a plan.
    #'
    #' This is how a synthetic order is stopped and how an order the engine is still holding is cancelled. A position the parent has already opened is not closed.
    #'
    #' With `part`, only that part of a `plan` order is cancelled, named by its path, such as `"root.each_fill.children.0"` for a bracket's stop, as the parent's `parameters.parts` lists it. A part whose turn has not come is never sent, a part waiting on its trigger is ended at once, and a part that has sent orders sends no more pieces and has each of its resting orders cancelled; the rest of the plan carries on, reacting as it does to that part finishing.
    #'
    #' When a broker refuses the cancel of one leg, or its outcome is unknown, UBI answers HTTP 207, which is returned rather than signalled, with the parent's `state` as `cancelling` rather than `cancelled`. The parent no longer acts, and becomes `cancelled` once the broker reports that leg finished, so read `cancelled_legs` to see which one may still be live, and call this again to retry it.
    #'
    #' The examples below, in order:
    #'
    #' * Cancel a held limit buy and print the cancelled parent's state and legs.
    #' * Show that a parent that has already finished cannot be cancelled a second time.
    #' @param parent_id The character `parent_id` that `place_order()` answered with.
    #' @param part The character path of one part of a plan to cancel, or `NULL` to cancel the whole parent.
    #' @param dry_run A logical that is `TRUE` to have UBI say what would be cancelled, under `resting_legs` for a whole parent or `orders` for a part, without cancelling anything.
    #' @return A named list with `parent_id`, `synthetic_type`, `state`, `intent_id` and `cancelled_legs`, one entry per leg with its `leg_id`, `broker`, `order_id`, `outcome` and `status_message`. A part answers instead with `parent_id`, `synthetic_type`, `part`, its `state`, `outcome`, `status_message`, `intent_id` and `orders`, where each order says in `cancel_accepted` whether its broker accepted the cancel, and HTTP 207 with an `outcome` of `partial` or `rejected` is returned rather than signalled.
    #' @details Errors: signals `BadRequestError` when the parent id or part path is malformed; `NotFoundError` when the order engine holds no parent with this id, or the plan has no part at this path; `ConflictError` when the parent or part has already finished, or the part is kept whole and has not started, or the parent is not a plan and was given a part; `ServiceUnavailableError` when the order engine is not running; `OrderOutcomeUnknownError` when the engine did not answer in time; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' cancelled <- idea$cancel_parent(parent_id)
    #' cat(cancelled[["state"]], cancelled[["synthetic_type"]], "\n")
    #' print(cancelled[["cancelled_legs"]])
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' idea$cancel_parent(parent_id)
    #' tryCatch(
    #'   idea$cancel_parent(parent_id),
    #'   ConflictError = function(error) {
    #'     cat("Refused:", conditionMessage(error), "\n")
    #'   }
    #' )
    #' }
    cancel_parent = function(parent_id, part = NULL, dry_run = FALSE) {
      body <- list(
        parent_id = parent_id,
        dry_run = dry_run
      )
      body[["part"]] <- part
      private$unified_broker_interface$delete(
        INSTRUMENTS_ORDER_CANCEL_PATH,
        body = body
      )
    },

    #' @description
    #' Today's broker orders that one of the order engine's parents placed.
    #'
    #' The examples below, in order:
    #'
    #' * Show that a held limit buy has placed no broker order yet, then cancel it.
    #' * Send a limit buy to the broker at once and list the broker order its parent placed, then cancel it.
    #' @param parent_id The character `parent_id` that `place_order()` answered with.
    #' @return A `data.frame` shaped like `orders`, whose `leg_role` column says what each order was to the parent, such as `entry`, `stop` or `target`, or `NULL` when the parent has placed nothing that the order book shows yet.
    #' @details Errors: signals `BrokerError` when no broker's order book could be read; `ServiceUnavailableError` when UBI's order book document is missing or too old to serve; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' tryCatch(
    #'   print(idea$parent_orders(parent_id)),
    #'   finally = {
    #'     idea$cancel_parent(parent_id)
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 0.97, 2)
    #'     answer <- idea$buy_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     legs <- idea$parent_orders(answer[["parent_id"]])
    #'     print(legs[, c(
    #'       "order_id",
    #'       "leg_role",
    #'       "status",
    #'       "price"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    parent_orders = function(parent_id) {
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_DETAILS_PATH,
        params = list(
          parent_id = parent_id
        )
      )[["orders"]]
      FrameBuilder$new()$frame(rows)
    },

    #' @description
    #' Today's trades in the broker orders that one of the order engine's parents placed.
    #'
    #' The examples below, in order:
    #'
    #' * Show that a held limit buy has no trades, then cancel it.
    #' * Buy one Vodafone Idea share at once with a marketable limit as an intraday order, list the trades its parent made, which is `NULL` until the broker's trade book links them to the parent, and close the position again.
    #' @param parent_id The character `parent_id` that `place_order()` answered with.
    #' @return A `data.frame` shaped like `trades`, or `NULL` when none of the parent's orders has traded.
    #' @details Errors: signals `BrokerError` when no broker's trade book could be read; `ServiceUnavailableError` when UBI's trade book document is missing or too old to serve; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' tryCatch(
    #'   print(idea$parent_trades(parent_id)),
    #'   finally = {
    #'     idea$cancel_parent(parent_id)
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     bought <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- bought
    #'     Sys.sleep(3)
    #'     print(idea$parent_trades(bought[["parent_id"]]))
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    parent_trades = function(parent_id) {
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_TRADES_PATH,
        params = list(
          parent_id = parent_id
        )
      )[["trades"]]
      FrameBuilder$new()$frame(rows)
    },

    #' @description
    #' Buys at whatever price the market is asking.
    #'
    #' A market order takes the best price on offer and fills straight away while the market is open. The price is therefore not known before the order is sent, and in a thin book it can be a good deal worse than the last traded price.
    #'
    #' UBI's order engine does not send this to a broker as a market order. It sends a `limit` two ticks past the best offer, moves it after that price on every tick until it fills, and cancels whatever has not filled 30 seconds after it was placed, so the order cannot fill far from the price that was showing. UBI refuses the order with HTTP 409, and sends nothing, when nobody is offering, no live quote has arrived or the quote is marked stale. An after-market order is always sent as a market order. Pass `as_marketable_limit = FALSE` to send a real market order at once, which an instrument with no live quote needs, and use `tradingmachine.orders.marketable_limit.MarketableLimitOrder` to choose a different buffer or time. Some brokers refuse a market order sent through an API outright: on 2026-10-06 Flattrade answered `ALGO_CHK: MKT Order type not allowed for API order`, which raises `OrderRejectedError`.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at the market as an intraday order, print the price it filled at, and close it again through `reduce_position()`, which UBI routes against the broker holding the position, until the position is back where it started.
    #' * Do the same round trip with a tag on the buy, so the order can be picked out of the order book later.
    #' * Try the same round trip with a real market order, which UBI sends to the broker at once rather than as a limit following the book, and report the broker's refusal when it does not accept market orders from an API.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param as_marketable_limit A logical that is `TRUE` to let UBI's order engine send the order as a limit that follows the other side of the book for up to 30 seconds, and `FALSE` to send a market order to a broker at once.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `BadRequestError` when a field is invalid; `ConflictError` when the order was to be sent as a marketable limit and could not be priced, because nobody is offering, no live quote has arrived or the quote is marked stale; `OrderRejectedError` when the broker refused the order, which some brokers do for every real market order sent through an API; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opening <- idea$buy_at_market_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- opening
    #'     cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "filled_quantity",
    #'       "average_price"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opening <- idea$buy_at_market_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- opening
    #'     cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "filled_quantity",
    #'       "average_price"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     caught_error <- tryCatch(
    #'       {
    #'         opening <- idea$buy_at_market_price(
    #'           quantity = 1,
    #'           product = "mis",
    #'           as_marketable_limit = FALSE
    #'         )
    #'         NULL
    #'       },
    #'       OrderRejectedError = function(error) error
    #'     )
    #'     if (inherits(caught_error, "OrderRejectedError")) {
    #'       error <- caught_error
    #'       cat(
    #'         "The broker refused a real market order:",
    #'         conditionMessage(error),
    #'         "\n"
    #'       )
    #'       opening <- NULL
    #'     }
    #'     if (!is.null(opening)) {
    #'       answers[[length(answers) + 1]] <- opening
    #'       cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'       Sys.sleep(3)
    #'       orders <- idea$orders
    #'       mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'       print(mine[, c(
    #'         "status",
    #'         "filled_quantity",
    #'         "average_price"
    #'       )])
    #'     }
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_market_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      as_marketable_limit = TRUE
    ) {
      synthetic <- NULL
      if (!as_marketable_limit) {
        synthetic <- list(
          type = "simple"
        )
      }
      self$place_order(
        transaction_type = "buy",
        order_type = "market",
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag,
        synthetic = synthetic
      )
    },

    #' @description
    #' Sells at whatever price the market is bidding.
    #'
    #' A market order takes the best price being bid and fills straight away while the market is open. The price is therefore not known before the order is sent, and in a thin book it can be a good deal worse than the last traded price.
    #'
    #' UBI's order engine does not send this to a broker as a market order. It sends a `limit` two ticks past the best bid, moves it after that price on every tick until it fills, and cancels whatever has not filled 30 seconds after it was placed, so the order cannot fill far from the price that was showing. UBI refuses the order with HTTP 409, and sends nothing, when nobody is bidding, no live quote has arrived or the quote is marked stale. An after-market order is always sent as a market order. Pass `as_marketable_limit = FALSE` to send a real market order at once, which an instrument with no live quote needs, and use `tradingmachine.orders.marketable_limit.MarketableLimitOrder` to choose a different buffer or time. Some brokers refuse a market order sent through an API outright: on 2026-10-06 Flattrade answered `ALGO_CHK: MKT Order type not allowed for API order`, which raises `OrderRejectedError`.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at the market as an intraday order, print the price it filled at, and buy it back through `reduce_position()` until the position is back where it started.
    #' * Do the same round trip with a tag on the sale.
    #' * Try the same round trip with a real market order, which UBI sends to the broker at once rather than as a limit following the book, and report the broker's refusal when it does not accept market orders from an API.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param as_marketable_limit A logical that is `TRUE` to let UBI's order engine send the order as a limit that follows the other side of the book for up to 30 seconds, and `FALSE` to send a market order to a broker at once.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `BadRequestError` when a field is invalid; `ConflictError` when the order was to be sent as a marketable limit and could not be priced, because nobody is bidding, no live quote has arrived or the quote is marked stale; `OrderRejectedError` when the broker refused the order, which some brokers do for every real market order sent through an API; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opening <- idea$sell_at_market_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- opening
    #'     cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "filled_quantity",
    #'       "average_price"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opening <- idea$sell_at_market_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- opening
    #'     cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "filled_quantity",
    #'       "average_price"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     caught_error <- tryCatch(
    #'       {
    #'         opening <- idea$sell_at_market_price(
    #'           quantity = 1,
    #'           product = "mis",
    #'           as_marketable_limit = FALSE
    #'         )
    #'         NULL
    #'       },
    #'       OrderRejectedError = function(error) error
    #'     )
    #'     if (inherits(caught_error, "OrderRejectedError")) {
    #'       error <- caught_error
    #'       cat(
    #'         "The broker refused a real market order:",
    #'         conditionMessage(error),
    #'         "\n"
    #'       )
    #'       opening <- NULL
    #'     }
    #'     if (!is.null(opening)) {
    #'       answers[[length(answers) + 1]] <- opening
    #'       cat("Opened:", opening[["outcome"]], opening[["broker"]], "\n")
    #'       Sys.sleep(3)
    #'       orders <- idea$orders
    #'       mine <- orders[orders$order_id == opening[["order_id"]], , drop = FALSE]
    #'       print(mine[, c(
    #'         "status",
    #'         "filled_quantity",
    #'         "average_price"
    #'       )])
    #'     }
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_market_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      as_marketable_limit = TRUE
    ) {
      synthetic <- NULL
      if (!as_marketable_limit) {
        synthetic <- list(
          type = "simple"
        )
      }
      self$place_order(
        transaction_type = "sell",
        order_type = "market",
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag,
        synthetic = synthetic
      )
    },

    #' @description
    #' Buys at a price of your choosing, or better.
    #'
    #' A limit buy never pays more than the price given. It waits in the market until someone sells at that price or lower, and it may never fill at all.
    #'
    #' UBI's order engine holds a `day` limit order that is not an after-market order rather than resting it at a broker, and sends it only once the other side of the book reaches the price, so an order that never fills costs no order messages. Until then `place_order` answers with an outcome of `armed` and a `parent_id` rather than an `order_id`, the order is not in `orders` but in `parents`, and it is changed with `modify_order(parent_id = ...)` and cancelled with `cancel_parent`.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share 3 per cent below the market, which the order engine holds until a seller reaches the price, and cancel it.
    #' * Send the bid to the broker at once instead of letting the engine hold it, wait for it to rest in the order book, and cancel it.
    #' @param price The numeric limit price in rupees.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param hold A logical that is `TRUE` to let UBI's order engine hold a `day` order until the other side of the book reaches the price, and `FALSE` to send it to a broker at once. An after-market order is always sent at once, whatever this says. Pass `FALSE` for an instrument with no live quote, whose order the engine would otherwise hold all day without sending.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(price = price, quantity = 1, product = "cnc")
    #' parent_id <- answer[["parent_id"]]
    #'
    #' tryCatch(
    #'   cat(answer[["outcome"]], "at", price, "as parent", parent_id, "\n"),
    #'   finally = {
    #'     print(idea$cancel_parent(parent_id)[["state"]])
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 0.97, 2)
    #'     answer <- idea$buy_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], answer[["broker"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     print(idea$cancel_order(order_id)[["outcome"]])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_limit_price = function(
      price,
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      hold = TRUE
    ) {
      synthetic <- NULL
      if (!hold) {
        synthetic <- list(
          type = "simple"
        )
      }
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price = price,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag,
        synthetic = synthetic
      )
    },

    #' @description
    #' Sells at a price of your choosing, or better.
    #'
    #' A limit sell never accepts less than the price given. It waits in the market until someone buys at that price or higher, and it may never fill at all.
    #'
    #' UBI's order engine holds a `day` limit order that is not an after-market order rather than resting it at a broker, and sends it only once the other side of the book reaches the price, so an order that never fills costs no order messages. Until then `place_order` answers with an outcome of `armed` and a `parent_id` rather than an `order_id`, the order is not in `orders` but in `parents`, and it is changed with `modify_order(parent_id = ...)` and cancelled with `cancel_parent`.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share 3 per cent above the market as an intraday order, which the order engine holds until a buyer reaches the price, and cancel it.
    #' * Send the offer to the broker at once with a tag, wait for it to rest in the order book, and cancel it.
    #' @param price The numeric limit price in rupees.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param hold A logical that is `TRUE` to let UBI's order engine hold a `day` order until the other side of the book reaches the price, and `FALSE` to send it to a broker at once. An after-market order is always sent at once, whatever this says. Pass `FALSE` for an instrument with no live quote, whose order the engine would otherwise hold all day without sending.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #'
    #' price <- round(idea$last_price * 1.03, 2)
    #' answer <- idea$sell_at_limit_price(price = price, quantity = 1, product = "mis")
    #' tryCatch(
    #'   {
    #'     cat(
    #'       answer[["outcome"]],
    #'       "at",
    #'       price,
    #'       "as parent",
    #'       answer[["parent_id"]],
    #'       "\n"
    #'     )
    #'   },
    #'   finally = {
    #'     print(idea$cancel_parent(answer[["parent_id"]])[["state"]])
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     price <- round(idea$last_price * 1.03, 2)
    #'     answer <- idea$sell_at_limit_price(
    #'       price = price,
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples",
    #'       hold = FALSE
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     order_id <- answer[["order_id"]]
    #'     cat(answer[["outcome"]], order_id, "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       open_orders <- idea$open_orders
    #'       if (!is.null(open_orders)) {
    #'         if (order_id %in% open_orders$order_id) {
    #'           break
    #'         }
    #'       }
    #'     }
    #'     print(idea$cancel_order(order_id)[["outcome"]])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_limit_price = function(
      price,
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      hold = TRUE
    ) {
      synthetic <- NULL
      if (!hold) {
        synthetic <- list(
          type = "simple"
        )
      }
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price = price,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag,
        synthetic = synthetic
      )
    },

    #' @description
    #' Buys patiently, joining the queue at the highest price anyone is bidding.
    #'
    #' This is the patient side of the pair. It prices the order alongside everyone already waiting at the best price on its own side of the book, so it saves the spread but only fills when the market comes to it.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the best bid as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the best bid as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 1
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at once, by crossing the spread to the lowest price anyone is offering.
    #'
    #' This is the aggressive side of the pair. It prices the order where the other side of the market already is, so it fills immediately against whoever is waiting there, and it pays the spread for that certainty.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Buy one share with a limit at the best offer as an ordinary day order with a tag, cancel it if it is still resting, and sell back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 1
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells patiently, joining the queue at the lowest price anyone is offering.
    #'
    #' This is the patient side of the pair. It prices the order alongside everyone already waiting at the best price on its own side of the book, so it saves the spread but only fills when the market comes to it.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the best offer as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the best offer with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 1
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at once, by crossing the spread to the highest price anyone is bidding.
    #'
    #' This is the aggressive side of the pair. It prices the order where the other side of the market already is, so it fills immediately against whoever is waiting there, and it pays the spread for that certainty.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Sell one share short with a limit at the best bid as an ordinary day order with a tag, cancel it if it is still resting, and buy back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 1
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys halfway between the best bid and the best offer.
    #'
    #' The mid price sits inside the spread, where nobody is waiting, so the order is better than joining its own side of the book and cheaper than crossing to the other. It fills only if the market moves that far. UBI works the midpoint out when it sends the order and rounds it to the tick, down for a buy and up for a sell, so the order never crosses the spread.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the mid price as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the mid price as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_mid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_mid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_mid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "mid"
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells halfway between the best bid and the best offer.
    #'
    #' The mid price sits inside the spread, where nobody is waiting, so the order is better than joining its own side of the book and cheaper than crossing to the other. It fills only if the market moves that far. UBI works the midpoint out when it sends the order and rounds it to the tick, down for a buy and up for a sell, so the order never crosses the spread.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the mid price as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the mid price with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_mid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_mid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_mid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "mid"
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the average price the day has traded at so far.
    #'
    #' The volume weighted average price is where the day's business has actually been done, which makes it a common benchmark to measure a fill against. It has no relation to where the book is now, so the order may cross the spread or sit far away from it. Not every broker reports it. UBI reads it when it sends the order and rounds it to the tick.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at today's volume weighted average price as an intraday order, which may fill or rest, then cancel whatever rests and sell back whatever filled.
    #' * Send the same bid at today's volume weighted average price as an immediate-or-cancel order, so nothing is left resting, and sell back anything that filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_volume_weighted_average_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_volume_weighted_average_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_volume_weighted_average_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "vwap"
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the average price the day has traded at so far.
    #'
    #' The volume weighted average price is where the day's business has actually been done, which makes it a common benchmark to measure a fill against. It has no relation to where the book is now, so the order may cross the spread or sit far away from it. Not every broker reports it. UBI reads it when it sends the order and rounds it to the tick.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share short at today's volume weighted average price as an intraday order, which may fill or rest, then cancel whatever rests and buy back whatever sold.
    #' * Send the same offer at today's volume weighted average price as an immediate-or-cancel order, so nothing is left resting, and buy back anything that sold.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_volume_weighted_average_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_volume_weighted_average_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_volume_weighted_average_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "vwap"
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys now with a limit order priced at the best offer, the price it takes to fill immediately.
    #'
    #' This is what a market order has become in India: brokers convert an API market order into a limit order with price protection, and some refuse market orders outright. A marketable limit states the cap itself, so the order fills at once up to that price and never beyond it. UBI reads the best offer when it sends the order, and `buffer_percent` moves the cap that far above it to reach deeper into the book. Pair it with `validity = "ioc"` to cancel whatever cannot fill at once.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Reach half a per cent past the best offer, which still fills at the best price available but tolerates the book moving, and sell back what filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param buffer_percent The numeric percentage to move the cap past the best offer, such as 0.5, or `NULL` for no buffer. A cap too far from the market is refused by the exchange's price protection.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_marketable_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_marketable_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc",
    #'       buffer_percent = 0.5
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_marketable_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      buffer_percent = NULL
    ) {
      price_reference <- list(
        kind = "marketable"
      )
      if (!is.null(buffer_percent)) {
        price_reference[["buffer_percent"]] <- buffer_percent
      }
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells now with a limit order priced at the best bid, the price it takes to fill immediately.
    #'
    #' This is what a market order has become in India: brokers convert an API market order into a limit order with price protection, and some refuse market orders outright. A marketable limit states the cap itself, so the order fills at once up to that price and never beyond it. UBI reads the best bid when it sends the order, and `buffer_percent` moves the cap that far below it to reach deeper into the book. Pair it with `validity = "ioc"` to cancel whatever cannot fill at once.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Reach half a per cent below the best bid, which still fills at the best price available but tolerates the book moving, and buy back what sold.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param buffer_percent The numeric percentage to move the cap past the best bid, such as 0.5, or `NULL` for no buffer. A cap too far from the market is refused by the exchange's price protection.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_marketable_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_marketable_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc",
    #'       buffer_percent = 0.5
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_marketable_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      buffer_percent = NULL
    ) {
      price_reference <- list(
        kind = "marketable"
      )
      if (!is.null(buffer_percent)) {
        price_reference[["buffer_percent"]] <- buffer_percent
      }
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys with a limit order at the price the instrument last traded at.
    #'
    #' The last traded price is where the most recent deal was done, which may be on either side of the book by the time the order arrives, so the order may fill at once or rest. UBI reads it when it sends the order and rounds it to the tick.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the last traded price as an intraday order, which may fill or rest, then cancel whatever rests and sell back whatever filled.
    #' * Send the same bid at the last traded price as an immediate-or-cancel order, so nothing is left resting, and sell back anything that filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_last_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_last_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_last_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "last"
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells with a limit order at the price the instrument last traded at.
    #'
    #' The last traded price is where the most recent deal was done, which may be on either side of the book by the time the order arrives, so the order may fill at once or rest. UBI reads it when it sends the order and rounds it to the tick.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share short at the last traded price as an intraday order, which may fill or rest, then cancel whatever rests and buy back whatever sold.
    #' * Send the same offer at the last traded price as an immediate-or-cancel order, so nothing is left resting, and buy back anything that sold.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_last_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_last_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_last_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "last"
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the second best price on the buy side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the second best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the second best bid as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the second best bid as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_second_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_second_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_second_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 2
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the third best price on the buy side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the third best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the third best bid as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the third best bid as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_third_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_third_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_third_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 3
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the fourth best price on the buy side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the fourth best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the fourth best bid as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the fourth best bid as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fourth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fourth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_fourth_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 4
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the fifth best price on the buy side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the fifth best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share at the fifth best bid as an intraday order, then cancel it, closing any share that filled in the meantime.
    #' * Send the same bid at the fifth best bid as an immediate-or-cancel order, which the exchange cancels at once unless a seller is already there.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fifth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fifth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_fifth_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 5
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the second best price on the buy side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the second. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the second best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Sell one share short with a limit at the second best bid as an ordinary day order with a tag, cancel it if it is still resting, and buy back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_second_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_second_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_second_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 2
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the third best price on the buy side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the third. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the third best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Sell one share short with a limit at the third best bid as an ordinary day order with a tag, cancel it if it is still resting, and buy back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_third_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_third_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_third_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 3
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the fourth best price on the buy side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the fourth. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the fourth best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Sell one share short with a limit at the fourth best bid as an ordinary day order with a tag, cancel it if it is still resting, and buy back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fourth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fourth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_fourth_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 4
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the fifth best price on the buy side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the fifth. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Sell one Vodafone Idea share short at once with a limit at the fifth best bid as an immediate-or-cancel intraday order, then buy it straight back.
    #' * Sell one share short with a limit at the fifth best bid as an ordinary day order with a tag, cancel it if it is still resting, and buy back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fifth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fifth_best_bid_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_fifth_best_bid_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "bid_level",
        level = 5
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the second best price on the sell side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the second. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the second best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Buy one share with a limit at the second best offer as an ordinary day order with a tag, cancel it if it is still resting, and sell back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_second_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_second_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_second_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 2
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the third best price on the sell side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the third. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the third best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Buy one share with a limit at the third best offer as an ordinary day order with a tag, cancel it if it is still resting, and sell back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_third_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_third_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_third_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 3
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the fourth best price on the sell side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the fourth. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the fourth best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Buy one share with a limit at the fourth best offer as an ordinary day order with a tag, cancel it if it is still resting, and sell back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fourth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fourth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_fourth_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 4
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Buys at the fifth best price on the sell side of the book.
    #'
    #' This is more aggressive than pricing at the best level, because the order reaches past the front of the other side and can sweep every level down to the fifth. Expect a larger fill at a worse average price.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share at once with a limit at the fifth best offer as an immediate-or-cancel intraday order, then sell it straight back.
    #' * Buy one share with a limit at the fifth best offer as an ordinary day order with a tag, cancel it if it is still resting, and sell back whatever filled.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fifth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       validity = "ioc"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$buy_at_fifth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    buy_at_fifth_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 5
      )
      self$place_order(
        transaction_type = "buy",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the second best price on the sell side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the second best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the second best offer as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the second best offer with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_second_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_second_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_second_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 2
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the third best price on the sell side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the third best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the third best offer as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the third best offer with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_third_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_third_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_third_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 3
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the fourth best price on the sell side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the fourth best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the fourth best offer as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the fourth best offer with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fourth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fourth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_fourth_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 4
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells at the fifth best price on the sell side of the book.
    #'
    #' This is more patient than pricing at the best level, because the order waits behind everyone at the fifth best price on its own side. It fills less often, and at a better price when it does.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share at the fifth best offer as an intraday short sale, then cancel it, buying back any share that sold in the meantime.
    #' * Send the same offer at the fifth best offer with a tag, so it can be picked out of the order book later, and cancel it.
    #' @param quantity The integer quantity in underlying units, not lots.
    #' @param product The character product, `cnc` for delivery, `mis` for intraday or `nrml` for carry forward.
    #' @param validity The character validity, `day` or `ioc`, or `NULL` to let UBI use `day`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character of up to twenty letters and digits to label the order with, or `NULL`.
    #' @return The named list `place_order` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `ServiceUnavailableError` when UBI could not work the price out, because there is no live quote, the order book is not that deep or no tick size is agreed, which is what the book looks like outside market hours; `BadRequestError` when a field is invalid; `OrderRejectedError` when the broker refused the order; `UnifiedBrokerInterfaceError` when any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fifth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     answer <- idea$sell_at_fifth_best_offer_price(
    #'       quantity = 1,
    #'       product = "mis",
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- answer
    #'     cat(
    #'       answer[["outcome"]],
    #'       answer[["broker"]],
    #'       answer[["order_id"]],
    #'       "\n"
    #'     )
    #'     Sys.sleep(3)
    #'     orders <- idea$orders
    #'     mine <- orders[orders$order_id == answer[["order_id"]], , drop = FALSE]
    #'     print(mine[, c(
    #'       "status",
    #'       "price",
    #'       "filled_quantity"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    sell_at_fifth_best_offer_price = function(
      quantity,
      product,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      price_reference <- list(
        kind = "offer_level",
        level = 5
      )
      self$place_order(
        transaction_type = "sell",
        order_type = "limit",
        price_reference = price_reference,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Makes an existing position bigger, or opens a new one.
    #'
    #' The direction follows the position you already hold: a long position is added to by buying and a short one by selling, so `transaction_type` is needed only when you hold nothing yet. Holding nothing also means there is no position to read a product from, so `product` is needed then too.
    #'
    #' Only positions held under `cnc`, `mis` and `nrml` are visible here. UBI also reports positions under `margin_trading`, `cover` and `bracket`, which come from order kinds it cannot send, and those are ignored as though they were not there.
    #'
    #' The examples below, in order:
    #'
    #' * Add one Vodafone Idea share to the intraday position with a limit a per cent above the market, so it fills at once even at a broker that refuses market orders, then add a second without naming a side, and sell both back until the position is where it started.
    #' * Show that naming a side against the position held is refused, because a sell would reduce a long position rather than add to it.
    #' @param quantity The integer quantity to add, in underlying units and always positive, whichever way the position points.
    #' @param product The character product of the position to add to, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` when only one position is held.
    #' @param transaction_type The character direction to open in, `"buy"` or `"sell"`, used only when no position is held yet.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `PositionError` when several positions are held and none was named, the direction given contradicts the position held, or nothing is held and no direction and product were given; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$add_to_position(
    #'       quantity = 1,
    #'       product = "mis",
    #'       transaction_type = "buy",
    #'       price = round(idea$last_price * 1.01, 2)
    #'     )
    #'     answers[[length(answers) + 1]] <- opened
    #'     cat("Opened:", opened[["outcome"]], "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     added <- idea$add_to_position(
    #'       quantity = 1,
    #'       product = "mis",
    #'       price = round(idea$last_price * 1.01, 2)
    #'     )
    #'     answers[[length(answers) + 1]] <- added
    #'     cat("Added:", added[["outcome"]], "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 2) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     tryCatch(
    #'       {
    #'         idea$add_to_position(
    #'           quantity = 1,
    #'           product = "mis",
    #'           transaction_type = "sell"
    #'         )
    #'       },
    #'       PositionError = function(error) {
    #'         cat("Refused:", conditionMessage(error), "\n")
    #'       }
    #'     )
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    add_to_position = function(
      quantity,
      product = NULL,
      transaction_type = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      frame <- private$tradeable_positions()
      if (is.null(frame)) {
        return(
          private$open_a_new_position(
            quantity = quantity,
            product = product,
            transaction_type = transaction_type,
            price = price,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      row <- private$position_row(product)
      if (row[["quantity"]] > 0) {
        wanted_direction <- "buy"
      } else {
        wanted_direction <- "sell"
      }
      if (!is.null(transaction_type)) {
        if (tolower(transaction_type) != wanted_direction) {
          ErrorCatalogue$raise(
            "PositionError",
            sprintf(
              "This is a position of %s under %s, so a %s reduces it rather than adding to it; use reduce_position: %s",
              format(row[["quantity"]]),
              row[["product"]],
              tolower(transaction_type),
              self$format()
            )
          )
        }
      }
      private$place_to_change_position(
        transaction_type = wanted_direction,
        quantity = quantity,
        product = INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT[[row[["product"]]]],
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Makes an existing position smaller, without turning it around.
    #'
    #' UBI works the direction out from the position when it sends the order: a long position is reduced by selling and a short one by buying. It also caps the order at what is held, so asking for more than the position closes the whole position and never opens a new one the other way round.
    #'
    #' Only positions held under `cnc`, `mis` and `nrml` are visible here, for the reason given on `add_to_position()`. When no product is named, the positions are read once to find the only one held; when one is named, nothing is read here and UBI reads the positions itself.
    #'
    #' The examples below, in order:
    #'
    #' * Buy two Vodafone Idea shares intraday, reduce the position by one with a limit a per cent below the market, and sell the other back.
    #' * Ask to reduce a one-share intraday position by five, which UBI caps at what is held, so the position closes and never turns short.
    #' @param quantity The integer largest quantity to close, in underlying units and always positive, whichever way the position points.
    #' @param product The character product of the position to reduce, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` when only one position is held.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `PositionError` when no product was named and nothing is held, several positions are held, or the product named is not `cnc`, `mis` or `nrml`; `ConflictError` when the product named is not held in this instrument; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$buy_at_marketable_price(quantity = 2, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 2) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     reduced <- idea$reduce_position(
    #'       quantity = 1,
    #'       product = "mis",
    #'       price = round(idea$last_price * 0.99, 2)
    #'     )
    #'     answers[[length(answers) + 1]] <- reduced
    #'     cat("Reduced:", reduced[["outcome"]], "\n")
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' if (start != 0) {
    #'   stop("An intraday IDEA position is already open.")
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     reduced <- idea$reduce_position(
    #'       quantity = 5,
    #'       product = "mis",
    #'       price = round(idea$last_price * 0.99, 2)
    #'     )
    #'     answers[[length(answers) + 1]] <- reduced
    #'     cat("Reduced:", reduced[["outcome"]], "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    reduce_position = function(
      quantity,
      product = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      private$place_to_close_position(
        kind = "reduce_position",
        quantity = quantity,
        product = product,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Closes one position in this instrument completely.
    #'
    #' UBI reads the position when it sends the order and closes the whole of it, so a long position is sold and a short one is bought back.
    #'
    #' Only positions held under `cnc`, `mis` and `nrml` are visible here, for the reason given on `add_to_position()`. When no product is named, the positions are read once to find the only one held; when one is named, nothing is read here and UBI reads the positions itself.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share intraday and close the whole position, with a limit a per cent below the market because some brokers refuse market orders from an API.
    #' * Close a short intraday position by buying it back, which UBI works out from the position, with a tag on the closing order.
    #' @param product The character product of the position to close, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` when only one position is held.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `PositionError` when no product was named and nothing is held, several positions are held, or the product named is not `cnc`, `mis` or `nrml`; `ConflictError` when the product named is not held in this instrument; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' if (start != 0) {
    #'   stop("An intraday IDEA position is already open.")
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     closed <- idea$liquidate_position(
    #'       product = "mis",
    #'       price = round(idea$last_price * 0.99, 2)
    #'     )
    #'     answers[[length(answers) + 1]] <- closed
    #'     cat("Closed:", closed[["outcome"]], closed[["order_id"]], "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' if (start != 0) {
    #'   stop("An intraday IDEA position is already open.")
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start - 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     closed <- idea$liquidate_position(
    #'       product = "mis",
    #'       price = round(idea$last_price * 1.01, 2),
    #'       tag = "examples"
    #'     )
    #'     answers[[length(answers) + 1]] <- closed
    #'     cat("Bought back:", closed[["outcome"]], closed[["order_id"]], "\n")
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    liquidate_position = function(
      product = NULL,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      private$place_to_close_position(
        kind = "liquidate_position",
        quantity = NULL,
        product = product,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Closes every position this instrument holds, under every product.
    #'
    #' The positions are read once to list them, and each is then closed with its own order, which UBI sizes and directs from the position when it sends it. Every one is attempted even when an earlier one fails, so a single refusal does not leave the rest open. A position held under a product UBI cannot send an order for, which is `margin_trading`, `cover` or `bracket`, is reported as ignored rather than passed over in silence, and has to be closed at the broker directly.
    #'
    #' The examples below, in order:
    #'
    #' * Buy one Vodafone Idea share intraday, then close every position the share holds, under every product, and print what was done.
    #' * Sell one share short intraday, close every position the share holds with tagged orders, and list any that could not be closed through UBI.
    #' @param price The numeric limit price in rupees for every order, or `NULL` to send market orders.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the orders as after-market orders.
    #' @param tag A character label of up to twenty letters and digits for the orders, or `NULL`.
    #' @return A `data.frame` with one row per position, holding `product`, `order_product`, `quantity`, `closed`, `order_id` and `error`, or `NULL` when this instrument holds no position at all.
    #' @details Errors: signals `BrokerError` when no broker's positions could be read; `ServiceUnavailableError` when UBI's positions document is missing or too old to serve; and another `UnifiedBrokerInterfaceError` subclass when the positions could not be read for any other reason. A failure to close one position is reported in the frame instead.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' if (start != 0) {
    #'   stop("An intraday IDEA position is already open.")
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$buy_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start + 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     outcomes <- idea$liquidate_all_positions(
    #'       price = round(idea$last_price * 0.99, 2)
    #'     )
    #'     print(outcomes)
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' start <- 0
    #' positions <- idea$net_positions
    #' if (!is.null(positions)) {
    #'   intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'   start <- sum(intraday$quantity)
    #' }
    #' if (start != 0) {
    #'   stop("An intraday IDEA position is already open.")
    #' }
    #' answers <- list()
    #' tryCatch(
    #'   {
    #'     opened <- idea$sell_at_marketable_price(quantity = 1, product = "mis")
    #'     answers[[length(answers) + 1]] <- opened
    #'     for (attempt in seq_len(30)) {
    #'       Sys.sleep(1)
    #'       positions <- idea$net_positions
    #'       intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'       if (sum(intraday$quantity) == start - 1) {
    #'         break
    #'       }
    #'     }
    #'     cat("Intraday quantity:", sum(intraday$quantity), "\n")
    #'     outcomes <- idea$liquidate_all_positions(
    #'       price = round(idea$last_price * 1.01, 2),
    #'       tag = "examples"
    #'     )
    #'     print(outcomes[, c(
    #'       "product",
    #'       "quantity",
    #'       "closed",
    #'       "order_id"
    #'     )])
    #'     print(outcomes[!outcomes$closed, , drop = FALSE][, c(
    #'       "product",
    #'       "error"
    #'     )])
    #'   },
    #'   finally = {
    #'     for (answer in answers) {
    #'       for (attempt in seq_len(3)) {
    #'         caught_error <- tryCatch(
    #'           {
    #'             cancelled <- idea$cancel_parent(answer[["parent_id"]])
    #'             NULL
    #'           },
    #'           ConflictError = function(error) error,
    #'           UnifiedBrokerInterfaceError = function(error) error
    #'         )
    #'         if (inherits(caught_error, "ConflictError")) {
    #'           cat("The order had already finished.", "\n")
    #'           break
    #'         } else if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'           error <- caught_error
    #'           cat("Cancelling failed, trying again:", conditionMessage(error), "\n")
    #'           Sys.sleep(2)
    #'           next
    #'         }
    #'         if (cancelled[["state"]] == "cancelled") {
    #'           cat("Cancelled what was still waiting.", "\n")
    #'           break
    #'         }
    #'         Sys.sleep(2)
    #'       }
    #'     }
    #'     quantity <- NA
    #'     for (attempt in seq_len(6)) {
    #'       Sys.sleep(5)
    #'       caught_error <- tryCatch(
    #'         {
    #'           quantity <- 0
    #'           positions <- idea$net_positions
    #'           if (!is.null(positions)) {
    #'             intraday <- positions[positions$product == "intraday", , drop = FALSE]
    #'             quantity <- sum(intraday$quantity)
    #'           }
    #'           if (quantity == start) {
    #'             break
    #'           }
    #'           difference <- as.integer(quantity - start)
    #'           if (difference > 0) {
    #'             price <- round(idea$last_price * 0.99, 2)
    #'           } else {
    #'             price <- round(idea$last_price * 1.01, 2)
    #'           }
    #'           if ((difference > 0) == (quantity > 0)) {
    #'             idea$reduce_position(
    #'               quantity = abs(difference),
    #'               product = "mis",
    #'               price = price
    #'             )
    #'           } else if (difference > 0) {
    #'             idea$sell_at_limit_price(
    #'               price = price,
    #'               quantity = difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           } else {
    #'             idea$buy_at_limit_price(
    #'               price = price,
    #'               quantity = -difference,
    #'               product = "mis",
    #'               hold = FALSE
    #'             )
    #'           }
    #'           NULL
    #'         },
    #'         UnifiedBrokerInterfaceError = function(error) error
    #'       )
    #'       if (inherits(caught_error, "UnifiedBrokerInterfaceError")) {
    #'         error <- caught_error
    #'         quantity <- NA
    #'         cat("Closing failed, trying again:", conditionMessage(error), "\n")
    #'       }
    #'     }
    #'     if (is.na(quantity) || quantity != start) {
    #'       stop(sprintf("The position is %s, not %s.", quantity, start))
    #'     }
    #'     cat("The intraday position is back at", start, "\n")
    #'   }
    #' )
    #' }
    liquidate_all_positions = function(
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      frame <- self$net_positions
      if (is.null(frame)) {
        return(NULL)
      }
      outcomes <- list()
      for (row in FrameBuilder$new()$rows(frame)) {
        order_product <- NULL
        if (row[["product"]] %in% names(INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT)) {
          order_product <- INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT[[row[["product"]]]]
        }
        outcome <- list(
          product = row[["product"]],
          order_product = order_product,
          quantity = row[["quantity"]],
          closed = FALSE,
          order_id = NULL,
          error = NULL
        )
        if (is.null(order_product)) {
          outcome[["error"]] <- sprintf(
            "ignored: UBI cannot send a %s order, so close this at the broker",
            row[["product"]]
          )
          outcomes[[length(outcomes) + 1]] <- outcome
          next
        }
        outcome <- tryCatch(
          {
            answer <- self$liquidate_position(
              product = order_product,
              price = price,
              validity = validity,
              after_market = after_market,
              tag = tag
            )
            outcome[["closed"]] <- TRUE
            outcome["order_id"] <- list(answer[["order_id"]])
            outcome
          },
          PositionError = function(error) {
            outcome[["error"]] <- private$error_text(error)
            outcome
          },
          UnifiedBrokerInterfaceError = function(error) {
            outcome[["error"]] <- private$error_text(error)
            outcome
          }
        )
        outcomes[[length(outcomes) + 1]] <- outcome
      }
      FrameBuilder$new()$frame(outcomes)
    }
  ),
  active = list(
    #' @field bids The buy side of the order book as a list of named lists with `price`, `quantity` and `orders`, best first, read from UBI on every access.
    bids = function(value) {
      if (!missing(value)) {
        stop("bids is read-only", call. = FALSE)
      }
      self$quote[["depth"]][["buy"]]
    },

    #' @field offers The sell side of the order book as a list of named lists with `price`, `quantity` and `orders`, best first, read from UBI on every access.
    offers = function(value) {
      if (!missing(value)) {
        stop("offers is read-only", call. = FALSE)
      }
      self$quote[["depth"]][["sell"]]
    },

    #' @field best_bid The highest bid in the order book as a named list with `price`, `quantity` and `orders`, or `NULL` when nobody is bidding.
    best_bid = function(value) {
      if (!missing(value)) {
        stop("best_bid is read-only", call. = FALSE)
      }
      private$best_level(self$bids)
    },

    #' @field best_offer The lowest offer in the order book as a named list with `price`, `quantity` and `orders`, or `NULL` when nobody is offering.
    best_offer = function(value) {
      if (!missing(value)) {
        stop("best_offer is read-only", call. = FALSE)
      }
      private$best_level(self$offers)
    },

    #' @field bid_offer_spread The numeric gap between the best offer and the best bid, measured from one quote, or `NULL` when either side is empty.
    bid_offer_spread = function(value) {
      if (!missing(value)) {
        stop("bid_offer_spread is read-only", call. = FALSE)
      }
      depth <- self$quote[["depth"]]
      best_bid <- private$best_level(depth[["buy"]])
      best_offer <- private$best_level(depth[["sell"]])
      if (is.null(best_bid) || is.null(best_offer)) {
        return(NULL)
      }
      best_offer[["price"]] - best_bid[["price"]]
    },

    #' @field mid_price The numeric price halfway between the best bid and the best offer, from one quote, or `NULL` when either side is empty.
    mid_price = function(value) {
      if (!missing(value)) {
        stop("mid_price is read-only", call. = FALSE)
      }
      depth <- self$quote[["depth"]]
      best_bid <- private$best_level(depth[["buy"]])
      best_offer <- private$best_level(depth[["sell"]])
      if (is.null(best_bid) || is.null(best_offer)) {
        return(NULL)
      }
      (best_bid[["price"]] + best_offer[["price"]]) / 2
    },

    #' @field volume_weighted_average_price Today's numeric volume weighted average price, or `NULL` when UBI has none.
    volume_weighted_average_price = function(value) {
      if (!missing(value)) {
        stop("volume_weighted_average_price is read-only", call. = FALSE)
      }
      self$quote[["average_price"]]
    },

    #' @field last_quantity The integer quantity of the last trade, or `NULL` when UBI has none.
    last_quantity = function(value) {
      if (!missing(value)) {
        stop("last_quantity is read-only", call. = FALSE)
      }
      self$quote[["last_quantity"]]
    },

    #' @field total_traded_volume The integer quantity traded so far today, or `NULL` when UBI has none.
    total_traded_volume = function(value) {
      if (!missing(value)) {
        stop("total_traded_volume is read-only", call. = FALSE)
      }
      self$quote[["volume"]]
    },

    #' @field open_interest The integer open interest of a future or an option, or `NULL` when UBI has none.
    open_interest = function(value) {
      if (!missing(value)) {
        stop("open_interest is read-only", call. = FALSE)
      }
      self$quote[["oi"]]
    },

    #' @field last_trade_time When the last trade happened, as a `POSIXct` in India time, or `NULL` when UBI has none.
    last_trade_time = function(value) {
      if (!missing(value)) {
        stop("last_trade_time is read-only", call. = FALSE)
      }
      epoch_seconds <- self$quote[["last_trade_time"]]
      if (is.null(epoch_seconds)) {
        return(NULL)
      }
      TimeConverter$new()$from_epoch(epoch_seconds)
    },

    #' @field parents The synthetic orders and held orders in this instrument that UBI's order engine has not finished, as a `data.frame`, or `NULL` when there are none. A parent is one order the engine was asked for, such as a bracket, a trailing stop or a held limit order, and its legs are the broker orders it placed. This is the only way to see a parent that has placed nothing yet, such as an armed trigger. UBI lists every open parent in the account, so this reads them all and keeps this instrument's own.
    parents = function(value) {
      if (!missing(value)) {
        stop("parents is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_PARENTS_PATH
      )[["parents"]]
      private$frame_for_this_instrument(rows)
    },

    #' @field orders Every one of today's orders in this instrument, whatever its status, as a `data.frame`, or `NULL` when there are none. UBI serves the whole account's order book and has no route for one instrument, so reading this reads the whole book and keeps this instrument's own rows. The book is not merged across brokers, so one order placed at one broker appears once, and the same instrument traded at two brokers gives a row from each. The `status` column holds UBI's own upper-case status, one of `PENDING`, `OPEN`, `COMPLETE`, `CANCELLED`, `REJECTED` or `EXPIRED`. An order still waiting in the market is `PENDING` at some brokers and `OPEN` at others, so `open_orders` is the way to ask for those. An order UBI's order engine is still holding has not reached a broker and is not here; it is in `parents`.
    orders = function(value) {
      if (!missing(value)) {
        stop("orders is read-only", call. = FALSE)
      }
      private$orders_with_status(NULL)
    },

    #' @field open_orders Today's orders in this instrument that can still be changed, as a `data.frame`, or `NULL` when there are none. An order counts as open while it is waiting in the market, which UBI reports as `PENDING` at some brokers and `OPEN` at others. Those are the orders `modify_order()` and `cancel_order()` will accept; every other status is final. An order UBI's order engine is still holding has not reached the market, so it is not here; `parents` lists it.
    open_orders = function(value) {
      if (!missing(value)) {
        stop("open_orders is read-only", call. = FALSE)
      }
      private$orders_with_status(INSTRUMENTS_OPEN_ORDER_STATUSES)
    },

    #' @field completed_orders Today's orders in this instrument that filled in full, as a `data.frame`, or `NULL` when there are none.
    completed_orders = function(value) {
      if (!missing(value)) {
        stop("completed_orders is read-only", call. = FALSE)
      }
      private$orders_with_status(INSTRUMENTS_COMPLETED_ORDER_STATUSES)
    },

    #' @field rejected_orders Today's orders in this instrument that a broker or the exchange refused, as a `data.frame`, or `NULL` when there are none. The `status_message` column holds the reason each one was refused, in the words of whoever refused it.
    rejected_orders = function(value) {
      if (!missing(value)) {
        stop("rejected_orders is read-only", call. = FALSE)
      }
      private$orders_with_status(INSTRUMENTS_REJECTED_ORDER_STATUSES)
    },

    #' @field cancelled_orders Today's orders in this instrument that were cancelled, as a `data.frame`, or `NULL` when there are none.
    cancelled_orders = function(value) {
      if (!missing(value)) {
        stop("cancelled_orders is read-only", call. = FALSE)
      }
      private$orders_with_status(INSTRUMENTS_CANCELLED_ORDER_STATUSES)
    },

    #' @field trades Today's trades in this instrument as a `data.frame`, or `NULL` when there are none. UBI serves the whole account's trade book and has no route for one instrument, so this reads the book and keeps its own rows. One order can produce several trades, and each trade names the order it came from.
    trades = function(value) {
      if (!missing(value)) {
        stop("trades is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_TRADES_PATH
      )[["trades"]]
      private$frame_for_this_instrument(rows)
    },

    #' @field net_positions The positions held in this instrument now, merged across every broker, as a `data.frame` whose `pnl` column is a list column, or `NULL` when none is held. This is UBI's `net` bucket, which counts everything open in this instrument whenever it was opened, as against `day_positions`, which counts only today. A position is what a derivative or an intraday trade leaves open, as against a holding, which is a share kept in the demat account and belongs to `Equity` instead. UBI merges the brokers' positions by instrument and product, so one instrument gives one row per product it is held under, and no row names a broker.
    net_positions = function(value) {
      if (!missing(value)) {
        stop("net_positions is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_POSITIONS_PATH
      )[["net"]]
      private$frame_for_this_instrument(rows)
    },

    #' @field day_positions Today's own positions in this instrument, without what was carried in, as a `data.frame`, or `NULL` when there are none. This is UBI's `day` bucket. It has the same shape as `net_positions` and counts only what was opened and closed today, so it is usually empty even when `net_positions` is not, because only some brokers report a position on a day basis at all.
    day_positions = function(value) {
      if (!missing(value)) {
        stop("day_positions is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_POSITIONS_PATH
      )[["day"]]
      private$frame_for_this_instrument(rows)
    },

    #' @field positions_value The numeric worth of this instrument's open positions at the moment, rounded to two places, or `NULL` when none is held or any position has no last price. Each position is counted as its quantity times its last price, and the sign is kept, so a long position adds and a short one subtracts. UBI prices a holding but not a position, so this is worked out here. This counts every position, including those held under `margin_trading`, `cover` and `bracket`, because they are real money even though UBI cannot send an order to close them.
    positions_value = function(value) {
      if (!missing(value)) {
        stop("positions_value is read-only", call. = FALSE)
      }
      frame <- self$net_positions
      if (is.null(frame)) {
        return(NULL)
      }
      total <- 0
      for (row in FrameBuilder$new()$rows(frame)) {
        last_price <- row[["last_price"]]
        if (is.null(last_price) || is.na(last_price)) {
          return(NULL)
        }
        total <- total + row[["quantity"]] * last_price
      }
      round(total, 2)
    },

    #' @field positions_pnl What this instrument's positions have made or lost, as a named list with numeric `realized`, `unrealized` and `total`, each rounded to two places, or `NULL` when none is held. The realised part is profit already booked by closing some of a position today, and the unrealised part is what is still riding on what remains open. Both are added across every position in this instrument, including those held under `margin_trading`, `cover` and `bracket`.
    positions_pnl = function(value) {
      if (!missing(value)) {
        stop("positions_pnl is read-only", call. = FALSE)
      }
      frame <- self$net_positions
      if (is.null(frame)) {
        return(NULL)
      }
      realized <- 0
      unrealized <- 0
      for (row in FrameBuilder$new()$rows(frame)) {
        realized <- realized + row[["pnl"]][["realized"]]
        unrealized <- unrealized + row[["pnl"]][["unrealized"]]
      }
      list(
        realized = round(realized, 2),
        unrealized = round(unrealized, 2),
        total = round(realized + unrealized, 2)
      )
    }
  ),
  private = list(
    #' Cancels one parent for `cancel_open_orders()`, reporting a failure rather than signalling it.
    #' @param parent_id The character id of the parent to cancel.
    #' @return A named list with `outcome`, a named list with `parent_id`, `order_id`, `broker`, `cancelled` and `error` for the returned frame, and `engine_answered`, a logical that is `TRUE` when the engine took the cancel, so the parent's own orders need no separate cancel.
    cancel_one_parent = function(parent_id) {
      outcome <- list(
        parent_id = parent_id,
        order_id = NULL,
        broker = NULL,
        cancelled = TRUE,
        error = NULL
      )
      answer <- tryCatch(
        self$cancel_parent(parent_id),
        UnifiedBrokerInterfaceError = function(error) error
      )
      if (inherits(answer, "UnifiedBrokerInterfaceError")) {
        outcome[["cancelled"]] <- FALSE
        outcome[["error"]] <- private$error_text(answer)
        return(
          list(
            outcome = outcome,
            engine_answered = FALSE
          )
        )
      }
      state <- answer[["state"]]
      if (!identical(state, "cancelled")) {
        outcome[["cancelled"]] <- FALSE
        outcome[["error"]] <- sprintf(
          "the parent is %s, because a broker refused or did not confirm the cancel of one of its orders",
          private$python_text(state)
        )
      }
      list(
        outcome = outcome,
        engine_answered = TRUE
      )
    },

    #' Cancels broker orders in one request for `cancel_open_orders()`, reporting each failure rather than signalling it.
    #' @param orders_to_cancel A list of named lists, each with the `order_id` and `broker` of one order.
    #' @return A list of named lists, one per order in the same order, each with `parent_id`, `order_id`, `broker`, `cancelled` and `error` for the returned frame, which is empty when `orders_to_cancel` is.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the whole list, or could not be reached.
    cancel_order_list = function(orders_to_cancel) {
      if (length(orders_to_cancel) == 0) {
        return(list())
      }
      answer <- private$unified_broker_interface$delete(
        INSTRUMENTS_ORDER_CANCEL_PATH,
        body = list(
          orders = orders_to_cancel
        )
      )
      outcomes <- list()
      for (result in answer[["results"]]) {
        order <- orders_to_cancel[[result[["request_index"]] + 1]]
        outcome <- list(
          parent_id = NULL,
          order_id = order[["order_id"]],
          broker = order[["broker"]],
          cancelled = TRUE,
          error = NULL
        )
        if (result[["status"]] != 200) {
          response <- result[["response"]]
          message <- response[["error"]]
          if (is.null(message) || identical(message, "")) {
            message <- response[["status_message"]]
          }
          outcome[["cancelled"]] <- FALSE
          outcome[["error"]] <- sprintf(
            "HTTP %s: %s",
            format(result[["status"]]),
            private$python_text(message)
          )
        }
        outcomes[[length(outcomes) + 1]] <- outcome
      }
      outcomes
    },

    #' Reads the order book and keeps this instrument's rows in the wanted statuses.
    #' @param wanted_statuses A character vector of upper-case UBI statuses to keep, or `NULL` to keep every status.
    #' @return A `data.frame` of the matching rows, or `NULL` when no row matches.
    #' @details Errors: signals `BrokerError` when no broker's order book could be read; `ServiceUnavailableError` when UBI's order book document is missing or too old to serve; and another `UnifiedBrokerInterfaceError` subclass for any other failure.
    orders_with_status = function(wanted_statuses) {
      rows <- private$unified_broker_interface$get(
        INSTRUMENTS_ORDER_DETAILS_PATH
      )[["orders"]]
      if (is.null(wanted_statuses)) {
        return(private$frame_for_this_instrument(rows))
      }
      wanted_rows <- list()
      for (row in rows) {
        if (isTRUE(row[["status"]] %in% wanted_statuses)) {
          wanted_rows[[length(wanted_rows) + 1]] <- row
        }
      }
      private$frame_for_this_instrument(wanted_rows)
    },

    #' Sends an order that UBI sizes and directs from the position it closes.
    #'
    #' The side sent is only a placeholder, because UBI replaces it with the one that closes the position. The order is marked as closing a position, so it may use the part of a broker's daily order cap that UBI keeps for exits.
    #' @param kind The character quantity reference kind, `"reduce_position"` or `"liquidate_position"`.
    #' @param quantity The integer largest quantity to close, or `NULL` to close the whole position.
    #' @param product The character order product of the position, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use the only position held.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, or `NULL`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label for the order, or `NULL`.
    #' @return The named list `place_order()` returns.
    #' @details Errors: signals `PositionError` when no product was named and there is not exactly one position, or the product is not `cnc`, `mis` or `nrml`; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    place_to_close_position = function(
      kind,
      quantity,
      product,
      price,
      validity,
      after_market,
      tag
    ) {
      if (is.null(product)) {
        row <- private$position_row(NULL)
        product <- INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT[[row[["product"]]]]
      }
      position_product <- NULL
      if (tolower(product) %in% names(INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT)) {
        position_product <- INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT[[tolower(product)]]
      }
      if (is.null(position_product)) {
        ErrorCatalogue$raise(
          "PositionError",
          sprintf(
            "Positions can be closed only under cnc, mis or nrml, not '%s': %s",
            product,
            self$format()
          )
        )
      }
      if (is.null(price)) {
        order_type <- "market"
      } else {
        order_type <- "limit"
      }
      self$place_order(
        transaction_type = "sell",
        order_type = order_type,
        quantity = quantity,
        product = product,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag,
        quantity_reference = list(
          kind = kind,
          product = position_product
        ),
        synthetic = list(
          type = "simple",
          closes_position = TRUE
        )
      )
    },

    #' Reads this instrument's positions, keeping the ones UBI can trade.
    #'
    #' UBI reports a position's product as `delivery`, `intraday`, `carry`, `margin_trading`, `cover` or `bracket`, but it accepts orders only for the first three. The last three come from order kinds its place route cannot send, so they are dropped here, which is the one place that happens.
    #' @return A `data.frame` of the positions that can be traded through UBI, or `NULL` when there are none.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when the positions cannot be read.
    tradeable_positions = function() {
      frame <- self$net_positions
      if (is.null(frame)) {
        return(NULL)
      }
      keep <- frame$product %in% names(INSTRUMENTS_ORDER_PRODUCT_FOR_POSITION_PRODUCT)
      if (!any(keep)) {
        return(NULL)
      }
      kept <- frame[keep, , drop = FALSE]
      rownames(kept) <- NULL
      kept
    },

    #' Picks the one position to act on.
    #' @param product The character order product naming the position, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use the only position held.
    #' @return The named list row of the position, with UBI's own `product` spelling in it.
    #' @details Errors: signals `PositionError` when nothing tradeable is held, the named product is not held, or several are held and none was named.
    position_row = function(product) {
      frame <- private$tradeable_positions()
      if (is.null(frame)) {
        ErrorCatalogue$raise(
          "PositionError",
          sprintf(
            "No position is held in this instrument that UBI can send an order for: %s",
            self$format()
          )
        )
      }
      rows <- FrameBuilder$new()$rows(frame)
      held_products <- sort(frame$product)
      if (is.null(product)) {
        if (length(rows) == 1) {
          return(rows[[1]])
        }
        ErrorCatalogue$raise(
          "PositionError",
          sprintf(
            "Positions are held under %s, so name the product to act on: %s",
            paste(held_products, collapse = ", "),
            self$format()
          )
        )
      }
      wanted_product <- NULL
      if (tolower(product) %in% names(INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT)) {
        wanted_product <- INSTRUMENTS_POSITION_PRODUCT_FOR_ORDER_PRODUCT[[tolower(product)]]
      }
      for (row in rows) {
        if (identical(row[["product"]], wanted_product)) {
          return(row)
        }
      }
      ErrorCatalogue$raise(
        "PositionError",
        sprintf(
          "No %s position is held in this instrument, which holds %s: %s",
          product,
          paste(held_products, collapse = ", "),
          self$format()
        )
      )
    },

    #' Sends the order that changes a position, as a market or a limit order.
    #' @param transaction_type The character direction to trade in, `"buy"` or `"sell"`.
    #' @param quantity The integer quantity in underlying units.
    #' @param product The character order product, `"cnc"`, `"mis"` or `"nrml"`.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, or `NULL`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label for the order, or `NULL`.
    #' @return The named list `place_order()` returns.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    place_to_change_position = function(
      transaction_type,
      quantity,
      product,
      price,
      validity,
      after_market,
      tag
    ) {
      if (transaction_type == "buy") {
        if (is.null(price)) {
          return(
            self$buy_at_market_price(
              quantity = quantity,
              product = product,
              validity = validity,
              after_market = after_market,
              tag = tag
            )
          )
        }
        return(
          self$buy_at_limit_price(
            price = price,
            quantity = quantity,
            product = product,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      if (is.null(price)) {
        return(
          self$sell_at_market_price(
            quantity = quantity,
            product = product,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$sell_at_limit_price(
        price = price,
        quantity = quantity,
        product = product,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' Opens a position in an instrument that holds none.
    #' @param quantity The integer quantity in underlying units.
    #' @param product The character order product to open under, or `NULL`.
    #' @param transaction_type The character direction to open in, `"buy"` or `"sell"`, or `NULL`.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, or `NULL`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label for the order, or `NULL`.
    #' @return The named list `place_order()` returns.
    #' @details Errors: signals `PositionError` when no direction or no product was given, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    open_a_new_position = function(
      quantity,
      product,
      transaction_type,
      price,
      validity,
      after_market,
      tag
    ) {
      if (is.null(transaction_type) || is.null(product)) {
        ErrorCatalogue$raise(
          "PositionError",
          sprintf(
            "No position is held in this instrument, so opening one needs both transaction_type and product: %s",
            self$format()
          )
        )
      }
      private$place_to_change_position(
        transaction_type = tolower(transaction_type),
        quantity = quantity,
        product = product,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' Keeps the rows belonging to this instrument and makes a frame of them.
    #'
    #' A row UBI could not trace back to an instrument carries a null `instrument_id` and is left out, because there is no other field that names this instrument reliably.
    #' @param rows A list of named lists from one of UBI's order, trade or position documents, each with an `instrument_id`.
    #' @return A `data.frame` of the matching rows, or `NULL` when no row belongs to this instrument.
    frame_for_this_instrument = function(rows) {
      matching_rows <- list()
      for (row in rows) {
        if (identical(row[["instrument_id"]], self$instrument_id)) {
          matching_rows[[length(matching_rows) + 1]] <- row
        }
      }
      FrameBuilder$new()$frame(matching_rows)
    },

    #' Picks the best level from one side of an order book.
    #' @param levels A list of named lists with `price`, `quantity` and `orders`, best first.
    #' @return The first named list in `levels`, or `NULL` when `levels` is empty.
    best_level = function(levels) {
      if (length(levels) == 0) {
        return(NULL)
      }
      levels[[1]]
    },

    #' Describes a caught error the way the Python library does, as its class name and message.
    #' @param error A condition.
    #' @return A character value such as `"ConflictError: no position"`.
    error_text = function(error) {
      sprintf(
        "%s: %s",
        ErrorCatalogue$name_of(error),
        conditionMessage(error)
      )
    },

    #' Writes a value the way a Python f-string would, with `NULL` as `None`.
    #' @param value A scalar or `NULL`.
    #' @return A character value.
    python_text = function(value) {
      if (is.null(value)) {
        return("None")
      }
      as.character(value)
    }
  )
)

#' An instrument that cannot be traded directly, which is an index
#'
#' @description
#' An index is followed rather than traded, so it has candles, a quote and the analysis methods but none of the order, position or order-book members of `TradeableInstrument`. Its futures and options are traded instead, through the derivative classes.
#'
#' The examples below start with a short tour of the class, then show its properties, in this order:
#'
#' * For `constituents`, print the stored members of the Nifty 50, or say that none are stored.
#' * For `constituents`, compare the index's own day change with the day change of its stored members, when a basket is stored.
#'
#' @examples
#' \dontrun{
#' nifty <- NonTradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equity_indices",
#'   symbol = "NIFTY"
#' )
#' nifty$last_price
#' members <- nifty$constituents
#'
#' nifty <- NonTradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equity_indices",
#'   symbol = "NIFTY"
#' )
#' basket <- nifty$constituents
#' if (is.null(basket)) {
#'   cat("No constituents are stored for NIFTY today.", "\n")
#' } else {
#'   print(basket)
#' }
#'
#' nifty <- NonTradeableInstrument$new(
#'   exchange = "nse",
#'   segment = "equity_indices",
#'   symbol = "NIFTY"
#' )
#' basket <- nifty$constituents
#' cat("Index day change:", nifty$ohlc[["change_percent"]], "\n")
#' if (is.null(basket)) {
#'   cat(
#'     "No constituents are stored, so there is nothing to compare.",
#'     "\n"
#'   )
#' } else {
#'   cat("Members stored:", basket$size, "\n")
#'   cat("Basket day change:", basket$day_change_percent, "\n")
#' }
#' }
#' @export
NonTradeableInstrument <- R6::R6Class(
  "NonTradeableInstrument",
  inherit = Instrument,
  public = list(
    #' @description
    #' Looks the instrument up in UBI and checks that it is an index.
    #' @param instrument_id The character UUID of the instrument, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, bare such as `"equity_indices"` or prefixed such as `"nse_equity_indices"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol of the index, such as `"NIFTY"`, or `NULL`.
    #' @param underlying_symbol The character symbol of an underlying, or `NULL`, since an index has none.
    #' @param expiry_date An expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`, since an index has none.
    #' @param strike_price A numeric strike price, or `NULL`, since an index has none.
    #' @param option_type A character option type, or `NULL`, since an index has none.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @param details The named list UBI returned for this instrument from `/api/instruments/details`, used instead of looking the instrument up again, or `NULL` to look it up from the other arguments.
    #' @return A new `NonTradeableInstrument` object.
    #' @details Errors: signals `NonTradeableInstrumentError` when the instrument is not an index, so it can be traded; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      unified_broker_interface = NULL,
      details = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        unified_broker_interface = unified_broker_interface,
        details = details
      )
      if (!endsWith(self$segment, INSTRUMENTS_INDEX_SEGMENT_SUFFIX)) {
        ErrorCatalogue$raise(
          "NonTradeableInstrumentError",
          sprintf(
            "Only an index is a NonTradeableInstrument, and this can be traded: %s",
            self$format()
          )
        )
      }
    }
  ),
  active = list(
    #' @field constituents The stored basket of the index's members, usually an `Index`, or `NULL` when none is stored for today, read from MongoDB and UBI on every access. The index's own price stays on this object; the basket describes what the index holds, and every analysis and performance method works on it too. UBI stores no constituents, so a basket exists only when one was saved with this index as its linked instrument, for instance by `BasketCsvImporter`.
    constituents = function(value) {
      if (!missing(value)) {
        stop("constituents is read-only", call. = FALSE)
      }
      store <- BasketStore$new(
        unified_broker_interface = private$unified_broker_interface
      )
      store$load_for_instrument(self)
    }
  )
)

#' A futures or option contract, which expires on a set day and is written on an underlying instrument
#'
#' @description
#' This is the shared base of `Futures` and `Option`, and it holds what is true of every contract: when it expires, what it is written on, how much of it is open, and what one lot of it is worth. It is rarely built directly; the family classes such as `EquityFutures` inherit it.
#'
#' The underlying is found in this order, and the first that applies wins. An underlying given as an object when the contract is built is kept and used as it is. Otherwise UBI's `underlying_instrument_id`, resolved from the brokers' own records, is used when UBI supplies one. Otherwise the family's default applies, from `INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT`: an equity contract's share or index found by its symbol, the nearest future for an option on a commodity, a currency pair or a bond, and nothing for a future outside equities, whose cash underlying has no price in UBI. Nothing but the given object is stored, so the other ways look the underlying up again on every read, and `UnderlyingError` says when none of them finds one.
#'
#' The examples below show its properties, in this order:
#'
#' * For `days_to_expiry`, print how many days the nearest Nifty future has left.
#' * For `days_to_expiry`, print the days left on every listed Reliance future.
#' * For `expired`, show that a listed Nifty future has not expired.
#' * For `expired`, build the oldest Nifty future UBI still knows, which has expired, and check it.
#' * For `expiry_kind`, say whether each of the next four Nifty option expiries is a weekly or a monthly one.
#' * For `expiry_kind`, show that a stock future is always monthly, since stocks have no weekly expiries.
#' * For `next_expiry`, find the expiry a position in the nearest Nifty future would roll to.
#' * For `next_expiry`, build the next Reliance future from the nearest one and compare their prices, which is the roll's cost.
#' * For `underlying`, print what the nearest Reliance future is written on, which is looked up in UBI.
#' * For `underlying`, give the underlying when building the contract, so the contract keeps that very object and makes no lookup.
#' * For `underlying`, print the index a Nifty future is written on.
#' * For `underlying_price`, print the Nifty index level beside the price of its nearest future.
#' * For `underlying_price`, print the share price under a Reliance future, read once for a report.
#' * For `open_interest_day_high`, print the highest open interest the nearest Nifty future reached today.
#' * For `open_interest_day_high`, say how far today's open interest is below its high for the day, which shows positions being closed.
#' * For `open_interest_day_low`, print the lowest open interest the nearest Nifty future reached today.
#' * For `open_interest_day_low`, print today's open interest range of the nearest Reliance future.
#' * For `contract_value`, print what one lot of the nearest Nifty future is worth.
#' * For `contract_value`, compare the exposure of one lot of the nearest Nifty and Reliance futures.
#'
#' @examples
#' \dontrun{
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(format(nifty_future), nifty_future$days_to_expiry, "\n")
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' for (expiry_date in as.list(expiries)) {
#'   future <- EquityFutures$new(
#'     exchange = "nse",
#'     underlying_symbol = "RELIANCE",
#'     expiry_date = expiry_date
#'   )
#'   cat(format(expiry_date), future$days_to_expiry, "\n")
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(format(nifty_future), "expired:", nifty_future$expired, "\n")
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   include_expired = TRUE
#' )
#' oldest_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#' cat(format(oldest_future), "expired:", oldest_future$expired, "\n")
#' cat("Days since expiry:", -oldest_future$days_to_expiry, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' for (expiry_date in as.list(head(expiries, 4))) {
#'   chain <- EquityIndexOption$chain(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date
#'   )
#'   first_row <- chain[1, ]
#'   option <- IndexOption$new(
#'     instrument_id = first_row[["instrument_id"]]
#'   )
#'   cat(format(expiry_date), option$expiry_kind, "\n")
#' }
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(format(reliance_future), reliance_future$expiry_kind, "\n")
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(
#'   format(nifty_future$expiry_date),
#'   "rolls to",
#'   format(nifty_future$next_expiry),
#'   "\n"
#' )
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' next_expiry <- reliance_future$next_expiry
#' if (is.null(next_expiry)) {
#'   cat("There is no later expiry listed.", "\n")
#' } else {
#'   next_future <- EquityFutures$new(
#'     exchange = "nse",
#'     underlying_symbol = "RELIANCE",
#'     expiry_date = next_expiry
#'   )
#'   near_price <- reliance_future$last_price
#'   far_price <- next_future$last_price
#'   cat(sprintf("Near %s, next %s", near_price, far_price), "\n")
#'   cat(
#'     sprintf("Rolling costs %.2f per share", far_price - near_price),
#'     "\n"
#'   )
#' }
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' underlying <- reliance_future$underlying
#' cat(format(underlying), underlying$last_price, "\n")
#'
#' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]],
#'   underlying = reliance
#' )
#' print(identical(reliance_future$underlying, reliance))
#' print(class(reliance_future$underlying)[[1]])
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' index <- nifty_future$underlying
#' cat(class(index)[[1]], index$symbol, index$last_price, "\n")
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat("Index:", nifty_future$underlying_price, "\n")
#' cat("Future:", nifty_future$last_price, "\n")
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' share_price <- reliance_future$underlying_price
#' if (is.null(share_price)) {
#'   cat("UBI has no price for the share.", "\n")
#' } else {
#'   cat(sprintf("Reliance shares at %s", share_price), "\n")
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' print(nifty_future$open_interest_day_high)
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' day_high <- nifty_future$open_interest_day_high
#' now <- nifty_future$open_interest
#' if (is.null(day_high) || is.null(now)) {
#'   cat("The broker does not report the open interest range.", "\n")
#' } else {
#'   cat(
#'     sprintf("Open interest is %s below today's high", day_high - now),
#'     "\n"
#'   )
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' print(nifty_future$open_interest_day_low)
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' day_low <- reliance_future$open_interest_day_low
#' day_high <- reliance_future$open_interest_day_high
#' cat(
#'   sprintf("Open interest ranged from %s to %s", day_low, day_high),
#'   "\n"
#' )
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(
#'   nifty_future$lot_size,
#'   "units worth Rs",
#'   nifty_future$contract_value,
#'   "\n"
#' )
#'
#' nifty_expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = nifty_expiries[[1]]
#' )
#' reliance_expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = reliance_expiries[[1]]
#' )
#' for (future in list(
#'   nifty_future,
#'   reliance_future
#' )) {
#'   cat(
#'     sprintf(
#'       "%s: Rs %s",
#'       future$underlying_symbol,
#'       formatC(future$contract_value, format = "f", digits = 0, big.mark = ",")
#'     ),
#'     "\n"
#'   )
#' }
#' }
#' @export
Derivative <- R6::R6Class(
  "Derivative",
  inherit = TradeableInstrument,
  public = list(
    #' @field underlying_segment The character exchange-prefixed segment of the underlying, such as `"nse_equities"`, `"nse_equity_indices"` or `"mcx_commodity_futures"`: the given underlying's own segment, or else the one the family's default searches, or `NULL` when the family has no default.
    underlying_segment = NULL,

    #' @description
    #' Looks the contract up in UBI and checks that it is a future or an option.
    #' @param instrument_id The character UUID of the contract, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, such as `"equity_futures"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol, or `NULL`, since a contract is named by its underlying.
    #' @param underlying_symbol The character symbol of the contract's underlying, or `NULL`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price The numeric strike price of an option, or `NULL`.
    #' @param option_type The character option type of an option, `"CE"` or `"PE"`, or `NULL`.
    #' @param underlying The `Instrument` the contract is written on, such as an `Equity`, an `EquityIndex` or a future, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Derivative` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `DerivativeError` when the instrument is neither a future nor an option, has no expiry date, or is in a segment with no known underlying segment and no underlying was given; `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      if (!is.null(underlying) && !inherits(underlying, "Instrument")) {
        ErrorCatalogue$raise(
          "TypeError",
          sprintf(
            "The underlying must be an Instrument, not a %s",
            class(underlying)[[1]]
          )
        )
      }
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        unified_broker_interface = unified_broker_interface
      )
      if (!(self$shape %in% INSTRUMENTS_DERIVATIVE_SHAPES)) {
        ErrorCatalogue$raise(
          "DerivativeError",
          sprintf(
            "Only a future or an option is a %s, and this is a %s: %s",
            class(self)[[1]],
            self$shape,
            self$format()
          )
        )
      }
      if (is.null(self$expiry_date)) {
        ErrorCatalogue$raise(
          "DerivativeError",
          sprintf(
            "A contract needs an expiry date, and UBI gave none: %s",
            self$format()
          )
        )
      }
      private$given_underlying <- underlying
      if (!is.null(underlying)) {
        self$underlying_segment <- underlying$segment
      } else {
        self$underlying_segment <- private$underlying_segment_from_table()
      }
    }
  ),
  active = list(
    #' @field days_to_expiry The integer number of calendar days from today until the contract expires, counted in India time.
    days_to_expiry = function(value) {
      if (!missing(value)) {
        stop("days_to_expiry is read-only", call. = FALSE)
      }
      as.integer(self$expiry_date - TimeConverter$new()$today())
    },

    #' @field expired A logical that is `TRUE` when the contract's expiry date has passed, counted in India time. A contract expiring today is not expired, because it can still be traded until the market closes, which matches the rule the discovery functions use.
    expired = function(value) {
      if (!missing(value)) {
        stop("expired is read-only", call. = FALSE)
      }
      self$days_to_expiry < 0
    },

    #' @field expiry_kind The character `"monthly"` when the contract is the month's last expiry for its underlying, or `"weekly"` when it is one of the weekly expiries before it. A contract is monthly when no later contract on the same underlying in the same segment expires in the same calendar month, so quarterly and half-yearly contracts count as monthly. Each read downloads the segment's whole instrument list from UBI, which takes about two seconds for single-stock options.
    expiry_kind = function(value) {
      if (!missing(value)) {
        stop("expiry_kind is read-only", call. = FALSE)
      }
      expiry_dates <- InstrumentCatalogue$new(
        private$unified_broker_interface
      )$expiry_dates(
        self$exchange,
        self$segment,
        self$underlying_symbol,
        TRUE
      )
      own_month <- format(self$expiry_date, "%Y-%m")
      for (expiry_index in seq_along(expiry_dates)) {
        expiry_date <- expiry_dates[[expiry_index]]
        if (expiry_date <= self$expiry_date) {
          next
        }
        if (format(expiry_date, "%Y-%m") == own_month) {
          return(INSTRUMENTS_WEEKLY_EXPIRY_KIND)
        }
      }
      INSTRUMENTS_MONTHLY_EXPIRY_KIND
    },

    #' @field next_expiry The `Date` of the first live expiry after this contract's on the same underlying in the same segment, which is where a position rolls to, or `NULL` when there is none. Each read downloads the segment's whole instrument list from UBI.
    next_expiry = function(value) {
      if (!missing(value)) {
        stop("next_expiry is read-only", call. = FALSE)
      }
      expiry_dates <- InstrumentCatalogue$new(
        private$unified_broker_interface
      )$expiry_dates(
        self$exchange,
        self$segment,
        self$underlying_symbol,
        FALSE
      )
      for (expiry_index in seq_along(expiry_dates)) {
        if (expiry_dates[[expiry_index]] > self$expiry_date) {
          return(expiry_dates[[expiry_index]])
        }
      }
      NULL
    },

    #' @field underlying The `Instrument` the contract is written on, found in the order the class description gives. A given underlying is returned as it is, with no request, whatever its class. Any other is looked up again on every read, so bind it to a local variable to use it more than once: UBI's link or an equity's share or index comes back as a `TradeableInstrument` or `NonTradeableInstrument`, never a family class such as `Equity`, and an option's default future comes back as a `Futures`.
    underlying = function(value) {
      if (!missing(value)) {
        stop("underlying is read-only", call. = FALSE)
      }
      if (!is.null(private$given_underlying)) {
        return(private$given_underlying)
      }
      private$look_up_underlying()
    },

    #' @field underlying_price The underlying's numeric last traded price, or `NULL` when UBI has none, read from UBI on every access as cheaply as the way `underlying` finds it allows: a given underlying's own `last_price`, one request by instrument id for UBI's link, one request by exchange, segment and symbol for an equity's share or index, and the future's lookup and last price for an option priced off a future.
    underlying_price = function(value) {
      if (!missing(value)) {
        stop("underlying_price is read-only", call. = FALSE)
      }
      if (!is.null(private$given_underlying)) {
        return(private$given_underlying$last_price)
      }
      if (!is.null(self$underlying_instrument_id)) {
        response <- private$unified_broker_interface$get(
          INSTRUMENTS_LAST_PRICE_PATH,
          params = list(
            instrument_id = self$underlying_instrument_id
          )
        )
        return(response[["last_price"]])
      }
      if (is.null(self$underlying_segment)) {
        return(private$look_up_underlying()$last_price)
      }
      if (endsWith(self$underlying_segment, INSTRUMENTS_FUTURES_SEGMENT_SUFFIX)) {
        return(private$nearest_future()$last_price)
      }
      response <- tryCatch(
        private$unified_broker_interface$get(
          INSTRUMENTS_LAST_PRICE_PATH,
          params = list(
            exchange = self$exchange,
            segment = self$underlying_segment,
            symbol = self$underlying_symbol
          )
        ),
        NotFoundError = function(error) {
          ErrorCatalogue$raise(
            "UnderlyingError",
            sprintf(
              "UBI has no %s instrument with the symbol %s, so %s has no underlying; give it when building the contract: %s",
              self$underlying_segment,
              self$underlying_symbol,
              self$format(),
              conditionMessage(error)
            ),
            parent = error
          )
        }
      )
      response[["last_price"]]
    },

    #' @field open_interest_day_high The highest integer open interest reached today, or `NULL` when UBI has none.
    open_interest_day_high = function(value) {
      if (!missing(value)) {
        stop("open_interest_day_high is read-only", call. = FALSE)
      }
      self$quote[["oi_day_high"]]
    },

    #' @field open_interest_day_low The lowest integer open interest reached today, or `NULL` when UBI has none.
    open_interest_day_low = function(value) {
      if (!missing(value)) {
        stop("open_interest_day_low is read-only", call. = FALSE)
      }
      self$quote[["oi_day_low"]]
    },

    #' @field contract_value The numeric worth of one lot of the contract at its last price, which is the last price times the lot size, or `NULL` when either is unknown. For a future this is the exposure one lot carries, and for an option it is the premium one lot costs. For currency contracts the lot size is the plurality of the brokers' figures rather than the lot an order is measured against, so there it is approximate.
    contract_value = function(value) {
      if (!missing(value)) {
        stop("contract_value is read-only", call. = FALSE)
      }
      last_price <- self$last_price
      if (is.null(last_price) || is.null(self$lot_size)) {
        return(NULL)
      }
      last_price * self$lot_size
    }
  ),
  private = list(
    given_underlying = NULL,

    #' Works out where the family's default underlying is found, from the contract's own segment.
    #' @return The character exchange-prefixed segment, such as `"nse_equity_indices"`, or `NULL` when the family has no default underlying for this kind of contract.
    #' @details Errors: signals `DerivativeError` when the contract's segment is not one of the sixteen derivative segments in `INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT`.
    underlying_segment_from_table = function() {
      prefix <- paste0(self$exchange, "_")
      bare_segment <- self$segment
      if (startsWith(bare_segment, prefix)) {
        bare_segment <- substring(bare_segment, nchar(prefix) + 1)
      }
      known_segments <- names(INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT)
      if (!(bare_segment %in% known_segments)) {
        ErrorCatalogue$raise(
          "DerivativeError",
          sprintf(
            "The %s segment has no known underlying segment, so give the underlying when building the contract: %s",
            self$segment,
            self$format()
          )
        )
      }
      underlying_bare_segment <- INSTRUMENTS_UNDERLYING_SEGMENT_FOR_DERIVATIVE_SEGMENT[[bare_segment]]
      if (is.null(underlying_bare_segment)) {
        return(NULL)
      }
      paste0(self$exchange, "_", underlying_bare_segment)
    },

    #' Finds the underlying when none was given, trying UBI's link first and then the family's default.
    #' @return The underlying as an `Instrument`: a `TradeableInstrument` or `NonTradeableInstrument` for UBI's link or an equity's share or index, or a `Futures` for an option priced off a future.
    #' @details Errors: signals `UnderlyingError` when UBI gives no link and the family has no default for this contract, or the default finds nothing; and a `UnifiedBrokerInterfaceError` subclass for any other failure.
    look_up_underlying = function() {
      if (!is.null(self$underlying_instrument_id)) {
        linked <- tryCatch(
          TradeableInstrument$new(
            instrument_id = self$underlying_instrument_id,
            unified_broker_interface = private$unified_broker_interface
          ),
          TradeableInstrumentError = function(error) NULL
        )
        if (!is.null(linked)) {
          return(linked)
        }
        return(
          NonTradeableInstrument$new(
            instrument_id = self$underlying_instrument_id,
            unified_broker_interface = private$unified_broker_interface
          )
        )
      }
      if (is.null(self$underlying_segment)) {
        ErrorCatalogue$raise(
          "UnderlyingError",
          sprintf(
            "UBI links %s to no underlying, and a %s contract has no default one, because its cash underlying has no price in UBI; give the underlying when building it",
            self$format(),
            self$segment
          )
        )
      }
      if (endsWith(self$underlying_segment, INSTRUMENTS_FUTURES_SEGMENT_SUFFIX)) {
        return(private$nearest_future())
      }
      tryCatch(
        {
          if (endsWith(self$underlying_segment, INSTRUMENTS_INDEX_SEGMENT_SUFFIX)) {
            NonTradeableInstrument$new(
              exchange = self$exchange,
              segment = self$underlying_segment,
              symbol = self$underlying_symbol,
              unified_broker_interface = private$unified_broker_interface
            )
          } else {
            TradeableInstrument$new(
              exchange = self$exchange,
              segment = self$underlying_segment,
              symbol = self$underlying_symbol,
              unified_broker_interface = private$unified_broker_interface
            )
          }
        },
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "UnderlyingError",
            sprintf(
              "UBI has no %s instrument with the symbol %s, so %s has no underlying; give it when building the contract",
              self$underlying_segment,
              self$underlying_symbol,
              self$format()
            ),
            parent = error
          )
        }
      )
    },

    #' Finds the future the contract is priced off: the same underlying's future that expires first on or after the contract does.
    #'
    #' On or after, rather than in the same month, because an option can settle into a later future: an MCX GOLD option expiring at the end of October settles into the December future, since the October one has already expired.
    #' @return The future as a `Futures`.
    #' @details Errors: signals `UnderlyingError` when no live future on the same underlying expires on or after the contract, and a `UnifiedBrokerInterfaceError` subclass for any other failure.
    nearest_future = function() {
      frame <- InstrumentCatalogue$new(
        private$unified_broker_interface
      )$contracts_for(
        self$exchange,
        self$underlying_segment,
        self$underlying_symbol,
        NULL,
        FALSE
      )
      chosen_instrument_id <- NULL
      chosen_expiry <- NULL
      if (!is.null(frame)) {
        for (row_index in seq_len(nrow(frame))) {
          row_expiry <- frame$expiry_date[[row_index]]
          if (row_expiry < self$expiry_date) {
            next
          }
          if (is.null(chosen_expiry) || row_expiry < chosen_expiry) {
            chosen_instrument_id <- frame$instrument_id[[row_index]]
            chosen_expiry <- row_expiry
          }
        }
      }
      if (is.null(chosen_instrument_id)) {
        ErrorCatalogue$raise(
          "UnderlyingError",
          sprintf(
            "No live %s contract on %s expires on or after %s, so %s has no underlying; give it when building the contract",
            self$underlying_segment,
            self$underlying_symbol,
            format(self$expiry_date, "%Y-%m-%d"),
            self$format()
          )
        )
      }
      Futures$new(
        instrument_id = chosen_instrument_id,
        unified_broker_interface = private$unified_broker_interface
      )
    },

    #' Says whether the contract is priced off a future, which decides between the Black-76 and Black-Scholes models.
    #' @return A logical that is `TRUE` when the given underlying is a future, or, with none given, when the family's default is a future.
    underlying_is_future = function() {
      if (!is.null(private$given_underlying)) {
        return(identical(private$given_underlying$shape, INSTRUMENTS_FUTURE_SHAPE))
      }
      if (is.null(self$underlying_segment)) {
        return(FALSE)
      }
      endsWith(self$underlying_segment, INSTRUMENTS_FUTURES_SEGMENT_SUFFIX)
    }
  )
)

#' A futures contract, an agreement to buy or sell the underlying at a set price on the expiry date
#'
#' @description
#' It holds the members every futures contract shares, such as its basis over the underlying. The family classes such as `EquityFutures` inherit it, and each carries the discovery functions `expiries()` and `contracts()` on its class generator, reading its own segment. Built directly, `Futures` accepts any futures contract, including one on an index.
#'
#' The examples below show its properties and the functions on its class generator, in this order:
#'
#' * For `Futures$expiries()`, list the live expiries of Nifty futures.
#' * For `Futures$expiries()`, count how many Reliance futures expiries UBI remembers, including those that have passed.
#' * For `Futures$expiries()`, show that the base class names no segment, so the family class is the one to call.
#' * For `Futures$contracts()`, list the live Reliance futures with their instrument ids.
#' * For `Futures$contracts()`, count the stock futures listed for the nearest expiry, which is the size of the futures universe.
#' * For `Futures$contracts()`, build a contract object from one row, using its instrument id.
#' * For `basis`, print the basis of the nearest Nifty future over the index.
#' * For `basis`, print the basis of every live Reliance future, which normally grows with the time to expiry.
#' * For `basis_percent`, print the basis of the nearest Nifty future as a percentage of the index.
#' * For `basis_percent`, say whether the nearest Reliance future trades at a premium or a discount to the share.
#' * For `cost_of_carry`, print the annual rate implied by the next month's Nifty future, which has enough days left to mean something.
#' * For `cost_of_carry`, compare the implied carry of Reliance's futures with a 6.5 per cent risk-free rate.
#'
#' @examples
#' \dontrun{
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' for (expiry_date in as.list(expiries)) {
#'   print(expiry_date)
#' }
#'
#' all_expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   include_expired = TRUE
#' )
#' live_expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' cat(
#'   sprintf(
#'     "%s expiries known, %s live",
#'     length(all_expiries),
#'     length(live_expiries)
#'   ),
#'   "\n"
#' )
#'
#' tryCatch(
#'   {
#'     Futures$expiries(
#'       exchange = "nse",
#'       underlying_symbol = "NIFTY"
#'     )
#'   },
#'   FuturesError = function(error) {
#'     cat("Refused:", conditionMessage(error), "\n")
#'   }
#' )
#'
#' contracts <- EquityFutures$contracts(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' print(contracts[, c(
#'   "underlying_symbol",
#'   "expiry_date",
#'   "instrument_id"
#' )])
#'
#' contracts <- EquityFutures$contracts(exchange = "nse")
#' nearest_expiry <- min(contracts$expiry_date)
#' nearest <- contracts[contracts$expiry_date == nearest_expiry, , drop = FALSE]
#' cat(
#'   sprintf(
#'     "%s stock futures expire on %s",
#'     nrow(nearest),
#'     nearest_expiry
#'   ),
#'   "\n"
#' )
#'
#' contracts <- EquityIndexFutures$contracts(
#'   exchange = "nse",
#'   underlying_symbol = "BANKNIFTY"
#' )
#' first_row <- contracts[1, ]
#' future <- IndexFutures$new(instrument_id = first_row[["instrument_id"]])
#' cat(format(future), future$last_price, "\n")
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(sprintf("Basis: %.2f points", nifty_future$basis), "\n")
#'
#' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' for (expiry_date in as.list(expiries)) {
#'   future <- EquityFutures$new(
#'     exchange = "nse",
#'     underlying_symbol = "RELIANCE",
#'     expiry_date = expiry_date,
#'     underlying = reliance
#'   )
#'   cat(format(expiry_date), future$days_to_expiry, future$basis, "\n")
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#'
#' cat(sprintf("%.3f%%", nifty_future$basis_percent), "\n")
#'
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' reliance_future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#'
#' basis_percent <- reliance_future$basis_percent
#' if (is.null(basis_percent)) {
#'   cat("A last price is missing.", "\n")
#' } else if (basis_percent >= 0) {
#'   cat(sprintf("Premium of %.3f%%", basis_percent), "\n")
#' } else {
#'   cat(sprintf("Discount of %.3f%%", -basis_percent), "\n")
#' }
#'
#' expiries <- EquityIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' nifty_future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[2]]
#' )
#' cat(nifty_future$days_to_expiry, "days left", "\n")
#' cat(
#'   sprintf("Cost of carry: %.2f%% a year", nifty_future$cost_of_carry),
#'   "\n"
#' )
#'
#' risk_free_percent <- 6.5
#' reliance <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' expiries <- EquityFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' for (expiry_date in as.list(expiries)) {
#'   future <- EquityFutures$new(
#'     exchange = "nse",
#'     underlying_symbol = "RELIANCE",
#'     expiry_date = expiry_date,
#'     underlying = reliance
#'   )
#'   carry <- future$cost_of_carry
#'   if (is.null(carry)) {
#'     cat(format(expiry_date), "expires today or a price is missing", "\n")
#'   } else if (carry > risk_free_percent) {
#'     cat(format(expiry_date), sprintf("%.2f%%: rich", carry), "\n")
#'   } else {
#'     cat(format(expiry_date), sprintf("%.2f%%: cheap", carry), "\n")
#'   }
#' }
#' }
#' @export
Futures <- R6::R6Class(
  "Futures",
  inherit = Derivative,
  public = list(
    #' @description
    #' Looks the contract up in UBI and checks that it is a futures contract.
    #' @param instrument_id The character UUID of the contract, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, such as `"equity_futures"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol, or `NULL`.
    #' @param underlying_symbol The character symbol of the contract's underlying, or `NULL`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price A numeric strike price, or `NULL`, since a future has none.
    #' @param option_type A character option type, or `NULL`, since a future has none.
    #' @param underlying The `Instrument` the contract is written on, or `NULL` to use UBI's link or the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Futures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `FuturesError` when the instrument is an option rather than a future; `DerivativeError` when the instrument is not a contract at all, or has no expiry date; `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        underlying = underlying,
        unified_broker_interface = unified_broker_interface
      )
      if (self$shape != INSTRUMENTS_FUTURE_SHAPE) {
        ErrorCatalogue$raise(
          "FuturesError",
          sprintf(
            "Only a futures contract is a %s, and this is an %s: %s",
            class(self)[[1]],
            self$shape,
            self$format()
          )
        )
      }
    }
  ),
  active = list(
    #' @field basis The numeric amount by which the future's last price is above the underlying's, read from two quotes that may be a moment apart, or `NULL` when either price is unknown. A positive basis, or premium, is usual, because holding the future instead of the underlying saves the cost of financing it until expiry.
    basis = function(value) {
      if (!missing(value)) {
        stop("basis is read-only", call. = FALSE)
      }
      last_price <- self$last_price
      underlying_price <- self$underlying_price
      if (is.null(last_price) || is.null(underlying_price)) {
        return(NULL)
      }
      last_price - underlying_price
    },

    #' @field basis_percent The basis as a numeric percentage of the underlying's last price, read from two quotes, or `NULL` when either price is unknown or the underlying's price is zero.
    basis_percent = function(value) {
      if (!missing(value)) {
        stop("basis_percent is read-only", call. = FALSE)
      }
      last_price <- self$last_price
      underlying_price <- self$underlying_price
      if (is.null(last_price) || is.null(underlying_price)) {
        return(NULL)
      }
      if (underlying_price == 0) {
        return(NULL)
      }
      (last_price - underlying_price) / underlying_price * INSTRUMENTS_PERCENT
    },

    #' @field cost_of_carry The basis annualised, as a numeric yearly percentage the future's premium implies, read from two quotes, or `NULL` on or after the expiry date or when the basis is unknown. It is the basis percentage scaled by the calendar days left, so a future 0.5 per cent above its underlying with 30 days to go carries about 6.1 per cent a year. In the last few days before expiry the scaling magnifies small differences, so a basis of 0.15 per cent with one day left reads as 55 per cent a year and says little.
    cost_of_carry = function(value) {
      if (!missing(value)) {
        stop("cost_of_carry is read-only", call. = FALSE)
      }
      days_to_expiry <- self$days_to_expiry
      if (days_to_expiry <= 0) {
        return(NULL)
      }
      basis_percent <- self$basis_percent
      if (is.null(basis_percent)) {
        return(NULL)
      }
      basis_percent * INSTRUMENTS_DAYS_PER_YEAR / days_to_expiry
    }
  )
)

Futures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  ErrorCatalogue$raise(
    "FuturesError",
    "Futures names no segment, so call expiries on a family class such as EquityFutures"
  )
}

Futures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  ErrorCatalogue$raise(
    "FuturesError",
    "Futures names no segment, so call contracts on a family class such as EquityFutures"
  )
}

#' An option contract, the right but not the obligation to buy the underlying at the strike price, for a call, or to sell it, for a put
#'
#' @description
#' It holds the members every option shares: its moneyness against the underlying, its premium split into intrinsic and time value, and its implied volatility and greeks from `BlackScholes` or `Black76`. The family classes such as `EquityOption` inherit it, and each carries the discovery functions `expiries()`, `strikes()` and `chain()` on its class generator, reading its own segment. Built directly, `Option` accepts any option, including one on an index.
#'
#' The pricing methods treat the option as European and without dividends, and take it to expire at 15:30 India time on its expiry date, which is what UBI's own order engine assumes. MCX commodity options trade until later in the evening, so for them 15:30 is an approximation.
#'
#' The examples below show its properties and the functions on its class generator, in this order:
#'
#' * For `Option$expiries()`, list the next five Nifty option expiries.
#' * For `Option$expiries()`, compare how many option expiries are listed on an index and on a share.
#' * For `Option$strikes()`, print the lowest and highest strikes and how many there are for the nearest Reliance option expiry.
#' * For `Option$strikes()`, find the at-the-money strike, the listed strike nearest the Nifty level.
#' * For `Option$chain()`, print the first rows of the nearest Nifty option chain.
#' * For `Option$chain()`, count the calls and the puts in a Reliance option chain.
#' * For `Option$chain()`, build the three calls nearest the money from the chain's instrument ids and print their prices.
#' * For `is_call`, check the kind of an at-the-money Nifty option.
#' * For `is_call`, split a list of options into calls and puts.
#' * For `is_put`, check that a contract built with the `PE` option type is a put.
#' * For `is_put`, show that a call is not a put.
#' * For `intrinsic_value`, print the intrinsic value of the at-the-money call and put.
#' * For `intrinsic_value`, compare the intrinsic value of a deep in-the-money Reliance call with its premium.
#' * For `time_value`, print how much of the at-the-money Nifty call's premium is time value.
#' * For `time_value`, compare the time value of the call and the put at the same strike.
#' * For `in_the_money`, say whether the at-the-money call and put are in the money right now.
#' * For `in_the_money`, count the in-the-money calls among five strikes around the money.
#' * For `moneyness_percent`, print how far the at-the-money call and put are from the money.
#' * For `moneyness_percent`, print the moneyness of the lowest and highest Reliance call strikes, one deep in and one far out of the money.
#' * For `breakeven_price`, print the level the Nifty must reach by expiry for a buyer of the at-the-money call to break even.
#' * For `breakeven_price`, print the move needed to break even for the call and the put, as a percentage of the index.
#' * For `premium_per_lot`, print what one lot of the at-the-money Nifty call costs.
#' * For `premium_per_lot`, work out how many lots of the call and the put a budget of Rs 50,000 buys.
#' * For `notional_value`, print the value of the index one lot of the at-the-money call controls.
#' * For `notional_value`, compare the premium with the notional value, which is the leverage an option gives.
#'
#' @examples
#' \dontrun{
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' for (expiry_date in as.list(head(expiries, 5))) {
#'   print(expiry_date)
#' }
#'
#' index_expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' share_expiries <- EquityOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' cat("NIFTY:", length(index_expiries), "\n")
#' cat("RELIANCE:", length(share_expiries), "\n")
#'
#' expiries <- EquityOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' strikes <- EquityOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#' cat(
#'   length(strikes),
#'   "strikes from",
#'   strikes[[1]],
#'   "to",
#'   strikes[[length(strikes)]],
#'   "\n"
#' )
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' cat(
#'   sprintf("Nifty at %s, at-the-money strike %s", level, nearest_strike),
#'   "\n"
#' )
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' chain <- EquityIndexOption$chain(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[1]]
#' )
#' cat(nrow(chain), "contracts", "\n")
#' print(head(
#'   chain[, c(
#'     "strike_price",
#'     "option_type",
#'     "instrument_id"
#'   )]
#' ))
#'
#' expiries <- EquityOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' chain <- EquityOption$chain(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#' print(sort(table(chain$option_type), decreasing = TRUE))
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' chain <- EquityIndexOption$chain(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[2]]
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' calls <- chain[chain$option_type == "CE", , drop = FALSE]
#' calls$distance <- abs(calls$strike_price - level)
#' nearest_calls <- head(calls[order(calls$distance), , drop = FALSE], 3)
#' for (instrument_id in nearest_calls$instrument_id) {
#'   option <- IndexOption$new(instrument_id = instrument_id)
#'   cat(option$strike_price, option$last_price, "\n")
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' cat(format(call), "is a call:", call$is_call, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   if (option$is_call) {
#'     cat("Call:", format(option), "\n")
#'   } else {
#'     cat("Put:", format(option), "\n")
#'   }
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' put <- options[[2]]
#' cat(format(put), "is a put:", put$is_put, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' print(call$is_put)
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   cat(option$option_type, option$intrinsic_value, "\n")
#' }
#'
#' expiries <- EquityOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' strikes <- EquityOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#' call <- EquityOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]],
#'   strike_price = strikes[[1]],
#'   option_type = "CE"
#' )
#' cat("Strike:", call$strike_price, "\n")
#' cat("Intrinsic value:", call$intrinsic_value, "\n")
#' cat("Premium:", call$last_price, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' cat("Premium:", call$last_price, "\n")
#' cat("Time value:", call$time_value, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   cat(option$option_type, option$time_value, "\n")
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   cat(
#'     option$option_type,
#'     option$strike_price,
#'     option$in_the_money,
#'     "\n"
#'   )
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiries[[2]]
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_index <- 1
#' for (index in seq_along(strikes)) {
#'   if (abs(strikes[[index]] - level) < abs(strikes[[nearest_index]] - level)) {
#'     nearest_index <- index
#'   }
#' }
#' in_the_money_count <- 0
#' first_index <- max(1, nearest_index - 2)
#' last_index <- min(length(strikes), nearest_index + 2)
#' for (strike in strikes[first_index:last_index]) {
#'   call <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiries[[2]],
#'     strike_price = strike,
#'     option_type = "CE"
#'   )
#'   if (call$in_the_money) {
#'     in_the_money_count <- in_the_money_count + 1
#'   }
#' }
#' cat(sprintf("%s of 5 calls are in the money", in_the_money_count), "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   cat(
#'     option$option_type,
#'     sprintf("%.3f%%", option$moneyness_percent),
#'     "\n"
#'   )
#' }
#'
#' expiries <- EquityOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE"
#' )
#' strikes <- EquityOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#' for (strike in list(
#'   strikes[[1]],
#'   strikes[[length(strikes)]]
#' )) {
#'   call <- EquityOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "RELIANCE",
#'     expiry_date = expiries[[1]],
#'     strike_price = strike,
#'     option_type = "CE"
#'   )
#'   cat(strike, sprintf("%.2f%%", call$moneyness_percent), "\n")
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' cat(
#'   call$strike_price,
#'   "+",
#'   call$last_price,
#'   "=",
#'   call$breakeven_price,
#'   "\n"
#' )
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' for (option in options) {
#'   breakeven <- option$breakeven_price
#'   move <- (breakeven - level) / level * 100
#'   cat(option$option_type, breakeven, sprintf("%+.2f%%", move), "\n")
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' cat(call$lot_size, "units cost Rs", call$premium_per_lot, "\n")
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' options <- list()
#' for (option_type in c(
#'   "CE",
#'   "PE"
#' )) {
#'   option <- EquityIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "NIFTY",
#'     expiry_date = expiry_date,
#'     strike_price = nearest_strike,
#'     option_type = option_type
#'   )
#'   options[[length(options) + 1]] <- option
#' }
#'
#' budget <- 50000
#' for (option in options) {
#'   premium <- option$premium_per_lot
#'   cat(option$option_type, as.integer(budget %/% premium), "lots", "\n")
#' }
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' cat(
#'   sprintf(
#'     "Rs %s",
#'     formatC(call$notional_value, format = "f", digits = 0, big.mark = ",")
#'   ),
#'   "\n"
#' )
#'
#' expiries <- EquityIndexOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY"
#' )
#' expiry_date <- expiries[[2]]
#' strikes <- EquityIndexOption$strikes(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date
#' )
#' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
#' nearest_strike <- strikes[[1]]
#' for (strike in strikes) {
#'   if (abs(strike - level) < abs(nearest_strike - level)) {
#'     nearest_strike <- strike
#'   }
#' }
#' call <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry_date,
#'   strike_price = nearest_strike,
#'   option_type = "CE"
#' )
#'
#' leverage <- call$notional_value / call$premium_per_lot
#' cat(
#'   sprintf("One rupee of premium controls Rs %.1f of index", leverage),
#'   "\n"
#' )
#' }
#' @export
Option <- R6::R6Class(
  "Option",
  inherit = Derivative,
  public = list(
    #' @description
    #' Looks the option up in UBI and checks that it is an option with a strike price and an option type.
    #' @param instrument_id The character UUID of the option, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, such as `"equity_options"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol, or `NULL`.
    #' @param underlying_symbol The character symbol of the option's underlying, or `NULL`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price The numeric strike price, or `NULL`.
    #' @param option_type The character option type, `"CE"` or `"PE"`, or `NULL`.
    #' @param underlying The `Instrument` the option is written on, or `NULL` to use UBI's link or the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Option` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `OptionError` when the instrument is a future rather than an option, or UBI gave it no strike price or option type; `DerivativeError` when the instrument is not a contract at all, or has no expiry date; `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        underlying = underlying,
        unified_broker_interface = unified_broker_interface
      )
      if (self$shape != INSTRUMENTS_OPTION_SHAPE) {
        ErrorCatalogue$raise(
          "OptionError",
          sprintf(
            "Only an option is an %s, and this is a %s: %s",
            class(self)[[1]],
            self$shape,
            self$format()
          )
        )
      }
      if (is.null(self$strike_price) || is.null(self$option_type)) {
        ErrorCatalogue$raise(
          "OptionError",
          sprintf(
            "An option needs a strike price and an option type, and UBI did not give both: %s",
            self$format()
          )
        )
      }
    },

    #' @description
    #' Finds the volatility at which the pricing model reproduces the option's last price.
    #'
    #' The model is Black-76 when the option is priced off a future, which is the default for an option on a commodity, a currency pair or a bond and the case whenever the given underlying is a future, and Black-Scholes otherwise. The underlying's price is read from UBI unless one is given, and a figure given is taken as the same kind of price, spot or forward, as the underlying it stands in for. The option still needs a last price of its own, which some contracts lack.
    #'
    #' The examples below, in order:
    #'
    #' * Print the implied volatility of the at-the-money Nifty call.
    #' * Compare the call's and the put's implied volatility at the same strike with a 6 per cent rate.
    #' * Ask what the implied volatility would be if the index were one per cent higher at today's premium.
    #' @param risk_free_rate The numeric annual risk-free interest rate, continuously compounded, such as 0.065 for 6.5 per cent.
    #' @param underlying_price The numeric price of the underlying to use, or `NULL` to read the underlying's last price from UBI.
    #' @return The numeric annual volatility, such as 0.12 for 12 per cent, or `NULL` when either price is unknown, when the option is at or past 15:30 India time on its expiry date, or when the premium is below the option's discounted intrinsic value.
    #' @details Errors: signals `ValueError` when `underlying_price` is given and is not above zero; `UnderlyingError` when no underlying price is given and the option's underlying cannot be found; `ServiceUnavailableError` when UBI has no recent quote for the option, or for the underlying when no price is given; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' call <- EquityIndexOption$new(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date,
    #'   strike_price = nearest_strike,
    #'   option_type = "CE"
    #' )
    #'
    #' volatility <- call$implied_volatility()
    #' if (is.null(volatility)) {
    #'   cat("No implied volatility could be found.", "\n")
    #' } else {
    #'   cat(sprintf("%.2f%% a year", volatility * 100), "\n")
    #' }
    #'
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' options <- list()
    #' for (option_type in c(
    #'   "CE",
    #'   "PE"
    #' )) {
    #'   option <- EquityIndexOption$new(
    #'     exchange = "nse",
    #'     underlying_symbol = "NIFTY",
    #'     expiry_date = expiry_date,
    #'     strike_price = nearest_strike,
    #'     option_type = option_type
    #'   )
    #'   options[[length(options) + 1]] <- option
    #' }
    #'
    #' for (option in options) {
    #'   volatility <- option$implied_volatility(risk_free_rate = 0.06)
    #'   cat(option$option_type, volatility, "\n")
    #' }
    #'
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' call <- EquityIndexOption$new(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date,
    #'   strike_price = nearest_strike,
    #'   option_type = "CE"
    #' )
    #'
    #' volatility <- call$implied_volatility(underlying_price = level * 1.01)
    #' cat("At an index 1% higher:", volatility, "\n")
    #' }
    implied_volatility = function(
      risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
      underlying_price = NULL
    ) {
      years_to_expiry <- private$years_to_expiry()
      if (years_to_expiry <= 0) {
        return(NULL)
      }
      if (is.null(underlying_price)) {
        underlying_price <- self$underlying_price
      }
      premium <- self$last_price
      if (is.null(underlying_price) || is.null(premium)) {
        return(NULL)
      }
      if (private$underlying_is_future()) {
        return(
          Black76$implied_volatility(
            premium,
            underlying_price,
            self$strike_price,
            years_to_expiry,
            risk_free_rate,
            self$is_call
          )
        )
      }
      BlackScholes$implied_volatility(
        premium,
        underlying_price,
        self$strike_price,
        years_to_expiry,
        risk_free_rate,
        self$is_call
      )
    },

    #' @description
    #' Works out the option's fair price and greeks with the pricing model that fits its underlying.
    #'
    #' The model is Black-76 when the option is priced off a future and Black-Scholes otherwise, as `implied_volatility()` explains, and the answer names it. Under Black-76 delta and gamma are measured against the future's price, and rho holds that price still, so it only discounts. Without a volatility, the option's implied volatility is used, so the fair price equals the last price and the greeks describe the option as the market prices it. Theta is per calendar day, and vega and rho are per percentage point, which is how brokers' option chains show them.
    #'
    #' The examples below, in order:
    #'
    #' * Print the greeks of the at-the-money Nifty call at its implied volatility.
    #' * Work out the fair value of the call at a volatility of 15 per cent and compare it with its premium.
    #' * Add up the delta of a straddle, one call and one put at the same strike, which is close to zero at the money.
    #' @param risk_free_rate The numeric annual risk-free interest rate, continuously compounded, such as 0.065 for 6.5 per cent.
    #' @param volatility The numeric annual volatility to use, such as 0.12 for 12 per cent, or `NULL` to use the option's implied volatility.
    #' @param underlying_price The numeric price of the underlying to use, or `NULL` to read the underlying's last price from UBI.
    #' @return A named list with `model`, the character `"black_76"` or `"black_scholes"`, and `volatility`, `price`, `delta`, `gamma`, `theta`, `vega` and `rho`, each numeric, or `NULL` when the prices needed are unknown, when the option is at or past 15:30 India time on its expiry date, or when no implied volatility can be found.
    #' @details Errors: signals `ValueError` when `underlying_price` or `volatility` is given and is not above zero; `UnderlyingError` when no underlying price is given and the option's underlying cannot be found; `ServiceUnavailableError` when UBI has no recent quote for the option, or for the underlying when no price is given; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' call <- EquityIndexOption$new(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date,
    #'   strike_price = nearest_strike,
    #'   option_type = "CE"
    #' )
    #'
    #' greeks <- call$greeks()
    #' if (is.null(greeks)) {
    #'   cat("The greeks could not be worked out.", "\n")
    #' } else {
    #'   for (name in names(greeks)) {
    #'     value <- greeks[[name]]
    #'     cat(name, value, "\n")
    #'   }
    #' }
    #'
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' call <- EquityIndexOption$new(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date,
    #'   strike_price = nearest_strike,
    #'   option_type = "CE"
    #' )
    #'
    #' greeks <- call$greeks(volatility = 0.15)
    #' cat("Model:", greeks[["model"]], "\n")
    #' cat("Fair value:", round(greeks[["price"]], 2), "\n")
    #' cat("Premium:", call$last_price, "\n")
    #'
    #' expiries <- EquityIndexOption$expiries(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY"
    #' )
    #' expiry_date <- expiries[[2]]
    #' strikes <- EquityIndexOption$strikes(
    #'   exchange = "nse",
    #'   underlying_symbol = "NIFTY",
    #'   expiry_date = expiry_date
    #' )
    #' level <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")$last_price
    #' nearest_strike <- strikes[[1]]
    #' for (strike in strikes) {
    #'   if (abs(strike - level) < abs(nearest_strike - level)) {
    #'     nearest_strike <- strike
    #'   }
    #' }
    #' options <- list()
    #' for (option_type in c(
    #'   "CE",
    #'   "PE"
    #' )) {
    #'   option <- EquityIndexOption$new(
    #'     exchange = "nse",
    #'     underlying_symbol = "NIFTY",
    #'     expiry_date = expiry_date,
    #'     strike_price = nearest_strike,
    #'     option_type = option_type
    #'   )
    #'   options[[length(options) + 1]] <- option
    #' }
    #'
    #' total_delta <- 0.0
    #' for (option in options) {
    #'   greeks <- option$greeks()
    #'   cat(option$option_type, round(greeks[["delta"]], 3), "\n")
    #'   total_delta <- total_delta + greeks[["delta"]]
    #' }
    #' cat("Straddle delta:", round(total_delta, 3), "\n")
    #' }
    greeks = function(
      risk_free_rate = OPTION_PRICING_DEFAULT_RISK_FREE_RATE,
      volatility = NULL,
      underlying_price = NULL
    ) {
      years_to_expiry <- private$years_to_expiry()
      if (years_to_expiry <= 0) {
        return(NULL)
      }
      if (is.null(underlying_price)) {
        underlying_price <- self$underlying_price
      }
      if (is.null(underlying_price)) {
        return(NULL)
      }
      if (is.null(volatility)) {
        volatility <- self$implied_volatility(
          risk_free_rate = risk_free_rate,
          underlying_price = underlying_price
        )
      }
      if (is.null(volatility)) {
        return(NULL)
      }
      if (private$underlying_is_future()) {
        model <- Black76$new(
          underlying_price,
          self$strike_price,
          years_to_expiry,
          risk_free_rate,
          volatility,
          self$is_call
        )
        model_name <- INSTRUMENTS_BLACK_76_MODEL
      } else {
        model <- BlackScholes$new(
          underlying_price,
          self$strike_price,
          years_to_expiry,
          risk_free_rate,
          volatility,
          self$is_call
        )
        model_name <- INSTRUMENTS_BLACK_SCHOLES_MODEL
      }
      list(
        model = model_name,
        volatility = volatility,
        price = model$price,
        delta = model$delta,
        gamma = model$gamma,
        theta = model$theta,
        vega = model$vega,
        rho = model$rho
      )
    }
  ),
  active = list(
    #' @field is_call A logical that is `TRUE` when the option is a call, the right to buy the underlying.
    is_call = function(value) {
      if (!missing(value)) {
        stop("is_call is read-only", call. = FALSE)
      }
      identical(self$option_type, INSTRUMENTS_CALL_OPTION_TYPE)
    },

    #' @field is_put A logical that is `TRUE` when the option is a put, the right to sell the underlying.
    is_put = function(value) {
      if (!missing(value)) {
        stop("is_put is read-only", call. = FALSE)
      }
      identical(self$option_type, INSTRUMENTS_PUT_OPTION_TYPE)
    },

    #' @field intrinsic_value The numeric worth of the option if exercised now, read from the underlying's last price, or `NULL` when that price is unknown. For a call it is how far the underlying is above the strike, and for a put how far it is below, and it is never less than zero.
    intrinsic_value = function(value) {
      if (!missing(value)) {
        stop("intrinsic_value is read-only", call. = FALSE)
      }
      underlying_price <- self$underlying_price
      if (is.null(underlying_price)) {
        return(NULL)
      }
      private$intrinsic_value_at(underlying_price)
    },

    #' @field time_value The numeric part of the premium above the intrinsic value, which is what the time left until expiry is worth, read from two quotes, or `NULL` when either is unknown.
    time_value = function(value) {
      if (!missing(value)) {
        stop("time_value is read-only", call. = FALSE)
      }
      last_price <- self$last_price
      intrinsic_value <- self$intrinsic_value
      if (is.null(last_price) || is.null(intrinsic_value)) {
        return(NULL)
      }
      last_price - intrinsic_value
    },

    #' @field in_the_money A logical that is `TRUE` when the option has intrinsic value, read from the underlying's last price, or `NULL` when that price is unknown.
    in_the_money = function(value) {
      if (!missing(value)) {
        stop("in_the_money is read-only", call. = FALSE)
      }
      intrinsic_value <- self$intrinsic_value
      if (is.null(intrinsic_value)) {
        return(NULL)
      }
      intrinsic_value > 0
    },

    #' @field moneyness_percent How far the option is in or out of the money, as a numeric percentage of the underlying's last price, or `NULL` when that price is unknown or zero. Positive means in the money and negative means out of it, for a call and a put alike, so a call struck 2 per cent above the underlying reads about -2.
    moneyness_percent = function(value) {
      if (!missing(value)) {
        stop("moneyness_percent is read-only", call. = FALSE)
      }
      underlying_price <- self$underlying_price
      if (is.null(underlying_price) || underlying_price == 0) {
        return(NULL)
      }
      distance <- (underlying_price - self$strike_price) / underlying_price *
        INSTRUMENTS_PERCENT
      if (self$is_call) {
        return(distance)
      }
      -distance
    },

    #' @field breakeven_price The numeric underlying price at expiry at which a buyer of the option at its last price neither gains nor loses, or `NULL` when the last price is unknown.
    breakeven_price = function(value) {
      if (!missing(value)) {
        stop("breakeven_price is read-only", call. = FALSE)
      }
      last_price <- self$last_price
      if (is.null(last_price)) {
        return(NULL)
      }
      if (self$is_call) {
        return(self$strike_price + last_price)
      }
      self$strike_price - last_price
    },

    #' @field premium_per_lot The numeric cost of buying one lot of the option at its last price, which is the last price times the lot size, or `NULL` when either is unknown.
    premium_per_lot = function(value) {
      if (!missing(value)) {
        stop("premium_per_lot is read-only", call. = FALSE)
      }
      self$contract_value
    },

    #' @field notional_value The numeric value of the underlying one lot controls at the strike price, which is the strike times the lot size, or `NULL` when the lot size is unknown.
    notional_value = function(value) {
      if (!missing(value)) {
        stop("notional_value is read-only", call. = FALSE)
      }
      if (is.null(self$lot_size)) {
        return(NULL)
      }
      self$strike_price * self$lot_size
    }
  ),
  private = list(
    #' Works out the option's intrinsic value at a given underlying price.
    #' @param underlying_price The numeric price of the underlying.
    #' @return The numeric intrinsic value, never less than zero.
    intrinsic_value_at = function(underlying_price) {
      if (self$is_call) {
        return(max(underlying_price - self$strike_price, 0))
      }
      max(self$strike_price - underlying_price, 0)
    },

    #' Works out the time from now until 15:30 India time on the expiry date, in years.
    #' @return The numeric number of years, which is zero or negative at or after that moment.
    years_to_expiry = function() {
      converter <- TimeConverter$new()
      expiry_moment <- converter$moment_on(self$expiry_date, INSTRUMENTS_EXPIRY_TIME)
      seconds_left <- as.numeric(expiry_moment) - as.numeric(converter$now())
      seconds_left / INSTRUMENTS_SECONDS_PER_YEAR
    }
  )
)

Option$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  ErrorCatalogue$raise(
    "OptionError",
    "Option names no segment, so call expiries on a family class such as EquityOption"
  )
}

Option$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  ErrorCatalogue$raise(
    "OptionError",
    "Option names no segment, so call chain on a family class such as EquityOption"
  )
}

Option$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  ErrorCatalogue$raise(
    "OptionError",
    "Option names no segment, so call chain on a family class such as EquityOption"
  )
}

#' A futures contract on an index, which settles in cash because an index cannot be delivered
#'
#' @description
#' It adds a guarantee to `Futures` rather than members: the contract is in an index futures segment, so its default underlying is the index, found by symbol as a `NonTradeableInstrument` unless it is given or UBI links it. The family classes such as `EquityIndexFutures` inherit it.
#'
#' @export
IndexFutures <- R6::R6Class(
  "IndexFutures",
  inherit = Futures,
  public = list(
    #' @description
    #' Looks the contract up in UBI and checks that it is a futures contract on an index.
    #' @param instrument_id The character UUID of the contract, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, such as `"equity_index_futures"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol, or `NULL`.
    #' @param underlying_symbol The character symbol of the index, such as `"NIFTY"`, or `NULL`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price A numeric strike price, or `NULL`, since a future has none.
    #' @param option_type A character option type, or `NULL`, since a future has none.
    #' @param underlying The `Instrument` the contract is written on, or `NULL` to use UBI's link or the family's default.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `IndexFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `IndexFuturesError` when the contract is a future on something other than an index; `FuturesError` when the instrument is an option rather than a future; `DerivativeError` when the instrument is not a contract at all, or has no expiry date; `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        underlying = underlying,
        unified_broker_interface = unified_broker_interface
      )
      if (!endsWith(self$segment, INSTRUMENTS_INDEX_FUTURES_SEGMENT_SUFFIX)) {
        ErrorCatalogue$raise(
          "IndexFuturesError",
          sprintf(
            "Only a futures contract on an index is an %s, and this is in %s: %s",
            class(self)[[1]],
            self$segment,
            self$format()
          )
        )
      }
    }
  )
)

#' An option on an index, which settles in cash because an index cannot be delivered
#'
#' @description
#' It adds a guarantee to `Option` rather than members: the option is in an index options segment, so its default underlying is the index, found by symbol as a `NonTradeableInstrument` unless it is given or UBI links it. The family classes such as `EquityIndexOption` inherit it.
#'
#' @export
IndexOption <- R6::R6Class(
  "IndexOption",
  inherit = Option,
  public = list(
    #' @description
    #' Looks the option up in UBI and checks that it is an option on an index.
    #' @param instrument_id The character UUID of the option, or `NULL` to look it up by exchange, segment and identity fields.
    #' @param exchange The character exchange, such as `"nse"`, or `NULL` when `instrument_id` is given.
    #' @param segment The character segment, such as `"equity_index_options"`, or `NULL` when `instrument_id` is given.
    #' @param symbol The character symbol, or `NULL`.
    #' @param underlying_symbol The character symbol of the index, such as `"NIFTY"`, or `NULL`.
    #' @param expiry_date The expiry as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL`.
    #' @param strike_price The numeric strike price, or `NULL`.
    #' @param option_type The character option type, `"CE"` or `"PE"`, or `NULL`.
    #' @param underlying The `Instrument` the option is written on, or `NULL` to use UBI's link or the family's default.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `IndexOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `IndexOptionError` when the option is written on something other than an index; `OptionError` when the instrument is a future rather than an option, or UBI gave it no strike price or option type; `DerivativeError` when the instrument is not a contract at all, or has no expiry date; `TradeableInstrumentError` when the instrument is an index; `InstrumentError` when UBI has no instrument matching the lookup; `BadRequestError` when the lookup is incomplete or malformed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      instrument_id = NULL,
      exchange = NULL,
      segment = NULL,
      symbol = NULL,
      underlying_symbol = NULL,
      expiry_date = NULL,
      strike_price = NULL,
      option_type = NULL,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      super$initialize(
        instrument_id = instrument_id,
        exchange = exchange,
        segment = segment,
        symbol = symbol,
        underlying_symbol = underlying_symbol,
        expiry_date = expiry_date,
        strike_price = strike_price,
        option_type = option_type,
        underlying = underlying,
        unified_broker_interface = unified_broker_interface
      )
      if (!endsWith(self$segment, INSTRUMENTS_INDEX_OPTIONS_SEGMENT_SUFFIX)) {
        ErrorCatalogue$raise(
          "IndexOptionError",
          sprintf(
            "Only an option on an index is an %s, and this is in %s: %s",
            class(self)[[1]],
            self$segment,
            self$format()
          )
        )
      }
    }
  )
)
