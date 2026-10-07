FIXED_INCOME_HOLDINGS_PATH <- "/api/portfolio/holdings"
FIXED_INCOME_HOLDINGS_ORDER_PRODUCT <- "cnc"
FIXED_INCOME_SEARCH_LIMIT <- 50
FIXED_INCOME_FIXED_INCOME_SEGMENT <- "fixed_income"
FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT <- "fixed_income_futures"
FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT <- "fixed_income_options"
FIXED_INCOME_FIXED_INCOME_INDICES_SEGMENT <- "fixed_income_indices"
FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT <- "fixed_income_index_futures"
FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT <- "fixed_income_index_options"

#' One listed fixed income security, such as a government bond or a treasury bill on the nse
#'
#' @description
#' The fixed income family has six classes, each fixing one of UBI's fixed income segments, so the kind of contract is the class rather than a segment name passed by hand, and each constructor asks for exactly the fields that identify one of its own contracts. `FixedIncome` and `FixedIncomeIndex` are named by exchange and symbol, the futures classes by exchange, underlying symbol and expiry date, and the option classes by those three plus a strike price and an option type. All six inherit every analysis class through `Instrument`.
#'
#' A bond is named by its ISIN rather than by a ticker, such as `IN000126C010`, because a one-off corporate bond or non-convertible debenture has no ticker that reconciles across brokers. The exception is a small set of interest rate underlyings on the nse, named by a rate code such as `633GS2035`, which are the instruments the futures and options are written on. Sovereign gold bonds live in this family too, rather than with commodities.
#'
#' Two limits of UBI's coverage are worth knowing before reaching for these classes, because they are not obvious and they are not faults in this package. No broker that serves quotes carries a cash bond or a rate index, so `quote`, `last_price`, `ohlc` and the order-book values signal `ServiceUnavailableError` for `FixedIncome` and `FixedIncomeIndex`, while the three derivative classes are quoted normally. And UBI stores no candles for any fixed income segment at all, so `prices()` returns `NULL` everywhere here and the analysis methods have nothing to work on.
#'
#' No broker quotes a bond or a rate index, so the two option classes find their underlying as the rate future on the same underlying that expires first on or after the option, and price with Black-76; the two futures classes have no default underlying, so their `underlying_price` and basis members signal `UnderlyingError` unless one is given.
#'
#' A bond is the only thing in this family that can be held, so `FixedIncome` alone carries the holdings members. Selling works on the units free to sell, which is the holding minus anything pledged as collateral. Because a cash bond has no quote, the holdings methods send a limit order to a broker at once rather than letting UBI's order engine hold it, and send an order without a price as a real market order rather than as a marketable limit, either of which would otherwise wait all day or be refused with HTTP 409.
#'
#' The class generator carries one discovery function:
#'
#' * `FixedIncome$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds listed bonds whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it. Because a bond is named by its ISIN, a useful term is an ISIN or the start of one, such as `"IN0001"`; a rate underlying is found by its rate code, such as `"GS2035"`. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no bond matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' bond <- FixedIncome$new(exchange = "nse", symbol = "IN000126C010")
#' row <- bond$holdings
#'
#' matches <- FixedIncome$search(exchange = "nse", term = "IN0001")
#' columns <- c(
#'   "symbol",
#'   "instrument_id"
#' )
#' print(matches[columns])
#'
#' matches <- FixedIncome$search(exchange = "nse", term = "GS2035", limit = 20)
#' print(matches$symbol)
#'
#' matches <- FixedIncome$search(exchange = "nse", term = "91DTB")
#' symbol <- matches$symbol[[1]]
#' bill <- FixedIncome$new(exchange = "nse", symbol = symbol)
#' cat(bill$symbol, bill$segment, bill$lot_size, "\n")
#' }
#' @export
FixedIncome <- R6::R6Class(
  "FixedIncome",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the bond up in UBI's fixed income segment and keeps its details.
    #' @param exchange The character exchange the bond is listed on, such as `"nse"`.
    #' @param symbol The character symbol of the bond, which is its ISIN, such as `"IN000126C010"`, or a rate code such as `"633GS2035"` for an interest rate underlying.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncome` object.
    #' @details Errors: signals `FixedIncomeError` when UBI has no bond with that symbol on that exchange, or the instrument it returned is not in the fixed income segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = FIXED_INCOME_FIXED_INCOME_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeError",
            sprintf("UBI has no %s bond for the symbol %s", exchange, symbol),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        FIXED_INCOME_FIXED_INCOME_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncome: %s",
            FIXED_INCOME_FIXED_INCOME_SEGMENT,
            self$format()
          )
        )
      }
    },

    #' @description
    #' Buys more of this bond to keep.
    #'
    #' The order is always sent as `cnc`, which is the product that puts a holding in the demat account. Nothing is read first, because a bond can be bought whether or not it is already held, and UBI checks funds no more than a broker's order route does. A limit order is sent to a broker at once, with `hold = FALSE`, because UBI's order engine would otherwise hold it until a quote that a cash bond never has. Without a price the order is sent to the broker as a real market order rather than as the marketable limit UBI would otherwise make of it, because a cash bond has no quote, so a marketable limit would always be refused with HTTP 409.
    #' @param quantity The integer number of units to buy.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' bond <- FixedIncome$new(exchange = "nse", symbol = "633GS2035")
    #' answer <- bond$add_to_holdings(quantity = 1, price = 90)
    #' cat(answer[["outcome"]], answer[["order_id"]], "\n")
    #' if (!is.null(answer[["parent_id"]])) {
    #'   bond$cancel_parent(answer[["parent_id"]])
    #' }
    #'
    #' answer <- bond$add_to_holdings(quantity = 1, price = 90, validity = "ioc")
    #' cat(answer[["outcome"]], answer[["status_message"]], "\n")
    #' if (!is.null(answer[["parent_id"]])) {
    #'   tryCatch(
    #'     bond$cancel_parent(answer[["parent_id"]]),
    #'     ConflictError = function(error) {
    #'       cat("The order had already finished.\n")
    #'     }
    #'   )
    #' }
    #' }
    add_to_holdings = function(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      if (is.null(price)) {
        return(
          self$buy_at_market_price(
            quantity = quantity,
            product = FIXED_INCOME_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag,
            as_marketable_limit = FALSE
          )
        )
      }
      self$buy_at_limit_price(
        price = price,
        quantity = quantity,
        product = FIXED_INCOME_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag,
        hold = FALSE
      )
    },

    #' @description
    #' Sells some of the bonds held, without selling more than are free.
    #'
    #' Units pledged as collateral cannot be sold until they are released at the broker, so the quantity asked for is measured against the free units rather than the whole holding.
    #' @param quantity The integer number of units to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this bond is not held, or the quantity is more than the free units; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' bond <- FixedIncome$new(exchange = "nse", symbol = "633GS2035")
    #' if (is.null(bond$holdings)) {
    #'   cat("No 633GS2035 units are held, so there is nothing to offer.\n")
    #' } else {
    #'   answer <- bond$reduce_holdings(quantity = 1, price = 150)
    #'   cat(answer[["outcome"]], answer[["order_id"]], "\n")
    #'   if (!is.null(answer[["parent_id"]])) {
    #'     bond$cancel_parent(answer[["parent_id"]])
    #'   }
    #' }
    #'
    #' bond <- FixedIncome$new(exchange = "nse", symbol = "IN000126C010")
    #' tryCatch(
    #'   bond$reduce_holdings(quantity = 1, price = 150),
    #'   HoldingError = function(error) {
    #'     cat("Refused:", conditionMessage(error), "\n")
    #'   }
    #' )
    #' }
    reduce_holdings = function(
      quantity,
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      row <- private$held_row()
      free_quantity <- private$free_quantity(row)
      if (quantity > free_quantity) {
        ErrorCatalogue$raise(
          "HoldingError",
          sprintf(
            "%d of the %d %s units held are free to sell, because %d are pledged as collateral, so %s cannot be sold",
            free_quantity,
            as.integer(row[["quantity"]]),
            self$symbol,
            as.integer(row[["collateral_quantity"]]),
            format(quantity)
          )
        )
      }
      private$sell_from_holdings(
        quantity = quantity,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells every unit held that is free to sell.
    #'
    #' Units pledged as collateral are left alone, because they cannot be sold until they are released at the broker, so this empties the holding only when nothing is pledged.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this bond is not held, or every unit held is pledged as collateral; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' bond <- FixedIncome$new(exchange = "nse", symbol = "633GS2035")
    #' if (is.null(bond$holdings)) {
    #'   cat("No 633GS2035 units are held, so there is nothing to sell.\n")
    #' } else {
    #'   answer <- bond$liquidate_holdings(price = 150)
    #'   cat(answer[["outcome"]], answer[["order_id"]], "\n")
    #'   if (!is.null(answer[["parent_id"]])) {
    #'     bond$cancel_parent(answer[["parent_id"]])
    #'   }
    #' }
    #'
    #' bond <- FixedIncome$new(exchange = "nse", symbol = "IN000126C010")
    #' tryCatch(
    #'   bond$liquidate_holdings(price = 150),
    #'   HoldingError = function(error) {
    #'     cat("Nothing sold:", conditionMessage(error), "\n")
    #'   }
    #' )
    #' }
    liquidate_holdings = function(
      price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL
    ) {
      row <- private$held_row()
      free_quantity <- private$free_quantity(row)
      if (free_quantity <= 0) {
        ErrorCatalogue$raise(
          "HoldingError",
          sprintf(
            "All %d %s units held are pledged as collateral, so none can be sold",
            as.integer(row[["quantity"]]),
            self$symbol
          )
        )
      }
      private$sell_from_holdings(
        quantity = free_quantity,
        price = price,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    }
  ),
  active = list(
    #' @field holdings The long-term holding of this bond, merged across every broker, as a named list, or `NULL` when it is not held. A bond is the only thing in this family that can be held: a derivative is a position rather than a holding, and an index cannot be held at all. Reading this sends one request to UBI every time, because UBI serves the whole account's holdings and has no route for a single instrument. The row's `symbol` and `isin` hold the same string for a bond, unlike a share, because a bond is named by its ISIN. A bond held only at Groww is not reported at all, because UBI matches a Groww holding by the ticker the broker sends rather than by an ISIN.
    holdings = function(value) {
      if (!missing(value)) {
        stop("holdings is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        FIXED_INCOME_HOLDINGS_PATH
      )[["holdings"]]
      for (row in rows) {
        if (identical(row[["instrument_id"]], self$instrument_id)) {
          return(row)
        }
      }
      for (row in rows) {
        if (identical(row[["symbol"]], self$symbol)) {
          return(row)
        }
      }
      NULL
    },

    #' @field holdings_value The numeric worth of the bonds held at the moment, or `NULL` when the bond is not held. UBI prices a holding itself, so this reads the figure rather than working it out, which is the opposite of `positions_value`. It counts every unit held, including any pledged as collateral, because a pledged bond is still owned.
    holdings_value = function(value) {
      if (!missing(value)) {
        stop("holdings_value is read-only", call. = FALSE)
      }
      row <- self$holdings
      if (is.null(row)) {
        return(NULL)
      }
      row[["current_value"]]
    },

    #' @field holdings_pnl What the bonds held have made or lost, as a named list with `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when the bond is not held. It is not shaped like a position's `pnl`, which reports `realized`, `unrealized` and `total`, so only `unrealized` means the same thing in both. There is no realised figure, because selling a bond removes it from the holding rather than booking a profit against it.
    holdings_pnl = function(value) {
      if (!missing(value)) {
        stop("holdings_pnl is read-only", call. = FALSE)
      }
      row <- self$holdings
      if (is.null(row)) {
        return(NULL)
      }
      row[["pnl"]]
    }
  ),
  private = list(
    # Reads this bond's holding once, refusing when it is not held.
    # @return The named list holdings row for this bond.
    # @details Errors: signals `HoldingError` when no broker holds this bond, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    held_row = function() {
      row <- self$holdings
      if (is.null(row)) {
        ErrorCatalogue$raise(
          "HoldingError",
          sprintf(
            "No %s units are held, so there is nothing to sell: %s",
            self$symbol,
            self$format()
          )
        )
      }
      row
    },

    # Works out how many of the units held can be sold.
    # @param row The named list holdings row, with `quantity` and `collateral_quantity`.
    # @return The integer number of units that are not pledged as collateral.
    free_quantity = function(row) {
      as.integer(row[["quantity"]] - row[["collateral_quantity"]])
    },

    # Sends the sell order that reduces the holding.
    #
    # A limit order is sent to a broker at once, and without a price the order is sent as a real market order, because a cash bond has no quote for UBI's order engine to hold a limit against or to price a marketable limit from.
    # @param quantity The integer number of units to sell.
    # @param price The numeric limit price in rupees, or `NULL` to send a market order.
    # @param validity The character validity, or `NULL`.
    # @param after_market A logical that is `TRUE` to send the order as an after-market order.
    # @param tag A character label for the order, or `NULL`.
    # @return The named list `place_order()` returns.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    sell_from_holdings = function(quantity, price, validity, after_market, tag) {
      if (is.null(price)) {
        return(
          self$sell_at_market_price(
            quantity = quantity,
            product = FIXED_INCOME_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag,
            as_marketable_limit = FALSE
          )
        )
      }
      self$sell_at_limit_price(
        price = price,
        quantity = quantity,
        product = FIXED_INCOME_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag,
        hold = FALSE
      )
    }
  )
)

