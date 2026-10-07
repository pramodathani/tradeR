#' One instrument's order inside a multi-instrument synthetic order, with the template fields it overrides
#'
#' @description
#' `BasketOrder`, `OneCancelsAllOrder`, `LeggedSpreadOrder` and `StrategyStopOrder` each place one real order per candidate. A candidate names its instrument and may override eight fields of the order template; every field left as `NULL` takes the template's value.
#'
#' @examples
#' \dontrun{
#' first <- OrderCandidate$new(nifty_call, price = 120.0)
#' second <- OrderCandidate$new(
#'   nifty_put,
#'   transaction_type = "sell",
#'   price = 95.0
#' )
#' document <- first$document()
#' }
#' @export
OrderCandidate <- R6::R6Class(
  "OrderCandidate",
  public = list(
    #' @field instrument The `TradeableInstrument` this leg trades.
    instrument = NULL,
    #' @field transaction_type The character side, `"buy"` or `"sell"`, or `NULL` to use the template's.
    transaction_type = NULL,
    #' @field product The character product, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use the template's.
    product = NULL,
    #' @field order_type The character kind of order, or `NULL` to use the template's.
    order_type = NULL,
    #' @field validity The character validity, `"day"` or `"ioc"`, or `NULL` to use the template's.
    validity = NULL,
    #' @field quantity The integer quantity in underlying units, or `NULL` to use the template's.
    quantity = NULL,
    #' @field price The numeric limit price in rupees, or `NULL` to use the template's.
    price = NULL,
    #' @field trigger_price The numeric trigger price in rupees, or `NULL` to use the template's.
    trigger_price = NULL,
    #' @field tag The character label, or `NULL` to use the template's.
    tag = NULL,

    #' @description
    #' Initialises the leg with its instrument and the fields it overrides.
    #'
    #' A candidate is merged over the whole template, so a template price is carried into a candidate that sets `order_type` to `market` unless the candidate is priced differently, and UBI then refuses the market order that carries a price. Give such a template no price, or give each candidate its own.
    #' @param instrument The `TradeableInstrument` this leg trades.
    #' @param transaction_type The character side, `"buy"` or `"sell"`, or `NULL` to use the template's.
    #' @param product The character product, `"cnc"`, `"mis"` or `"nrml"`, or `NULL` to use the template's.
    #' @param order_type The character kind of order, `"market"`, `"limit"`, `"sl"` or `"sl-m"`, or `NULL` to use the template's.
    #' @param validity The character validity, `"day"` or `"ioc"`, or `NULL` to use the template's.
    #' @param quantity The integer quantity in underlying units, or `NULL` to use the template's.
    #' @param price The numeric limit price in rupees, or `NULL` to use the template's.
    #' @param trigger_price The numeric trigger price in rupees, or `NULL` to use the template's.
    #' @param tag A character label of up to twenty letters and digits, or `NULL` to use the template's.
    #' @return A new `OrderCandidate` object.
    initialize = function(
      instrument,
      transaction_type = NULL,
      product = NULL,
      order_type = NULL,
      validity = NULL,
      quantity = NULL,
      price = NULL,
      trigger_price = NULL,
      tag = NULL
    ) {
      self$instrument <- instrument
      self$transaction_type <- transaction_type
      self$product <- product
      self$order_type <- order_type
      self$validity <- validity
      self$quantity <- quantity
      self$price <- price
      self$trigger_price <- trigger_price
      self$tag <- tag
    },

    #' @description
    #' Builds the candidate object UBI reads, naming the instrument and every field that is set.
    #' @return A named list with `instrument_id` and each overridden field that is not `NULL`.
    #' @examples
    #' \dontrun{
    #' share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' candidate <- OrderCandidate$new(share, price = 13.0)
    #' print(candidate$document())
    #'
    #' first_share <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' second_share <- Equity$new(exchange = "nse", symbol = "YESBANK")
    #' candidates <- list(
    #'   OrderCandidate$new(first_share, price = 13.0),
    #'   OrderCandidate$new(
    #'     second_share,
    #'     transaction_type = "sell",
    #'     quantity = 2,
    #'     price = 21.0,
    #'     tag = "pairleg"
    #'   )
    #' )
    #' for (candidate in candidates) {
    #'   print(candidate$document())
    #' }
    #' }
    document = function() {
      candidate <- list(
        instrument_id = self$instrument$instrument_id
      )
      overrides <- list(
        transaction_type = self$transaction_type,
        product = self$product,
        order_type = self$order_type,
        validity = self$validity,
        quantity = self$quantity,
        price = self$price,
        trigger_price = self$trigger_price,
        tag = self$tag
      )
      for (field in names(overrides)) {
        if (!is.null(overrides[[field]])) {
          candidate[[field]] <- overrides[[field]]
        }
      }
      candidate
    }
  )
)
