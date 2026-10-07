#' One order of a plan, with the presets and slot values that shape it
#'
#' @description
#' One order inside a plan, which may wait for a trigger, protect or close a position, be priced, be sent in pieces and end on its own.
#'
#' By default the order's instrument, side, quantity, product and validity come from the `PlanOrder` it belongs to, and an order inside a join is sized by the join. An order can also give its own instrument, quantity, side, product, validity and tag, which is how one plan trades several instruments, and say for itself whether UBI holds it until the market reaches its price. An order with no presets and no settings is the template as it stands, run as a `simple` order.
#' @examples
#' \dontrun{
#' part <- OrderPart$new(
#'   presets = list(
#'     Preset$new("scheduled", at_time = "10:00")
#'   ),
#'   trigger = PriceCrosses$new(level = 995.0),
#'   pricing = MarketablePricing$new(buffer_ticks = 2)
#' )
#' document <- part$document()
#' }
#' @export
OrderPart <- R6::R6Class(
  "OrderPart",
  inherit = PlanPart,
  public = list(
    #' @field presets The list of `PlanPart` presets merged into the order first, in order, or `NULL` for none.
    presets = NULL,
    #' @field trigger The `PlanPart` condition the order waits for, or `NULL` to place it at once.
    trigger = NULL,
    #' @field side The character side, `buy`, `sell`, `protect`, `close`, `same_as_first` or `against_delta`, or `NULL` to use the template's side.
    side = NULL,
    #' @field pricing The `PlanPart` pricing rule that sets the price, or `NULL` to use the template's own order type and price.
    pricing = NULL,
    #' @field cap The `PlanPart` `CapModifier` that bounds the price the rule sets, or `NULL` for no bound.
    cap = NULL,
    #' @field discretion The `PlanPart` `DiscretionModifier` that lets part of the order trade a little past its price, or `NULL`.
    discretion = NULL,
    #' @field execution The `PlanPart` execution that sends the order, such as `TwapExecution`, or `NULL` to send it all at once.
    execution = NULL,
    #' @field inner_execution The `PlanPart` execution that sends each piece of `execution`, such as `IcebergExecution`, or `NULL`.
    inner_execution = NULL,
    #' @field guard The `PlanPart` `PostOnlyGuard` that keeps the order from trading at once, or `NULL`.
    guard = NULL,
    #' @field lifetime The `PlanPart` `Lifetime` that ends the order, or `NULL` to let it run until it is done.
    lifetime = NULL,
    #' @field venue The `PlanPart` venue, `PreOpenVenue` or `PaperVenue`, or `NULL` for the normal market.
    venue = NULL,
    #' @field quantity The integer quantity, or a `PlanPart` quantity such as `PositionQuantity`, or `NULL` to use the template's or the join's quantity.
    quantity = NULL,
    #' @field instrument The `TradeableInstrument` this order trades, or `NULL` for the plan's own instrument.
    instrument = NULL,
    #' @field transaction_type The character side of the order's own body, `buy` or `sell`, or `NULL` for the template's.
    transaction_type = NULL,
    #' @field product The character product of the order's own body, such as `mis`, or `NULL` for the template's.
    product = NULL,
    #' @field validity The character validity of the order's own body, `day` or `ioc`, or `NULL` for the template's.
    validity = NULL,
    #' @field tag The character tag of the order's own body, or `NULL` for the template's.
    tag = NULL,
    #' @field hold_limits A logical that is `TRUE` to hold this order in UBI's virtual order book until the other side of the book reaches its price, `FALSE` to send it as it comes whatever the plan says, or `NULL` to follow the plan.
    hold_limits = NULL,

    #' @description
    #' Initialises the order with its presets and its own slot values.
    #'
    #' UBI merges the presets first and the order's own values after them. Triggers from several sources are joined so that all of them must hold, a later pricing rule, cap, execution, guard or lifetime replaces an earlier one with a warning, and two different sides are refused.
    #' @param presets A list of `PlanPart` presets, usually `Preset` objects, or `NULL` for none.
    #' @param trigger A `PlanPart` condition, such as `PriceCrosses` or `AllConditions`, or `NULL` to place the order at once.
    #' @param side The character side, `buy`, `sell`, `protect` to trade against the position the template's side opened, `close` to close the position a `PositionQuantity` names, `same_as_first` to trade, as a Then join's child, on the side the first plan filled on, or `against_delta` to hedge the delta of an option the plan traded, or `NULL` to use the template's side.
    #' @param pricing A `PlanPart` pricing rule that sets the price, such as `FixedPricing`, `PegPricing` or `TrailPricing`, or `NULL` to use the template's own order type and price.
    #' @param cap A `PlanPart` `CapModifier`, the worst price the rule may set, or `NULL`.
    #' @param discretion A `PlanPart` `DiscretionModifier`, or `NULL`.
    #' @param execution A `PlanPart` execution, such as `TwapExecution` or `IcebergExecution`, or `NULL` to send the order all at once.
    #' @param inner_execution A `PlanPart` execution that works each piece `execution` releases, such as an `IcebergExecution` inside a `TwapExecution`, or `NULL`. It needs `execution`.
    #' @param guard A `PlanPart` `PostOnlyGuard`, or `NULL`.
    #' @param lifetime A `PlanPart` `Lifetime`, or `NULL`.
    #' @param venue A `PlanPart` `PreOpenVenue` or `PaperVenue`, or `NULL`.
    #' @param quantity An integer quantity, a `PlanPart` quantity such as `PositionQuantity` or `ParentFillQuantity`, or `NULL`.
    #' @param instrument The `TradeableInstrument` this order trades instead of the plan's, or `NULL`.
    #' @param transaction_type The character side of this order's own body, `buy` or `sell`, or `NULL`.
    #' @param product The character product of this order's own body, `cnc`, `mis` or `nrml`, or `NULL`.
    #' @param validity The character validity of this order's own body, `day` or `ioc`, or `NULL`.
    #' @param tag The character tag of this order's own body, or `NULL`.
    #' @param hold_limits A logical that is `TRUE` to hold this order until the other side of the book reaches its price, `FALSE` to send it as it comes, or `NULL` to follow the plan. UBI refuses `TRUE` with HTTP 400 and the rule `not_holdable` for an order that cannot be held, such as a market order or one priced by anything but `FixedPricing`.
    #' @return A new `OrderPart` object.
    initialize = function(
      presets = NULL,
      trigger = NULL,
      side = NULL,
      pricing = NULL,
      cap = NULL,
      discretion = NULL,
      execution = NULL,
      inner_execution = NULL,
      guard = NULL,
      lifetime = NULL,
      venue = NULL,
      quantity = NULL,
      instrument = NULL,
      transaction_type = NULL,
      product = NULL,
      validity = NULL,
      tag = NULL,
      hold_limits = NULL
    ) {
      self$presets <- presets
      self$trigger <- trigger
      self$side <- side
      self$pricing <- pricing
      self$cap <- cap
      self$discretion <- discretion
      self$execution <- execution
      self$inner_execution <- inner_execution
      self$guard <- guard
      self$lifetime <- lifetime
      self$venue <- venue
      self$quantity <- quantity
      self$instrument <- instrument
      self$transaction_type <- transaction_type
      self$product <- product
      self$validity <- validity
      self$tag <- tag
      self$hold_limits <- hold_limits
    },

    #' @description
    #' Builds the `order` node UBI reads, holding every setting that is not `NULL`.
    #' @return A named list with the single key `order`, whose value holds each setting that is set. UBI takes `pricing`, `execution`, `guards`, `lifetime` and `venue` as lists: the pricing rule, cap and discretion go in one `pricing` list, the execution and inner execution in one `execution` list, and the guard, lifetime and venue each in a list of one. An instrument is sent as its `instrument_id`, and `hold_limits` is sent only when it is not `NULL`.
    #' @examples
    #' \dontrun{
    #' part <- OrderPart$new(
    #'   trigger = PriceCrosses$new(level = 995.0),
    #'   pricing = MarketablePricing$new(buffer_ticks = 2)
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   presets = list(
    #'     Preset$new("scheduled", at_time = "10:00"),
    #'     Preset$new("market_if_touched", trigger_price = 995.0)
    #'   )
    #' )
    #' print(part$document())
    #'
    #' part <- OrderPart$new(
    #'   pricing = PegPricing$new(reference = "own_touch"),
    #'   cap = CapModifier$new(worst_price = 1010.0),
    #'   execution = TwapExecution$new(
    #'     slices = 6,
    #'     over_minutes = 60
    #'   ),
    #'   inner_execution = IcebergExecution$new(
    #'     visible_quantity = 10
    #'   ),
    #'   lifetime = Lifetime$new(at_time = "14:30")
    #' )
    #' print(part$document())
    #' }
    document = function() {
      settings <- structure(list(), names = character(0))
      if (!is.null(self$presets)) {
        preset_documents <- list()
        for (preset in self$presets) {
          preset_documents[[length(preset_documents) + 1]] <- preset$document()
        }
        settings[["presets"]] <- preset_documents
      }
      if (!is.null(self$trigger)) {
        settings[["trigger"]] <- self$trigger$document()
      }
      if (!is.null(self$side)) {
        settings[["side"]] <- self$side
      }
      pricing_documents <- list()
      if (!is.null(self$pricing)) {
        pricing_documents[[length(pricing_documents) + 1]] <-
          self$pricing$document()
      }
      if (!is.null(self$cap)) {
        pricing_documents[[length(pricing_documents) + 1]] <-
          self$cap$document()
      }
      if (!is.null(self$discretion)) {
        pricing_documents[[length(pricing_documents) + 1]] <-
          self$discretion$document()
      }
      if (length(pricing_documents) > 0) {
        settings[["pricing"]] <- pricing_documents
      }
      execution_documents <- list()
      if (!is.null(self$execution)) {
        execution_documents[[length(execution_documents) + 1]] <-
          self$execution$document()
      }
      if (!is.null(self$inner_execution)) {
        execution_documents[[length(execution_documents) + 1]] <-
          self$inner_execution$document()
      }
      if (length(execution_documents) > 0) {
        settings[["execution"]] <- execution_documents
      }
      if (!is.null(self$guard)) {
        settings[["guards"]] <- list(
          self$guard$document()
        )
      }
      if (!is.null(self$lifetime)) {
        settings[["lifetime"]] <- list(
          self$lifetime$document()
        )
      }
      if (!is.null(self$venue)) {
        settings[["venue"]] <- list(
          self$venue$document()
        )
      }
      if (inherits(self$quantity, "PlanPart")) {
        settings[["quantity"]] <- self$quantity$document()
      } else if (!is.null(self$quantity)) {
        settings[["quantity"]] <- self$quantity
      }
      if (!is.null(self$instrument)) {
        settings[["instrument_id"]] <- self$instrument$instrument_id
      }
      if (!is.null(self$transaction_type)) {
        settings[["transaction_type"]] <- self$transaction_type
      }
      if (!is.null(self$product)) {
        settings[["product"]] <- self$product
      }
      if (!is.null(self$validity)) {
        settings[["validity"]] <- self$validity
      }
      if (!is.null(self$tag)) {
        settings[["tag"]] <- self$tag
      }
      if (!is.null(self$hold_limits)) {
        settings[["hold_limits"]] <- self$hold_limits
      }
      list(
        order = settings
      )
    }
  )
)