FixedIncome$search <- function(
  exchange,
  term,
  limit = FIXED_INCOME_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, FIXED_INCOME_FIXED_INCOME_SEGMENT, term, limit)
}

#' One futures contract on a bond, such as 633GS2035 expiring in September
#'
#' @description
#' Built on `Futures`, so it carries the order-book values, the expiry and underlying members and the basis. It has no default underlying, because no broker that serves quotes carries the bond itself, so `underlying_price` and the basis members signal `UnderlyingError` unless an underlying is given or UBI links one.
#'
#' The class generator carries two discovery functions, which read the fixed income futures segment:
#'
#' * `FixedIncomeFutures$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the bond's futures are listed for as a `Date` vector, soonest first, which is empty when nothing is listed. A contract expiring today counts as live.
#' * `FixedIncomeFutures$contracts(exchange, underlying_symbol = NULL, include_expired = FALSE, unified_broker_interface = NULL)` lists the contracts as a `data.frame` of identities, with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol` and `expiry_date`, sorted by expiry, or `NULL` when nothing matches.
#'
#' Both signal `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' contract <- FixedIncomeFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "633GS2035",
#'   expiry_date = "2026-09-24"
#' )
#' price <- contract$last_price
#' FixedIncomeFutures$expiries(exchange = "nse", underlying_symbol = "633GS2035")
#' }
#' @export
FixedIncomeFutures <- R6::R6Class(
  "FixedIncomeFutures",
  inherit = Futures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's fixed income futures segment and keeps its details.
    #' @param exchange The character exchange the contract trades on, such as `"nse"`.
    #' @param underlying_symbol The character rate code of the bond the contract is written on, such as `"633GS2035"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as a `FixedIncome`, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncomeFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `FixedIncomeFuturesError` when UBI has no such contract, or the instrument it returned is not in the fixed income futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeFuturesError",
            sprintf(
              "UBI has no %s bond futures contract on %s expiring %s",
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
        FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncomeFutures: %s",
            FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

FixedIncomeFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

FixedIncomeFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    FIXED_INCOME_FIXED_INCOME_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a bond, such as a 633GS2035 call at a given strike and expiry
#'
#' @description
#' Built on `Option`, so it carries the order-book values, the expiry and underlying members, the moneyness members, and `implied_volatility()` and `greeks()`. Unless an underlying is given or UBI links one, it finds its underlying as the rate future on the same bond that expires first on or after the option, and prices with Black-76.
#'
#' The class generator carries three discovery functions, which read the fixed income options segment:
#'
#' * `FixedIncomeOption$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the bond's options are listed for as a `Date` vector, soonest first.
#' * `FixedIncomeOption$strikes(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists the strike prices for one expiry as a numeric vector, lowest first. It builds the chain and takes its distinct strikes, so it costs the same as `chain()`.
#' * `FixedIncomeOption$chain(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists every option for one expiry as a `data.frame` of identities with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol`, `expiry_date`, `strike_price` and `option_type`, sorted by strike price and then option type, or `NULL` when nothing matches.
#'
#' Each signals `BadRequestError` when the exchange is not one UBI knows, and a plain error when `expiry_date` is text that is not a valid ISO date.
#'
#' @examples
#' \dontrun{
#' expiries <- FixedIncomeOption$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "633GS2035"
#' )
#' chain <- FixedIncomeOption$chain(
#'   exchange = "nse",
#'   underlying_symbol = "633GS2035",
#'   expiry_date = expiries[[1]]
#' )
#' option <- FixedIncomeOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "633GS2035",
#'   expiry_date = expiries[[1]],
#'   strike_price = 97.25,
#'   option_type = "CE"
#' )
#' option$last_price
#' }
#' @export
FixedIncomeOption <- R6::R6Class(
  "FixedIncomeOption",
  inherit = Option,
  public = list(
    #' @description
    #' Looks the option up in UBI's fixed income options segment and keeps its details.
    #' @param exchange The character exchange the option trades on, such as `"nse"`.
    #' @param underlying_symbol The character rate code of the bond the option is written on, such as `"633GS2035"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option, quoted as a bond price rather than in rupees.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the rate future it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncomeOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `FixedIncomeOptionError` when UBI has no such option, or the instrument it returned is not in the fixed income options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeOptionError",
            sprintf(
              "UBI has no %s bond option on %s expiring %s at strike %s %s",
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
        FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeOptionError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncomeOption: %s",
            FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

FixedIncomeOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

FixedIncomeOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

FixedIncomeOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    FIXED_INCOME_FIXED_INCOME_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

#' One fixed income index, such as ONMIBOR on the nse, which is followed rather than traded
#'
#' @description
#' Built on `NonTradeableInstrument`, because an index cannot be traded, so it has candles, a quote, the analysis methods and `constituents`, but no order or position members. No broker that serves quotes carries a rate index, so its quote members signal `ServiceUnavailableError`, and UBI stores no candles for it.
#'
#' The class generator carries one discovery function:
#'
#' * `FixedIncomeIndex$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds fixed income indices whose symbol contains `term`, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"MIBOR"` finds ONMIBOR near the top. UBI carries very few of these indices, so an empty term returns everything there is. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no index matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' matches <- FixedIncomeIndex$search(exchange = "nse", term = "")
#' print(matches$symbol)
#'
#' matches <- FixedIncomeIndex$search(exchange = "nse", term = "MIBOR")
#' symbol <- matches$symbol[[1]]
#' index <- FixedIncomeIndex$new(exchange = "nse", symbol = symbol)
#' tryCatch(
#'   print(index$last_price),
#'   ServiceUnavailableError = function(error) {
#'     cat(symbol, "is carried by UBI but no broker quotes it.\n")
#'   }
#' )
#' }
#' @export
FixedIncomeIndex <- R6::R6Class(
  "FixedIncomeIndex",
  inherit = NonTradeableInstrument,
  public = list(
    #' @description
    #' Looks the index up in UBI's fixed income indices segment and keeps its details.
    #' @param exchange The character exchange that publishes the index, such as `"nse"`.
    #' @param symbol The character symbol of the index, such as `"ONMIBOR"` or `"10YGS7"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncomeIndex` object.
    #' @details Errors: signals `FixedIncomeIndexError` when UBI has no index with that symbol on that exchange, or the instrument it returned is not in the fixed income indices segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = FIXED_INCOME_FIXED_INCOME_INDICES_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeIndexError",
            sprintf(
              "UBI has no %s fixed income index for the symbol %s",
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
        FIXED_INCOME_FIXED_INCOME_INDICES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeIndexError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncomeIndex: %s",
            FIXED_INCOME_FIXED_INCOME_INDICES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

FixedIncomeIndex$search <- function(
  exchange,
  term,
  limit = FIXED_INCOME_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDICES_SEGMENT,
    term,
    limit
  )
}

#' One futures contract on a fixed income index, such as ONMIBOR expiring in September
#'
#' @description
#' Built on `IndexFutures`. It has no default underlying, because no broker that serves quotes carries the rate index itself, so `underlying_price` and the basis members signal `UnderlyingError` unless an underlying is given or UBI links one.
#'
#' The class generator carries the discovery functions `FixedIncomeIndexFutures$expiries()` and `FixedIncomeIndexFutures$contracts()`, which take the same arguments and return the same shapes as `FixedIncomeFutures$expiries()` and `FixedIncomeFutures$contracts()`, reading the fixed income index futures segment.
#'
#' @examples
#' \dontrun{
#' expiry <- FixedIncomeIndexFutures$expiries(
#'   exchange = "nse",
#'   underlying_symbol = "ONMIBOR"
#' )[[1]]
#' future <- FixedIncomeIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "ONMIBOR",
#'   expiry_date = expiry
#' )
#' future$last_price
#' FixedIncomeIndexFutures$contracts(exchange = "nse")
#' }
#' @export
FixedIncomeIndexFutures <- R6::R6Class(
  "FixedIncomeIndexFutures",
  inherit = IndexFutures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's fixed income index futures segment and keeps its details.
    #' @param exchange The character exchange the contract trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the index the contract is written on, such as `"ONMIBOR"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as a `FixedIncomeIndex`, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncomeIndexFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `FixedIncomeIndexFuturesError` when UBI has no such contract, or the instrument it returned is not in the fixed income index futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeIndexFuturesError",
            sprintf(
              "UBI has no %s fixed income index futures contract on %s expiring %s",
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
        FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeIndexFuturesError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncomeIndexFutures: %s",
            FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

FixedIncomeIndexFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

FixedIncomeIndexFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a fixed income index, which UBI carries none of yet
#'
#' @description
#' Built on `IndexOption`. No broker UBI maps lists an option on a fixed income index, so the segment is empty and every lookup signals `FixedIncomeIndexOptionError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them. Once one resolves, it finds its underlying as the rate future that expires first on or after the option, and prices with Black-76.
#'
#' The class generator carries the discovery functions `FixedIncomeIndexOption$expiries()`, `FixedIncomeIndexOption$strikes()` and `FixedIncomeIndexOption$chain()`, which take the same arguments and return the same shapes as those on `FixedIncomeOption`, reading the fixed income index options segment. Today they return an empty `Date` vector, an empty numeric vector and `NULL`, without signalling anything.
#'
#' @examples
#' \dontrun{
#' FixedIncomeIndexOption$expiries(exchange = "nse", underlying_symbol = "ONMIBOR")
#' tryCatch(
#'   FixedIncomeIndexOption$new(
#'     exchange = "nse",
#'     underlying_symbol = "ONMIBOR",
#'     expiry_date = "2026-09-30",
#'     strike_price = 5.5,
#'     option_type = "CE"
#'   ),
#'   FixedIncomeIndexOptionError = function(error) {
#'     cat("UBI carries no such option yet.\n")
#'   }
#' )
#' }
#' @export
FixedIncomeIndexOption <- R6::R6Class(
  "FixedIncomeIndexOption",
  inherit = IndexOption,
  public = list(
    #' @description
    #' Looks the option up in UBI's fixed income index options segment and keeps its details.
    #'
    #' No broker UBI maps lists an option on a fixed income index, so this segment is empty and every lookup signals `FixedIncomeIndexOptionError` today. The class exists so that the family is complete and so that these contracts work the moment UBI gains a mapping for them.
    #' @param exchange The character exchange the option trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the index the option is written on, such as `"ONMIBOR"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option, quoted in the index's own units.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as the rate future it is priced off, which is also what is found when none is given, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `FixedIncomeIndexOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `FixedIncomeIndexOptionError` when UBI has no such option, which is true of every option today, or the instrument it returned is not in the fixed income index options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "FixedIncomeIndexOptionError",
            sprintf(
              "UBI has no %s fixed income index option on %s expiring %s at strike %s %s",
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
        FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "FixedIncomeIndexOptionError",
          sprintf(
            "An instrument outside the %s segment is not a FixedIncomeIndexOption: %s",
            FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

FixedIncomeIndexOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

FixedIncomeIndexOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

FixedIncomeIndexOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    FIXED_INCOME_FIXED_INCOME_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}
