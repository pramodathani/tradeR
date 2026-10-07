ORDERS_SYNTHETIC_ORDER_SYNTHETIC_TYPE <- "simple"

#' One order for UBI's order engine: an order template and the synthetic type that works it
#'
#' @description
#' A synthetic order is one ordinary order body, the template, plus a `synthetic` object naming the type and holding that type's own settings. UBI's order engine then places, watches, changes and cancels the real orders the type is made of. `SyntheticOrder` holds the template and sends it through `TradeableInstrument$place_order()`; each subclass, such as `BracketOrder`, adds its own settings.
#'
#' The template is validated by UBI exactly as a plain order is, and most types use it for every real order they send, changing only what they must. Nothing is checked here before sending.
#'
#' @examples
#' \dontrun{
#' share <- Equity$new(exchange = "nse", symbol = "RELIANCE")
#' order <- BracketOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 10,
#'   price = 1000.0,
#'   stop_price = 990.0,
#'   stop_limit_price = 988.0,
#'   target_price = 1010.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#'
#' share <- Equity$new(exchange = "nse", symbol = "IDEA")
#' order <- SyntheticOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 1,
#'   price = 13.0
#' )
#' print(order$synthetic)
#'
#' order <- SyntheticOrder$new(
#'   share,
#'   transaction_type = "sell",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 1,
#'   price = 14.0,
#'   closes_position = TRUE,
#'   reduce_only = TRUE
#' )
#' print(order$synthetic)
#' order$reduce_only <- FALSE
#' print(order$synthetic)
#'
#' order <- LadderOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 2,
#'   price = 13.0,
#'   from_price = 13.0,
#'   to_price = 12.9,
#'   steps = 2
#' )
#' print(order$synthetic)
#' order$hold_limits <- FALSE
#' print(order$synthetic)
#'
#' limit_price <- round(share$last_price * 0.97, 2)
#' order <- SyntheticOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 1,
#'   price = limit_price
#' )
#' order$place()
#' tryCatch(
#'   {
#'     parent <- order$parent
#'     cat(parent$synthetic_type, parent$state, "\n")
#'     cat(length(parent$legs), "legs\n")
#'     cat("before:", order$parent$state, "\n")
#'     Sys.sleep(2)
#'     print(order$orders)
#'     print(order$trades)
#'   },
#'   finally = order$cancel()
#' )
#' cat("after:", order$parent$state, "\n")
#' Sys.sleep(2)
#' broker_orders <- order$orders
#' if (is.null(broker_orders)) {
#'   print("No broker order was placed.")
#' } else {
#'   print(broker_orders[, c(
#'     "order_id",
#'     "status"
#'   )])
#' }
#'
#' order <- SyntheticOrder$new(
#'   share,
#'   transaction_type = "buy",
#'   product = "mis",
#'   order_type = "limit",
#'   quantity = 1,
#'   validity = "ioc",
#'   price_reference = list(
#'     kind = "marketable"
#'   )
#' )
#' order$place()
#' fills <- NULL
#' tryCatch(
#'   {
#'     for (attempt in 1:10) {
#'       fills <- order$trades
#'       if (!is.null(fills)) {
#'         break
#'       }
#'       Sys.sleep(1)
#'     }
#'     print(fills)
#'   },
#'   finally = {
#'     if (!is.null(fills)) {
#'       share$reduce_position(
#'         quantity = 1,
#'         product = "mis",
#'         price = round(share$last_price * 0.995, 2)
#'       )
#'     }
#'   }
#' )
#' }
#' @export
SyntheticOrder <- R6::R6Class(
  "SyntheticOrder",
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_SYNTHETIC_ORDER_SYNTHETIC_TYPE,
    #' @field instrument The `TradeableInstrument` the order is placed in.
    instrument = NULL,
    #' @field transaction_type The character side of the order, `"buy"` or `"sell"`.
    transaction_type = NULL,
    #' @field product The character product, `"cnc"`, `"mis"` or `"nrml"`.
    product = NULL,
    #' @field order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    order_type = NULL,
    #' @field quantity The integer quantity in underlying units, or `NULL` when a quantity reference supplies it.
    quantity = NULL,
    #' @field price The numeric limit price in rupees, or `NULL`.
    price = NULL,
    #' @field trigger_price The numeric trigger price in rupees of the order itself, or `NULL`.
    trigger_price = NULL,
    #' @field validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    validity = NULL,
    #' @field disclosed_quantity The integer quantity to show on the exchange, or `NULL`.
    disclosed_quantity = NULL,
    #' @field after_market A logical that is `TRUE` to send the order as an after-market order.
    after_market = NULL,
    #' @field tag A character label of up to twenty letters and digits to label the order with, or `NULL`.
    tag = NULL,
    #' @field price_reference A named list describing the price for UBI to work out, or `NULL`.
    price_reference = NULL,
    #' @field quantity_reference A named list describing the quantity for UBI to work out, or `NULL`.
    quantity_reference = NULL,
    #' @field closes_position A logical that is `TRUE` when every order this type sends closes a position, so it may use the share of a broker's daily order cap kept for exits.
    closes_position = NULL,
    #' @field reduce_only A logical that is `TRUE` to have UBI check every leg against the net position held in the leg's instrument and product just before sending it, and refuse with HTTP 409 any leg that is not on the closing side or is bigger than the position.
    reduce_only = NULL,
    #' @field hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price in its virtual order book until the other side of the book reaches that price, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    hold_limits = NULL,
    #' @field dry_run A logical that is `TRUE` to have UBI build the first broker request and return it without recording or sending anything.
    dry_run = NULL,
    #' @field parent_id The character id UBI's order engine gave this order when `place()` sent it, or `NULL` before then and after a dry run, which records nothing.
    parent_id = NULL,

    #' @description
    #' Initialises the order template.
    #' @param instrument The `TradeableInstrument` to place the order in.
    #' @param transaction_type The character side of the order, `"buy"` or `"sell"`.
    #' @param product The character product, `"cnc"` for delivery, `"mis"` for intraday or `"nrml"` for carry forward.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer quantity in underlying units, not lots, or `NULL` when a quantity reference supplies it.
    #' @param price The numeric limit price in rupees, or `NULL` for an order type that takes no price or when a price reference supplies it.
    #' @param trigger_price The numeric trigger price in rupees of the order itself, or `NULL` for an order type that takes no trigger.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param disclosed_quantity The integer quantity to show on the exchange, or `NULL` to disclose the whole order.
    #' @param after_market A logical that is `TRUE` to send the order as an after-market order.
    #' @param tag A character label of up to twenty letters and digits to label the order with, or `NULL`.
    #' @param price_reference A named list describing the price for UBI to work out, such as `list(kind = "mid")`, or `NULL`.
    #' @param quantity_reference A named list describing the quantity for UBI to work out, such as `list(kind = "liquidate_position")`, or `NULL`.
    #' @param closes_position A logical that is `TRUE` when every order this type sends closes a position.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI build the first broker request and return it without recording or sending anything.
    #' @return A new `SyntheticOrder` object.
    initialize = function(
      instrument,
      transaction_type,
      product,
      order_type,
      quantity,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      disclosed_quantity = NULL,
      after_market = FALSE,
      tag = NULL,
      price_reference = NULL,
      quantity_reference = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE
    ) {
      self$instrument <- instrument
      self$transaction_type <- transaction_type
      self$product <- product
      self$order_type <- order_type
      self$quantity <- quantity
      self$price <- price
      self$trigger_price <- trigger_price
      self$validity <- validity
      self$disclosed_quantity <- disclosed_quantity
      self$after_market <- after_market
      self$tag <- tag
      self$price_reference <- price_reference
      self$quantity_reference <- quantity_reference
      self$closes_position <- closes_position
      self$reduce_only <- reduce_only
      self$hold_limits <- hold_limits
      self$dry_run <- dry_run
      self$parent_id <- NULL
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, where a value of `NULL` means the field is left out. The base type has no settings, so this is empty.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0
    #' )
    #' print(order$synthetic_fields())
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' plain_order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0
    #' )
    #' bracket_order <- BracketOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0,
    #'   stop_price = 12.5,
    #'   stop_limit_price = 12.45
    #' )
    #' cat(plain_order$SYNTHETIC_TYPE, ":\n", sep = "")
    #' str(plain_order$synthetic_fields())
    #' cat(bracket_order$SYNTHETIC_TYPE, ":\n", sep = "")
    #' str(bracket_order$synthetic_fields())
    #' }
    synthetic_fields = function() {
      list()
    },

    #' @description
    #' Sends the order to UBI's order engine through `TradeableInstrument$place_order()`, and keeps the `parent_id` the engine answers with.
    #' @return The named list `place_order()` returns. A type that acts at once answers with the broker's answer and a `parent_id`; a type that waits for a price or a time, or whose limit orders UBI holds until the market reaches them, answers with an `outcome` of `armed`, a `broker` and `order_id` of `NULL`, and a `parent_id`, which is the only handle on the order until it reaches a broker. The types that send several orders at once, `freeze_slicer`, `ladder`, `grid`, `two_sided_quote`, `basket`, `oco`, `bracket` and `two_sided_breakout`, answer with a `legs` list, one entry per order with its plan `path`, `instrument_id`, `outcome`, `order_id` and `status_message`, and one combined `outcome`: `accepted` when every order was accepted, `partial` with HTTP 207 when only some were, which is returned rather than signalled, and otherwise `unknown` or `rejected`, which are signalled.
    #' @details Errors: signals `BadRequestError` when a template field is invalid, or one of this type's own settings is missing or wrong; `LossLockoutError` when the day's loss is past UBI's daily loss limit; `ConflictError` when the engine refused to act on the account's state, such as a post-only order that would cross the book or a reduce-only leg that would not reduce the position, or the engine had already started this order before a restart; `RateLimitError` when the broker's daily order cap has no room for this order; `ServiceUnavailableError` when no broker could take the order, a price UBI needed could not be read, or the order engine is not running; `OrderOutcomeUnknownError` when the engine did not answer in time, so the order may still be placed; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = round(share$last_price * 0.97, 2),
    #'   dry_run = TRUE
    #' )
    #' answer <- order$place()
    #' print(answer)
    #' print(order$parent_id)
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' limit_price <- round(share$last_price * 0.97, 2)
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = limit_price
    #' )
    #' answer <- order$place()
    #' tryCatch(
    #'   cat(answer$outcome, answer$order_id, order$parent_id, "\n"),
    #'   finally = print(order$cancel()$state)
    #' )
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "sell",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 100000,
    #'   price = round(share$last_price * 1.03, 2),
    #'   reduce_only = TRUE
    #' )
    #' tryCatch(
    #'   order$place(),
    #'   ConflictError = function(error) {
    #'     cat("Refused:", conditionMessage(error), "\n")
    #'   },
    #'   finally = {
    #'     if (!is.null(order$parent_id)) {
    #'       print(order$cancel()$state)
    #'     }
    #'   }
    #' )
    #' }
    place = function() {
      answer <- self$instrument$place_order(
        transaction_type = self$transaction_type,
        order_type = self$order_type,
        quantity = self$quantity,
        product = self$product,
        price = self$price,
        trigger_price = self$trigger_price,
        validity = self$validity,
        disclosed_quantity = self$disclosed_quantity,
        after_market = self$after_market,
        tag = self$tag,
        dry_run = self$dry_run,
        price_reference = self$price_reference,
        quantity_reference = self$quantity_reference,
        synthetic = self$synthetic
      )
      if (is.list(answer) && !is.null(answer[["parent_id"]])) {
        self$parent_id <- answer[["parent_id"]]
      }
      answer
    },

    #' @description
    #' Cancels this order in UBI's order engine, with every leg it still has resting at a broker.
    #'
    #' A position the order has already opened is not closed.
    #' @return The named list `TradeableInstrument$cancel_parent()` returns, with `parent_id`, `synthetic_type`, `state` and a `cancelled_legs` list. Its `state` is `cancelling` rather than `cancelled` when a broker refused a leg's cancel, so that leg may still be live.
    #' @details Errors: signals `ValueError` when the order has not been placed, so there is no parent to cancel; `NotFoundError` when the engine holds no parent with this id; `ConflictError` when the parent has already finished; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' limit_price <- round(share$last_price * 0.97, 2)
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = limit_price
    #' )
    #' order$place()
    #' answer <- order$cancel()
    #' print(answer$state)
    #' for (leg in answer$cancelled_legs) {
    #'   cat(leg$broker, leg$order_id, leg$outcome, "\n")
    #' }
    #'
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' order <- SyntheticOrder$new(
    #'   share,
    #'   transaction_type = "buy",
    #'   product = "mis",
    #'   order_type = "limit",
    #'   quantity = 1,
    #'   price = 13.0
    #' )
    #' tryCatch(
    #'   order$cancel(),
    #'   ValueError = function(error) print(conditionMessage(error))
    #' )
    #' }
    cancel = function() {
      self$instrument$cancel_parent(private$placed_parent_id())
    }
  ),
  active = list(
    #' @field synthetic The `synthetic` object sent with the order, as a named list holding `type`, this type's settings that are not `NULL`, `closes_position` and `reduce_only` when each is `TRUE`, and `hold_limits` when it is not `NULL`. Read-only.
    synthetic = function(value) {
      if (!missing(value)) {
        stop("synthetic is read-only", call. = FALSE)
      }
      document <- list(
        type = self$SYNTHETIC_TYPE
      )
      fields <- self$synthetic_fields()
      for (field in names(fields)) {
        if (!is.null(fields[[field]])) {
          document[[field]] <- fields[[field]]
        }
      }
      if (isTRUE(self$closes_position)) {
        document[["closes_position"]] <- TRUE
      }
      if (isTRUE(self$reduce_only)) {
        document[["reduce_only"]] <- TRUE
      }
      if (!is.null(self$hold_limits)) {
        document[["hold_limits"]] <- self$hold_limits
      }
      document
    },

    #' @field parent The order as UBI's order engine holds it now, as a named list with its `state`, the caller's `body`, the type's `parameters` and one entry per leg, read from UBI on every access. Reading it signals `ValueError` when the order has not been placed, `NotFoundError` when the engine holds no parent with this id, and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    parent = function(value) {
      if (!missing(value)) {
        stop("parent is read-only", call. = FALSE)
      }
      self$instrument$parent(private$placed_parent_id())
    },

    #' @field orders Today's broker orders this order has placed, as a `data.frame` shaped like `TradeableInstrument$orders`, or `NULL` when it has placed none yet. Reading it signals `ValueError` when the order has not been placed, and a `UnifiedBrokerInterfaceError` subclass when the order book could not be read.
    orders = function(value) {
      if (!missing(value)) {
        stop("orders is read-only", call. = FALSE)
      }
      self$instrument$parent_orders(private$placed_parent_id())
    },

    #' @field trades Today's fills of the broker orders this order has placed, as a `data.frame` shaped like `TradeableInstrument$trades`, or `NULL` when nothing has filled yet. Reading it signals `ValueError` when the order has not been placed, and a `UnifiedBrokerInterfaceError` subclass when the trade book could not be read.
    trades = function(value) {
      if (!missing(value)) {
        stop("trades is read-only", call. = FALSE)
      }
      self$instrument$parent_trades(private$placed_parent_id())
    }
  ),
  private = list(
    # Gives the engine's id for this order, refusing when it has not been placed.
    #
    # Returns the character `parent_id` that `place()` kept.
    #
    # Errors: signals `ValueError` when `place()` has not been called, was a dry run, or was answered without a `parent_id`.
    placed_parent_id = function() {
      if (is.null(self$parent_id)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "This %s order has no parent_id, because place() has not sent it to UBI's order engine yet, or sent it only as a dry run",
            self$SYNTHETIC_TYPE
          )
        )
      }
      self$parent_id
    }
  )
)
