#' The simulated broker of a backtest
#'
#' @description
#' The R counterpart of the `_Broker` class inside the Python `backtesting` package (version 0.6.5). It holds the cash, the order queue, the open and closed trades and the equity of every candle, and on each candle it fills the orders whose conditions the candle met.
#'
#' A strategy never builds one; `Backtest$run()` does, and the strategy reaches it through `BacktestStrategy$buy()`, `BacktestStrategy$sell()`, `BacktestStrategy$position` and the other members of `BacktestStrategy`.
#'
#' The fill rules are backtesting.py's:
#'
#' - A market order fills at the open of the candle after the one it was placed on, or at the close of the candle it was placed on when `trade_on_close` is `TRUE`.
#' - A stop order waits until a candle's high reaches the stop for a buy, or its low reaches it for a sell, and then fills like a market or limit order.
#' - A limit order fills when a candle's low reaches the limit for a buy, or its high reaches it for a sell, at the limit or at the open when the open is better.
#' - An order sized as a fraction between 0 and 1 buys as many whole units as that fraction of the available margin, times the leverage, pays for.
#' - Without hedging, an order first closes opposite trades, oldest first.
#' - An order the margin cannot pay for is dropped.
#' - Commission is a fraction of each fill's value, charged when a trade opens and again when it closes.
#'
#' @examples
#' \dontrun{
#' candles <- data.frame(
#'   datetime = as.POSIXct(
#'     c(
#'       "2025-01-01",
#'       "2025-01-02"
#'     ),
#'     tz = "Asia/Kolkata"
#'   ),
#'   Open = c(
#'     100,
#'     101
#'   ),
#'   High = c(
#'     102,
#'     103
#'   ),
#'   Low = c(
#'     99,
#'     100
#'   ),
#'   Close = c(
#'     101,
#'     102
#'   ),
#'   Volume = c(
#'     1000,
#'     1200
#'   )
#' )
#' broker <- BacktestBroker$new(
#'   candles = candles,
#'   cash = 10000,
#'   commission = 0.001,
#'   margin = 1,
#'   trade_on_close = FALSE,
#'   hedging = FALSE,
#'   exclusive_orders = FALSE
#' )
#' broker$current_bar <- 1
#' broker$new_order(10)
#' broker$next_bar(2)
#' print(broker$trades[[1]])
#' }
#' @export
BacktestBroker <- R6::R6Class(
  "BacktestBroker",
  public = list(
    #' @field candles The `data.frame` of every candle, with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns.
    candles = NULL,

    #' @field cash The numeric cash held, which changes as trades open and close.
    cash = NULL,

    #' @field commission The numeric commission as a fraction of each fill's value.
    commission = NULL,

    #' @field leverage The numeric leverage, which is 1 divided by the margin.
    leverage = NULL,

    #' @field trade_on_close A logical that is `TRUE` to fill market orders at the close of the candle they were placed on.
    trade_on_close = NULL,

    #' @field hedging A logical that is `TRUE` to let long and short trades stay open together.
    hedging = NULL,

    #' @field exclusive_orders A logical that is `TRUE` to cancel waiting orders and close open trades whenever a new order is placed.
    exclusive_orders = NULL,

    #' @field equity_curve A numeric vector with the equity at the end of each candle, `NA` for the candles before the strategy started.
    equity_curve = NULL,

    #' @field orders A list of the waiting `BacktestOrder` objects, in the order they will be processed.
    orders = NULL,

    #' @field trades A list of the open `BacktestTrade` objects, oldest first.
    trades = NULL,

    #' @field closed_trades A list of the closed `BacktestTrade` objects, in the order they closed.
    closed_trades = NULL,

    #' @field position The `BacktestPosition` summing the open trades.
    position = NULL,

    #' @field current_bar The integer number of the candle being processed, counting from 1.
    current_bar = NULL,

    #' @description
    #' Creates a broker with its starting cash and rules.
    #' @param candles A `data.frame` with `datetime`, `Open`, `High`, `Low`, `Close` and `Volume` columns, oldest candle first.
    #' @param cash The numeric starting cash, above zero.
    #' @param commission The numeric commission as a fraction of each fill's value, from -0.1 up to but not including 0.1.
    #' @param margin The numeric margin as a fraction, above 0 and at most 1, where 1 means no leverage.
    #' @param trade_on_close A logical that is `TRUE` to fill market orders at the current candle's close.
    #' @param hedging A logical that is `TRUE` to allow long and short trades at the same time.
    #' @param exclusive_orders A logical that is `TRUE` to close the open trades whenever a new order is placed.
    #' @return A new `BacktestBroker` object.
    #' @details Errors: signals `ValueError` when `cash`, `commission` or `margin` is outside its allowed range.
    initialize = function(
      candles,
      cash,
      commission,
      margin,
      trade_on_close,
      hedging,
      exclusive_orders
    ) {
      if (!(cash > 0)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("cash should be > 0, is %s", format(cash))
        )
      }
      if (!(margin > 0 && margin <= 1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("margin should be between 0 and 1, is %s", format(margin))
        )
      }
      if (!(commission >= -0.1 && commission < 0.1)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "commission should be between -10%% (e.g. market-maker's rebates) and 10%% (fees), is %s",
            format(commission)
          )
        )
      }
      self$candles <- candles
      self$cash <- cash
      self$commission <- commission
      self$leverage <- 1 / margin
      self$trade_on_close <- trade_on_close
      self$hedging <- hedging
      self$exclusive_orders <- exclusive_orders
      self$equity_curve <- rep(NA_real_, nrow(candles))
      self$orders <- list()
      self$trades <- list()
      self$closed_trades <- list()
      self$position <- BacktestPosition$new(self)
      self$current_bar <- nrow(candles)
    },

    #' @description
    #' Works out the commission on one fill.
    #' @param order_size The numeric number of units, of either sign.
    #' @param price The numeric fill price.
    #' @return The numeric commission in cash.
    commission_of = function(order_size, price) {
      abs(order_size) * price * self$commission
    },

    #' @description
    #' Checks an order's prices and puts it in the queue.
    #' @param size The numeric size, positive to buy and negative to sell.
    #' @param limit The numeric limit price, or `NULL`.
    #' @param stop The numeric stop price, or `NULL`.
    #' @param sl The numeric stop-loss price for the trade the order opens, or `NULL`.
    #' @param tp The numeric take-profit price for the trade the order opens, or `NULL`.
    #' @param tag Any value to recognise the order by, or `NULL`.
    #' @param trade The `BacktestTrade` the order closes, or `NULL` for an order that opens a trade.
    #' @return The new `BacktestOrder`.
    #' @details Errors: signals `ValueError` when the stop-loss, the limit or stop price, and the take-profit are not in rising order for a buy, or falling order for a sell.
    new_order = function(
      size,
      limit = NULL,
      stop = NULL,
      sl = NULL,
      tp = NULL,
      tag = NULL,
      trade = NULL
    ) {
      size <- as.numeric(size)
      reference_price <- self$last_price
      if (!is.null(stop)) {
        reference_price <- as.numeric(stop)
      }
      if (!is.null(limit)) {
        reference_price <- as.numeric(limit)
      }
      lowest <- -Inf
      highest <- Inf
      if (size > 0) {
        if (!is.null(sl)) {
          lowest <- sl
        }
        if (!is.null(tp)) {
          highest <- tp
        }
        if (!(lowest < reference_price && reference_price < highest)) {
          ErrorCatalogue$raise(
            "ValueError",
            sprintf(
              "Long orders require: SL (%s) < LIMIT (%s) < TP (%s)",
              private$describe(sl),
              format(reference_price),
              private$describe(tp)
            )
          )
        }
      } else {
        if (!is.null(tp)) {
          lowest <- tp
        }
        if (!is.null(sl)) {
          highest <- sl
        }
        if (!(lowest < reference_price && reference_price < highest)) {
          ErrorCatalogue$raise(
            "ValueError",
            sprintf(
              "Short orders require: TP (%s) < LIMIT (%s) < SL (%s)",
              private$describe(tp),
              format(reference_price),
              private$describe(sl)
            )
          )
        }
      }
      order <- BacktestOrder$new(
        self,
        size,
        limit = limit,
        stop = stop,
        sl = sl,
        tp = tp,
        parent_trade = trade,
        tag = tag
      )
      if (is.null(trade) && self$exclusive_orders) {
        private$cancel_standalone_orders()
        for (open_trade in self$trades) {
          open_trade$close()
        }
      }
      if (!is.null(trade) && !is.null(stop)) {
        self$insert_order_first(order)
      } else {
        self$orders[[length(self$orders) + 1]] <- order
      }
      order
    },

    #' @description
    #' Puts an order at the front of the queue, so it is processed first.
    #' @param order The `BacktestOrder` to insert.
    #' @return `NULL`, invisibly.
    insert_order_first = function(order) {
      self$orders <- c(
        list(order),
        self$orders
      )
      invisible(NULL)
    },

    #' @description
    #' Takes an order out of the queue, if it is there.
    #' @param order The `BacktestOrder` to remove.
    #' @return `NULL`, invisibly.
    remove_order = function(order) {
      position <- private$position_in(self$orders, order)
      if (position > 0) {
        self$orders[[position]] <- NULL
      }
      invisible(NULL)
    },

    #' @description
    #' Processes one candle: fills the orders it allows, then records the equity.
    #' @param bar The integer number of the candle, counting from 1.
    #' @return A logical that is `TRUE` when the equity fell to zero or below, which ends the backtest.
    next_bar = function(bar) {
      self$current_bar <- bar
      private$process_orders()
      equity <- self$equity
      self$equity_curve[[bar]] <- equity
      if (equity > 0) {
        return(FALSE)
      }
      last_close <- self$candles$Close[[bar]]
      index <- 1
      while (index <= length(self$trades)) {
        private$close_trade(self$trades[[index]], last_close, bar)
        index <- index + 1
      }
      self$cash <- 0
      self$equity_curve[bar:length(self$equity_curve)] <- 0
      TRUE
    }
  ),
  active = list(
    #' @field last_price The numeric close of the candle being processed.
    last_price = function(value) {
      if (!missing(value)) {
        stop("last_price is read-only", call. = FALSE)
      }
      self$candles$Close[[self$current_bar]]
    },

    #' @field equity The numeric cash plus the profit or loss of the open trades.
    equity = function(value) {
      if (!missing(value)) {
        stop("equity is read-only", call. = FALSE)
      }
      total <- self$cash
      for (trade in self$trades) {
        total <- total + trade$pl
      }
      total
    },

    #' @field margin_available The numeric equity left after the margin the open trades use, never below zero.
    margin_available = function(value) {
      if (!missing(value)) {
        stop("margin_available is read-only", call. = FALSE)
      }
      margin_used <- 0
      for (trade in self$trades) {
        margin_used <- margin_used + trade$value / self$leverage
      }
      max(0, self$equity - margin_used)
    }
  ),
  private = list(
    # Writes an optional price for an error message, as Python prints `None`.
    # @param price A numeric price or `NULL`.
    # @return A character value.
    describe = function(price) {
      if (is.null(price)) {
        return("None")
      }
      format(price)
    },

    # Finds an object in a list by identity.
    # @param objects A list of R6 objects.
    # @param target The R6 object to look for.
    # @return The integer position of `target` in `objects`, or 0 when it is absent.
    position_in = function(objects, target) {
      for (index in seq_along(objects)) {
        if (identical(objects[[index]], target)) {
          return(index)
        }
      }
      0
    },

    # Cancels every waiting order that is not a stop-loss or take-profit, walking the queue the way backtesting.py does.
    # @return `NULL`, invisibly.
    cancel_standalone_orders = function() {
      index <- 1
      while (index <= length(self$orders)) {
        order <- self$orders[[index]]
        if (!order$is_contingent) {
          order$cancel()
        }
        index <- index + 1
      }
      invisible(NULL)
    },

    # Fills the waiting orders that the current candle allows.
    # @return `NULL`, invisibly.
    process_orders = function() {
      bar <- self$current_bar
      open <- self$candles$Open[[bar]]
      high <- self$candles$High[[bar]]
      low <- self$candles$Low[[bar]]
      reprocess_orders <- FALSE
      waiting_orders <- self$orders
      for (order in waiting_orders) {
        if (private$position_in(self$orders, order) == 0) {
          next
        }
        stop_price <- order$stop
        if (!is.null(stop_price)) {
          if (order$is_long) {
            is_stop_hit <- high >= stop_price
          } else {
            is_stop_hit <- low <= stop_price
          }
          if (!is_stop_hit) {
            next
          }
          order$stop <- NULL
        }
        if (!is.null(order$limit)) {
          if (order$is_long) {
            is_limit_hit <- low <= order$limit
          } else {
            is_limit_hit <- high >= order$limit
          }
          is_limit_hit_before_stop <- FALSE
          if (is_limit_hit && !is.null(stop_price)) {
            if (order$is_long) {
              is_limit_hit_before_stop <- order$limit <= stop_price
            } else {
              is_limit_hit_before_stop <- order$limit >= stop_price
            }
          }
          if (!is_limit_hit || is_limit_hit_before_stop) {
            next
          }
          reference <- open
          if (!is.null(stop_price)) {
            reference <- stop_price
          }
          if (order$is_long) {
            price <- min(reference, order$limit)
          } else {
            price <- max(reference, order$limit)
          }
        } else {
          price <- open
          if (self$trade_on_close && !order$is_contingent) {
            price <- self$candles$Close[[bar - 1]]
          }
          if (!is.null(stop_price)) {
            if (order$is_long) {
              price <- max(price, stop_price)
            } else {
              price <- min(price, stop_price)
            }
          }
        }
        is_market_order <- is.null(order$limit) && is.null(stop_price)
        time_index <- bar
        if (is_market_order && self$trade_on_close && !order$is_contingent) {
          time_index <- bar - 1
        }
        if (!is.null(order$parent_trade)) {
          private$fill_closing_order(order, price, stop_price, time_index)
          next
        }
        reprocess_orders <- private$fill_opening_order(
          order,
          price,
          stop_price,
          time_index,
          is_market_order,
          high,
          low
        ) || reprocess_orders
      }
      if (reprocess_orders) {
        private$process_orders()
      }
      invisible(NULL)
    },

    # Fills an order that closes all or part of its parent trade.
    # @param order The `BacktestOrder` with a parent trade.
    # @param price The numeric fill price.
    # @param stop_price The numeric stop price the order had before it was reached, or `NULL`.
    # @param time_index The integer candle number to record as the exit.
    # @return `NULL`, invisibly.
    fill_closing_order = function(order, price, stop_price, time_index) {
      trade <- order$parent_trade
      previous_size <- trade$size
      size <- sign(order$size) * min(abs(previous_size), abs(order$size))
      if (private$position_in(self$trades, trade) > 0) {
        private$reduce_trade(trade, price, size, time_index)
        if (!is.null(stop_price) && price == stop_price) {
          if (!is.null(trade$sl_order)) {
            trade$sl_order$stop <- stop_price
          }
        }
      }
      is_contingent_order <- identical(order, trade$sl_order) ||
        identical(order, trade$tp_order)
      if (!is_contingent_order) {
        self$remove_order(order)
      }
      invisible(NULL)
    },

    # Fills an order that opens a trade, after closing opposite trades when hedging is off.
    # @param order The `BacktestOrder` without a parent trade.
    # @param price The numeric fill price.
    # @param stop_price The numeric stop price the order had before it was reached, or `NULL`.
    # @param time_index The integer candle number to record as the entry.
    # @param is_market_order A logical that is `TRUE` when the order had neither a limit nor a stop.
    # @param high The numeric high of the current candle.
    # @param low The numeric low of the current candle.
    # @return A logical that is `TRUE` when the queue must be processed again for the new trade's stop-loss or take-profit order.
    fill_opening_order = function(
      order,
      price,
      stop_price,
      time_index,
      is_market_order,
      high,
      low
    ) {
      price_plus_commission <- price +
        self$commission_of(order$size, price) / abs(order$size)
      size <- order$size
      if (size > -1 && size < 1) {
        affordable <- self$margin_available * self$leverage * abs(size)
        size <- sign(size) * floor(affordable / price_plus_commission)
        if (size == 0) {
          warning(
            sprintf(
              "time=%d: Broker canceled the relative-sized order due to insufficient margin.",
              self$current_bar
            ),
            call. = FALSE
          )
          self$remove_order(order)
          return(FALSE)
        }
      }
      need_size <- size
      if (!self$hedging) {
        for (trade in self$trades) {
          if (trade$is_long == order$is_long) {
            next
          }
          if (abs(need_size) >= abs(trade$size)) {
            private$close_trade(trade, price, time_index)
            need_size <- need_size + trade$size
          } else {
            private$reduce_trade(trade, price, need_size, time_index)
            need_size <- 0
          }
          if (need_size == 0) {
            break
          }
        }
      }
      cost <- abs(need_size) * price_plus_commission
      buying_power <- self$margin_available * self$leverage
      if (cost > buying_power) {
        self$remove_order(order)
        return(FALSE)
      }
      reprocess_orders <- FALSE
      if (need_size != 0) {
        private$open_trade(
          price,
          need_size,
          order$sl,
          order$tp,
          time_index,
          order$tag
        )
        has_contingent <- !is.null(order$sl) || !is.null(order$tp)
        if (has_contingent) {
          reprocess_orders <- private$needs_reprocessing(
            order,
            stop_price,
            is_market_order,
            high,
            low
          )
        }
      }
      self$remove_order(order)
      reprocess_orders
    },

    # Decides whether a new trade's stop-loss or take-profit order may fill on the candle the trade opened on.
    # @param order The `BacktestOrder` that opened the trade.
    # @param stop_price The numeric stop price the order had, or `NULL`.
    # @param is_market_order A logical that is `TRUE` when the order had neither a limit nor a stop.
    # @param high The numeric high of the current candle.
    # @param low The numeric low of the current candle.
    # @return A logical that is `TRUE` when the queue must be processed again.
    needs_reprocessing = function(
      order,
      stop_price,
      is_market_order,
      high,
      low
    ) {
      if (is_market_order) {
        return(TRUE)
      }
      sl_or_lowest <- -Inf
      sl_or_highest <- Inf
      if (!is.null(order$sl)) {
        sl_or_lowest <- order$sl
        sl_or_highest <- order$sl
      }
      is_stop_market <- !is.null(stop_price) &&
        is.null(order$limit) &&
        !is.null(order$tp)
      if (is_stop_market) {
        long_case <- order$is_long &&
          order$tp <= high &&
          sl_or_lowest < low
        short_case <- order$is_short &&
          order$tp >= low &&
          sl_or_highest > high
        if (long_case || short_case) {
          return(TRUE)
        }
      }
      sl_in_candle <- !is.null(order$sl) && low <= order$sl && order$sl <= high
      tp_in_candle <- !is.null(order$tp) && low <= order$tp && order$tp <= high
      if (sl_in_candle || tp_in_candle) {
        warning(
          sprintf(
            "(%s) A contingent SL/TP order would execute in the same bar its parent stop/limit order was turned into a trade. Since we can't assert the precise intra-candle price movement, the affected SL/TP order will instead be executed on the next (matching) price/bar, making the result (of this trade) somewhat dubious. See https://github.com/kernc/backtesting.py/issues/119",
            format(self$candles$datetime[[self$current_bar]])
          ),
          call. = FALSE
        )
      }
      FALSE
    },

    # Closes part of a trade by splitting off a closed copy of that part.
    # @param trade The open `BacktestTrade`.
    # @param price The numeric exit price.
    # @param size The numeric number of units to close, with the opposite sign to the trade's size.
    # @param time_index The integer candle number to record as the exit.
    # @return `NULL`, invisibly.
    reduce_trade = function(trade, price, size, time_index) {
      size_left <- trade$size + size
      if (size_left == 0) {
        closing_trade <- trade
      } else {
        trade$size <- size_left
        if (!is.null(trade$sl_order)) {
          trade$sl_order$size <- -trade$size
        }
        if (!is.null(trade$tp_order)) {
          trade$tp_order$size <- -trade$size
        }
        closing_trade <- trade$clone()
        closing_trade$size <- -size
        closing_trade$sl_order <- NULL
        closing_trade$tp_order <- NULL
        self$trades[[length(self$trades) + 1]] <- closing_trade
      }
      private$close_trade(closing_trade, price, time_index)
      invisible(NULL)
    },

    # Closes a whole trade, settles its profit and commission in cash and moves it to the closed trades.
    # @param trade The open `BacktestTrade`.
    # @param price The numeric exit price.
    # @param time_index The integer candle number to record as the exit.
    # @return `NULL`, invisibly.
    close_trade = function(trade, price, time_index) {
      position <- private$position_in(self$trades, trade)
      if (position > 0) {
        self$trades[[position]] <- NULL
      }
      if (!is.null(trade$sl_order)) {
        self$remove_order(trade$sl_order)
      }
      if (!is.null(trade$tp_order)) {
        self$remove_order(trade$tp_order)
      }
      trade$exit_price <- price
      trade$exit_bar <- time_index
      self$closed_trades[[length(self$closed_trades) + 1]] <- trade
      commission <- self$commission_of(trade$size, price)
      self$cash <- self$cash + trade$pl - commission
      opening_commission <- self$commission_of(trade$size, trade$entry_price)
      trade$commissions <- commission + opening_commission
      invisible(NULL)
    },

    # Opens a trade, pays its opening commission and places its stop-loss and take-profit orders.
    # @param price The numeric entry price.
    # @param size The numeric number of units, positive for long and negative for short.
    # @param sl The numeric stop-loss price, or `NULL`.
    # @param tp The numeric take-profit price, or `NULL`.
    # @param time_index The integer candle number to record as the entry.
    # @param tag Any value copied from the order, or `NULL`.
    # @return `NULL`, invisibly.
    open_trade = function(price, size, sl, tp, time_index, tag) {
      trade <- BacktestTrade$new(self, size, price, time_index, tag)
      self$trades[[length(self$trades) + 1]] <- trade
      self$cash <- self$cash - self$commission_of(size, price)
      if (!is.null(tp)) {
        trade$tp <- tp
      }
      if (!is.null(sl)) {
        trade$sl <- sl
      }
      invisible(NULL)
    }
  )
)
