#!/usr/bin/env bash
# Install Homebrew
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

command -v brew &>/dev/null && { _info "brew already installed"; exit 0; }

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")

[[ "$DISTRO" == "termux" ]] && _error "Homebrew not supported on Termux"
[[ "$OS" != "darwin" && "$OS" != "linux" ]] && _error "Homebrew only supports macOS and Linux"

_info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

_success "Homebrew installed"
