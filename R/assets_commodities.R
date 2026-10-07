COMMODITIES_SEARCH_LIMIT <- 50
COMMODITIES_COMMODITY_SEGMENT <- "commodities"
COMMODITIES_COMMODITY_FUTURES_SEGMENT <- "commodity_futures"
COMMODITIES_COMMODITY_OPTIONS_SEGMENT <- "commodity_options"
COMMODITIES_COMMODITY_INDICES_SEGMENT <- "commodity_indices"
COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT <- "commodity_index_futures"
COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT <- "commodity_index_options"

#' One commodity the exchange publishes as an underlying, such as GOLD on the mcx
#'
#' @description
#' The commodity family has six classes, each fixing one of UBI's commodity segments, so the kind of contract is the class rather than a segment name passed by hand, and each constructor asks for exactly the fields that identify one of its own contracts. `Commodity` and `CommodityIndex` are named by exchange and symbol, the futures classes by exchange, underlying symbol and expiry date, and the option classes by those three plus a strike price and an option type. All six inherit every analysis class through `Instrument`.
#'
#' Symbols are readable tickers, such as `GOLD`, `CRUDEOIL` and `ALUMINIUM` for a commodity and `MCXBULLDEX` or `MCXCOMDEX` for an index. UBI carries commodities on three exchanges, `mcx`, `ncdex` and `nse`, and the indices and their derivatives on `mcx` and `ncdex` only.
#'
#' Three things about ordering in this family differ from equities, and two of them cost money if they are assumed away.
#'
#' A quantity is counted in quotation units and must be a whole number of lots. A commodity market is not a securities market, so UBI measures the quantity against the contract's size and refuses anything that is not an exact multiple: `quantity = 1` on an MCX gold future is answered with HTTP 400 and `quantity must be a whole number of lots of 100`, while `quantity = 100` is one lot. UBI converts that figure to whatever each broker counts in before sending, so the number given here is the same whichever broker takes the order. On the `ncdex` the quotation unit is tonnes, although prices are quoted in quintals.
#'
#' A `Commodity` cannot be ordered at all, although it inherits every order method. Its rows are the exchange's underlying reference records rather than tradeable spot contracts, no broker declares a cash market for commodities, and UBI's contract size check refuses any order in this family that is not a future or an option. Every order method on `Commodity` therefore fails, and `CommodityIndex` cannot be traded either by the ordinary index rule.
#'
#' An order can also be refused for a reason that has nothing to do with the order. UBI decides each contract's size once every morning from the exchanges' own fields, and when its sources disagree the contract is untradeable for the day. That is answered with HTTP 503 and a `contract_size_status` of `conflict`, `undecided`, `no_source` or `single_source`, which means UBI does not trust the contract's size today rather than that UBI is unavailable.
#'
#' A commodity or a commodity index has no quote, because the tick streams only resolve a token to a derivative segment, so `quote`, `last_price`, `ohlc` and the order-book values signal `ServiceUnavailableError` for `Commodity` and `CommodityIndex`. The four derivative classes are quoted normally, and unlike the fixed income and currency families they also have candles, so the analysis methods work on them.
#'
#' A `Commodity` has no quote, so the two option classes find their underlying as the future on the same underlying that expires first on or after the option, which is also what an MCX option settles into, and price with Black-76; an MCX GOLD option expiring at the end of October is priced off the December future. The two futures classes have no default underlying, so their `underlying_price` and basis members signal `UnderlyingError` unless one is given.
#'
#' UBI cannot report a commodity as a holding, so no class in this family has holdings members; positions do cover the family.
#'
#' The class generator carries one discovery function:
#'
#' * `Commodity$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds commodities whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"CRUDE"` finds CRUDEOIL near the top. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no commodity matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' gold <- Commodity$new(exchange = "mcx", symbol = "GOLD")
#' gold$lot_size
#'
#' matches <- Commodity$search(exchange = "mcx", term = "CRUDE")
#' print(matches$symbol)
#'
#' matches <- Commodity$search(exchange = "ncdex", term = "", limit = 10)
#' print(matches$symbol)
#'
#' matches <- Commodity$search(exchange = "mcx", term = "SILVER")
#' symbol <- matches$symbol[[1]]
#' expiries <- CommodityFutures$expiries(
#'   exchange = "mcx",
#'   underlying_symbol = symbol
#' )
#' print(symbol)
#' print(expiries)
#' }
#' @export
Commodity <- R6::R6Class(
  "Commodity",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the commodity up in UBI's commodities segment and keeps its details.
    #'
    #' A commodity cannot be ordered or quoted, although it inherits the methods for both. Its row is the exchange's underlying reference record rather than a tradeable spot contract, so an order is refused by UBI and a quote signals `ServiceUnavailableError`. Use `CommodityFutures` or `CommodityOption` to trade it.
    #' @param exchange The character exchange the commodity is published on, `"mcx"`, `"ncdex"` or `"nse"`.
    #' @param symbol The character symbol of the commodity, such as `"GOLD"` or `"CRUDEOIL"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Commodity` object.
    #' @details Errors: signals `CommodityError` when UBI has no commodity with that symbol on that exchange, or the instrument it returned is not in the commodities segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = COMMODITIES_COMMODITY_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityError",
            sprintf(
              "UBI has no %s commodity for the symbol %s",
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
        COMMODITIES_COMMODITY_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityError",
          sprintf(
            "An instrument outside the %s segment is not a Commodity: %s",
            COMMODITIES_COMMODITY_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

Commodity$search <- function(
  exchange,
  term,
  limit = COMMODITIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, COMMODITIES_COMMODITY_SEGMENT, term, limit)
}

#' One futures contract on a commodity, such as GOLD expiring in October
#'
#' @description
#' Built on `Futures`, so it carries the order-book values, the expiry and underlying members and the basis. It has no default underlying, because a commodity itself has no quote, so `underlying_price` and the basis members signal `UnderlyingError` unless an underlying is given or UBI links one. Unlike most families, its candles are stored, so the analysis methods work on it.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 100` is one lot of a contract whose lot is 100 and `quantity = 1` is refused.
#'
#' The class generator carries two discovery functions, which read the commodity futures segment:
#'
#' * `CommodityFutures$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the commodity's futures are listed for as a `Date` vector, soonest first, which is empty when nothing is listed. A contract expiring today counts as live.
#' * `CommodityFutures$contracts(exchange, underlying_symbol = NULL, include_expired = FALSE, unified_broker_interface = NULL)` lists the contracts as a `data.frame` of identities, with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol` and `expiry_date`, sorted by expiry, or `NULL` when nothing matches.
#'
#' Both signal `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' expiries <- CommodityFutures$expiries(exchange = "mcx", underlying_symbol = "GOLD")
#' contract <- CommodityFutures$new(
#'   exchange = "mcx",
#'   underlying_symbol = "GOLD",
#'   expiry_date = expiries[[1]]
#' )
#' price <- contract$last_price
#' frame <- contract$relative_strength_index(window = 14, days = 90)
#' }
#' @export
CommodityFutures <- R6::R6Class(
  "CommodityFutures",
  inherit = Futures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's commodity futures segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 100` is one lot of a contract whose lot is 100 and `quantity = 1` is refused.
    #' @param exchange The character exchange the contract trades on, `"mcx"`, `"ncdex"` or `"nse"`.
    #' @param underlying_symbol The character symbol of the commodity the contract is written on, such as `"GOLD"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as the `Commodity` it is written on, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CommodityFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CommodityFuturesError` when UBI has no such contract, or the instrument it returned is not in the commodity futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = COMMODITIES_COMMODITY_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityFuturesError",
            sprintf(
              "UBI has no %s commodity futures contract on %s expiring %s",
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
        COMMODITIES_COMMODITY_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a CommodityFutures: %s",
            COMMODITIES_COMMODITY_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CommodityFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    COMMODITIES_COMMODITY_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CommodityFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    COMMODITIES_COMMODITY_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a commodity, such as a GOLD call at a given strike and expiry
#'
#' @description
#' Built on `Option`, so it carries the order-book values, the expiry and underlying members, the moneyness members, and `implied_volatility()` and `greeks()`. Unless an underlying is given or UBI links one, it finds its underlying as the future on the same commodity that expires first on or after the option, which is also what an MCX option settles into, and prices with Black-76. Pricing still needs the option's own last price, which some contracts lack.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots.
#'
#' The class generator carries three discovery functions, which read the commodity options segment:
#'
#' * `CommodityOption$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the commodity's options are listed for as a `Date` vector, soonest first.
#' * `CommodityOption$strikes(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists the strike prices for one expiry as a numeric vector, lowest first. It builds the chain and takes its distinct strikes, so it costs the same as `chain()`.
#' * `CommodityOption$chain(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists every option for one expiry as a `data.frame` of identities with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol`, `expiry_date`, `strike_price` and `option_type`, sorted by strike price and then option type, or `NULL` when nothing matches.
#'
#' Each signals `BadRequestError` when the exchange is not one UBI knows, and a plain error when `expiry_date` is text that is not a valid ISO date.
#'
#' @examples
#' \dontrun{
#' expiry <- CommodityOption$expiries(exchange = "mcx", underlying_symbol = "GOLD")[[1]]
#' strikes <- CommodityOption$strikes("mcx", "GOLD", expiry)
#' call <- CommodityOption$new(
#'   exchange = "mcx",
#'   underlying_symbol = "GOLD",
#'   expiry_date = expiry,
#'   strike_price = strikes[[length(strikes) %/% 2]],
#'   option_type = "CE"
#' )
#' call$underlying
#' }
#' @export
CommodityOption <- R6::R6Class(
  "CommodityOption",
  inherit = Option,
  public = list(
    #' @description
    #' Looks the option up in UBI's commodity options segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 100` is one lot of a contract whose lot is 100 and `quantity = 1` is refused.
    #' @param exchange The character exchange the option trades on, `"mcx"`, `"ncdex"` or `"nse"`.
    #' @param underlying_symbol The character symbol of the commodity the option is written on, such as `"GOLD"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option in the commodity's own quotation units.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the `CommodityFutures` it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CommodityOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CommodityOptionError` when UBI has no such option, or the instrument it returned is not in the commodity options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = COMMODITIES_COMMODITY_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityOptionError",
            sprintf(
              "UBI has no %s commodity option on %s expiring %s at strike %s %s",
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
        COMMODITIES_COMMODITY_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityOptionError",
          sprintf(
            "An instrument outside the %s segment is not a CommodityOption: %s",
            COMMODITIES_COMMODITY_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CommodityOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    COMMODITIES_COMMODITY_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CommodityOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    COMMODITIES_COMMODITY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

CommodityOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    COMMODITIES_COMMODITY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

#' One commodity index, such as MCXBULLDEX on the mcx, which is followed rather than traded
#'
#' @description
#' Built on `NonTradeableInstrument`, because an index cannot be traded, so it has the analysis methods and `constituents`, but no order or position members. No broker's tick stream resolves a commodity index, so its quote members signal `ServiceUnavailableError` even though the index itself is listed.
#'
#' The class generator carries one discovery function:
#'
#' * `CommodityIndex$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds commodity indices whose symbol contains `term`, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"BULL"` finds MCXBULLDEX near the top. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no index matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' index <- CommodityIndex$new(exchange = "mcx", symbol = "MCXBULLDEX")
#'
#' matches <- CommodityIndex$search(exchange = "mcx", term = "MCX")
#' print(matches$symbol)
#'
#' matches <- CommodityIndex$search(exchange = "mcx", term = "BULL")
#' symbol <- matches$symbol[[1]]
#' contracts <- CommodityIndexFutures$contracts(
#'   exchange = "mcx",
#'   underlying_symbol = symbol
#' )
#' if (is.null(contracts)) {
#'   cat(symbol, "has no live futures.\n")
#' } else {
#'   cat(symbol, "has", nrow(contracts), "live futures.\n")
#' }
#' }
#' @export
CommodityIndex <- R6::R6Class(
  "CommodityIndex",
  inherit = NonTradeableInstrument,
  public = list(
    #' @description
    #' Looks the index up in UBI's commodity indices segment and keeps its details.
    #'
    #' No broker's tick stream resolves a commodity index, so `quote`, `last_price` and `ohlc` signal `ServiceUnavailableError` even though the index itself is listed.
    #' @param exchange The character exchange that publishes the index, `"mcx"` or `"ncdex"`.
    #' @param symbol The character symbol of the index, such as `"MCXBULLDEX"` or `"MCXCOMDEX"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CommodityIndex` object.
    #' @details Errors: signals `CommodityIndexError` when UBI has no index with that symbol on that exchange, or the instrument it returned is not in the commodity indices segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = COMMODITIES_COMMODITY_INDICES_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityIndexError",
            sprintf(
              "UBI has no %s commodity index for the symbol %s",
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
        COMMODITIES_COMMODITY_INDICES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityIndexError",
          sprintf(
            "An instrument outside the %s segment is not a CommodityIndex: %s",
            COMMODITIES_COMMODITY_INDICES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CommodityIndex$search <- function(
  exchange,
  term,
  limit = COMMODITIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, COMMODITIES_COMMODITY_INDICES_SEGMENT, term, limit)
}

#' One futures contract on a commodity index, such as MCXBULLDEX expiring in October
#'
#' @description
#' Built on `IndexFutures`. It has no default underlying, because a commodity index has no quote, so `underlying_price` and the basis members signal `UnderlyingError` unless an underlying is given or UBI links one.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 30` is one lot of a contract whose lot is 30 and `quantity = 1` is refused.
#'
#' The class generator carries the discovery functions `CommodityIndexFutures$expiries()` and `CommodityIndexFutures$contracts()`, which take the same arguments and return the same shapes as `CommodityFutures$expiries()` and `CommodityFutures$contracts()`, reading the commodity index futures segment.
#'
#' @examples
#' \dontrun{
#' expiry <- CommodityIndexFutures$expiries(
#'   exchange = "mcx",
#'   underlying_symbol = "MCXBULLDEX"
#' )[[1]]
#' future <- CommodityIndexFutures$new(
#'   exchange = "mcx",
#'   underlying_symbol = "MCXBULLDEX",
#'   expiry_date = expiry
#' )
#' future$last_price
#' }
#' @export
CommodityIndexFutures <- R6::R6Class(
  "CommodityIndexFutures",
  inherit = IndexFutures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's commodity index futures segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 30` is one lot of a contract whose lot is 30 and `quantity = 1` is refused.
    #' @param exchange The character exchange the contract trades on, such as `"mcx"`.
    #' @param underlying_symbol The character symbol of the index the contract is written on, such as `"MCXBULLDEX"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as the `CommodityIndex` it is written on, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CommodityIndexFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CommodityIndexFuturesError` when UBI has no such contract, or the instrument it returned is not in the commodity index futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityIndexFuturesError",
            sprintf(
              "UBI has no %s commodity index futures contract on %s expiring %s",
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
        COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityIndexFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a CommodityIndexFutures: %s",
            COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CommodityIndexFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CommodityIndexFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    COMMODITIES_COMMODITY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a commodity index, such as an MCXBULLDEX call at a given strike and expiry
#'
#' @description
#' Built on `IndexOption`. Unless an underlying is given or UBI links one, it finds its underlying as the future on the same index that expires first on or after the option, and prices with Black-76.
#'
#' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 30` is one lot of a contract whose lot is 30 and `quantity = 1` is refused.
#'
#' The class generator carries the discovery functions `CommodityIndexOption$expiries()`, `CommodityIndexOption$strikes()` and `CommodityIndexOption$chain()`, which take the same arguments and return the same shapes as those on `CommodityOption`, reading the commodity index options segment.
#'
#' @examples
#' \dontrun{
#' expiries <- CommodityIndexFutures$expiries(
#'   exchange = "mcx",
#'   underlying_symbol = "MCXBULLDEX"
#' )
#' chain <- CommodityIndexOption$chain(
#'   exchange = "mcx",
#'   underlying_symbol = "MCXBULLDEX",
#'   expiry_date = expiries[[1]]
#' )
#' option <- CommodityIndexOption$new(
#'   exchange = "mcx",
#'   underlying_symbol = "MCXBULLDEX",
#'   expiry_date = expiries[[1]],
#'   strike_price = 34900,
#'   option_type = "CE"
#' )
#' option$last_price
#' }
#' @export
CommodityIndexOption <- R6::R6Class(
  "CommodityIndexOption",
  inherit = IndexOption,
  public = list(
    #' @description
    #' Looks the option up in UBI's commodity index options segment and keeps its details.
    #'
    #' An order's quantity is counted in quotation units and must be a whole number of lots, so `quantity = 30` is one lot of a contract whose lot is 30 and `quantity = 1` is refused.
    #' @param exchange The character exchange the option trades on, such as `"mcx"`.
    #' @param underlying_symbol The character symbol of the index the option is written on, such as `"MCXBULLDEX"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option in the index's own units.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the `CommodityIndexFutures` it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `CommodityIndexOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `CommodityIndexOptionError` when UBI has no such option, or the instrument it returned is not in the commodity index options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "CommodityIndexOptionError",
            sprintf(
              "UBI has no %s commodity index option on %s expiring %s at strike %s %s",
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
        COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "CommodityIndexOptionError",
          sprintf(
            "An instrument outside the %s segment is not a CommodityIndexOption: %s",
            COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

CommodityIndexOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

CommodityIndexOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

CommodityIndexOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    COMMODITIES_COMMODITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}
