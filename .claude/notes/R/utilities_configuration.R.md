# R/utilities_configuration.R

Port of `src/tradingmachine/utilities/configuration.py`.

## Same variable names as the Python library

The environment variables keep their `TRADINGMACHINE_` prefix rather than being renamed for this package. Both projects then read one `.env` file and talk to one MongoDB, so the UBI credentials in its `settings` collection and the baskets in its `asset_baskets` collection are shared, and a basket saved from Python can be loaded from R.

## The environment wins over the file

Python's `dotenv.load_dotenv` leaves a variable that is already set alone. The R `dotenv::load_dot_env` overwrites it, so `ensure_environment_file_loaded` records the whole environment first, loads the file, and then sets every recorded variable back. Only variables that were not set before therefore come from the file, as in Python. A missing file is skipped silently, as `load_dotenv` does.

## The connection string with a missing host

Python builds the URI with an f-string, so a missing host or port appears as the text `None`. `text_or_none` keeps that, so the two libraries fail with the same message when MongoDB is not configured.
