# New Motoko Base Library

> **Work in progress! Please consider providing feedback on the [GitHub discussions page](https://github.com/dfinity/new-motoko-base/discussions)**. 

#### ✨ [Documentation preview](https://dfinity.github.io/new-motoko-base)

---

This repository contains the source code for a revamped [Motoko](https://github.com/dfinity/motoko) base library. 

If you are new to Motoko, the original base library is available [here](https://github.com/dfinity/motoko-base).

## Quick Start

A preview of the new base library is available as a [Mops package](https://mops.one/new-base).
Try it out with the following change to your `mops.toml` config file:

```toml
base = "new-base"
```

## Local Environment

Run the following commands to configure your local development branch:

```sh
# First-time setup
git clone https://github.com/dfinity/new-motoko-base
cd new-motoko-base
npm ci

# Run code formatter
npm run format
```

## Documentation

It's possible to generate a documentation preview by running the following command:

```sh
npm run docs
```

We automatically generate previews for each pull request.

## Contributing

PRs are welcome! Please check out the [contributor guidelines](.github/CONTRIBUTING.md) for more information.
