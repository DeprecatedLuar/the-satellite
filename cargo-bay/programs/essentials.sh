#!/usr/bin/env bash
# Essentials: core tools for a productive shell environment

SAT_BASE="https://raw.githubusercontent.com/DeprecatedLuar/the-satellite/main"

ESSENTIALS=(
    curl
    wget
    git
    zoxide
    ranger
    micro
    btop
    ncdu
    exa
    starship
)

for prog in "${ESSENTIALS[@]}"; do
    WRAPPER_URL="$SAT_BASE/cargo-bay/programs/${prog}.sh"
    curl -sSL "$WRAPPER_URL" | bash
done
