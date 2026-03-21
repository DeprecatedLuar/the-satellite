# the-satellite

The remote backend powering update checks and binary distribution for my CLI tools.

## What it is

Satellite sits between my CLI tools and GitHub releases, handling:

- **Version checking** — querying GitHub for the latest release/tag
- **Installer delivery** — serving and executing `install.sh` scripts
- **Package management** — managing packages and cargo-bay sources

It's not something you install manually — it's the infrastructure my tools talk to under the hood.

## Structure

```
satellite.sh      # Core script (entry point)
the-lib/          # Go library for wiring Satellite into my CLI tools
packages/         # Package source definitions
cargo-bay/        # Package manager integrations and workspace init
```

## Integration

If you want to use Satellite in your own CLI tool, grab the Go library:

```bash
go get github.com/DeprecatedLuar/the-satellite/the-lib
```

See [`the-lib/README.md`](./the-lib/README.md) for full API docs and usage examples.
