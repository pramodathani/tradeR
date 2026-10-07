# R/utilities_time_converter.R

The Python library uses `datetime.date.fromisoformat`, `pd.to_datetime(...).dt.tz_convert("Asia/Kolkata")` and `datetime.now(INDIA_TIME_ZONE)`. Base R parses neither a `+05:30` offset nor a trailing `Z` in one format string, so `epoch_seconds` strips the offset, parses the rest as UTC and subtracts the offset itself. A value with no offset is read as India time, which is what UBI's ticks route assumes for a bare start or end.

Every moment comes back as `POSIXct` with the `Asia/Kolkata` time zone attribute, so printing shows India time as the Python frames do.
