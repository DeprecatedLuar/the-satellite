#!/usr/bin/env bash
# Essentials: core tools for a productive shell environment
set -e

# Cache sudo/doas credentials upfront
if command -v doas &>/dev/null; then
    doas true
elif command -v sudo &>/dev/null; then
    sudo -v
fi

# Bootstrap fetcher
eval "$(curl -sSL https://raw.githubusercontent.com/DeprecatedLuar/the-satellite/main/internal/fetcher.sh)"
sat_init

# Install essentials
sat_run_all \
    curl \
    wget \
    git \
    openssh \
    sensors \
    zoxide \
    ranger \
    micro \
    btop \
    ncdu \
    exa \
    starship
