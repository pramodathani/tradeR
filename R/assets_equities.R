EQUITIES_HOLDINGS_PATH <- "/api/portfolio/holdings"
EQUITIES_HOLDINGS_ORDER_PRODUCT <- "cnc"
EQUITIES_SEARCH_LIMIT <- 50
EQUITIES_EQUITY_SEGMENT <- "equities"
EQUITIES_EQUITY_FUTURES_SEGMENT <- "equity_futures"
EQUITIES_EQUITY_OPTIONS_SEGMENT <- "equity_options"
EQUITIES_EQUITY_INDICES_SEGMENT <- "equity_indices"
EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT <- "equity_index_futures"
EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT <- "equity_index_options"

#' One listed share, such as RELIANCE on the nse
#'
#' @description
#' The equity family has six classes, each fixing one of UBI's equity segments, so the kind of contract is the class rather than a segment name passed by hand, and each constructor asks for exactly the fields that identify one of its own contracts. `Equity` and `EquityIndex` are named by exchange and symbol, the futures classes by exchange, underlying symbol and expiry date, and the option classes by those three plus a strike price and an option type. All six inherit every analysis class through `Instrument`.
#'
#' A share is the only thing in this family that can be held, so `Equity` alone carries the holdings members. Selling works on the shares free to sell, which is the holding minus anything pledged as collateral. A holding's `pnl` reports `day_change`, `day_change_percentage` and `unrealized`, while a position's reports `realized`, `unrealized` and `total`.
#'
#' The class generator carries one discovery function:
#'
#' * `Equity$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds listed shares whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"RELI"` finds RELIANCE near the top. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no share matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' The examples below start with a short tour of the class, then show its properties and the functions on its class generator, in this order:
#'
#' * For `holdings`, print the holding of Vodafone Idea, or say that none is held.
#' * For `holdings`, report how many shares of each of a few companies are held and how many are free to sell.
#' * For `holdings`, compare what was paid for a holding with what it is worth now.
#' * For `holdings_value`, print what the Vodafone Idea shares held are worth, which is `NULL` when none are held.
#' * For `holdings_value`, add up the value of the shares held in a few companies, skipping any that are not held.
#' * For `holdings_pnl`, print the profit and loss of the Vodafone Idea shares held, which is `NULL` when none are held.
#' * For `holdings_pnl`, print today's change and the unrealised profit of each of a few holdings.
#' * For `Equity$search()`, find the nse shares whose symbol contains a partial name.
#' * For `Equity$search()`, search, then build the first match and print its last price.
#' * For `Equity$search()`, check whether a symbol is listed on both the nse and the bse.
#'
#' @examples
#' \dontrun{
#' share <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' frame <- share$relative_strength_index(window = 14, days = 365)
#' share$holdings
#' Equity$search(exchange = "nse", term = "RELI")
#'
#' share <- Equity$new(exchange = "nse", symbol = "IDEA")
#' holding <- share$holdings
#' if (is.null(holding)) {
#'   cat("No IDEA shares are held.", "\n")
#' } else {
#'   cat(
#'     holding[["quantity"]],
#'     "shares at",
#'     holding[["average_price"]],
#'     "\n"
#'   )
#' }
#'
#' symbols <- c(
#'   "IDEA",
#'   "ITC",
#'   "RELIANCE"
#' )
#' for (symbol in symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   holding <- share$holdings
#'   if (is.null(holding)) {
#'     cat(sprintf("%s: not held", symbol), "\n")
#'     next
#'   }
#'   pledged <- holding[["collateral_quantity"]]
#'   free_quantity <- holding[["quantity"]] - pledged
#'   cat(
#'     sprintf(
#'       "%s: %s held, %s free",
#'       symbol,
#'       holding[["quantity"]],
#'       free_quantity
#'     ),
#'     "\n"
#'   )
#' }
#'
#' share <- Equity$new(exchange = "nse", symbol = "ITC")
#' holding <- share$holdings
#' if (is.null(holding)) {
#'   cat("No ITC shares are held.", "\n")
#' } else {
#'   invested <- holding[["invested_value"]]
#'   current <- holding[["current_value"]]
#'   cat(sprintf("Invested %.2f, worth %.2f now", invested, current), "\n")
#' }
#'
#' share <- Equity$new(exchange = "nse", symbol = "IDEA")
#' print(share$holdings_value)
#'
#' symbols <- c(
#'   "IDEA",
#'   "ITC",
#'   "TCS"
#' )
#' total_value <- 0.0
#' for (symbol in symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   value <- share$holdings_value
#'   if (!is.null(value)) {
#'     total_value <- total_value + value
#'   }
#' }
#' cat(sprintf("Held in these shares: %.2f rupees", total_value), "\n")
#'
#' share <- Equity$new(exchange = "nse", symbol = "IDEA")
#' print(share$holdings_pnl)
#'
#' symbols <- c(
#'   "IDEA",
#'   "ITC"
#' )
#' for (symbol in symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   profit_and_loss <- share$holdings_pnl
#'   if (is.null(profit_and_loss)) {
#'     cat(sprintf("%s: not held", symbol), "\n")
#'     next
#'   }
#'   day_change <- profit_and_loss[["day_change"]]
#'   unrealized <- profit_and_loss[["unrealized"]]
#'   cat(
#'     sprintf("%s: today %s, unrealised %s", symbol, day_change, unrealized),
#'     "\n"
#'   )
#' }
#'
#' matches <- Equity$search(exchange = "nse", term = "RELI")
#' print(matches[, c(
#'   "symbol",
#'   "instrument_id"
#' )])
#'
#' matches <- Equity$search(exchange = "nse", term = "INFY", limit = 5)
#' if (is.null(matches)) {
#'   cat("No share matches.", "\n")
#' } else {
#'   symbol <- matches$symbol[[1]]
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   cat(symbol, share$last_price, "\n")
#' }
#'
#' exchanges <- c(
#'   "nse",
#'   "bse"
#' )
#' for (exchange in exchanges) {
#'   matches <- Equity$search(
#'     exchange = exchange,
#'     term = "TCS",
#'     limit = 1
#'   )
#'   found <- !is.null(matches) && matches$symbol[[1]] == "TCS"
#'   cat(sprintf("TCS listed on %s: %s", exchange, found), "\n")
#' }
#' }
#' @export
Equity <- R6::R6Class(
  "Equity",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the share up in UBI's equities segment and keeps its details.
    #' @param exchange The character exchange the share is listed on, such as `"nse"`.
    #' @param symbol The character symbol of the share, such as `"RELIANCE"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `Equity` object.
    #' @details Errors: signals `EquityError` when UBI has no share with that symbol on that exchange, or the instrument it returned is not in the equities segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = EQUITIES_EQUITY_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityError",
            sprintf("UBI has no %s share for the symbol %s", exchange, symbol),
            parent = error
          )
        }
      )
      expected_segment <- paste0(self$exchange, "_", EQUITIES_EQUITY_SEGMENT)
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityError",
          sprintf(
            "An instrument outside the %s segment is not an Equity: %s",
            EQUITIES_EQUITY_SEGMENT,
            self$format()
          )
        )
      }
    },

    #' @description
    #' Buys more of this share to keep.
    #'
    #' The order is always sent as `cnc`, which is the product that puts shares in the demat account. Nothing is read first, because a share can be bought whether or not it is already held, and UBI checks funds no more than a broker's order route does.
    #'
    #' The examples below, in order:
    #'
    #' * Bid for one Vodafone Idea share to keep, three per cent below the last price, and cancel the order the engine holds at once.
    #' * Send the same bid as an immediate-or-cancel order, which the exchange cancels itself when nothing matches.
    #' @param quantity The integer number of shares to buy.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(share$last_price * 0.97, 2)
    #' answer <- share$add_to_holdings(quantity = 1, price = price)
    #' cat(answer[["outcome"]], answer[["parent_id"]], "\n")
    #' if (!is.null(answer[["parent_id"]])) {
    #'   cancelled <- share$cancel_parent(answer[["parent_id"]])
    #'   print(cancelled[["state"]])
    #' }
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(share$last_price * 0.97, 2)
    #' answer <- share$add_to_holdings(
    #'   quantity = 1,
    #'   price = price,
    #'   validity = "ioc",
    #'   tag = "examplebid"
    #' )
    #' cat(answer[["outcome"]], answer[["status_message"]], "\n")
    #' if (!is.null(answer[["parent_id"]])) {
    #'   tryCatch(
    #'     share$cancel_parent(answer[["parent_id"]]),
    #'     ConflictError = function(error) {
    #'       cat("The order had already finished.", "\n")
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
            product = EQUITIES_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$buy_at_limit_price(
        price = price,
        quantity = quantity,
        product = EQUITIES_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    },

    #' @description
    #' Sells some of the shares held, without selling more than are free.
    #'
    #' Shares pledged as collateral cannot be sold until they are released at the broker, so the quantity asked for is measured against the free shares rather than the whole holding.
    #'
    #' The examples below, in order:
    #'
    #' * Offer one Vodafone Idea share from the holding three per cent above the last price, and cancel the order at once.
    #' * Catch the error raised when more shares are asked for than are free to sell, which sends no order.
    #' @param quantity The integer number of shares to sell.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this share is not held, or the quantity is more than the free shares; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' if (is.null(share$holdings)) {
    #'   cat("No IDEA shares are held, so there is nothing to offer.", "\n")
    #' } else {
    #'   price <- round(share$last_price * 1.03, 2)
    #'   answer <- share$reduce_holdings(quantity = 1, price = price)
    #'   cat(answer[["outcome"]], answer[["parent_id"]], "\n")
    #'   if (!is.null(answer[["parent_id"]])) {
    #'     share$cancel_parent(answer[["parent_id"]])
    #'   }
    #' }
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' tryCatch(
    #'   share$reduce_holdings(quantity = 10000000, price = 100.0),
    #'   HoldingError = function(error) {
    #'     cat(sprintf("Refused: %s", conditionMessage(error)), "\n")
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
            "%d of the %d %s shares held are free to sell, because %d are pledged as collateral, so %s cannot be sold",
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
    #' Sells every share held that is free to sell.
    #'
    #' Shares pledged as collateral are left alone, because they cannot be sold until they are released at the broker, so this empties the holding only when nothing is pledged.
    #'
    #' The examples below, in order:
    #'
    #' * Offer every free Vodafone Idea share three per cent above the last price, and cancel the order at once.
    #' * Catch the error raised for a share that is not held, which sends no order.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals `HoldingError` when this share is not held, or every share held is pledged as collateral; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' if (is.null(share$holdings)) {
    #'   cat("No IDEA shares are held, so there is nothing to sell.", "\n")
    #' } else {
    #'   price <- round(share$last_price * 1.03, 2)
    #'   answer <- share$liquidate_holdings(price = price)
    #'   cat(answer[["outcome"]], answer[["parent_id"]], "\n")
    #'   if (!is.null(answer[["parent_id"]])) {
    #'     share$cancel_parent(answer[["parent_id"]])
    #'   }
    #' }
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' tryCatch(
    #'   share$liquidate_holdings(price = 100.0),
    #'   HoldingError = function(error) {
    #'     cat(sprintf("Nothing sold: %s", conditionMessage(error)), "\n")
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
            "All %d %s shares held are pledged as collateral, so none can be sold",
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
    #' @field holdings The long-term holding of this share, merged across every broker, as a named list, or `NULL` when it is not held. A derivative is a position rather than a holding, and an index cannot be held at all. Reading this sends one request to UBI every time, because UBI serves the whole account's holdings and has no route for a single instrument.
    holdings = function(value) {
      if (!missing(value)) {
        stop("holdings is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        EQUITIES_HOLDINGS_PATH
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

    #' @field holdings_value The numeric worth of the shares held at the moment, or `NULL` when the share is not held. UBI prices a holding itself, so this reads the figure rather than working it out, which is the opposite of `positions_value`. It counts every share held, including any pledged as collateral, because a pledged share is still owned.
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

    #' @field holdings_pnl What the shares held have made or lost, as a named list with `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when the share is not held. It is not shaped like a position's `pnl`, which reports `realized`, `unrealized` and `total`, so only `unrealized` means the same thing in both. There is no realised figure, because selling a share removes it from the holding rather than booking a profit against it.
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
    # Reads this share's holding once, refusing when it is not held.
    # @return The named list holdings row for this share.
    # @details Errors: signals `HoldingError` when no broker holds this share, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    held_row = function() {
      row <- self$holdings
      if (is.null(row)) {
        ErrorCatalogue$raise(
          "HoldingError",
          sprintf(
            "No %s shares are held, so there is nothing to sell: %s",
            self$symbol,
            self$format()
          )
        )
      }
      row
    },

    # Works out how many of the shares held can be sold.
    # @param row The named list holdings row, with `quantity` and `collateral_quantity`.
    # @return The integer number of shares that are not pledged as collateral.
    free_quantity = function(row) {
      as.integer(row[["quantity"]] - row[["collateral_quantity"]])
    },

    # Sends the sell order that reduces the holding.
    # @param quantity The integer number of shares to sell.
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
            product = EQUITIES_HOLDINGS_ORDER_PRODUCT,
            validity = validity,
            after_market = after_market,
            tag = tag
          )
        )
      }
      self$sell_at_limit_price(
        price = price,
        quantity = quantity,
        product = EQUITIES_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag
      )
    }
  )
)

