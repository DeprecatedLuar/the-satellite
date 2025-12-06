#!/usr/bin/env bash
# Install Rust/Cargo via rustup
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

command -v cargo &>/dev/null && { _info "cargo already installed"; exit 0; }

_info "Installing Rust via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

_success "Rust/Cargo installed"
_info "Run: source ~/.cargo/env"
