ASSET_BASKETS_HOLDINGS_PATH <- "/api/portfolio/holdings"
ASSET_BASKETS_POSITIONS_PATH <- "/api/portfolio/positions"
ASSET_BASKETS_ORDER_PLACE_PATH <- "/api/orders/place"
ASSET_BASKETS_ORDER_LIST_TIMEOUT_SECONDS <- 60
ASSET_BASKETS_BUY <- "buy"
ASSET_BASKETS_SELL <- "sell"
ASSET_BASKETS_MARKET_ORDER_TYPE <- "market"
ASSET_BASKETS_ORDER_RESULT_COLUMNS <- c(
  "label",
  "instrument_id",
  "transaction_type",
  "quantity",
  "status",
  "broker",
  "outcome",
  "order_id",
  "parent_id",
  "intent_id",
  "error"
)
ASSET_BASKETS_REBALANCE_COLUMNS <- c(
  "label",
  "instrument_id",
  "last_price",
  "current_quantity",
  "target_quantity",
  "trade_quantity",
  "transaction_type"
)

#' A basket of instruments held in known quantities
#'
#' @description
#' `Portfolio` gives every member a quantity, and optionally the average price it was bought at. It can be built by hand, or read from the account with `Portfolio$from_holdings()` or `Portfolio$from_positions()`, which build every member from one list request. Its weights are the members' shares of today's value, and its candles are what the same quantities would have been worth at each candle, so the inherited `sharpe_ratio()` or `maximum_drawdown()` describe the portfolio as it is held now.
#'
#' `place_orders()` sends one market order per member in a single `POST /api/orders/place` list request, which UBI's order engine places in parallel at whichever broker each order suits; it does not use UBI's `basket` synthetic order, which is capped at 25 legs and sends every leg to one broker. `rebalance_trades()` works out the buys and sells that would move the portfolio to another basket's weights, and `rebalance()` sends them. The quantities are floored to whole units and sent as computed, with no lot size or tick size check, because UBI checks orders itself. UBI's order engine sends each market order as a `marketable_limit`, a limit two ticks past the other side's best price that follows the book and is cancelled after 30 seconds, so a member with nobody on the other side of the book or no fresh quote gets HTTP 409 in its row and an order that has not filled within the 30 seconds is left part filled; `as_marketable_limit = FALSE` sends real market orders instead.
#'
#' The class generator carries `Portfolio$KIND`, `"portfolio"`, and two functions that stand in for Python's class methods:
#'
#' * `Portfolio$from_holdings(name = "holdings", unified_broker_interface = NULL)` builds a portfolio of the account's long-term holdings, as UBI reports them now, with one member per holding carrying its quantity and average price. It signals `BasketMemberError` when the account holds nothing or UBI could not find a held instrument, and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
#' * `Portfolio$from_positions(name = "positions", day = FALSE, unified_broker_interface = NULL)` builds a portfolio of the account's open positions, today's when `day` is `TRUE` and the net ones otherwise, with one member per instrument with a non-zero position. An instrument held under more than one product, such as intraday and carry, becomes one member whose quantity is the total; its average price is then left unknown, because the products' prices cannot be added. It signals `BasketMemberError` when no position is open or UBI could not find a position's instrument, and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
#'
#' @examples
#' \dontrun{
#' held <- Portfolio$from_holdings()
#' value <- held$value
#' profit <- held$unrealized_pnl
#'
#' held <- tryCatch(
#'   Portfolio$from_holdings(),
#'   BasketMemberError = function(error) {
#'     print(conditionMessage(error))
#'     NULL
#'   }
#' )
#' if (!is.null(held)) {
#'   print(held$quantities)
#' }
#' held <- Portfolio$from_holdings(name = "demat holdings")
#' cat(sprintf("%d holdings worth %s\n", held$size, held$value))
#' cat(sprintf("Unrealised profit: %s\n", held$unrealized_pnl))
#'
#' positions <- tryCatch(
#'   Portfolio$from_positions(),
#'   BasketMemberError = function(error) {
#'     print(conditionMessage(error))
#'     NULL
#'   }
#' )
#' if (!is.null(positions)) {
#'   print(positions$quantities)
#' }
#' today <- tryCatch(
#'   Portfolio$from_positions(name = "today", day = TRUE),
#'   BasketMemberError = function(error) {
#'     cat(sprintf("Nothing traded today: %s\n", conditionMessage(error)))
#'     NULL
#'   }
#' )
#' if (!is.null(today)) {
#'   print(today$value)
#' }
#'
#' quantities <- c(
#'   IDEA = 100,
#'   INFY = 5,
#'   TCS = 2
#' )
#' average_prices <- c(
#'   IDEA = 12.5,
#'   INFY = 1450,
#'   TCS = 3100
#' )
#' members <- list()
#' for (symbol in names(quantities)) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   members[[length(members) + 1]] <- BasketMember$new(
#'     share,
#'     quantity = quantities[[symbol]],
#'     average_price = average_prices[[symbol]]
#'   )
#' }
#' held <- Portfolio$new(name = "long-term shares", members = members)
#'
#' pair <- Portfolio$new(
#'   name = "bank pair",
#'   members = list(
#'     BasketMember$new(
#'       Equity$new(exchange = "nse", symbol = "HDFCBANK"),
#'       quantity = 10
#'     ),
#'     BasketMember$new(
#'       Equity$new(exchange = "nse", symbol = "ICICIBANK"),
#'       quantity = -8
#'     )
#'   )
#' )
#'
#' print(held$quantities)
#' print(pair$quantities)
#'
#' print(round(held$values, 2))
#' values <- pair$values
#' print(round(values, 2))
#' cat(sprintf("Net: %.2f\n", sum(values)))
#'
#' cat(sprintf("Portfolio value: Rs %.2f\n", held$value))
#' print(pair$value)
#'
#' print(round(held$weights, 3))
#' weights <- pair$weights
#' print(round(weights, 3))
#' cat(sprintf("Absolute weights add up to %s\n", sum(abs(weights))))
#'
#' cat(sprintf("Invested: Rs %.2f\n", held$invested_value))
#' print(pair$invested_value)
#'
#' cat(sprintf("Unrealised profit: Rs %.2f\n", held$unrealized_pnl))
#' profit <- held$unrealized_pnl
#' percent <- profit / held$invested_value * 100
#' cat(sprintf("%+.2f%%\n", percent))
#'
#' cat(sprintf("Today: Rs %+.2f\n", held$day_pnl))
#' print(pair$day_pnl)
#'
#' cat(sprintf("%+.2f%%\n", held$day_change_percent))
#' print(held$ohlc[, c("label", "change_percent")])
#' cat(sprintf("Portfolio: %+.2f%%\n", held$day_change_percent))
#' }
#' @export
Portfolio <- R6::R6Class(
  "Portfolio",
  inherit = AssetBasket,
  public = list(
    #' @field KIND The character kind stored with the portfolio, `"portfolio"`.
    KIND = "portfolio",

    #' @description
    #' Initialises the portfolio and checks that every member has a quantity.
    #' @param name The character name of the portfolio.
    #' @param members A list of `BasketMember` objects, each with a quantity, negative for a short position, and each a different instrument.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `Portfolio` object.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or has a member without a quantity.
    initialize = function(name, members, unified_broker_interface = NULL) {
      super$initialize(
        name = name,
        members = members,
        unified_broker_interface = unified_broker_interface
      )
      for (member in self$members) {
        if (is.null(member$quantity)) {
          ErrorCatalogue$raise(
            "BasketMemberError",
            sprintf(
              "Every member of a Portfolio needs a quantity: %s",
              member$label
            )
          )
        }
      }
    },

    #' @description
    #' Sends one market order per member for its quantity, all in one list request.
    #'
    #' With `buy`, each member's quantity is bought, and a negative quantity is sold instead; with `sell`, the other way round. This buys a portfolio built by hand or by `Index$to_portfolio()`, and sells one to close it. The orders are placed in parallel and not as one unit, so some can be accepted while others are refused, and each row of the answer says what happened to its order.
    #'
    #' UBI's order engine sends each order as a `marketable_limit`: a limit two ticks past the other side's best price, moved after that price until it fills, with whatever is left cancelled 30 seconds after it was placed. A member that cannot be priced, because nobody is on the other side of its book, no live quote has arrived or the quote is marked stale, gets HTTP 409 in its row and nothing is sent for it. Pass `as_marketable_limit = FALSE` to send real market orders, which a member with no live quote, such as a mutual fund, needs.
    #' @param product The character product every order is sent with, such as `"cnc"` for delivery or `"mis"` for intraday.
    #' @param transaction_type The character side for a positive quantity, `"buy"` or `"sell"`.
    #' @param validity The character validity of every order, such as `"day"`.
    #' @param tag A character tag to put on every order, or `NULL`.
    #' @param dry_run A logical that is `TRUE` to have UBI build every order without sending it.
    #' @param as_marketable_limit A logical that is `TRUE` to let UBI's order engine send each order as a limit that follows the other side of the book for up to 30 seconds, and `FALSE` to send market orders to the brokers at once.
    #' @return A `data.frame` with one row per order, holding `label`, `instrument_id`, `transaction_type`, `quantity`, the entry's HTTP `status`, the `broker` UBI chose, `outcome`, `order_id`, `parent_id`, `intent_id` and `error`.
    #' @details Errors: signals `BadRequestError` when UBI refused the whole list, such as one longer than its limit of 500 orders; `ServiceUnavailableError` when UBI's order engine is not running, so nothing was placed; and another `UnifiedBrokerInterfaceError` subclass for any other failure of the whole request.
    #' @examples
    #' \dontrun{
    #' quantities <- c(
    #'   IDEA = 100,
    #'   INFY = 5,
    #'   TCS = 2
    #' )
    #' average_prices <- c(
    #'   IDEA = 12.5,
    #'   INFY = 1450,
    #'   TCS = 3100
    #' )
    #' members <- list()
    #' for (symbol in names(quantities)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     quantity = quantities[[symbol]],
    #'     average_price = average_prices[[symbol]]
    #'   )
    #' }
    #' held <- Portfolio$new(name = "long-term shares", members = members)
    #' results <- held$place_orders(product = "cnc", dry_run = TRUE)
    #' print(results[, c("label", "transaction_type", "quantity", "status")])
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' one_share <- Portfolio$new(
    #'   name = "one IDEA share",
    #'   members = list(
    #'     BasketMember$new(idea, quantity = 1)
    #'   )
    #' )
    #' bought <- one_share$place_orders(product = "mis", tag = "basketexample")
    #' print(bought[, c("label", "transaction_type", "outcome", "order_id")])
    #' order_id <- as.character(bought$order_id[[1]])
    #' status <- NULL
    #' for (attempt in seq_len(15)) {
    #'   Sys.sleep(2)
    #'   orders <- idea$orders
    #'   if (is.null(orders)) {
    #'     next
    #'   }
    #'   matching <- orders[as.character(orders$order_id) == order_id, ]
    #'   if (nrow(matching) == 0) {
    #'     next
    #'   }
    #'   status <- matching$status[[1]]
    #'   if (status %in% c(
    #'     "COMPLETE",
    #'     "REJECTED",
    #'     "CANCELLED"
    #'   )) {
    #'     break
    #'   }
    #' }
    #' cat(sprintf("The buy order is %s\n", status))
    #' if (identical(status, "COMPLETE")) {
    #'   sold <- one_share$place_orders(
    #'     product = "mis",
    #'     transaction_type = "sell"
    #'   )
    #'   print(sold[, c("label", "transaction_type", "outcome", "error")])
    #'   if (!identical(sold$outcome[[1]], "accepted")) {
    #'     closed <- idea$reduce_position(quantity = 1, product = "mis")
    #'     cat(sprintf("Closed instead: %s\n", closed$outcome))
    #'   }
    #' } else if (status %in% c(
    #'   "OPEN",
    #'   "PENDING"
    #' )) {
    #'   print(idea$cancel_order(order_id)$outcome)
    #' }
    #'
    #' results <- held$place_orders(
    #'   product = "cnc",
    #'   dry_run = TRUE,
    #'   as_marketable_limit = FALSE
    #' )
    #' print(results[, c("label", "transaction_type", "quantity", "status")])
    #' }
    place_orders = function(
      product,
      transaction_type = ASSET_BASKETS_BUY,
      validity = "day",
      tag = NULL,
      dry_run = FALSE,
      as_marketable_limit = TRUE
    ) {
      planned <- list()
      for (member in self$members) {
        if (member$quantity == 0) {
          next
        }
        side <- transaction_type
        if (member$quantity < 0) {
          side <- private$opposite_side(transaction_type)
        }
        planned[[length(planned) + 1]] <- list(
          label = member$label,
          instrument_id = member$instrument$instrument_id,
          transaction_type = side,
          quantity = abs(member$quantity)
        )
      }
      private$send_orders(
        planned,
        product,
        validity,
        tag,
        dry_run,
        as_marketable_limit
      )
    },

    #' @description
    #' Works out the buys and sells that would give the portfolio another basket's weights, without sending anything.
    #'
    #' Each target quantity is the capital times the target weight divided by the last price, floored to a whole unit. An instrument held but not in the target is sold entirely, and one in the target but not held is bought.
    #' @param target The `AssetBasket` whose weights to move to, such as an `Index`.
    #' @param capital The numeric amount in rupees to spread across the target, or `NULL` to use the portfolio's value now.
    #' @return A `data.frame` with one row per instrument that needs a trade, sells first, holding `label`, `instrument_id`, `last_price`, `current_quantity`, `target_quantity`, `trade_quantity`, which is negative for a sale, and `transaction_type`.
    #' @details Errors: signals `BasketMemberError` when an instrument in either basket has no last price; and a `UnifiedBrokerInterfaceError` subclass when UBI refused a request or could not be reached.
    #' @examples
    #' \dontrun{
    #' quantities <- c(
    #'   IDEA = 100,
    #'   INFY = 5,
    #'   TCS = 2
    #' )
    #' average_prices <- c(
    #'   IDEA = 12.5,
    #'   INFY = 1450,
    #'   TCS = 3100
    #' )
    #' members <- list()
    #' for (symbol in names(quantities)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     quantity = quantities[[symbol]],
    #'     average_price = average_prices[[symbol]]
    #'   )
    #' }
    #' held <- Portfolio$new(name = "long-term shares", members = members)
    #'
    #' target_members <- list()
    #' for (symbol in c(
    #'   "INFY",
    #'   "TCS"
    #' )) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   target_members[[length(target_members) + 1]] <- BasketMember$new(share)
    #' }
    #' target <- Index$new(
    #'   name = "IT equal",
    #'   members = target_members,
    #'   weighting = "equal"
    #' )
    #' trades <- held$rebalance_trades(target = target)
    #' print(trades[, c("label", "current_quantity", "target_quantity")])
    #'
    #' trades <- held$rebalance_trades(target = target, capital = 50000)
    #' print(trades[, c("label", "trade_quantity", "transaction_type")])
    #' }
    rebalance_trades = function(target, capital = NULL) {
      target_weights <- private$weights_by_instrument_id_of(target)
      instruments_by_id <- list()
      for (member in self$members) {
        held_instrument <- member$instrument
        instruments_by_id[[held_instrument$instrument_id]] <- held_instrument
      }
      for (instrument in target$instruments) {
        if (!(instrument$instrument_id %in% names(instruments_by_id))) {
          instruments_by_id[[instrument$instrument_id]] <- instrument
        }
      }
      all_instruments <- unname(instruments_by_id)
      last_prices <- private$last_prices_by_instrument_id(all_instruments)
      current_quantities <- list()
      for (member in self$members) {
        current_quantities[[member$instrument$instrument_id]] <- as.numeric(
          member$quantity
        )
      }
      if (is.null(capital)) {
        capital <- 0
        for (instrument_id in names(current_quantities)) {
          capital <- capital +
            current_quantities[[instrument_id]] * last_prices[[instrument_id]]
        }
      }
      rows <- list()
      for (instrument in all_instruments) {
        instrument_id <- instrument$instrument_id
        last_price <- last_prices[[instrument_id]]
        current_quantity <- 0
        if (instrument_id %in% names(current_quantities)) {
          current_quantity <- current_quantities[[instrument_id]]
        }
        target_weight <- 0
        if (instrument_id %in% names(target_weights)) {
          target_weight <- target_weights[[instrument_id]]
        }
        target_quantity <- private$whole_units(
          capital * target_weight / last_price
        )
        trade_quantity <- target_quantity - current_quantity
        if (trade_quantity == 0) {
          next
        }
        if (trade_quantity > 0) {
          side <- ASSET_BASKETS_BUY
        } else {
          side <- ASSET_BASKETS_SELL
        }
        rows[[length(rows) + 1]] <- list(
          label = BasketMember$new(instrument)$label,
          instrument_id = instrument_id,
          last_price = last_price,
          current_quantity = current_quantity,
          target_quantity = target_quantity,
          trade_quantity = trade_quantity,
          transaction_type = side
        )
      }
      if (length(rows) == 0) {
        return(private$empty_rebalance_frame())
      }
      frame <- FrameBuilder$new()$frame(rows)
      frame <- frame[order(frame$trade_quantity, method = "radix"), ,
                     drop = FALSE]
      rownames(frame) <- NULL
      frame
    },

    #' @description
    #' Sends the market orders `rebalance_trades()` works out, all in one list request.
    #'
    #' The sales and purchases are sent together and placed in parallel, so for a delivery account the purchases must be affordable without the money the sales will release.
    #'
    #' UBI's order engine sends each order as a `marketable_limit`: a limit two ticks past the other side's best price, moved after that price until it fills, with whatever is left cancelled 30 seconds after it was placed. A member that cannot be priced, because nobody is on the other side of its book, no live quote has arrived or the quote is marked stale, gets HTTP 409 in its row, which leaves the portfolio part rebalanced, and nothing is sent for it. Pass `as_marketable_limit = FALSE` to send real market orders, which a member with no live quote, such as a mutual fund, needs.
    #' @param target The `AssetBasket` whose weights to move to, such as an `Index`.
    #' @param product The character product every order is sent with, such as `"cnc"`.
    #' @param capital The numeric amount in rupees to spread across the target, or `NULL` to use the portfolio's value now.
    #' @param validity The character validity of every order, such as `"day"`.
    #' @param tag A character tag to put on every order, or `NULL`.
    #' @param dry_run A logical that is `TRUE` to have UBI build every order without sending it.
    #' @param as_marketable_limit A logical that is `TRUE` to let UBI's order engine send each order as a limit that follows the other side of the book for up to 30 seconds, and `FALSE` to send market orders to the brokers at once.
    #' @return A `data.frame` with one row per order, in the form `place_orders()` returns, which has no rows when no trade is needed.
    #' @details Errors: signals `BasketMemberError` when an instrument in either basket has no last price; `ServiceUnavailableError` when UBI's order engine is not running, so nothing was placed; and another `UnifiedBrokerInterfaceError` subclass for any other failure of a whole request.
    #' @examples
    #' \dontrun{
    #' quantities <- c(
    #'   IDEA = 100,
    #'   INFY = 5,
    #'   TCS = 2
    #' )
    #' average_prices <- c(
    #'   IDEA = 12.5,
    #'   INFY = 1450,
    #'   TCS = 3100
    #' )
    #' members <- list()
    #' for (symbol in names(quantities)) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(
    #'     share,
    #'     quantity = quantities[[symbol]],
    #'     average_price = average_prices[[symbol]]
    #'   )
    #' }
    #' held <- Portfolio$new(name = "long-term shares", members = members)
    #'
    #' target_members <- list()
    #' for (symbol in c(
    #'   "INFY",
    #'   "TCS"
    #' )) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   target_members[[length(target_members) + 1]] <- BasketMember$new(share)
    #' }
    #' target <- Index$new(
    #'   name = "IT equal",
    #'   members = target_members,
    #'   weighting = "equal"
    #' )
    #' results <- held$rebalance(
    #'   target = target,
    #'   product = "cnc",
    #'   dry_run = TRUE
    #' )
    #' print(results[, c("label", "transaction_type", "quantity", "status")])
    #'
    #' results <- held$rebalance(
    #'   target = target,
    #'   product = "cnc",
    #'   capital = 50000,
    #'   tag = "rebalance",
    #'   dry_run = TRUE
    #' )
    #' print(results[, c("label", "quantity", "status", "error")])
    #' }
    rebalance = function(
      target,
      product,
      capital = NULL,
      validity = "day",
      tag = NULL,
      dry_run = FALSE,
      as_marketable_limit = TRUE
    ) {
      trades <- self$rebalance_trades(target, capital)
      planned <- list()
      for (row_index in seq_len(nrow(trades))) {
        planned[[length(planned) + 1]] <- list(
          label = trades$label[[row_index]],
          instrument_id = trades$instrument_id[[row_index]],
          transaction_type = trades$transaction_type[[row_index]],
          quantity = abs(trades$trade_quantity[[row_index]])
        )
      }
      private$send_orders(
        planned,
        product,
        validity,
        tag,
        dry_run,
        as_marketable_limit
      )
    }
  ),
  active = list(
    #' @field quantities A named numeric vector of each member's quantity, named by member label.
    quantities = function(value) {
      if (!missing(value)) {
        stop("quantities is read-only", call. = FALSE)
      }
      held <- numeric(0)
      for (member in self$members) {
        held <- c(
          held,
          as.numeric(member$quantity)
        )
      }
      names(held) <- self$labels
      held
    },

    #' @field values A named numeric vector of each member's value in rupees at its last price, negative for a short position, named by member label, or `NULL` when any member has no last price; read from UBI in one request on every access.
    values = function(value) {
      if (!missing(value)) {
        stop("values is read-only", call. = FALSE)
      }
      frame <- self$last_prices
      last_prices <- as.numeric(frame$last_price)
      if (any(is.na(last_prices))) {
        return(NULL)
      }
      names(last_prices) <- self$labels
      self$quantities * last_prices
    },

    #' @field value The numeric value in rupees of the whole portfolio at last prices, or `NULL` when any member has no last price, read from UBI on every access.
    value = function(value) {
      if (!missing(value)) {
        stop("value is read-only", call. = FALSE)
      }
      values <- self$values
      if (is.null(values)) {
        return(NULL)
      }
      sum(values)
    },

    #' @field weights A named numeric vector of each member's share of the portfolio's gross value at last prices, named by member label, where a short position has a negative weight and the absolute weights sum to 1, read from UBI on every access. Reading it signals `BasketMemberError` when a member has no last price.
    weights = function(value) {
      if (!missing(value)) {
        stop("weights is read-only", call. = FALSE)
      }
      values <- self$values
      if (is.null(values)) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "A member of '%s' has no last price, so the weights cannot be known",
            self$name
          )
        )
      }
      values / sum(abs(values))
    },

    #' @field invested_value The numeric amount in rupees paid for the portfolio, the sum of quantity times average price, or `NULL` when any member's average price is unknown.
    invested_value = function(value) {
      if (!missing(value)) {
        stop("invested_value is read-only", call. = FALSE)
      }
      total <- 0
      for (member in self$members) {
        if (is.null(member$average_price)) {
          return(NULL)
        }
        total <- total +
          as.numeric(member$quantity) * as.numeric(member$average_price)
      }
      total
    },

    #' @field unrealized_pnl The numeric profit in rupees of the portfolio's value over what was paid for it, or `NULL` when the value or any average price is unknown, read from UBI on every access.
    unrealized_pnl = function(value) {
      if (!missing(value)) {
        stop("unrealized_pnl is read-only", call. = FALSE)
      }
      invested_value <- self$invested_value
      if (is.null(invested_value)) {
        return(NULL)
      }
      current_value <- self$value
      if (is.null(current_value)) {
        return(NULL)
      }
      current_value - invested_value
    },

    #' @field day_pnl The numeric profit in rupees since the previous close, the sum of quantity times the change from the previous close to the last price, or `NULL` when any member has no quote, read from UBI on every access.
    day_pnl = function(value) {
      if (!missing(value)) {
        stop("day_pnl is read-only", call. = FALSE)
      }
      frame <- self$ohlc
      last_prices <- as.numeric(frame$last_price)
      previous_closes <- as.numeric(frame$previous_close)
      if (any(is.na(last_prices)) || any(is.na(previous_closes))) {
        return(NULL)
      }
      changes <- last_prices - previous_closes
      sum(unname(self$quantities) * changes)
    },

    #' @field day_change_percent The numeric move of the portfolio's value since the previous close, in percent, or `NULL` when any member has no quote or the previous value is zero, read from UBI on every access.
    day_change_percent = function(value) {
      if (!missing(value)) {
        stop("day_change_percent is read-only", call. = FALSE)
      }
      frame <- self$ohlc
      last_prices <- as.numeric(frame$last_price)
      previous_closes <- as.numeric(frame$previous_close)
      if (any(is.na(last_prices)) || any(is.na(previous_closes))) {
        return(NULL)
      }
      quantities <- unname(self$quantities)
      previous_value <- sum(quantities * previous_closes)
      if (previous_value == 0) {
        return(NULL)
      }
      last_value <- sum(quantities * last_prices)
      (last_value / previous_value - 1) * 100
    }
  ),
  private = list(
    # Sends planned market orders in one list request and tabulates UBI's answer.
    # @param planned A list of named lists, each with `label`, `instrument_id`, `transaction_type` and a positive `quantity`.
    # @param product The character product every order is sent with.
    # @param validity The character validity of every order.
    # @param tag A character tag to put on every order, or `NULL`.
    # @param dry_run A logical that is `TRUE` to have UBI build every order without sending it.
    # @param as_marketable_limit A logical that is `TRUE` to let UBI's order engine send each order as a marketable limit, and `FALSE` to send market orders at once.
    # @return A `data.frame` with one row per planned order, holding `label`, `instrument_id`, `transaction_type`, `quantity`, `status`, `broker`, `outcome`, `order_id`, `parent_id`, `intent_id` and `error`, which has no rows when nothing was planned.
    # @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI refused the whole list or could not be reached.
    send_orders = function(
      planned,
      product,
      validity,
      tag,
      dry_run,
      as_marketable_limit
    ) {
      if (length(planned) == 0) {
        return(private$empty_order_frame())
      }
      orders <- list()
      for (order in planned) {
        body <- list(
          instrument_id = order$instrument_id,
          transaction_type = order$transaction_type,
          order_type = ASSET_BASKETS_MARKET_ORDER_TYPE,
          product = product,
          quantity = private$plain_number(order$quantity),
          validity = validity,
          after_market = FALSE
        )
        if (!is.null(tag)) {
          body[["tag"]] <- tag
        }
        if (!isTRUE(as_marketable_limit)) {
          body[["synthetic"]] <- list(
            type = "simple"
          )
        }
        orders[[length(orders) + 1]] <- body
      }
      response <- private$unified_broker_interface$post(
        ASSET_BASKETS_ORDER_PLACE_PATH,
        body = list(
          orders = orders,
          dry_run = isTRUE(as.logical(dry_run))
        ),
        timeout_seconds = ASSET_BASKETS_ORDER_LIST_TIMEOUT_SECONDS
      )
      results <- response[["results"]]
      request_indexes <- numeric(0)
      for (result in results) {
        request_indexes <- c(
          request_indexes,
          as.numeric(result[["request_index"]])
        )
      }
      results <- results[order(request_indexes, method = "radix")]
      rows <- list()
      for (order_index in seq_along(planned)) {
        order <- planned[[order_index]]
        result <- results[[order_index]]
        answer <- result[["response"]]
        if (is.null(answer)) {
          answer <- list()
        }
        rows[[order_index]] <- list(
          label = order$label,
          instrument_id = order$instrument_id,
          transaction_type = order$transaction_type,
          quantity = order$quantity,
          status = result[["status"]],
          broker = answer[["broker"]],
          outcome = answer[["outcome"]],
          order_id = answer[["order_id"]],
          parent_id = answer[["parent_id"]],
          intent_id = result[["intent_id"]],
          error = answer[["error"]]
        )
      }
      FrameBuilder$new()$frame(rows)
    },

    # Builds the answer table of `place_orders()` with no rows.
    # @return A `data.frame` with the eleven order result columns and no rows.
    empty_order_frame = function() {
      data.frame(
        label = character(0),
        instrument_id = character(0),
        transaction_type = character(0),
        quantity = numeric(0),
        status = numeric(0),
        broker = character(0),
        outcome = character(0),
        order_id = character(0),
        parent_id = character(0),
        intent_id = character(0),
        error = character(0)
      )
    },

    # Builds the table of `rebalance_trades()` with no rows.
    # @return A `data.frame` with the seven trade columns and no rows.
    empty_rebalance_frame = function() {
      data.frame(
        label = character(0),
        instrument_id = character(0),
        last_price = numeric(0),
        current_quantity = numeric(0),
        target_quantity = numeric(0),
        trade_quantity = numeric(0),
        transaction_type = character(0)
      )
    },

    # Uses the quantities held for the portfolio's candles, so they show what the holdings were worth.
    # @param first_closes A named numeric vector of each member's close at the first shared candle, named by member label, which only fixes the order here.
    # @return A named numeric vector of quantities, named by member label.
    candle_quantities = function(first_closes) {
      self$quantities[names(first_closes)]
    },

    # Gives the other side of a trade.
    # @param transaction_type The character side, `"buy"` or `"sell"`.
    # @return The character `"sell"` for `"buy"`, and `"buy"` for anything else.
    opposite_side = function(transaction_type) {
      if (transaction_type == ASSET_BASKETS_BUY) {
        return(ASSET_BASKETS_SELL)
      }
      ASSET_BASKETS_BUY
    },

    # Rounds a quantity towards zero to a whole number of units.
    # @param quantity The numeric quantity, negative for a short position.
    # @return The numeric whole quantity, with the same sign.
    whole_units = function(quantity) {
      as.numeric(trunc(quantity))
    },

    # Turns a whole numeric quantity into an integer, so it reaches UBI as a whole number.
    # @param quantity The integer or numeric quantity.
    # @return The integer quantity when it is whole and fits in an integer, or the numeric as given otherwise.
    plain_number = function(quantity) {
      if (is.numeric(quantity) && is.finite(quantity) &&
            quantity == round(quantity) &&
            abs(quantity) <= .Machine$integer.max) {
        return(as.integer(quantity))
      }
      quantity
    }
  )
)

