#!/usr/bin/env bash
# Install uv (Python package manager)
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

command -v uv &>/dev/null && { _info "uv already installed"; exit 0; }

_info "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

_success "uv installed"
