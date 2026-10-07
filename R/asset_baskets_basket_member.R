#' One instrument held in a basket
#'
#' @description
#' A basket that describes an allocation, such as an index or a fund's contents, gives each member a `weight`. A portfolio gives each member a `quantity` and, when it is known, the `average_price` it was bought at. A watchlist gives neither.
#'
#' @examples
#' \dontrun{
#' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
#' member <- BasketMember$new(infosys, weight = 0.05)
#' held <- BasketMember$new(infosys, quantity = 10, average_price = 1450)
#'
#' print(BasketMember$new(infosys, weight = 0.05)$label)
#'
#' for (exchange in c(
#'   "nse",
#'   "bse"
#' )) {
#'   share <- Equity$new(exchange = exchange, symbol = "TCS")
#'   print(BasketMember$new(share)$label)
#' }
#' }
#' @export
BasketMember <- R6::R6Class(
  "BasketMember",
  public = list(
    #' @field instrument The `Instrument` this member is.
    instrument = NULL,
    #' @field weight The numeric share of the basket this member is meant to be, in any units such as fractions or percentages because the basket normalises them, or `NULL` when the basket is not weighted.
    weight = NULL,
    #' @field quantity The integer or numeric number of units held, negative for a short position, or `NULL` when the basket is not counted in units.
    quantity = NULL,
    #' @field average_price The numeric average price in rupees the quantity was bought at, or `NULL` when it is not known.
    average_price = NULL,

    #' @description
    #' Initialises the member.
    #' @param instrument The `Instrument` this member is.
    #' @param weight The numeric share of the basket, or `NULL`.
    #' @param quantity The integer or numeric number of units held, or `NULL`.
    #' @param average_price The numeric average price in rupees the quantity was bought at, or `NULL`.
    #' @return A new `BasketMember` object.
    initialize = function(
      instrument,
      weight = NULL,
      quantity = NULL,
      average_price = NULL
    ) {
      self$instrument <- instrument
      self$weight <- weight
      self$quantity <- quantity
      self$average_price <- average_price
    },

    #' @description
    #' Describes the member as a named list for storing in MongoDB.
    #' @return A named list with the instrument's `instrument_id`, `exchange`, `segment`, `symbol`, `underlying_symbol`, `expiry_date` as `"YYYY-MM-DD"` text, `strike_price` and `option_type`, and the member's `weight`, `quantity` and `average_price`, where a missing value is `NULL`.
    #' @examples
    #' \dontrun{
    #' infosys <- Equity$new(exchange = "nse", symbol = "INFY")
    #' str(BasketMember$new(infosys, weight = 0.05)$document())
    #'
    #' idea <- Equity$new(exchange = "nse", symbol = "IDEA")
    #' member <- BasketMember$new(idea, quantity = 100, average_price = 12.5)
    #' document <- member$document()
    #' cat(document$symbol, document$quantity, document$average_price, "\n")
    #' }
    document = function() {
      instrument <- self$instrument
      expiry_date <- NULL
      if (inherits(instrument$expiry_date, "Date")) {
        expiry_date <- format(instrument$expiry_date, "%Y-%m-%d")
      }
      list(
        instrument_id = instrument$instrument_id,
        exchange = instrument$exchange,
        segment = instrument$segment,
        symbol = instrument$symbol,
        underlying_symbol = instrument$underlying_symbol,
        expiry_date = expiry_date,
        strike_price = instrument$strike_price,
        option_type = instrument$option_type,
        weight = self$weight,
        quantity = self$quantity,
        average_price = self$average_price
      )
    },

    #' @description
    #' Describes the member by its label and whichever of weight, quantity and average price it has.
    #' @param ... Ignored, accepted so that `format()` works.
    #' @return A character value such as `"BasketMember('nse:INFY', weight=0.05)"`.
    format = function(...) {
      described_fields <- sprintf("'%s'", self$label)
      if (!is.null(self$weight)) {
        described_fields <- c(
          described_fields,
          sprintf("weight=%s", private$python_number_text(self$weight))
        )
      }
      if (!is.null(self$quantity)) {
        described_fields <- c(
          described_fields,
          sprintf("quantity=%s", private$python_number_text(self$quantity))
        )
      }
      if (!is.null(self$average_price)) {
        described_fields <- c(
          described_fields,
          sprintf(
            "average_price=%s",
            private$python_number_text(self$average_price)
          )
        )
      }
      sprintf("BasketMember(%s)", paste(described_fields, collapse = ", "))
    },

    #' @description
    #' Prints the description `format()` gives.
    #' @param ... Ignored.
    #' @return The member, invisibly.
    print = function(...) {
      cat(self$format(), "\n", sep = "")
      invisible(self)
    }
  ),
  active = list(
    #' @field label The character readable name of the member, such as `"nse:INFY"` or `"nse:NIFTY 2026-10-27 25000.0CE"`.
    label = function(value) {
      if (!missing(value)) {
        stop("label is read-only", call. = FALSE)
      }
      instrument <- self$instrument
      if (!is.null(instrument$symbol)) {
        return(sprintf("%s:%s", instrument$exchange, instrument$symbol))
      }
      parts <- instrument$underlying_symbol
      if (inherits(instrument$expiry_date, "Date")) {
        parts <- c(
          parts,
          format(instrument$expiry_date, "%Y-%m-%d")
        )
      }
      if (!is.null(instrument$strike_price)) {
        parts <- c(
          parts,
          paste0(
            private$python_number_text(instrument$strike_price),
            instrument$option_type
          )
        )
      }
      sprintf("%s:%s", instrument$exchange, paste(parts, collapse = " "))
    }
  ),
  private = list(
    # Writes a number the way Python's `repr` writes it, so a whole double reads `25000.0` and an integer reads `25000`.
    # @param value A numeric or integer scalar.
    # @return A character value.
    python_number_text = function(value) {
      if (is.integer(value)) {
        return(as.character(value))
      }
      if (is.numeric(value) && is.finite(value) && value == round(value) &&
            abs(value) < 1e16) {
        return(sprintf("%.1f", value))
      }
      format(value, digits = 15)
    }
  )
)