Equity$search <- function(
  exchange,
  term,
  limit = EQUITIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, EQUITIES_EQUITY_SEGMENT, term, limit)
}

#' One futures contract on a share, such as RELIANCE expiring in September
#'
#' @description
#' Built on `Futures`, so it carries the order-book values, the expiry and underlying members and the basis. Its underlying defaults to the share with the same symbol, found by UBI's link or by symbol on every read unless one is given.
#'
#' The class generator carries two discovery functions, which read the equity futures segment:
#'
#' * `EquityFutures$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the share's futures are listed for as a `Date` vector, soonest first, which is empty when nothing is listed. A contract expiring today counts as live.
#' * `EquityFutures$contracts(exchange, underlying_symbol = NULL, include_expired = FALSE, unified_broker_interface = NULL)` lists the contracts as a `data.frame` of identities, with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol` and `expiry_date`, sorted by expiry, or `NULL` when nothing matches. The rows are identities rather than objects, because building an object looks each contract up in UBI.
#'
#' Both signal `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' expiries <- EquityFutures$expiries(exchange = "nse", underlying_symbol = "RELIANCE")
#' future <- EquityFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiries[[1]]
#' )
#' future$basis_percent
#' }
#' @export
EquityFutures <- R6::R6Class(
  "EquityFutures",
  inherit = Futures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's equity futures segment and keeps its details.
    #' @param exchange The character exchange the contract trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the share the contract is written on, such as `"RELIANCE"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as an `Equity`, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `EquityFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `EquityFuturesError` when UBI has no such contract, or the instrument it returned is not in the equity futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = EQUITIES_EQUITY_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityFuturesError",
            sprintf(
              "UBI has no %s share futures contract on %s expiring %s",
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
        EQUITIES_EQUITY_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityFuturesError",
          sprintf(
            "An instrument outside the %s segment is not an EquityFutures: %s",
            EQUITIES_EQUITY_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

EquityFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    EQUITIES_EQUITY_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

EquityFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    EQUITIES_EQUITY_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on a share, such as a RELIANCE call at a given strike and expiry
#'
#' @description
#' Built on `Option`, so it carries the order-book values, the expiry and underlying members, the moneyness members, and `implied_volatility()` and `greeks()`, priced with Black-Scholes off the share unless a future is given as the underlying.
#'
#' The class generator carries three discovery functions, which read the equity options segment:
#'
#' * `EquityOption$expiries(exchange, underlying_symbol, include_expired = FALSE, unified_broker_interface = NULL)` lists the expiries the share's options are listed for as a `Date` vector, soonest first.
#' * `EquityOption$strikes(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists the strike prices for one expiry as a numeric vector, lowest first. It builds the chain and takes its distinct strikes, so it costs the same as `chain()`.
#' * `EquityOption$chain(exchange, underlying_symbol, expiry_date, include_expired = FALSE, unified_broker_interface = NULL)` lists every option for one expiry as a `data.frame` of identities with `instrument_id`, `exchange`, `segment`, `shape`, `underlying_symbol`, `expiry_date`, `strike_price` and `option_type`, sorted by strike price and then option type, or `NULL` when nothing matches.
#'
#' Each signals `BadRequestError` when the exchange is not one UBI knows, and a plain error when `expiry_date` is text that is not a valid ISO date.
#'
#' @examples
#' \dontrun{
#' expiry <- EquityOption$expiries(exchange = "nse", underlying_symbol = "RELIANCE")[[1]]
#' strikes <- EquityOption$strikes("nse", "RELIANCE", expiry)
#' call <- EquityOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "RELIANCE",
#'   expiry_date = expiry,
#'   strike_price = strikes[[length(strikes) %/% 2]],
#'   option_type = "CE"
#' )
#' call$greeks()
#' }
#' @export
EquityOption <- R6::R6Class(
  "EquityOption",
  inherit = Option,
  public = list(
    #' @description
    #' Looks the option up in UBI's equity options segment and keeps its details.
    #' @param exchange The character exchange the option trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the share the option is written on, such as `"RELIANCE"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option in rupees.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as an `Equity`, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `EquityOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `EquityOptionError` when UBI has no such option, or the instrument it returned is not in the equity options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = EQUITIES_EQUITY_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityOptionError",
            sprintf(
              "UBI has no %s share option on %s expiring %s at strike %s %s",
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
        EQUITIES_EQUITY_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityOptionError",
          sprintf(
            "An instrument outside the %s segment is not an EquityOption: %s",
            EQUITIES_EQUITY_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

EquityOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    EQUITIES_EQUITY_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

EquityOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    EQUITIES_EQUITY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

EquityOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    EQUITIES_EQUITY_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

#' One equity index, such as NIFTY on the nse, which is followed rather than traded
#'
#' @description
#' Built on `NonTradeableInstrument`, because an index cannot be traded, so it has candles, a quote, the analysis methods and `constituents`, but no order or position members.
#'
#' The class generator carries one discovery function:
#'
#' * `EquityIndex$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds equity indices whose symbol contains `term`, with an exact match first, then symbols starting with the term, then symbols containing it, so a partial name such as `"BANK"` finds BANKNIFTY near the top. It returns a `data.frame` of identities, or `NULL` when no index matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' The examples below start with a short tour of the class, then show the functions on its class generator, in this order:
#'
#' * For `EquityIndex$search()`, find the nse indices whose symbol contains `BANK`.
#' * For `EquityIndex$search()`, print the level of each index whose symbol contains `NIFTY IT`.
#' * For `EquityIndex$search()`, count how many indices the bse publishes with `SENSEX` in the symbol.
#'
#' @examples
#' \dontrun{
#' nifty <- EquityIndex$new(exchange = "nse", symbol = "NIFTY")
#' nifty$last_price
#' EquityIndex$search(exchange = "nse", term = "BANK")
#'
#' matches <- EquityIndex$search(exchange = "nse", term = "BANK")
#' print(matches$symbol)
#'
#' matches <- EquityIndex$search(exchange = "nse", term = "NIFTY IT")
#' if (is.null(matches)) {
#'   cat("No index matches.", "\n")
#' } else {
#'   for (symbol in matches$symbol) {
#'     index <- EquityIndex$new(exchange = "nse", symbol = symbol)
#'     cat(symbol, index$last_price, "\n")
#'   }
#' }
#'
#' matches <- EquityIndex$search(
#'   exchange = "bse",
#'   term = "SENSEX",
#'   limit = 200
#' )
#' if (is.null(matches)) {
#'   print(0)
#' } else {
#'   print(nrow(matches))
#' }
#' }
#' @export
EquityIndex <- R6::R6Class(
  "EquityIndex",
  inherit = NonTradeableInstrument,
  public = list(
    #' @description
    #' Looks the index up in UBI's equity indices segment and keeps its details.
    #' @param exchange The character exchange that publishes the index, such as `"nse"`.
    #' @param symbol The character symbol of the index, such as `"NIFTY"` or `"BANKNIFTY"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `EquityIndex` object.
    #' @details Errors: signals `EquityIndexError` when UBI has no index with that symbol on that exchange, or the instrument it returned is not in the equity indices segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = EQUITIES_EQUITY_INDICES_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityIndexError",
            sprintf("UBI has no %s equity index for the symbol %s", exchange, symbol),
            parent = error
          )
        }
      )
      expected_segment <- paste0(
        self$exchange,
        "_",
        EQUITIES_EQUITY_INDICES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityIndexError",
          sprintf(
            "An instrument outside the %s segment is not an EquityIndex: %s",
            EQUITIES_EQUITY_INDICES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

EquityIndex$search <- function(
  exchange,
  term,
  limit = EQUITIES_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, EQUITIES_EQUITY_INDICES_SEGMENT, term, limit)
}

#' One futures contract on an equity index, such as NIFTY expiring in September
#'
#' @description
#' Built on `IndexFutures`, so its default underlying is the index, found by symbol as a `NonTradeableInstrument` unless it is given or UBI links it.
#'
#' The class generator carries the discovery functions `EquityIndexFutures$expiries()` and `EquityIndexFutures$contracts()`, which take the same arguments and return the same shapes as `EquityFutures$expiries()` and `EquityFutures$contracts()`, reading the equity index futures segment.
#'
#' @examples
#' \dontrun{
#' expiry <- EquityIndexFutures$expiries(exchange = "nse", underlying_symbol = "NIFTY")[[1]]
#' future <- EquityIndexFutures$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = expiry
#' )
#' future$cost_of_carry
#' }
#' @export
EquityIndexFutures <- R6::R6Class(
  "EquityIndexFutures",
  inherit = IndexFutures,
  public = list(
    #' @description
    #' Looks the contract up in UBI's equity index futures segment and keeps its details.
    #' @param exchange The character exchange the contract trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the index the contract is written on, such as `"NIFTY"`.
    #' @param expiry_date The day the contract expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param underlying The `Instrument` the contract is written on, such as an `EquityIndex`, which the contract keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `EquityIndexFutures` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `EquityIndexFuturesError` when UBI has no such contract, or the instrument it returned is not in the equity index futures segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityIndexFuturesError",
            sprintf(
              "UBI has no %s equity index futures contract on %s expiring %s",
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
        EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityIndexFuturesError",
          sprintf(
            "An instrument outside the %s segment is not an EquityIndexFutures: %s",
            EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

EquityIndexFutures$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

EquityIndexFutures$contracts <- function(
  exchange,
  underlying_symbol = NULL,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    EQUITIES_EQUITY_INDEX_FUTURES_SEGMENT,
    underlying_symbol,
    NULL,
    include_expired
  )
}

#' One option on an equity index, such as a NIFTY call at a given strike and expiry
#'
#' @description
#' Built on `IndexOption`, so its default underlying is the index, and it is priced with Black-Scholes off the index unless a future is given as the underlying.
#'
#' The class generator carries the discovery functions `EquityIndexOption$expiries()`, `EquityIndexOption$strikes()` and `EquityIndexOption$chain()`, which take the same arguments and return the same shapes as those on `EquityOption`, reading the equity index options segment.
#'
#' @examples
#' \dontrun{
#' option <- EquityIndexOption$new(
#'   exchange = "nse",
#'   underlying_symbol = "NIFTY",
#'   expiry_date = "2026-09-29",
#'   strike_price = 25000,
#'   option_type = "CE"
#' )
#' option$last_price
#' option$moneyness_percent
#' }
#' @export
EquityIndexOption <- R6::R6Class(
  "EquityIndexOption",
  inherit = IndexOption,
  public = list(
    #' @description
    #' Looks the option up in UBI's equity index options segment and keeps its details.
    #' @param exchange The character exchange the option trades on, such as `"nse"`.
    #' @param underlying_symbol The character symbol of the index the option is written on, such as `"NIFTY"`.
    #' @param expiry_date The day the option expires, as a `Date` or a `"YYYY-MM-DD"` character value.
    #' @param strike_price The numeric strike price of the option in index points.
    #' @param option_type The character option type, `"CE"` for a call or `"PE"` for a put.
    #' @param underlying The `Instrument` the option is written on, such as an `EquityIndex`, which the option keeps and uses for `underlying` and `underlying_price`, or `NULL` to use UBI's link to the underlying or else the family's default, looked up on every read.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `EquityIndexOption` object.
    #' @details Errors: signals `TypeError` when `underlying` is given and is not an `Instrument`; `EquityIndexOptionError` when UBI has no such option, or the instrument it returned is not in the equity index options segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
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
          segment = EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT,
          underlying_symbol = underlying_symbol,
          expiry_date = expiry_date,
          strike_price = strike_price,
          option_type = option_type,
          underlying = underlying,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "EquityIndexOptionError",
            sprintf(
              "UBI has no %s equity index option on %s expiring %s at strike %s %s",
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
        EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "EquityIndexOptionError",
          sprintf(
            "An instrument outside the %s segment is not an EquityIndexOption: %s",
            EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT,
            self$format()
          )
        )
      }
    }
  )
)

EquityIndexOption$expiries <- function(
  exchange,
  underlying_symbol,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$expiry_dates(
    exchange,
    EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    include_expired
  )
}

EquityIndexOption$strikes <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$strikes(
    exchange,
    EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}

EquityIndexOption$chain <- function(
  exchange,
  underlying_symbol,
  expiry_date,
  include_expired = FALSE,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$contracts_for(
    exchange,
    EQUITIES_EQUITY_INDEX_OPTIONS_SEGMENT,
    underlying_symbol,
    expiry_date,
    include_expired
  )
}
