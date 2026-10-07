FakeMongoIterator <- R6::R6Class(
  "FakeMongoIterator",
  public = list(
    documents = list(),
    position = 0,

    initialize = function(documents) {
      self$documents <- documents
    },

    one = function() {
      if (self$position >= length(self$documents)) {
        return(NULL)
      }
      self$position <- self$position + 1
      self$documents[[self$position]]
    }
  )
)

FakeMongoCollection <- R6::R6Class(
  "FakeMongoCollection",
  public = list(
    documents = list(),
    calls = list(),

    run = function(command = "{\"ping\": 1}", simplify = TRUE) {
      self$record("run", list(command = command))
      list(ok = 1)
    },

    replace = function(query, update = "{}", upsert = FALSE) {
      self$record(
        "replace",
        list(
          query = query,
          update = update,
          upsert = upsert
        )
      )
      parsed_query <- self$parse(query)
      replacement <- self$parse(update)
      for (index in seq_along(self$documents)) {
        if (self$matches(self$documents[[index]], parsed_query)) {
          self$documents[[index]] <- replacement
          return(list(modifiedCount = 1L, matchedCount = 1L, upsertedCount = 0L))
        }
      }
      if (upsert) {
        self$documents[[length(self$documents) + 1]] <- replacement
        return(list(modifiedCount = 0L, matchedCount = 0L, upsertedCount = 1L))
      }
      list(modifiedCount = 0L, matchedCount = 0L, upsertedCount = 0L)
    },

    iterate = function(
      query = "{}",
      fields = "{\"_id\":0}",
      sort = "{}",
      skip = 0,
      limit = 0
    ) {
      self$record(
        "iterate",
        list(
          query = query,
          sort = sort,
          limit = limit
        )
      )
      found <- self$find_matching(query)
      sort_keys <- self$parse(sort)
      if (length(sort_keys) > 0 && length(found) > 0) {
        key <- names(sort_keys)[[1]]
        values <- character(0)
        for (document in found) {
          values <- c(
            values,
            as.character(document[[key]])
          )
        }
        found <- found[order(
          values,
          decreasing = sort_keys[[key]] < 0,
          method = "radix"
        )]
      }
      if (limit > 0 && length(found) > limit) {
        found <- found[seq_len(limit)]
      }
      FakeMongoIterator$new(found)
    },

    distinct = function(key, query = "{}") {
      self$record(
        "distinct",
        list(
          key = key,
          query = query
        )
      )
      values <- character(0)
      for (document in self$find_matching(query)) {
        values <- unique(c(
          values,
          document[[key]]
        ))
      }
      values
    },

    count = function(query = "{}") {
      self$record("count", list(query = query))
      length(self$find_matching(query))
    },

    remove = function(query, just_one = FALSE) {
      self$record(
        "remove",
        list(
          query = query,
          just_one = just_one
        )
      )
      parsed_query <- self$parse(query)
      kept <- list()
      removed <- 0
      for (document in self$documents) {
        removing <- self$matches(document, parsed_query) &&
          (!just_one || removed == 0)
        if (removing) {
          removed <- removed + 1
        } else {
          kept[[length(kept) + 1]] <- document
        }
      }
      self$documents <- kept
      invisible(TRUE)
    },

    record = function(method, arguments) {
      self$calls[[length(self$calls) + 1]] <- c(
        list(method = method),
        arguments
      )
      invisible(NULL)
    },

    calls_named = function(method) {
      matching <- list()
      for (call in self$calls) {
        if (call$method == method) {
          matching[[length(matching) + 1]] <- call
        }
      }
      matching
    },

    parse = function(json) {
      parsed <- jsonlite::fromJSON(json, simplifyVector = FALSE)
      self$with_dates(parsed)
    },

    with_dates = function(value) {
      if (is.list(value)) {
        if (identical(names(value), "$date")) {
          return(
            as.POSIXct(
              as.numeric(value[["$date"]]) / 1000,
              origin = "1970-01-01",
              tz = "UTC"
            )
          )
        }
        for (index in seq_along(value)) {
          element <- value[[index]]
          if (!is.null(element)) {
            value[[index]] <- self$with_dates(element)
          }
        }
      }
      value
    },

    find_matching = function(query) {
      parsed_query <- self$parse(query)
      found <- list()
      for (document in self$documents) {
        if (self$matches(document, parsed_query)) {
          found[[length(found) + 1]] <- document
        }
      }
      found
    },

    matches = function(document, parsed_query) {
      for (field in names(parsed_query)) {
        condition <- parsed_query[[field]]
        value <- document[[field]]
        if (is.list(condition) && identical(names(condition), "$lte")) {
          if (is.null(value) || !(value <= condition[["$lte"]])) {
            return(FALSE)
          }
        } else if (is.null(value) || !identical(value, condition)) {
          return(FALSE)
        }
      }
      TRUE
    }
  )
)
