#' Show what each fixed pricing setting takes from the template and what it overrides.
#'
#' An empty `FixedPricing` keeps the template's own order type and price, giving only a price keeps the template's order type, and giving both overrides it completely. The program prints the three objects with a note on what each sends, so a plan's last order can reuse the template or depart from it. Nothing is sent to UBI.
#'
#' Typical usage example:
#'
#'   Rscript examples/orders/plan_parts/fixed_pricing/fixed_pricing/override_the_template_price.R

library(tradeR)

#' Three fixed pricing rules that override more and more of the template.
#'
#' @field rules The list of named lists, each holding `note`, a character value, and `rule`, a `FixedPricing`.
TemplateOverrides <- R6::R6Class(
  "TemplateOverrides",
  public = list(
    rules = NULL,

    #' @description
    #' Builds the rules.
    #' @return A new `TemplateOverrides` object.
    initialize = function() {
      self$rules <- list(
        list(
          note = "the template's order type and price",
          rule = FixedPricing$new()
        ),
        list(
          note = "the template's order type at 1005",
          rule = FixedPricing$new(price = 1005.0)
        ),
        list(
          note = "a limit at 1005, whatever the template says",
          rule = FixedPricing$new(price = 1005.0, order_type = "LIMIT")
        )
      )
    },

    #' @description
    #' Prints each rule's object, as one line of JSON padded to 52 characters, and what it sends.
    #' @return `NULL`, invisibly.
    run = function() {
      for (entry in self$rules) {
        document <- jsonlite::toJSON(
          entry[["rule"]]$document(),
          auto_unbox = TRUE,
          null = "null",
          digits = NA
        )
        cat(
          sprintf(
            "%-52s sends %s\n",
            as.character(document),
            entry[["note"]]
          )
        )
      }
      invisible(NULL)
    }
  )
)

if (sys.nframe() == 0) {
  TemplateOverrides$new()$run()
}
