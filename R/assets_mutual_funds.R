MUTUAL_FUNDS_HOLDINGS_PATH <- "/api/portfolio/holdings"
MUTUAL_FUNDS_HOLDINGS_ORDER_PRODUCT <- "cnc"
MUTUAL_FUNDS_SEARCH_LIMIT <- 50
MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT <- "mutual_funds"

#' One mutual fund scheme, such as ABSLFTTIDG on the nse
#'
#' @description
#' `MutualFund` fixes UBI's `mutual_funds` segment, so the kind of instrument is the class rather than a segment name passed by hand. A fund is named by exchange and symbol, where the symbol is the scheme's exchange code such as `ABSLFTTIDG`. UBI carries them on the `nse` only, and it has no futures or options written on a mutual fund, so this family is one class.
#'
#' A mutual fund is unlike every other instrument. It is subscribed to and redeemed at the day's net asset value rather than bought and sold in a continuous market, and UBI has no quote for one: only a single broker carries the segment, and no broker that serves quotes does, so `quote`, `last_price`, `ohlc` and every order-book value signal `ServiceUnavailableError`. UBI stores no candles either, so `prices()` returns `NULL` and the inherited analysis methods have nothing to work on. `constituents` is the way to measure a scheme instead.
#'
#' What does work is holding. `mutual_funds` is one of UBI's cash segments, so a fund is reported in the account's holdings exactly as a share is, and `MutualFund` carries the same holdings members `Equity` does, including `add_to_holdings()`, `reduce_holdings()` and `liquidate_holdings()`, so that no class is an exception a caller has to remember.
#'
#' Those three methods send ordinary `cnc` orders, which is what UBI accepts for this segment. Whether a broker will treat such an order as a subscription is a question for the broker, and the practical obstacle comes first: with no quote there is no price to send a market order against, so a limit price is the only sensible form. Nothing here checks that, in keeping with the rule that orders reach UBI as given. A limit order is sent to a broker at once rather than held by UBI's order engine, and a market order is sent to the broker as a real market order rather than as the marketable limit UBI would otherwise make of it, because both of those need a quote.
#'
#' The class generator carries one discovery function:
#'
#' * `MutualFund$search(exchange, term, limit = 50, unified_broker_interface = NULL)` finds mutual fund schemes whose symbol contains `term`, matched without regard to case, with an exact match first, then symbols starting with the term, then symbols containing it. A scheme's symbol is its exchange code rather than its published name, so a useful term is the fund house's prefix, such as `"ABSL"`, rather than words from the scheme's title. It returns a `data.frame` with `instrument_id`, `exchange`, `segment`, `shape`, `symbol` and the derivative fields left empty, or `NULL` when no scheme matches, and signals `BadRequestError` when the exchange is not one UBI knows.
#'
#' @examples
#' \dontrun{
#' fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
#' row <- fund$holdings
#' value <- fund$holdings_value
#' basket <- fund$constituents
#'
#' matches <- MutualFund$search(exchange = "nse", term = "ABSL")
#' print(matches$symbol)
#'
#' prefixes <- c(
#'   "ABSL",
#'   "HDFC",
#'   "SBI",
#'   "ICICI"
#' )
#' for (prefix in prefixes) {
#'   matches <- MutualFund$search(exchange = "nse", term = prefix, limit = 200)
#'   if (is.null(matches)) {
#'     cat(prefix, ": none\n", sep = "")
#'   } else {
#'     cat(prefix, ": ", nrow(matches), " schemes\n", sep = "")
#'   }
#' }
#'
#' matches <- MutualFund$search(exchange = "nse", term = "ABSLFT")
#' first_symbol <- matches$symbol[[1]]
#' fund <- MutualFund$new(exchange = "nse", symbol = first_symbol)
#' print(fund)
#' cat("Lot size", fund$lot_size, "tick size", fund$tick_size, "\n")
#' }
#' @export
MutualFund <- R6::R6Class(
  "MutualFund",
  inherit = TradeableInstrument,
  public = list(
    #' @description
    #' Looks the scheme up in UBI's mutual funds segment and keeps its details.
    #'
    #' A mutual fund has no quote, because no broker that serves quotes carries the segment, so `last_price`, `quote`, `ohlc` and the order-book values signal `ServiceUnavailableError`. UBI stores no candles for one either, so `prices()` returns `NULL`. What works is the holdings members.
    #' @param exchange The character exchange the scheme is listed on, which UBI only has as `"nse"`.
    #' @param symbol The character exchange code of the scheme, such as `"ABSLFTTIDG"`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share one client among all instruments.
    #' @return A new `MutualFund` object.
    #' @details Errors: signals `MutualFundError` when UBI has no scheme with that symbol on that exchange, or the instrument it returned is not in the mutual funds segment; and a `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    initialize = function(exchange, symbol, unified_broker_interface = NULL) {
      tryCatch(
        super$initialize(
          exchange = exchange,
          segment = MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT,
          symbol = symbol,
          unified_broker_interface = unified_broker_interface
        ),
        InstrumentError = function(error) {
          ErrorCatalogue$raise(
            "MutualFundError",
            sprintf(
              "UBI has no %s mutual fund for the symbol %s",
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
        MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT
      )
      if (self$segment != expected_segment) {
        ErrorCatalogue$raise(
          "MutualFundError",
          sprintf(
            "An instrument outside the %s segment is not a MutualFund: %s",
            MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT,
            self$format()
          )
        )
      }
    },

    #' @description
    #' Buys more units of this scheme to keep.
    #'
    #' The order is sent as `cnc`, which is what UBI accepts for this segment. Give a price: a mutual fund has no quote, so there is nothing for a market order to be priced against, and leaving `price` as `NULL` sends one anyway rather than second-guessing UBI. A limit order is sent to a broker at once, with `hold = FALSE`, because UBI's order engine would otherwise hold it until a quote that never comes. A market order is sent to the broker as a real market order rather than as the marketable limit UBI would otherwise make of it, because a marketable limit needs a quote and would always be refused with HTTP 409.
    #' @param quantity The integer number of units to buy.
    #' @param price The numeric limit price in rupees, or `NULL` to send a market order.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits for the order, or `NULL`.
    #' @return The named list `place_order()` returns, holding `broker`, `order_id`, `outcome` and the rest.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    #' answer <- fund$add_to_holdings(quantity = 1, price = 10)
    #' print(answer)
    #' order_id <- answer[["order_id"]]
    #' for (attempt in seq_len(30)) {
    #'   open_orders <- fund$open_orders
    #'   if (!is.null(open_orders) && order_id %in% open_orders$order_id) {
    #'     print(fund$cancel_order(order_id))
    #'     break
    #'   }
    #'   Sys.sleep(1)
    #' }
    #' print(fund$orders)
    #'
    #' answer <- fund$add_to_holdings(
    #'   quantity = 1,
    #'   price = 10,
    #'   tag = "examplefund"
    #' )
    #' order_id <- answer[["order_id"]]
    #' Sys.sleep(10)
    #' open_orders <- fund$open_orders
    #' if (!is.null(open_orders) && order_id %in% open_orders$order_id) {
    #'   print(fund$cancel_order(order_id))
    #' }
    #' orders <- fund$orders
    #' print(orders[orders$order_id == order_id, ])
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
            product = MUTUAL_FUNDS_HOLDINGS_ORDER_PRODUCT,
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
        product = MUTUAL_FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag,
        hold = FALSE
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
    #' @details Errors: signals `HoldingError` when this scheme is not held, or the quantity is more than the free units; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    #' row <- fund$holdings
    #' if (is.null(row)) {
    #'   cat("No ABSLFTTIDG units are held, so there is nothing to reduce.\n")
    #' } else {
    #'   limit_price <- round(row[["last_price"]] * 1.03, 2)
    #'   answer <- fund$reduce_holdings(quantity = 1, price = limit_price)
    #'   print(answer)
    #'   order_id <- answer[["order_id"]]
    #'   for (attempt in seq_len(30)) {
    #'     open_orders <- fund$open_orders
    #'     if (!is.null(open_orders) && order_id %in% open_orders$order_id) {
    #'       print(fund$cancel_order(order_id))
    #'       break
    #'     }
    #'     Sys.sleep(1)
    #'   }
    #' }
    #'
    #' tryCatch(
    #'   fund$reduce_holdings(quantity = 10000000, price = 10),
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
    #' @details Errors: signals `HoldingError` when this scheme is not held, or every unit held is pledged as collateral; and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDG")
    #' row <- fund$holdings
    #' if (is.null(row)) {
    #'   cat("No ABSLFTTIDG units are held, so there is nothing to sell.\n")
    #' } else {
    #'   limit_price <- round(row[["last_price"]] * 1.03, 2)
    #'   answer <- fund$liquidate_holdings(price = limit_price)
    #'   print(answer)
    #'   order_id <- answer[["order_id"]]
    #'   for (attempt in seq_len(30)) {
    #'     open_orders <- fund$open_orders
    #'     if (!is.null(open_orders) && order_id %in% open_orders$order_id) {
    #'       print(fund$cancel_order(order_id))
    #'       break
    #'     }
    #'     Sys.sleep(1)
    #'   }
    #' }
    #'
    #' fund <- MutualFund$new(exchange = "nse", symbol = "ABSLFTTIDN")
    #' answer <- tryCatch(
    #'   fund$liquidate_holdings(price = 10),
    #'   HoldingError = function(error) {
    #'     cat("Nothing to redeem:", conditionMessage(error), "\n")
    #'     NULL
    #'   }
    #' )
    #' if (!is.null(answer)) {
    #'   print(answer)
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
    #' @field constituents The stored basket of what the scheme holds, a `MutualFundConstituents`, or `NULL` when none is stored for today, read from MongoDB and UBI on every access. This is the scheme's own portfolio, which is different from `holdings`, the units of the scheme this account holds. UBI has no price for a mutual fund, so this is the only way to measure one: the scheme's own `sharpe_ratio()` and the other performance methods return `NULL`, while the basket's work. UBI stores no fund holdings, so a basket exists only when one was saved with this scheme as its linked instrument.
    constituents = function(value) {
      if (!missing(value)) {
        stop("constituents is read-only", call. = FALSE)
      }
      store <- BasketStore$new(
        unified_broker_interface = private$unified_broker_interface
      )
      store$load_for_instrument(self)
    },

    #' @field holdings The holding of this scheme, merged across every broker, as a named list, or `NULL` when it is not held. Reading this sends one request to UBI every time, because UBI serves the whole account's holdings and has no route for a single instrument.
    holdings = function(value) {
      if (!missing(value)) {
        stop("holdings is read-only", call. = FALSE)
      }
      rows <- private$unified_broker_interface$get(
        MUTUAL_FUNDS_HOLDINGS_PATH
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

    #' @field holdings_value The numeric worth of the units held at the moment, or `NULL` when the scheme is not held. UBI prices a holding itself, so this reads the figure rather than working it out. A mutual fund has no quote of its own, so the figure rests on whatever last price the broker reported for the holding.
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

    #' @field holdings_pnl What the units held have made or lost, as a named list with `day_change`, `day_change_percentage` and `unrealized`, or `NULL` when the scheme is not held. It is not shaped like a position's `pnl`, which reports `realized`, `unrealized` and `total`, so only `unrealized` means the same thing in both.
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
    # Reads this scheme's holding once, refusing when it is not held.
    # @return The named list holdings row for this scheme.
    # @details Errors: signals `HoldingError` when no broker holds this scheme, and a `UnifiedBrokerInterfaceError` subclass for any failure reported by, or on the way to, UBI.
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
    # A limit order is sent to a broker at once, and without a price the order is sent as a real market order, because a mutual fund has no quote for UBI's order engine to hold a limit against or to price a marketable limit from.
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
            product = MUTUAL_FUNDS_HOLDINGS_ORDER_PRODUCT,
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
        product = MUTUAL_FUNDS_HOLDINGS_ORDER_PRODUCT,
        validity = validity,
        after_market = after_market,
        tag = tag,
        hold = FALSE
      )
    }
  )
)

MutualFund$search <- function(
  exchange,
  term,
  limit = MUTUAL_FUNDS_SEARCH_LIMIT,
  unified_broker_interface = NULL
) {
  catalogue <- InstrumentCatalogue$new(unified_broker_interface)
  catalogue$search(exchange, MUTUAL_FUNDS_MUTUAL_FUNDS_SEGMENT, term, limit)
}
