#' The errors the Unified Broker Interface client signals
#'
#' @description
#' Each name is an error class and each value is its parent class. `UnifiedBrokerInterfaceError` is the root, carrying a `status_code` and a `detail` holding UBI's parsed answer, and every other class here is one HTTP status code UBI returns, or a failure to reach UBI at all.
#'
#' @format A named character vector, one entry per error class:
#' \describe{
#'   \item{`UnifiedBrokerInterfaceError`}{A failure reported by, or on the way to, the Unified Broker Interface. The condition carries `message`, a character description taken from the response's `error` field when it has one; `status_code`, the integer HTTP status code, or `NULL` when no response arrived; and `detail`, the parsed JSON body as a named list, or an empty list when there was none.}
#'   \item{`BadRequestError`}{The request was malformed, such as a missing or invalid parameter (HTTP 400).}
#'   \item{`AuthenticationError`}{The api key or secret was wrong, or the access token was missing, invalid or expired (HTTP 401).}
#'   \item{`LossLockoutError`}{The day's loss is past UBI's daily loss limit, so the order engine refuses every new order (HTTP 403).}
#'   \item{`NotFoundError`}{The requested instrument, profile or order does not exist (HTTP 404).}
#'   \item{`ConflictError`}{The request conflicts with the account's state, such as an order no longer open, a position that is not held, or an order the engine read too late (HTTP 409).}
#'   \item{`OrderRejectedError`}{The broker rejected the order, and the detail holds the order document (HTTP 422).}
#'   \item{`RateLimitError`}{The broker chosen for the order is at its order limit, or has used its daily order cap (HTTP 429).}
#'   \item{`BrokerError`}{No broker's data could be read for the request (HTTP 502).}
#'   \item{`ServiceUnavailableError`}{The requested data is stale or not being kept, no broker can take the order, or a price reference cannot be resolved (HTTP 503).}
#'   \item{`OrderOutcomeUnknownError`}{The order was sent but its outcome is unknown, and the detail holds the order document (HTTP 504).}
#'   \item{`ServerError`}{A failure status that has no more specific class, such as HTTP 500 or 405.}
#'   \item{`UnreachableError`}{The Unified Broker Interface could not be reached, so no response arrived.}
#' }
#' @keywords internal
UNIFIED_BROKER_INTERFACE_ERROR_PARENTS <- c(
  UnifiedBrokerInterfaceError = "error",
  BadRequestError = "UnifiedBrokerInterfaceError",
  AuthenticationError = "UnifiedBrokerInterfaceError",
  LossLockoutError = "UnifiedBrokerInterfaceError",
  NotFoundError = "UnifiedBrokerInterfaceError",
  ConflictError = "UnifiedBrokerInterfaceError",
  OrderRejectedError = "UnifiedBrokerInterfaceError",
  RateLimitError = "UnifiedBrokerInterfaceError",
  BrokerError = "UnifiedBrokerInterfaceError",
  ServiceUnavailableError = "UnifiedBrokerInterfaceError",
  OrderOutcomeUnknownError = "UnifiedBrokerInterfaceError",
  ServerError = "UnifiedBrokerInterfaceError",
  UnreachableError = "UnifiedBrokerInterfaceError"
)

#' The error class UBI's client signals for each failing HTTP status code
#'
#' @description
#' A status code missing from this table is signalled as `ServerError`.
#'
#' @format A named character vector whose names are HTTP status codes and whose values are error class names.
#' @keywords internal
UNIFIED_BROKER_INTERFACE_ERROR_FOR_STATUS_CODE <- c(
  "400" = "BadRequestError",
  "401" = "AuthenticationError",
  "403" = "LossLockoutError",
  "404" = "NotFoundError",
  "409" = "ConflictError",
  "422" = "OrderRejectedError",
  "429" = "RateLimitError",
  "502" = "BrokerError",
  "503" = "ServiceUnavailableError",
  "504" = "OrderOutcomeUnknownError"
)
