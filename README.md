# New Motoko Base Library

> **Work in progress! Please consider providing feedback on the [GitHub discussions page](https://github.com/dfinity/new-motoko-base/discussions)**. 

#### ✨ [Documentation preview](https://dfinity.github.io/new-motoko-base)

---

This repository contains the source code for a revamped [Motoko](https://github.com/dfinity/motoko) base library. 

If you are new to Motoko, the original base library is available [here](https://github.com/dfinity/motoko-base).

## Quick Start

A preview of the new base library is available via the [`new-base`](https://mops.one/new-base) Mops package.

You can quickly try out the new base library by making the following change to your `mops.toml` config file:

```toml
base = "https://github.com/dfinity/new-motoko-base"
```

It's also possible to start using both versions in parallel:

```toml
base = "0.13.7"
new-base = "0.3.0"
```

Since this is a preview release for community feedback, expect breaking changes.
Please report any bugs or inconsistencies by opening a [GitHub issue](https://github.com/dfinity/new-motoko-base/issues). 

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

Code and documentation style guidelines for the repository can be found [here](./STYLEGUIDE.md).

Big thanks to the following community contributors:

* [MR Research AG (A. Stepanov, T. Hanke)](https://github.com/research-ag): [`vector`](https://github.com/research-ag/vector), [`prng`](https://github.com/research-ag/prng)
* [Byron Becker](https://github.com/ByronBecker): [`StableHeapBTreeMap`](https://github.com/canscale/StableHeapBTreeMap)
* [Zen Voich](https://github.com/ZenVoich): [`test`](https://github.com/ZenVoich/test)