Portfolio$KIND <- "portfolio"

Portfolio$from_holdings <- function(
  name = "holdings",
  unified_broker_interface = NULL
) {
  resolver <- MemberResolver$new(unified_broker_interface)
  answer <- resolver$unified_broker_interface$get(ASSET_BASKETS_HOLDINGS_PATH)
  rows <- list()
  for (holding in answer[["holdings"]]) {
    quantity <- holding[["quantity"]]
    if (is.null(quantity) || quantity == 0) {
      next
    }
    rows[[length(rows) + 1]] <- list(
      instrument_id = holding[["instrument_id"]],
      exchange = holding[["exchange"]],
      segment = holding[["segment"]],
      symbol = holding[["symbol"]],
      quantity = quantity,
      average_price = holding[["average_price"]]
    )
  }
  if (length(rows) == 0) {
    ErrorCatalogue$raise("BasketMemberError", "The account holds nothing")
  }
  members <- resolver$resolve(rows)
  Portfolio$new(
    name = name,
    members = members,
    unified_broker_interface = resolver$unified_broker_interface
  )
}

Portfolio$from_positions <- function(
  name = "positions",
  day = FALSE,
  unified_broker_interface = NULL
) {
  resolver <- MemberResolver$new(unified_broker_interface)
  answer <- resolver$unified_broker_interface$get(ASSET_BASKETS_POSITIONS_PATH)
  if (isTRUE(day)) {
    positions <- answer[["day"]]
  } else {
    positions <- answer[["net"]]
  }
  rows_by_instrument_id <- list()
  for (position in positions) {
    quantity <- position[["quantity"]]
    if (is.null(quantity) || quantity == 0) {
      next
    }
    instrument_id <- position[["instrument_id"]]
    if (instrument_id %in% names(rows_by_instrument_id)) {
      row <- rows_by_instrument_id[[instrument_id]]
      row[["quantity"]] <- row[["quantity"]] + quantity
      row["average_price"] <- list(NULL)
      rows_by_instrument_id[[instrument_id]] <- row
    } else {
      rows_by_instrument_id[[instrument_id]] <- list(
        instrument_id = instrument_id,
        quantity = quantity,
        average_price = position[["average_price"]]
      )
    }
  }
  rows <- list()
  for (row in rows_by_instrument_id) {
    if (row[["quantity"]] != 0) {
      rows[[length(rows) + 1]] <- row
    }
  }
  if (length(rows) == 0) {
    ErrorCatalogue$raise("BasketMemberError", "No position is open")
  }
  members <- resolver$resolve(rows)
  Portfolio$new(
    name = name,
    members = members,
    unified_broker_interface = resolver$unified_broker_interface
  )
}
