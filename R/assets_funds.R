FUNDS_HOLDINGS_PATH <- "/api/portfolio/holdings"
FUNDS_HOLDINGS_ORDER_PRODUCT <- "cnc"
FUNDS_SEARCH_LIMIT <- 50
FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT <- "exchange_traded_funds"
FUNDS_INVESTMENT_TRUSTS_SEGMENT <- "investment_trusts"

#' One exchange-traded fund, such as NIFTYBEES on the nse
#'
#' @description
#' The exchange-traded fund family is two classes, `ExchangeTradedFund` and `InvestmentTrust`, each fixing one of UBI's segments, so the kind of instrument is the class rather than a segment name passed by hand. Both are named by exchange and symbol, because a fund and a trust have no expiry, strike or option type, and UBI has no futures or options written on either.
#'
#' Both trade on the `nse` and the `bse` exactly as a share does. They are quoted, they can be ordered with the ordinary market and limit wrappers, and they can be held in the demat account, so both carry the same holdings members `Equity` does. An order's quantity is a plain count of units, as for a share, rather than the whole number of lots a commodity or currency order needs. Selling works on the units free to sell, which is the holding minus anything pledged as collateral.
#'
#' Symbols are readable tickers, such as `NIFTYBEES` for a fund and `EMBASSY` for a trust. A mutual fund is a different thing and is `MutualFund`, because it is subscribed to at its net asset value rather than traded.
#'
#' A fund's candles are adjusted for splits and bonuses and carry a `price_factor` column, as a share's do, so the analysis methods work on it. `constituents` holds the stored basket of what the fund itself owns, which is different from `holdings`, the units of the fund this account owns.
#'
#' The class generator carries one discovery function:
#'
#' * `ExchangeTradedFund$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds exchange traded funds whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"NIFTYBEE"` finds NIFTYBEES near the top. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no fund matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
#' price <- fund$last_price
#' frame <- fund$relative_strength_index(window = 14, days = 90)
#' row <- fund$holdings
#' basket <- fund$constituents
#'
#' matches <- ExchangeTradedFund$search(exchange = "nse", term = "NIFTYBEE")
#' columns <- c(
#'   "symbol",
#'   "exchange",
#'   "segment"
#' )
#' print(matches[columns])
#'
#' matches <- ExchangeTradedFund$search(exchange = "bse", term = "GOLD", limit = 10)
#' if (is.null(matches)) {
#'   cat("No gold fund was found on the bse.\n")
#' } else {
#'   print(matches$symbol)
#' }
#'
#' matches <- ExchangeTradedFund$search(exchange = "nse", term = "BANKBEE")
#' first_symbol <- matches$symbol[[1]]
#' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = first_symbol)
#' cat(fund$symbol, ": ", fund$last_price, "\n", sep = "")
#' }
#' @export
ExchangeTradedFund <- R6::R6Class(
  "ExchangeTradedFund",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the fund up in UBI's exchange traded funds segment and keeps its details.
    #' @param exchange The character exchange the fund is listed on, `"nse"` or `"bse"`.
    #' @param symbol The character symbol of the fund, such as `"NIFTYBEES"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `ExchangeTradedFund` object.
    #' @details Errors: signals `ExchangeTradedFundError` when UBI has no fund with that symbol on that exchange, or the instrument it returned is not in the exchange traded funds segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "ExchangeTradedFundError",
            sprintf(
              "UBI has no %s exchange traded fund for the symbol %s",
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
        FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "ExchangeTradedFundError",
          sprintf(
            "An instrument outside the %s segment is not an ExchangeTradedFund: %s",
            FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT,
            self$format()
          )
        )
      }
    },

    #' @description
    #' Buys more of this fund to keep.
    #'
    #' The order is always sent as `cnc`, which is the product that puts units in the demat account. Nothing is read first, because a fund can be bought whether or not it is already held. A `day` limit order is held by UBI's order engine until the other side of the book reaches its price, as `buy_at_limit_price()` describes, and a market order is sent as a marketable limit, as `buy_at_market_price()` describes.
    #' @param quantity The integer number of units to buy.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    #' limit_price <- round(fund$last_price * 0.97, 2)
    #' answer <- fund$add_to_holdings(quantity = 1, price = limit_price)
    #' tryCatch(
    #'   print(answer),
    #'   finally = print(fund$cancel_parent(answer[["parent_id"]]))
    #' )
    #'
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
    #' limit_price <- round(fund$last_price * 0.97, 2)
    #' answer <- fund$add_to_holdings(
    #'   quantity = 1,
    #'   price = limit_price,
    #'   tag = "examplebid"
    #' )
    #' columns <- c(
    #'   "parent_order_id",
    #'   "synthetic_type",
    #'   "state"
    #' )
    #' tryCatch(
    #'   print(fund$parents[columns]),
    #'   finally = print(fund$cancel_parent(answer[["parent_id"]]))
    #' )
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
            product = FUNDS_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$buy_at_limit_price(
        price = price,
        quantity = quantity,
        product = FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells some of the units held, without selling more than are free.
    #'
    #' Units pledged as collateral cannot be sold until they are released at the broker, so the quantity asked for is measured against the free units rather than the whole holding.
    #' @param quantity The integer number of units to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this fund is not held, or the quantity is more than the free units; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    #' if (is.null(fund$holdings)) {
    #'   cat("No NIFTYBEES units are held, so there is nothing to reduce.\n")
    #' } else {
    #'   limit_price <- round(fund$last_price * 1.03, 2)
    #'   answer <- fund$reduce_holdings(quantity = 1, price = limit_price)
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(fund$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
    #'
    #' limit_price <- round(fund$last_price * 1.03, 2)
    #' tryCatch(
    #'   fund$reduce_holdings(quantity = 10000000, price = limit_price),
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
    #' @details Errors: signals `HoldingError` when this fund is not held, or every unit held is pledged as collateral; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "NIFTYBEES")
    #' if (is.null(fund$holdings)) {
    #'   cat("No NIFTYBEES units are held, so there is nothing to sell.\n")
    #' } else {
    #'   limit_price <- round(fund$last_price * 1.03, 2)
    #'   answer <- fund$liquidate_holdings(price = limit_price)
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(fund$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
    #'
    #' fund <- ExchangeTradedFund$new(exchange = "nse", symbol = "GOLDBEES")
    #' limit_price <- round(fund$last_price * 1.03, 2)
    #' answer <- tryCatch(
    #'   fund$liquidate_holdings(price = limit_price),
    #'   HoldingError = function(error) {
    #'     cat("Nothing to sell:", conditionMessage(error), "\n")
    #'     NULL
    #'   }
    #' )
    #' if (!is.null(answer)) {
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(fund$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
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
    #' @field constituents The stored basket of what the fund holds, an `ExchangeTradedFundConstituents`, or `NULL` when none is stored for today, read from MongoDB and UBI on every access. This is the fund's own portfolio, which is different from `holdings`, the units of the fund this account holds. UBI stores no fund holdings, so a basket exists only when one was saved with this fund as its linked instrument.
    constituents = function(value) {
      if (!missing(value)) {
        stop("constituents is read-only", call. = FALSE)
      }
      store <- BasketStore$new(
        unified_broker_interface = private$unified_broker_interface
      )
      store$load_for_instrument(self)
    },

    #' @field holdings The long-term holding of this fund, merged across every broker, as a named list, or `NULL` when it is not held. Reading this sends one request to UBI every time, because UBI serves the whole account's holdings and has no route for a single instrument.
    holdings = function(value) {
      if (!missing(value)) {
        stop("holdings is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        FUNDS_HOLDINGS_PATH
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

    #' @field holdings_value The numeric worth of the units held at the moment, or `NULL` when the fund is not held. UBI prices a holding itself, so this reads the figure rather than working it out. It counts every unit held, including any pledged as collateral, because a pledged unit is still owned.
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

    #' @field holdings_pnl What the units held have made or lost, as a named list with `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when the fund is not held. It is not shaped like a position's `pnl`, which reports `realized`, `unrealized` and `total`, so only `unrealized` means the same thing in both.
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
    #' Reads this fund's holding once, refusing when it is not held.
    #' @return The named list holdings row for this fund.
    #' @details Errors: signals `HoldingError` when no broker holds this fund, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
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

    #' Works out how many of the units held can be sold.
    #' @param row The named list holdings row, with `quantity` and `collateral_quantity`.
    #' @return The integer number of units that are not pledged as collateral.
    free_quantity = function(row) {
      as.integer(row[["quantity"]] - row[["collateral_quantity"]])
    },

    #' Sends the sell order that reduces the holding.
    #' @param quantity The integer number of units to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, or `NULL`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label for the order, or `NULL`.
    #' @return The named list `place_order()` returns.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    sell_from_holdings = function(quantity, price, validity, after_market, tag) {
      if (is.null(price)) {
        return(
          self$sell_at_market_price(
            quantity = quantity,
            product = FUNDS_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$sell_at_limit_price(
        price = price,
        quantity = quantity,
        product = FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    }
  )
)

ExchangeTradedFund$search <- function(
  exchange,
  term,
  limit = FUNDS_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, FUNDS_EXCHANGE_TRADED_FUNDS_SEGMENT, term, limit)
}

#' One listed investment trust, such as the real estate trust EMBASSY on the nse
#'
#' @description
#' A trust is quoted, ordered and held exactly as an exchange-traded fund is, so it carries the same holdings members as `ExchangeTradedFund` and `Equity`. UBI stores no candles for a trust, so `prices()` returns `NULL` and the inherited analysis methods have nothing to work on, although the trust is quoted and traded normally. It has no `constituents`, because a real estate or infrastructure trust holds property rather than listed instruments UBI can price.
#'
#' The class generator carries one discovery function:
#'
#' * `InvestmentTrust$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds investment trusts whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"EMBAS"` finds EMBASSY near the top. UBI carries only twenty-seven trusts on each exchange, so a short term may return most of them. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no trust matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
#' level <- trust$last_price
#'
#' matches <- InvestmentTrust$search(exchange = "nse", term = "EMBAS")
#' columns <- c(
#'   "symbol",
#'   "exchange",
#'   "segment"
#' )
#' print(matches[columns])
#'
#' matches <- InvestmentTrust$search(exchange = "nse", term = "INVIT")
#' if (is.null(matches)) {
#'   cat("No trust matched.\n")
#' } else {
#'   cat(nrow(matches), "trusts:", matches$symbol, "\n")
#' }
#'
#' matches <- InvestmentTrust$search(exchange = "nse", term = "PGINV")
#' first_symbol <- matches$symbol[[1]]
#' trust <- InvestmentTrust$new(exchange = "nse", symbol = first_symbol)
#' cat(trust$symbol, ": ", trust$last_price, "\n", sep = "")
#' }
#' @export
InvestmentTrust <- R6::R6Class(
  "InvestmentTrust",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the trust up in UBI's investment trusts segment and keeps its details.
    #'
    #' UBI stores no candles for a trust, so `prices()` returns `NULL` and the inherited analysis methods have nothing to work on, although the trust is quoted and traded normally.
    #' @param exchange The character exchange the trust is listed on, `"nse"` or `"bse"`.
    #' @param symbol The character symbol of the trust, such as `"EMBASSY"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `InvestmentTrust` object.
    #' @details Errors: signals `InvestmentTrustError` when UBI has no trust with that symbol on that exchange, or the instrument it returned is not in the investment trusts segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = FUNDS_INVESTMENT_TRUSTS_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "InvestmentTrustError",
            sprintf(
              "UBI has no %s investment trust for the symbol %s",
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
        FUNDS_INVESTMENT_TRUSTS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "InvestmentTrustError",
          sprintf(
            "An instrument outside the %s segment is not an InvestmentTrust: %s",
            FUNDS_INVESTMENT_TRUSTS_SEGMENT,
            self$format()
          )
        )
      }
    },

    #' @description
    #' Buys more of this trust to keep.
    #'
    #' The order is always sent as `cnc`, which is the product that puts units in the demat account. Nothing is read first, because a trust can be bought whether or not it is already held. A `day` limit order is held by UBI's order engine until the other side of the book reaches its price, as `buy_at_limit_price()` describes, and a market order is sent as a marketable limit, as `buy_at_market_price()` describes.
    #' @param quantity The integer number of units to buy.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
    #' limit_price <- round(trust$last_price * 0.97, 2)
    #' answer <- trust$add_to_holdings(quantity = 1, price = limit_price)
    #' tryCatch(
    #'   print(answer),
    #'   finally = print(trust$cancel_parent(answer[["parent_id"]]))
    #' )
    #'
    #' trust <- InvestmentTrust$new(exchange = "nse", symbol = "PGINVIT")
    #' limit_price <- round(trust$last_price * 0.97, 2)
    #' answer <- trust$add_to_holdings(
    #'   quantity = 1,
    #'   price = limit_price,
    #'   tag = "examplebid"
    #' )
    #' columns <- c(
    #'   "parent_order_id",
    #'   "synthetic_type",
    #'   "state"
    #' )
    #' tryCatch(
    #'   print(trust$parents[columns]),
    #'   finally = print(trust$cancel_parent(answer[["parent_id"]]))
    #' )
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
            product = FUNDS_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$buy_at_limit_price(
        price = price,
        quantity = quantity,
        product = FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells some of the units held, without selling more than are free.
    #'
    #' Units pledged as collateral cannot be sold until they are released at the broker, so the quantity asked for is measured against the free units rather than the whole holding.
    #' @param quantity The integer number of units to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this trust is not held, or the quantity is more than the free units; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
    #' if (is.null(trust$holdings)) {
    #'   cat("No EMBASSY units are held, so there is nothing to reduce.\n")
    #' } else {
    #'   limit_price <- round(trust$last_price * 1.03, 2)
    #'   answer <- trust$reduce_holdings(quantity = 1, price = limit_price)
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(trust$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
    #'
    #' limit_price <- round(trust$last_price * 1.03, 2)
    #' tryCatch(
    #'   trust$reduce_holdings(quantity = 10000000, price = limit_price),
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
    #' @details Errors: signals `HoldingError` when this trust is not held, or every unit held is pledged as collateral; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' trust <- InvestmentTrust$new(exchange = "nse", symbol = "EMBASSY")
    #' if (is.null(trust$holdings)) {
    #'   cat("No EMBASSY units are held, so there is nothing to sell.\n")
    #' } else {
    #'   limit_price <- round(trust$last_price * 1.03, 2)
    #'   answer <- trust$liquidate_holdings(price = limit_price)
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(trust$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
    #'
    #' trust <- InvestmentTrust$new(exchange = "nse", symbol = "PGINVIT")
    #' limit_price <- round(trust$last_price * 1.03, 2)
    #' answer <- tryCatch(
    #'   trust$liquidate_holdings(price = limit_price),
    #'   HoldingError = function(error) {
    #'     cat("Nothing to sell:", conditionMessage(error), "\n")
    #'     NULL
    #'   }
    #' )
    #' if (!is.null(answer)) {
    #'   tryCatch(
    #'     print(answer),
    #'     finally = print(trust$cancel_parent(answer[["parent_id"]]))
    #'   )
    #' }
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
    #' @field holdings The long-term holding of this trust, merged across every broker, as a named list, or `NULL` when it is not held. Reading this sends one request to UBI every time, because UBI serves the whole account's holdings and has no route for a single instrument.
    holdings = function(value) {
      if (!missing(value)) {
        stop("holdings is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        FUNDS_HOLDINGS_PATH
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

    #' @field holdings_value The numeric worth of the units held at the moment, or `NULL` when the trust is not held. UBI prices a holding itself, so this reads the figure rather than working it out. It counts every unit held, including any pledged as collateral, because a pledged unit is still owned.
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

    #' @field holdings_pnl What the units held have made or lost, as a named list with `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when the trust is not held. It is not shaped like a position's `pnl`, which reports `realized`, `unrealized` and `total`, so only `unrealized` means the same thing in both.
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
    #' Reads this trust's holding once, refusing when it is not held.
    #' @return The named list holdings row for this trust.
    #' @details Errors: signals `HoldingError` when no broker holds this trust, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
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

    #' Works out how many of the units held can be sold.
    #' @param row The named list holdings row, with `quantity` and `collateral_quantity`.
    #' @return The integer number of units that are not pledged as collateral.
    free_quantity = function(row) {
      as.integer(row[["quantity"]] - row[["collateral_quantity"]])
    },

    #' Sends the sell order that reduces the holding.
    #' @param quantity The integer number of units to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, or `NULL`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label for the order, or `NULL`.
    #' @return The named list `place_order()` returns.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    sell_from_holdings = function(quantity, price, validity, after_market, tag) {
      if (is.null(price)) {
        return(
          self$sell_at_market_price(
            quantity = quantity,
            product = FUNDS_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$sell_at_limit_price(
        price = price,
        quantity = quantity,
        product = FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    }
  )
)

InvestmentTrust$search <- function(
  exchange,
  term,
  limit = FUNDS_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, FUNDS_INVESTMENT_TRUSTS_SEGMENT, term, limit)
}
