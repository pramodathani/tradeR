# R/asset_baskets_exchange_traded_fund_constituents.R

This is the R port of `tradingmachine/asset_baskets/exchange_traded_fund_constituents.py`. The user asked on 2026-09-28 for a way to fold the existing `ExchangeTradedFund` together with the basket. The chosen design keeps them as two classes linked both ways: `ExchangeTradedFund$constituents` returns this basket, and this basket's `fund` is the ETF. The name `...Constituents` avoids clashing with the instrument class's name and says what the class is.

## Premium or discount needs an iNAV row

An ETF's indicative net asset value is published by the exchange, and UBI carries some as index rows with names such as `HANGSENG BEES-NAV`. A search of the nse equity indices on 2026-09-28 found none for NIFTYBEES, so `premium_or_discount` could not be checked live; it returns `NULL` whenever the fund, the iNAV row or either price is missing, or the iNAV price is zero. The iNAV row's id is stored with the basket as `indicative_net_asset_value_instrument_id`.

## Tracking difference

`tracking_difference()` is the fund's cumulative return minus its holdings' over a range. The holdings' return assumes today's weights all through the range, so it drifts from the fund's real history when the fund changed its holdings. It calls `cumulative_return()` on both the fund and the basket, which both inherit from `PerformanceMeasures`. The test drives it with a `FakeClient`: a fund moving from 100 to 110 and holdings moving from 50 to 52 give 0.1 minus 0.04.

## Where the R version differs from Python

| Python | R | Why |
|---|---|---|
| `not net_asset_value` treats `None` and `0` as missing | `is.null(net_asset_value) || net_asset_value == 0` | Same rule written out |
| `document` sets `indicative_net_asset_value_instrument_id` to `None` | Sets the element with `list(NULL)` so the name stays | Assigning `NULL` with `[[` would delete it, and MongoDB must receive an explicit null |
| `fund` property | Active binding returning `linked_instrument` | Project mapping |
