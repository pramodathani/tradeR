# Get started

This section takes you from an empty machine to an R session that looks
up a share, reads its prices and rehearses an order. It is written for
someone who wants to use the package, and it assumes no knowledge of how
the package is built inside.

The package does not talk to brokers itself. Every price and every order
goes through the Unified Broker Interface (UBI), the sibling project
that runs on the same machine and speaks to ten Indian brokers. So
getting started means two things: installing this package, and having a
UBI it can reach.

## What you need before you start

The table below lists what the machine needs, and why each piece is
there.

| You need | Why |
|----|----|
| R 4.3 or later | `DESCRIPTION` requires it, and the package was developed on R 4.6.1 |
| The system libraries for curl, OpenSSL, SASL and libuv, and CMake | `httr2`, `mongolite` and the development tools compile against the libraries, and the `talib` package builds its bundled TA-Lib C library with CMake |
| A MongoDB the package can reach | It holds UBI’s api key and secret and the stored asset baskets; the Python library’s `docker-compose.yml` runs one on port 2003 |
| A running UBI on `127.0.0.1:8080` | Every candle, quote and order comes from it |
| UBI’s order engine running | UBI places every order through it, and refuses orders while it is stopped |
| UBI’s api key and secret | The client logs in with them, reading them from the project’s MongoDB |

**UBI trades with real money.**

UBI is connected to live broker accounts, and there is no paper trading
mode. Nothing in this section places an order: the one order in [First
steps](https://pramodathani.github.io/tradeR/articles/get-started-first-steps.md)
is a dry run, which UBI builds and hands back without sending.

## The path through this section

Setting up happens in a fixed order, because each step needs the one
before it. The numbered list below is that order.

1.  **Install the software.** You install the system libraries, install
    the R packages the package imports, install the package itself, and
    make sure MongoDB is running. This is on
    [Installation](https://pramodathani.github.io/tradeR/articles/get-started-installation.md).
2.  **Configure it.** You write the `.env` file that says where UBI and
    MongoDB are, and put UBI’s api key and secret into MongoDB. This is
    on
    [Configuration](https://pramodathani.github.io/tradeR/articles/get-started-configuration.md).
3.  **Use it.** You look up a share, read its candles and quote, search
    for instruments, read an option chain and rehearse an order. This is
    on [First
    steps](https://pramodathani.github.io/tradeR/articles/get-started-first-steps.md).

The diagram below shows the same path, with the place each step writes
to or reads from.

``` mermaid

flowchart LR
    A["System libraries<br/>and CMake"] --> B["install.packages and<br/>devtools::install()"]
    B --> C["MongoDB from<br/>docker compose up -d"]
    C --> D[".env and the<br/>MongoDB settings document"]
    D --> E["UBI and its<br/>order engine running"]
    E --> F["First steps<br/>in R"]
    C -.-> MG[("MongoDB<br/>port 2003")]
    D -.-> MG
    F -.-> U["UBI<br/>127.0.0.1:8080"]
    F -.-> MG
```

## The pages

The list below names each page of this section and what it covers.

- **[Installation](https://pramodathani.github.io/tradeR/articles/get-started-installation.md)**
  covers the system libraries, the R packages the package imports, the
  install from the repository root, the MongoDB container and its port,
  and the UBI this package needs.
- **[Configuration](https://pramodathani.github.io/tradeR/articles/get-started-configuration.md)**
  covers every environment variable the code and the containers read,
  the MongoDB document holding UBI’s key and secret, where stored
  baskets are kept, and why the order engine needs no configuration
  here.
- **[First
  steps](https://pramodathani.github.io/tradeR/articles/get-started-first-steps.md)**
  is a first session: a share, its candles and quote, a search, an
  option chain and a dry-run order.
- **[The R API
  guide](https://pramodathani.github.io/tradeR/articles/guide.md)**
  covers every class and member, one page per group, in the style of a
  broker’s API reference.
