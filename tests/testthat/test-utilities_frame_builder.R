test_that("rows become columns in first-seen order with missing values as NA", {
  frame <- FrameBuilder$new()$frame(
    list(
      list(
        symbol = "INFY",
        quantity = 10
      ),
      list(
        symbol = "TCS",
        quantity = NULL,
        extra = TRUE
      )
    )
  )

  expect_equal(
    names(frame),
    c(
      "symbol",
      "quantity",
      "extra"
    )
  )
  expect_equal(
    frame$quantity,
    c(
      10,
      NA
    )
  )
  expect_equal(
    frame$extra,
    c(
      NA,
      TRUE
    )
  )
})

test_that("nested objects become list columns that round-trip through row()", {
  builder <- FrameBuilder$new()
  frame <- builder$frame(
    list(
      list(
        product = "intraday",
        pnl = list(
          realized = 5
        )
      ),
      list(
        product = "carry",
        pnl = list(
          realized = 7
        )
      )
    )
  )

  expect_type(frame$pnl, "list")
  expect_equal(frame$pnl[[2]]$realized, 7)
  expect_equal(builder$row(frame, 1)$pnl$realized, 5)
  expect_length(builder$rows(frame), 2)
})

test_that("no rows give NULL", {
  builder <- FrameBuilder$new()

  expect_null(builder$frame(list()))
  expect_null(builder$frame(NULL))
  expect_equal(builder$rows(NULL), list())
})
