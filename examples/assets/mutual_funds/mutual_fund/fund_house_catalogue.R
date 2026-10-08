#' Count the mutual fund schemes UBI carries for several fund houses, and check which of them this account holds.
#'
#' A scheme's symbol is its exchange code, which starts with a prefix naming the fund house, such as `ABSL`. The program searches for each of a few prefixes, prints how many schemes each returns and the first few codes, and then builds every scheme of the first fund house to see whether this account holds any of it.
#'
#' Typical usage example:
#'
#'   Rscript examples/assets/mutual_funds/mutual_fund/fund_house_catalogue.R

library(tradeR)

#' A count of schemes by fund house prefix.
#'
#' @field prefixes The character vector of fund house prefixes to search for.
#' @field shown_codes The integer number of scheme codes printed for each prefix.
FundHouseCatalogue <- R6::R6Class(
  "FundHouseCatalogue",
  public = list(
    prefixes = NULL,
    shown_codes = NULL,

    #' @description
    #' Sets the prefixes to search for.
    #' @return A new `FundHouseCatalogue` object.
    initialize = function() {
      self$prefixes <- c(
        "ABSL",
        "HDFC",
        "SBI",
        "ICICI",
        "AXIS",
        "KOTAK"
      )
      self$shown_codes <- 4
    },

    #' @description
    #' Prints the count and first codes for each prefix, then the first house's holdings.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    run = function() {
      total <- 0
      for (prefix in self$prefixes) {
        matches <- MutualFund$search(
          exchange = "nse",
          term = prefix,
          limit = 200
        )
        if (is.null(matches)) {
          cat(sprintf("%-6s no schemes\n", prefix))
          next
        }
        total <- total + nrow(matches)
        first_codes <- head(matches$symbol, self$shown_codes)
        cat(sprintf(
          "%-6s %3d schemes, such as %s\n",
          prefix,
          nrow(matches),
          jsonlite::toJSON(first_codes)
        ))
      }
      cat(sprintf("Schemes found across these prefixes: %d\n", total))
      private$print_held_schemes(self$prefixes[1])
      invisible(NULL)
    }
  ),
  private = list(
    #' @description
    #' Builds every scheme of one fund house and prints the ones this account holds.
    #' @param prefix The character fund house prefix to check.
    #' @return `NULL`, invisibly.
    #' @details Errors: signals a `UnifiedBrokerInterfaceError` subclass when UBI could not be reached or refused the request.
    print_held_schemes = function(prefix) {
      matches <- MutualFund$search(
        exchange = "nse",
        term = prefix,
        limit = 200
      )
      if (is.null(matches)) {
        return(invisible(NULL))
      }
      held_count <- 0
      for (symbol in matches$symbol) {
        fund <- MutualFund$new(exchange = "nse", symbol = symbol)
        row <- fund$holdings
        if (!is.null(row)) {
          held_count <- held_count + 1
          cat(sprintf(
            "Held: %s, %s units\n",
            symbol,
            format(row[["quantity"]])
          ))
        }
      }
      cat(sprintf(
        "%d of the %d %s schemes are held.\n",
        held_count,
        nrow(matches),
        prefix
      ))
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  FundHouseCatalogue$new()$run()
}
