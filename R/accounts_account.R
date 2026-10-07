ACCOUNTS_FLATTEN_PATH <- "/api/orders/flatten"
ACCOUNTS_PARENTS_PATH <- "/api/orders/parents"
ACCOUNTS_INTENT_PATH <- "/api/orders/intents/%s"
ACCOUNTS_DEFAULT_FLATTEN_TIMEOUT_SECONDS <- 120

#' The trading account UBI trades for, across every broker it is connected to
#'
#' @description
#' `flatten()` sends `POST /api/orders/flatten`, which stops every synthetic order UBI's order engine is running, cancels every open order at every broker, waits until the brokers confirm the cancellations, and only then closes every position with market orders. It acts on the whole account, not on one instrument; `TradeableInstrument$liquidate_all_positions()` is the per-instrument equivalent. `parents` lists every synthetic order the engine has not finished, and `intent()` reads the engine's answer to an order whose placement stopped waiting for it.
#'
#' @examples
#' \dontrun{
#' trading_account <- Account$new()
#' preview <- trading_account$flatten(confirm = "FLATTEN", dry_run = TRUE)
#' outcome <- trading_account$flatten(confirm = "FLATTEN")
#'
#' print(trading_account$parents)
#'
#' parents <- trading_account$parents
#' if (is.null(parents)) {
#'   cat("No parent is open.\n")
#' } else {
#'   print(table(parents$synthetic_type))
#' }
#' }
#' @export
Account <- R6::R6Class(
  "Account",
  public = list(
    #' @field unified_broker_interface The `UnifiedBrokerInterface` the account's requests are sent through.
    unified_broker_interface = NULL,

    #' @description
    #' Initialises the account with the client it sends requests through.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to use, or `NULL` to share the one every instrument uses, which is almost always right because one shared client keeps one cached access token and one place that reconnects after HTTP 401.
    #' @return A new `Account` object.
    #' @details Errors: signals a plain error when no client was given and the shared client's base url or MongoDB credentials are not configured.
    initialize = function(unified_broker_interface = NULL) {
      if (is.null(unified_broker_interface)) {
        unified_broker_interface <- Instrument$shared_unified_broker_interface()
      }
      self$unified_broker_interface <- unified_broker_interface
    },

    #' @description
    #' Stops every synthetic order, cancels every open order at every broker, then closes every position in the account.
    #'
    #' UBI first halts every parent its order engine has not finished, so no armed trigger, trailing stop or grid can place anything afterwards; a halted parent's resting orders are left for the cancellations. The cancellations go next and the closes wait for them to be confirmed, because a stop or a target still resting when its position is closed would fill afterwards and open a new position the other way. Each position is then closed with a market order at the broker that holds it, all of them at once, and UBI waits again until the brokers' positions show zero before answering that the account is flat.
    #'
    #' A timeout does not mean nothing happened: read the orders and positions before calling it again, or a second flatten may close positions twice.
    #' @param confirm The character `"FLATTEN"`, typed by the caller, which UBI requires so that a stray call cannot unwind the account. It is sent as given and UBI refuses anything else.
    #' @param dry_run A logical that is `TRUE` to report what would be cancelled and closed without sending anything.
    #' @param timeout_seconds The numeric number of seconds to wait for UBI's answer, which takes one wait for the cancellations and one for the closed positions to show zero.
    #' @return For a dry run, a named list with `dry_run`, `would_cancel` and `would_close`. Otherwise a named list with `halted`, `cancelled`, `still_open_after_waiting`, `closed`, `positions_still_open_after_waiting`, `flat` and `timing_ms`, where `flat` is `FALSE` when any part was not done or a closed position was still held when the wait ended, which UBI answers with HTTP 207 rather than as an error.
    #' @details Errors: signals `BadRequestError` when `confirm` is not exactly `"FLATTEN"`; `ServiceUnavailableError` when UBI could not read the order books or positions; `UnreachableError` when no answer arrived within the timeout, so part of the flatten may have happened; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' trading_account <- Account$new()
    #' preview <- trading_account$flatten(confirm = "FLATTEN", dry_run = TRUE)
    #' cat("Would cancel:\n")
    #' str(preview$would_cancel)
    #' cat("Would close:\n")
    #' str(preview$would_close)
    #'
    #' tryCatch(
    #'   trading_account$flatten(confirm = "flatten", dry_run = TRUE),
    #'   BadRequestError = function(error) {
    #'     cat(sprintf("Refused: %s\n", conditionMessage(error)))
    #'   }
    #' )
    #'
    #' outcome <- trading_account$flatten(confirm = "FLATTEN")
    #' if (isTRUE(outcome$flat)) {
    #'   cat(sprintf("The account is flat after %s ms.\n", outcome$timing_ms))
    #' } else {
    #'   str(outcome$still_open_after_waiting)
    #'   str(outcome$positions_still_open_after_waiting)
    #' }
    #' }
    flatten = function(
      confirm,
      dry_run = FALSE,
      timeout_seconds = ACCOUNTS_DEFAULT_FLATTEN_TIMEOUT_SECONDS
    ) {
      body <- list(
        confirm = confirm,
        dry_run = isTRUE(as.logical(dry_run))
      )
      self$unified_broker_interface$post(
        ACCOUNTS_FLATTEN_PATH,
        body = body,
        timeout_seconds = timeout_seconds
      )
    },

    #' @description
    #' Reads what UBI's order engine did with one order after its placement stopped waiting for the answer.
    #'
    #' Every answer to placing an order carries an `intent_id`, and so does the detail of an `OrderOutcomeUnknownError` signalled when the engine did not answer in time. UBI keeps each answer for five minutes by default after the engine gives it.
    #' @param intent_id The character `intent_id` from the placement's answer or error detail.
    #' @return A named list with `intent_id`, the HTTP `status` the placement would have answered with, and the `response` body it would have answered with.
    #' @details Errors: signals `NotFoundError` when the engine has not answered this intent yet, the id is not one, or its answer has expired; `ServiceUnavailableError` when UBI could not read its store; and another `UnifiedBrokerInterfaceError` subclass for any other failure reported by, or on the way to, UBI.
    #' @examples
    #' \dontrun{
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' price <- round(idea$last_price * 0.97, 2)
    #' answer <- idea$buy_at_limit_price(
    #'   price = price,
    #'   quantity = 1,
    #'   product = "mis"
    #' )
    #' tryCatch(
    #'   {
    #'     trading_account <- Account$new()
    #'     engine_answer <- trading_account$intent(answer$intent_id)
    #'     cat(engine_answer$status, engine_answer$response$outcome, "\n")
    #'   },
    #'   finally = idea$cancel_parent(answer$parent_id)
    #' )
    #'
    #' trading_account <- Account$new()
    #' tryCatch(
    #'   trading_account$intent("00000000-0000-0000-0000-000000000000"),
    #'   NotFoundError = function(error) print(conditionMessage(error))
    #' )
    #' }
    intent = function(intent_id) {
      path <- sprintf(ACCOUNTS_INTENT_PATH, intent_id)
      self$unified_broker_interface$get(path)
    }
  ),
  active = list(
    #' @field parents Every synthetic order and held order that UBI's order engine has not finished, in every instrument, as a `data.frame` with one row per parent holding UBI's parent fields, among them `parent_order_id`, `synthetic_type`, `state`, `instrument_id`, `body`, `parameters` and `legs` (nested fields become list columns), or `NULL` when no parent is open, read from UBI on every access. A parent is one order the engine was asked for, such as a bracket, a trailing stop or a limit order it is holding until the book reaches its price, and its legs are the broker orders it placed. `TradeableInstrument$parents` gives one instrument's.
    parents = function(value) {
      if (!missing(value)) {
        stop("parents is read-only", call. = FALSE)
      }
      answer <- self$unified_broker_interface$get(ACCOUNTS_PARENTS_PATH)
      rows <- answer[["parents"]]
      if (length(rows) == 0) {
        return(NULL)
      }
      FrameBuilder$new()$frame(rows)
    }
  )
)
