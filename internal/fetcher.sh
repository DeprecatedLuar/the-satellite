#!/usr/bin/env bash
# Lightweight fetcher - downloads only what's needed

SAT_REMOTE="https://raw.githubusercontent.com/DeprecatedLuar/the-satellite/main"

# Core dependencies every wrapper needs
SAT_CORE=(
    internal/messages.sh
    internal/os_detection.sh
)

# Setup temp dir and fetch core deps
sat_init() {
    SAT_DIR=$(mktemp -d)
    trap "rm -rf $SAT_DIR" EXIT

    mkdir -p "$SAT_DIR/internal" "$SAT_DIR/cargo-bay/programs"

    for file in "${SAT_CORE[@]}"; do
        curl -sSL "$SAT_REMOTE/$file" -o "$SAT_DIR/$file"
    done
}

# Fetch and run a program wrapper
sat_run() {
    local prog="$1"
    local wrapper="cargo-bay/programs/${prog}.sh"

    curl -sSL "$SAT_REMOTE/$wrapper" -o "$SAT_DIR/$wrapper"
    bash "$SAT_DIR/$wrapper"
}

# Fetch and run multiple programs
sat_run_all() {
    for prog in "$@"; do
        sat_run "$prog"
    done
}
