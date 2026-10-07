ASSET_BASKETS_STATED_WEIGHTING <- "stated"
ASSET_BASKETS_EQUAL_WEIGHTING <- "equal"
ASSET_BASKETS_PRICE_WEIGHTING <- "price"
ASSET_BASKETS_WEIGHTINGS <- c(
  "stated",
  "equal",
  "price"
)
ASSET_BASKETS_BASE_DATE_SEARCH_DAYS <- 10

#' A weighted basket of instruments that is followed as one level
#'
#' @description
#' `Index` weights its members in one of three ways. `stated` uses each member's own weight, as a published index's factsheet gives them. `equal` gives every member the same weight. `price` weights each member by its price, as a price-weighted index such as the Dow Jones does, which is the same as holding one unit of each. Its candles start from `base_value` at the first candle of whatever range is asked for, so two ranges start from the same number; `level` instead fixes the start at `base_date` and reports today's level from it.
#'
#' An `Index` usually describes the contents of an official index that UBI quotes, such as NIFTY, and then `linked_instrument` is that index. Comparing the two, for instance with `tracking_error(benchmark = index$linked_instrument)`, shows how well the stored members and weights reproduce it. `to_portfolio()` turns the index into whole units of each member for a sum of money, ready for `Portfolio$place_orders()`.
#'
#' The generator carries `Index$KIND`, the kind stored with the index, `"index"`.
#'
#' @examples
#' \dontrun{
#' symbols <- c(
#'   "INFY",
#'   "TCS",
#'   "HCLTECH",
#'   "WIPRO",
#'   "TECHM"
#' )
#' members <- list()
#' for (symbol in symbols) {
#'   share <- Equity$new(exchange = "nse", symbol = symbol)
#'   members[[length(members) + 1]] <- BasketMember$new(share)
#' }
#' it_index <- Index$new(
#'   name = "my IT index",
#'   members = members,
#'   weighting = "equal"
#' )
#' frame <- it_index$prices(days = 365)
#' holdings <- it_index$to_portfolio(capital = 100000)
#'
#' print(it_index$weights)
#' price_index <- Index$new(name = "IT", members = members, weighting = "price")
#' print(round(price_index$weights, 3))
#'
#' based_index <- Index$new(
#'   name = "IT",
#'   members = members,
#'   weighting = "equal",
#'   base_value = 1000,
#'   base_date = "2026-01-01"
#' )
#' cat(sprintf("%s: %.2f\n", based_index$name, based_index$level))
#'
#' unbased_index <- Index$new(
#'   name = "IT",
#'   members = members,
#'   weighting = "equal"
#' )
#' tryCatch(
#'   print(unbased_index$level),
#'   AssetBasketError = function(error) print(conditionMessage(error))
#' )
#' }
#' @export
Index <- R6::R6Class(
  "Index",
  inherit = AssetBasket,
  public = list(
    #' @field KIND The character kind stored with the index, `"index"`.
    KIND = "index",
    #' @field weighting The character way the members are weighted: `"stated"`, `"equal"` or `"price"`.
    weighting = NULL,
    #' @field base_date The `Date` the level is measured from, when it equals `base_value`, or `NULL` when no base date is set.
    base_date = NULL,

    #' @description
    #' Initialises the index and checks its weighting.
    #' @param name The character name of the index, such as `"NIFTY"`.
    #' @param members A list of `BasketMember` objects, each a different instrument, all with a weight when `weighting` is `"stated"`.
    #' @param weighting The character way to weight the members: `"stated"`, `"equal"` or `"price"`.
    #' @param base_value The numeric level the index starts from.
    #' @param base_date The `Date` or `"YYYY-MM-DD"` character value the level starts from, or `NULL` when no level is followed.
    #' @param linked_instrument The `Instrument` the index describes, such as the NIFTY index row UBI quotes, or `NULL`.
    #' @param unified_broker_interface The `UnifiedBrokerInterface` to send requests through, or `NULL` to share the one every instrument uses.
    #' @return A new `Index` object.
    #' @details Errors: signals `BasketMemberError` when `members` is empty, names an instrument twice, or lacks weights when `weighting` is `"stated"`; and `ValueError` when `weighting` is not one of `"stated"`, `"equal"` and `"price"`, or `base_value` is not positive.
    initialize = function(
      name,
      members,
      weighting = ASSET_BASKETS_STATED_WEIGHTING,
      base_value = ASSET_BASKETS_DEFAULT_BASE_VALUE,
      base_date = NULL,
      linked_instrument = NULL,
      unified_broker_interface = NULL
    ) {
      if (!(weighting %in% ASSET_BASKETS_WEIGHTINGS)) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf("Not an index weighting: weighting='%s'", weighting)
        )
      }
      if (base_value <= 0) {
        ErrorCatalogue$raise(
          "ValueError",
          sprintf(
            "The base value must be positive: base_value=%s",
            private$python_number_text(base_value)
          )
        )
      }
      super$initialize(
        name = name,
        members = members,
        linked_instrument = linked_instrument,
        unified_broker_interface = unified_broker_interface
      )
      if (weighting == ASSET_BASKETS_STATED_WEIGHTING &&
            is.null(self$members[[1]]$weight)) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "A stated weighting needs a weight on every member of '%s'; use weighting='equal' otherwise",
            name
          )
        )
      }
      self$weighting <- weighting
      self$base_value <- as.numeric(base_value)
      self$base_date <- TimeConverter$new()$date(base_date)
    },

    #' @description
    #' Turns the index into whole units of each member for a sum of money, at last prices.
    #'
    #' Each quantity is the capital times the member's weight divided by its last price, floored to a whole unit, so a little of the capital is left over. A member whose share buys less than one unit is left out. Nothing is sent; pass the result to `Portfolio$place_orders()` to buy it.
    #' @param capital The numeric amount in rupees to spread across the members.
    #' @param name The character name to give the portfolio, or `NULL` to name it after the index.
    #' @return A `Portfolio` of the members that get at least one unit.
    #' @details Errors: signals `BasketMemberError` when a member has no last price, or the capital buys no unit of any member; and a `UnifiedBrokerInterfaceError` subclass when UBI refused the request or could not be reached.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HCLTECH",
    #'   "WIPRO",
    #'   "TECHM"
    #' )
    #' members <- list()
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(share)
    #' }
    #' it_index <- Index$new(
    #'   name = "IT",
    #'   members = members,
    #'   weighting = "equal"
    #' )
    #' holdings <- it_index$to_portfolio(capital = 100000)
    #' print(holdings$quantities)
    #' cat(sprintf("Worth Rs %.2f of the Rs 100,000\n", holdings$value))
    #'
    #' tryCatch(
    #'   it_index$to_portfolio(capital = 500, name = "too small"),
    #'   BasketMemberError = function(error) print(conditionMessage(error))
    #' )
    #' }
    to_portfolio = function(capital, name = NULL) {
      weights <- self$weights
      last_prices <- private$last_prices_by_instrument_id(self$instruments)
      members <- list()
      for (member in self$members) {
        last_price <- last_prices[[member$instrument$instrument_id]]
        quantity <- floor(capital * weights[[member$label]] / last_price)
        if (quantity < 1) {
          next
        }
        if (quantity <= .Machine$integer.max) {
          quantity <- as.integer(quantity)
        }
        members[[length(members) + 1]] <- BasketMember$new(
          member$instrument,
          quantity = quantity
        )
      }
      if (length(members) == 0) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "%s rupees buys no whole unit of any member of '%s'",
            format(capital, digits = 15),
            self$name
          )
        )
      }
      if (is.null(name)) {
        name <- sprintf("%s portfolio", self$name)
      }
      Portfolio$new(
        name = name,
        members = members,
        unified_broker_interface = private$unified_broker_interface
      )
    },

    #' @description
    #' Describes the index as a named list for storing in MongoDB.
    #' @param effective_date The first day the index is in effect as a `Date` or a `"YYYY-MM-DD"` character value, or `NULL` for today.
    #' @return The named list `AssetBasket$document()` gives, with `weighting` and `base_date`, as `"YYYY-MM-DD"` text or `NULL`, added.
    #' @examples
    #' \dontrun{
    #' symbols <- c(
    #'   "INFY",
    #'   "TCS",
    #'   "HCLTECH",
    #'   "WIPRO",
    #'   "TECHM"
    #' )
    #' members <- list()
    #' for (symbol in symbols) {
    #'   share <- Equity$new(exchange = "nse", symbol = symbol)
    #'   members[[length(members) + 1]] <- BasketMember$new(share)
    #' }
    #' it_index <- Index$new(
    #'   name = "IT",
    #'   members = members,
    #'   weighting = "equal",
    #'   base_date = "2026-01-01"
    #' )
    #' document <- it_index$document(effective_date = "2026-10-01")
    #' cat(document$kind, document$weighting, document$base_date, "\n")
    #'
    #' price_index <- Index$new(
    #'   name = "IT",
    #'   members = members,
    #'   weighting = "price"
    #' )
    #' print(price_index$document()$base_date)
    #' }
    document = function(effective_date = NULL) {
      document <- super$document(effective_date)
      document[["weighting"]] <- self$weighting
      if (is.null(self$base_date)) {
        document["base_date"] <- list(NULL)
      } else {
        document[["base_date"]] <- format(self$base_date, "%Y-%m-%d")
      }
      document
    }
  ),
  active = list(
    #' @field weights A named numeric vector of weights, named by member label, that sum to 1: the stated weights, equal weights, or for a price weighting each member's share of the sum of last prices, read from UBI on every access.
    weights = function(value) {
      if (!missing(value)) {
        stop("weights is read-only", call. = FALSE)
      }
      if (self$weighting == ASSET_BASKETS_EQUAL_WEIGHTING) {
        equal_weights <- rep(1 / self$size, self$size)
        names(equal_weights) <- self$labels
        return(equal_weights)
      }
      if (self$weighting == ASSET_BASKETS_PRICE_WEIGHTING) {
        last_prices <- private$last_prices_by_instrument_id(self$instruments)
        prices <- numeric(0)
        for (member in self$members) {
          prices <- c(
            prices,
            last_prices[[member$instrument$instrument_id]]
          )
        }
        names(prices) <- self$labels
        return(prices / sum(prices))
      }
      super$weights
    },

    #' @field level The numeric level of the index now: `base_value` at the closes of `base_date`, moved by the members' last prices since, read from UBI on every access. Reading it signals `AssetBasketError` when no `base_date` is set, and `BasketMemberError` when not every member has a candle within ten days of `base_date` or a member has no last price.
    level = function(value) {
      if (!missing(value)) {
        stop("level is read-only", call. = FALSE)
      }
      if (is.null(self$base_date)) {
        ErrorCatalogue$raise(
          "AssetBasketError",
          sprintf(
            "The index '%s' has no base_date, so it has no level; use prices() for a series starting at base_value",
            self$name
          )
        )
      }
      closes <- self$member_closes(
        from_date = self$base_date,
        to_date = self$base_date + ASSET_BASKETS_BASE_DATE_SEARCH_DAYS
      )
      if (is.null(closes)) {
        ErrorCatalogue$raise(
          "BasketMemberError",
          sprintf(
            "Not every member of '%s' has a candle within %d days of %s",
            self$name,
            ASSET_BASKETS_BASE_DATE_SEARCH_DAYS,
            format(self$base_date, "%Y-%m-%d")
          )
        )
      }
      quantities <- private$candle_quantities(private$row_values(closes, 1))
      last_prices <- private$last_prices_by_instrument_id(self$instruments)
      level <- 0
      for (member in self$members) {
        level <- level + quantities[[member$label]] *
          last_prices[[member$instrument$instrument_id]]
      }
      level
    }
  ),
  private = list(
    #' Works out the fixed quantity of each member the index's candles are built from.
    #'
    #' A price weighting holds the same quantity of every member, sized so the first close equals `base_value`. Any other weighting spreads `base_value` by weight, as `AssetBasket` does.
    #' @param first_closes A named numeric vector of each member's close at the first shared candle, named by member label.
    #' @return A named numeric vector of quantities, named by member label.
    candle_quantities = function(first_closes) {
      if (self$weighting == ASSET_BASKETS_PRICE_WEIGHTING) {
        equal_quantity <- self$base_value / sum(first_closes)
        quantities <- rep(equal_quantity, length(first_closes))
        names(quantities) <- names(first_closes)
        return(quantities)
      }
      super$candle_quantities(first_closes)
    }
  )
)

Index$KIND <- "index"
