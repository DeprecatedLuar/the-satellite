#!/usr/bin/env bash
# Essentials: core tools for a productive shell environment
set -e

# Bootstrap fetcher
eval "$(curl -sSL https://raw.githubusercontent.com/DeprecatedLuar/the-satellite/main/internal/fetcher.sh)"
sat_init

# Install essentials
sat_run_all \
    curl \
    wget \
    git \
    openssh \
    zoxide \
    ranger \
    micro \
    btop \
    ncdu \
    exa \
    starship
