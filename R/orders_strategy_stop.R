ORDERS_STRATEGY_STOP_SYNTHETIC_TYPE <- "strategy_stop"

#' A basket whose every leg is closed when the whole strategy's profit or loss crosses a line
#'
#' @description
#' It places its candidates the way a basket does, then marks every leg to its last traded price on each tick and closes every leg when the total falls to `loss_limit` or below or rises to `profit_target` or above. Give at least one of the two. A quote marked stale marks nothing, so the stop waits for a live one. When the stop acts, the basket's orders still resting are cancelled, and whatever they fill before the cancel lands is closed too, so the parent completes only once nothing of the basket rests and every close has finished. A close the broker refuses is not sent again, and the parent ends `failed`, because that leg is left open. UBI never resolves references for this type. The first candidate's instrument anchors the request.
#'
#' The order template's attributes are described on `SyntheticOrder`, where `instrument` is the first candidate's.
#'
#' @examples
#' \dontrun{
#' order <- StrategyStopOrder$new(
#'   candidates = list(
#'     OrderCandidate$new(reliance, price = 1450.0),
#'     OrderCandidate$new(infosys, price = 1500.0)
#'   ),
#'   transaction_type = "buy",
#'   product = "cnc",
#'   order_type = "limit",
#'   quantity = 1,
#'   loss_limit = -5000.0,
#'   dry_run = TRUE
#' )
#' answer <- order$place()
#' }
#' @export
StrategyStopOrder <- R6::R6Class(
  "StrategyStopOrder",
  inherit = SyntheticOrder,
  public = list(
    #' @field SYNTHETIC_TYPE The character name UBI gives this synthetic type, sent as the `type` of the `synthetic` object.
    SYNTHETIC_TYPE = ORDERS_STRATEGY_STOP_SYNTHETIC_TYPE,
    #' @field candidates The list of `OrderCandidate`, one per instrument.
    candidates = NULL,
    #' @field hedge_benefit A logical that is `TRUE` to have UBI price options and futures on one underlying and expiry together, as a hedged whole, when it checks that the broker can afford the legs.
    hedge_benefit = NULL,
    #' @field loss_limit The numeric loss in rupees for the whole strategy at or below which every leg is closed, below zero, or `NULL`.
    loss_limit = NULL,
    #' @field profit_target The numeric profit in rupees for the whole strategy at or above which every leg is closed, above zero, or `NULL`.
    profit_target = NULL,

    #' @description
    #' Initialises the candidates, the template they default to and this type's own settings.
    #' @param candidates The list of `OrderCandidate`, from 1 to 25, each on a different instrument.
    #' @param transaction_type The character default side for every candidate, `"buy"` or `"sell"`.
    #' @param product The character default product for every candidate, `"cnc"`, `"mis"` or `"nrml"`.
    #' @param order_type The character default kind of order for every candidate, `"market"`, `"limit"`, `"sl"` or `"sl-m"`.
    #' @param quantity The integer default quantity in underlying units for every candidate.
    #' @param price The numeric default limit price in rupees for every candidate, or `NULL`. It is carried into a candidate that sets `order_type` to `market` unless that candidate sets its own price.
    #' @param trigger_price The numeric default trigger price in rupees for every candidate, or `NULL`.
    #' @param validity The character default validity, `"day"` or `"ioc"`, or `NULL` to let UBI use `"day"`.
    #' @param after_market A logical that is `TRUE` to send the orders as after-market orders.
    #' @param tag A character default label of up to twenty letters and digits, or `NULL`.
    #' @param closes_position A logical that is `TRUE` when every order this type sends closes a position, so it may use the share of a broker's daily order cap kept for exits.
    #' @param reduce_only A logical that is `TRUE` to have UBI refuse, with HTTP 409, any leg that is not on the closing side of the net position held when it is sent or is bigger than that position.
    #' @param hold_limits A logical that is `TRUE` to have UBI hold each order that would rest at the broker at a fixed limit price until the other side of the book reaches it, `FALSE` to send them as they come, or `NULL` to let UBI use the type's default.
    #' @param dry_run A logical that is `TRUE` to have UBI check the order and answer with the `plan` it would run, without recording or sending anything; the answer's `request` is the template as a broker would receive it, which for a stop is not the stop.
    #' @param loss_limit The numeric loss in rupees for the whole strategy at or below which every leg is closed, below zero, or `NULL`.
    #' @param profit_target The numeric profit in rupees for the whole strategy at or above which every leg is closed, above zero, or `NULL`.
    #' @param hedge_benefit A logical that is `TRUE` to have UBI price options and futures on one underlying and expiry together, as a hedged whole, when it checks that the broker can afford the legs, rather than adding every leg's margin up.
    #' @details Errors: signals `ValueError` when no candidate was given, so there is no instrument to anchor the request.
    #' @return A new `StrategyStopOrder` object.
    initialize = function(
      candidates,
      transaction_type,
      product,
      order_type,
      quantity,
      price = NULL,
      trigger_price = NULL,
      validity = NULL,
      after_market = FALSE,
      tag = NULL,
      closes_position = FALSE,
      reduce_only = FALSE,
      hold_limits = NULL,
      dry_run = FALSE,
      loss_limit = NULL,
      profit_target = NULL,
      hedge_benefit = FALSE
    ) {
      if (length(candidates) == 0) {
        ErrorCatalogue$raise(
          "ValueError",
          "A strategy_stop order needs at least one candidate to anchor the request"
        )
      }
      super$initialize(
        candidates[[1]]$instrument,
        transaction_type = transaction_type,
        product = product,
        order_type = order_type,
        quantity = quantity,
        price = price,
        trigger_price = trigger_price,
        validity = validity,
        after_market = after_market,
        tag = tag,
        closes_position = closes_position,
        reduce_only = reduce_only,
        hold_limits = hold_limits,
        dry_run = dry_run
      )
      self$candidates <- as.list(candidates)
      self$loss_limit <- loss_limit
      self$profit_target <- profit_target
      self$hedge_benefit <- hedge_benefit
    },

    #' @description
    #' Gives this type's own settings, the fields of the `synthetic` object besides `type`.
    #' @return A named list of UBI field names to values, holding the candidates as UBI reads them, where a value of `NULL` means the field is left out.
    synthetic_fields = function() {
      documents <- list()
      for (candidate in self$candidates) {
        documents[[length(documents) + 1]] <- candidate$document()
      }
      fields <- list(
        candidates = documents,
        loss_limit = self$loss_limit,
        profit_target = self$profit_target
      )
      if (isTRUE(self$hedge_benefit)) {
        fields[["hedge_benefit"]] <- TRUE
      }
      fields
    }
  )
)
