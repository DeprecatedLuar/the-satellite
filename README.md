# the-satellite

Hi, basically if you found this probably was from a install line of one of my tools. 

The satellite is a repo with a ton of remote execution utilities but most important it has an installation pipeline so I dont have to make nor update install scripts on my tools basically.

## What it is

Satellite sits between my CLI tools and GitHub releases, handling:

- **Version checking** — querying GitHub for the latest release/tag
- **Installer delivery** — serving and executing `install.sh` scripts
- **Package management** — managing packages and cargo-bay sources


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
