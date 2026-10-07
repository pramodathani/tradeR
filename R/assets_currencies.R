CURRENCIES_SEARCH_LIMIT <- 50
CURRENCIES_CURRENCY_SEGMENT <- "currencies"
CURRENCIES_CURRENCY_FUTURES_SEGMENT <- "currency_futures"
CURRENCIES_CURRENCY_OPTIONS_SEGMENT <- "currency_options"
CURRENCIES_CURRENCY_INDICES_SEGMENT <- "currency_indices"
CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT <- "currency_index_futures"
CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT <- "currency_index_options"

#' One currency pair the exchange publishes as an underlying, such as USDINR on the nse
#'
#' @description
#' The currency family has six classes, each fixing one of UBI's currency segments, so the kind of contract is the class rather than a segment name passed by hand, and each constructor asks for exactly the fields that identify one of its own contracts. `Currency` and `CurrencyIndex` are named by exchange and symbol, the futures classes by exchange, underlying symbol and expiry date, and the option classes by those three plus a strike price and an option type. All six inherit every analysis class through `Instrument`.
#'
#' Symbols are the readable pair names, and UBI carries only seven of them on the nse: `EURINR`, `EURUSD`, `GBPINR`, `GBPUSD`, `JPYINR`, `USDINR` and `USDJPY`. The bse adds over-the-counter variants such as `EURINROTC`. Currencies trade on the nse and the bse only.
#'
#' Half of this family does not exist in UBI. There are no rows at all in `currency_indices`, `currency_index_futures` or `currency_index_options`, on any exchange, and no broker maps anything into them, so `CurrencyIndex`, `CurrencyIndexFutures` and `CurrencyIndexOption` resolve nothing today. They are written so that the family has the same shape as every other asset class and so that they work the moment UBI gains a mapping, and they fail cleanly: a lookup signals the class's own error and the discovery functions return an empty vector or `NULL`.
#'
#' Ordering here works as it does for commodities rather than for shares. A quantity is counted in quotation units and must be a whole number of lots, because a currency market is not a securities market, so UBI measures the quantity against the contract's size and refuses anything that is not an exact multiple. Do not work an order quantity out from `lot_size`, which is the plurality of the brokers' own figures rather than the lot UBI measures an order against. An order can also be refused with HTTP 503 and a `contract_size_status` when UBI does not trust the contract's size for the day, which means the contract rather than the service is the problem.
#'
#' A `Currency` cannot be ordered at all, although it inherits every order method. Its rows are the exchange's underlying reference records rather than tradeable spot contracts, no broker declares a cash market for currencies, and UBI's contract size check refuses any order in this family that is not a future or an option.
#'
#' Coverage of prices is thinner than for commodities. A currency pair itself has no quote, because the tick streams only resolve a token to a derivative segment. The nse derivatives are quoted, the bse ones are not, and UBI stores no candles for anything in this family, so `prices()` returns `NULL` and the analysis methods have nothing to work on.
#'
#' No broker that serves quotes carries a currency pair itself, on the nse or the bse, so the two option classes find their underlying as the future on the same pair that expires first on or after the option, and price with Black-76. The two futures classes have no default underlying, so their `underlying_price` and basis members signal `UnderlyingError` unless one is given. A bse contract has no quote of its own either, so it cannot be priced at all, and the bse `USDINR-CNV` and `USDINR-STD` options have no future to be priced off.
#'
#' UBI cannot report a currency as a holding, so no class in this family has holdings members; positions do cover the family.
#'
#' The class generator carries one discovery function:
#'
#' * `Currency$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds currency pairs whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"USD"` finds USDINR near the top. UBI carries only seven pairs on the nse, so a short term may return all of them. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no pair matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' pair <- Currency$new(exchange = "nse", symbol = "USDINR")
#'
#' matches <- Currency$search(exchange = "nse", term = "USD")
#' print(matches$symbol)
#'
#' matches <- Currency$search(exchange = "bse", term = "OTC", limit = 200)
#' print(matches$symbol)
#'
#' exchanges <- c(
#'   "nse",
#'   "bse"
#' )
#' for (exchange in exchanges) {
#'   matches <- Currency$search(exchange = exchange, term = "", limit = 200)
#'   if (is.null(matches)) {
#'     cat(exchange, ": 0 pairs\n", sep = "")
#'   } else {
#'     cat(exchange, ": ", nrow(matches), " pairs\n", sep = "")
#'   }
#' }
#' }
#' @export
Currency <- R6::R6Class(
  "Currency",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the pair up in UBI's currencies segment and keeps its details.
    #'
    #' A currency pair cannot be ordered or quoted, although it inherits the methods for both. Its row is the exchange's underlying reference record rather than a tradeable spot contract, so an order is refused by UBI and a quote signals `ServiceUnavailableError`. Use `CurrencyFutures` or `CurrencyOption` to trade it.
    #' @param exchange The character exchange the pair is published on, `"nse"` or `"bse"`.
    #' @param symbol The character symbol of the pair, such as `"USDINR"` or `"EURINR"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Currency` object.
    #' @details Errors: signals `CurrencyError` when UBI has no pair with that symbol on that exchange, or the instrument it returned is not in the currencies segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyError",
            sprintf(
              "UBI has no %s currency pair for the symbol %s",
              exchange,
              symbol
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyError",
          sprintf(
            "An instrument outside the %s segment is not a Currency: %s",
            CURRENCIES_CURRENCY_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

Currency$search <- function(
  exchange,
  term,
  limit = CURRENCIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, CURRENCIES_CURRENCY_SEGMENT, term, limit)
}

#' One futures contract on a currency pair, such as USDINR expiring in September
#'
#' @description
#' Built on `Futures`, so it carries the order-book values, the expiry and underlying members and the basis. It has no default underlying, because a currency pair itself has no quote, so `underlying_price` and the basis members signal `UnderlyingError` unless an underlying is given or UBI links one.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots. Only the nse contracts are quoted; a bse contract resolves but has no quote, so `last_price` signals `ServiceUnavailableError` there.
#'
#' The class generator carries two discovery functions, which read the currency futures segment:
#'
#' * `CurrencyFutures$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the pair's futures are listed for as a `Date` vector, soonest first, which is empty when nothing is listed. A contract expiring today counts as live.
#' * `CurrencyFutures$contracts(exchange, underlying_symbol = NULL, include_expired = FALSE, unified_broker_interface = NULL)` lists the contracts as a `data.frame` of identities, with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol` and `expiry_date`, sorted by expiry, or `NULL` when nothing matches.
#'
#' Both signal `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' expiries <- CurrencyFutures$expiries(exchange = "nse", underlying_symbol = "USDINR")
#' contract <- CurrencyFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "USDINR",
#'   expiry_date = expiries[[1]]
#' )
#' rate <- contract$last_price
#' }
#' @export
CurrencyFutures <- R6::R6Class(
  "CurrencyFutures",
  inherit = Futures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's currency futures segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots. Only the nse contracts are quoted; a bse contract resolves but has no quote, so `last_price` signals `ServiceUnavailableError` there.
    #' @param exchange The character exchange the contract trades on, `"nse"` or `"bse"`.
    #' @param underlying_symbol The character symbol of the pair the contract is written on, such as `"USDINR"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as the `Currency` it is written on, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CurrencyFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CurrencyFuturesError` when UBI has no such contract, or the instrument it returned is not in the currency futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      exchange,
      underlying_symbol,
      expiry_date,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyFuturesError",
            sprintf(
              "UBI has no %s currency futures contract on %s expiring %s",
              exchange,
              underlying_symbol,
              format(expiry_date)
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a CurrencyFutures: %s",
            CURRENCIES_CURRENCY_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CurrencyFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    CURRENCIES_CURRENCY_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CurrencyFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    CURRENCIES_CURRENCY_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a currency pair, such as a USDINR call at a given strike and expiry
#'
#' @description
#' Built on `Option`, so it carries the order-book values, the expiry and underlying members, the moneyness members, and `implied_volatility()` and `greeks()`. Unless an underlying is given or UBI links one, it finds its underlying as the future on the same pair that expires first on or after the option, and prices with Black-76. A bse option has no quote and cannot be priced.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots.
#'
#' The class generator carries three discovery functions, which read the currency options segment:
#'
#' * `CurrencyOption$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the pair's options are listed for as a `Date` vector, soonest first.
#' * `CurrencyOption$strikes(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists the strike prices for one expiry as a numeric vector, lowest first. It builds the chain and takes its distinct strikes, so it costs the same as `chain()`.
#' * `CurrencyOption$chain(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists every option for one expiry as a `data.frame` of identities with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol`, `expiry_date`, `strike_price` and `option_type`, sorted by strike price and then option type, or `NULL` when nothing matches.
#'
#' Each signals `BadRequestError` when the exchange is not one UBI knows, and a plain error when `expiry_date` is text that is not a valid ISO date.
#'
#' @examples
#' \dontrun{
#' expiries <- CurrencyFutures$expiries(exchange = "nse", underlying_symbol = "USDINR")
#' chain <- CurrencyOption$chain(
#'   exchange = "nse",
#'   underlying_symbol = "USDINR",
#'   expiry_date = expiries[[1]]
#' )
#' option <- CurrencyOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "USDINR",
#'   expiry_date = expiries[[1]],
#'   strike_price = 95.625,
#'   option_type = "CE"
#' )
#' option$implied_volatility()
#' }
#' @export
CurrencyOption <- R6::R6Class(
  "CurrencyOption",
  inherit = Option,
  public = list(
    #' @description
    #' Looks the option up in UBI's currency options segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots.
    #' @param exchange The character exchange the option trades on, `"nse"` or `"bse"`.
    #' @param underlying_symbol The character symbol of the pair the option is written on, such as `"USDINR"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option, quoted in the pair's own rate units.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the `CurrencyFutures` it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CurrencyOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CurrencyOptionError` when UBI has no such option, or the instrument it returned is not in the currency options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      exchange,
      underlying_symbol,
      expiry_date,
      strike_price,
      option_type,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyOptionError",
            sprintf(
              "UBI has no %s currency option on %s expiring %s at strike %s %s",
              exchange,
              underlying_symbol,
              format(expiry_date),
              format(strike_price),
              option_type
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyOptionError",
          sprintf(
            "An instrument outside the %s segment is not a CurrencyOption: %s",
            CURRENCIES_CURRENCY_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CurrencyOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    CURRENCIES_CURRENCY_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CurrencyOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    CURRENCIES_CURRENCY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

CurrencyOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    CURRENCIES_CURRENCY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

#' One currency index, which UBI carries none of yet
#'
#' @description
#' Built on `NonTradeableInstrument`, because an index cannot be traded. No broker UBI maps lists a currency index, so the segment is empty and every lookup signals `CurrencyIndexError` today. The class exists so that the family is complete and so that these instruments work the moment UBI gains a mapping for them.
#'
#' The class generator carries one discovery function:
#'
#' * `CurrencyIndex$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds currency indices whose symbol contains `term`, of which there are none. It returns a `data.frame` of identities, or `NULL`, which is what it returns while UBI carries no currency index, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' matches <- CurrencyIndex$search(exchange = "nse", term = "")
#' if (is.null(matches)) {
#'   cat("UBI carries no currency index on the nse.\n")
#' } else {
#'   print(matches$symbol)
#' }
#'
#' exchanges <- c(
#'   "nse",
#'   "bse"
#' )
#' for (exchange in exchanges) {
#'   matches <- CurrencyIndex$search(exchange = exchange, term = "USD")
#'   if (is.null(matches)) {
#'     cat(exchange, ": no currency index\n", sep = "")
#'   } else {
#'     cat(exchange, ": ", nrow(matches), " indices\n", sep = "")
#'   }
#' }
#' }
#' @export
CurrencyIndex <- R6::R6Class(
  "CurrencyIndex",
  inherit = NonTradeableInstrument,
  public = list(
    #' @description
    #' Looks the index up in UBI's currency indices segment and keeps its details.
    #'
    #' No broker UBI maps lists a currency index, so this segment is empty and every lookup signals `CurrencyIndexError` today. The class exists so that the family is complete and so that these instruments work the moment UBI gains a mapping for them.
    #' @param exchange The character exchange that publishes the index, `"nse"` or `"bse"`.
    #' @param symbol The character symbol of the index.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CurrencyIndex` object.
    #' @details Errors: signals `CurrencyIndexError` when UBI has no such index, which is true of every symbol today, or the instrument it returned is not in the currency indices segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_INDICES_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyIndexError",
            sprintf(
              "UBI has no %s currency index for the symbol %s",
              exchange,
              symbol
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_INDICES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyIndexError",
          sprintf(
            "An instrument outside the %s segment is not a CurrencyIndex: %s",
            CURRENCIES_CURRENCY_INDICES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CurrencyIndex$search <- function(
  exchange,
  term,
  limit = CURRENCIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, CURRENCIES_CURRENCY_INDICES_SEGMENT, term, limit)
}

#' One futures contract on a currency index, which UBI carries none of yet
#'
#' @description
#' Built on `IndexFutures`. No broker UBI maps lists a futures contract on a currency index, so the segment is empty and every lookup signals `CurrencyIndexFuturesError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them.
#'
#' The class generator carries the discovery functions `CurrencyIndexFutures$expiries()` and `CurrencyIndexFutures$contracts()`, which take the same arguments and return the same shapes as `CurrencyFutures$expiries()` and `CurrencyFutures$contracts()`, reading the currency index futures segment. Today they return an empty `Date` vector and `NULL`, without signalling anything.
#'
#' @examples
#' \dontrun{
#' CurrencyIndexFutures$expiries(exchange = "nse", underlying_symbol = "USDINR")
#' CurrencyIndexFutures$contracts(exchange = "nse")
#' }
#' @export
CurrencyIndexFutures <- R6::R6Class(
  "CurrencyIndexFutures",
  inherit = IndexFutures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's currency index futures segment and keeps its details.
    #'
    #' No broker UBI maps lists a futures contract on a currency index, so this segment is empty and every lookup signals `CurrencyIndexFuturesError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them.
    #' @param exchange The character exchange the contract trades on, `"nse"` or `"bse"`.
    #' @param underlying_symbol The character symbol of the index the contract is written on.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as the `CurrencyIndex` it is written on, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CurrencyIndexFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CurrencyIndexFuturesError` when UBI has no such contract, which is true of every one today, or the instrument it returned is not in the currency index futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      exchange,
      underlying_symbol,
      expiry_date,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyIndexFuturesError",
            sprintf(
              "UBI has no %s currency index futures contract on %s expiring %s",
              exchange,
              underlying_symbol,
              format(expiry_date)
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyIndexFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a CurrencyIndexFutures: %s",
            CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CurrencyIndexFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CurrencyIndexFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    CURRENCIES_CURRENCY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a currency index, which UBI carries none of yet
#'
#' @description
#' Built on `IndexOption`. No broker UBI maps lists an option on a currency index, so the segment is empty and every lookup signals `CurrencyIndexOptionError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them.
#'
#' The class generator carries the discovery functions `CurrencyIndexOption$expiries()`, `CurrencyIndexOption$strikes()` and `CurrencyIndexOption$chain()`, which take the same arguments and return the same shapes as those on `CurrencyOption`, reading the currency index options segment. Today they return an empty `Date` vector, an empty numeric vector and `NULL`, without signalling anything.
#'
#' @examples
#' \dontrun{
#' CurrencyIndexOption$expiries(exchange = "nse", underlying_symbol = "USDINR")
#' CurrencyIndexOption$strikes("nse", "USDINR", "2026-10-28")
#' CurrencyIndexOption$chain("nse", "USDINR", "2026-10-28")
#' }
#' @export
CurrencyIndexOption <- R6::R6Class(
  "CurrencyIndexOption",
  inherit = IndexOption,
  public = list(
    #' @description
    #' Looks the option up in UBI's currency index options segment and keeps its details.
    #'
    #' No broker UBI maps lists an option on a currency index, so this segment is empty and every lookup signals `CurrencyIndexOptionError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them.
    #' @param exchange The character exchange the option trades on, `"nse"` or `"bse"`.
    #' @param underlying_symbol The character symbol of the index the option is written on.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option in the index's own units.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the `CurrencyIndexFutures` it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CurrencyIndexOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CurrencyIndexOptionError` when UBI has no such option, which is true of every one today, or the instrument it returned is not in the currency index options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(
      exchange,
      underlying_symbol,
      expiry_date,
      strike_price,
      option_type,
      underlying = NULL,
      unified_broker_interface = NULL
    ) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CurrencyIndexOptionError",
            sprintf(
              "UBI has no %s currency index option on %s expiring %s at strike %s %s",
              exchange,
              underlying_symbol,
              format(expiry_date),
              format(strike_price),
              option_type
            ),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CurrencyIndexOptionError",
          sprintf(
            "An instrument outside the %s segment is not a CurrencyIndexOption: %s",
            CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CurrencyIndexOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CurrencyIndexOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

CurrencyIndexOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    CURRENCIES_CURRENCY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}
