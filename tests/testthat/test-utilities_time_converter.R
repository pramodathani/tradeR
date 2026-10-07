test_that("moments with any offset come back as the same India time", {
  converter <- TimeConverter$new()
  moments <- converter$moments(
    c(
      "2026-09-29T09:15:00+05:30",
      "2026-09-29T03:45:00Z",
      "2026-09-29T03:45:00.000+00:00",
      "2026-09-29 09:15",
      NA
    )
  )

  expect_equal(attr(moments, "tzone"), "Asia/Kolkata")
  expect_equal(
    format(moments[1:4], "%Y-%m-%d %H:%M:%S"),
    rep("2026-09-29 09:15:00", 4)
  )
  expect_true(is.na(moments[[5]]))
})

test_that("dates parse, keep missing values missing and refuse bad text", {
  converter <- TimeConverter$new()

  expect_equal(converter$date("2026-10-28"), as.Date("2026-10-28"))
  expect_null(converter$date(NULL))
  expect_equal(
    converter$dates(
      c(
        "2026-10-28",
        NA,
        ""
      )
    ),
    as.Date(
      c(
        "2026-10-28",
        NA,
        NA
      )
    )
  )
  expect_error(converter$date("28/10/2026"), "Invalid isoformat")
})

test_that("an expiry moment is 15:30 in India", {
  moment <- TimeConverter$new()$moment_on(as.Date("2026-10-28"), "15:30")

  expect_equal(as.numeric(moment), as.numeric(as.POSIXct("2026-10-28 10:00:00", tz = "UTC")))
})
