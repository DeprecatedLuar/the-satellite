#!/usr/bin/env bash
# Install uv (Python package manager)
set -e

source <(curl -sSL "${SAT_BASE}/packages/sources/common.sh" | tr -d '\r')

command -v uv &>/dev/null && { _info "uv already installed"; exit 0; }

_info "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

_success "uv installed"
