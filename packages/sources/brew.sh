#!/usr/bin/env bash
# Install Homebrew
set -e

source <(curl -sSL "${SAT_BASE}/packages/sources/common.sh" | tr -d '\r')

command -v brew &>/dev/null && { _info "brew already installed"; exit 0; }

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")

[[ "$DISTRO" == "termux" ]] && _error "Homebrew not supported on Termux"
[[ "$OS" != "darwin" && "$OS" != "linux" ]] && _error "Homebrew only supports macOS and Linux"

_info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

_success "Homebrew installed"
