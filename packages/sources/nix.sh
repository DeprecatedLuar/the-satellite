#!/usr/bin/env bash
# Install Nix
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

command -v nix &>/dev/null && { _info "nix already installed"; exit 0; }

DISTRO=$(detect_distro "$(detect_os)")
FAMILY=$(detect_distro_family "$DISTRO")

[[ "$DISTRO" == "termux" ]] && _error "Nix not supported on Termux"

# Alpine needs coreutils (BusyBox lacks GNU cp options)
[[ "$FAMILY" == "alpine" ]] && { _info "Installing coreutils..."; sudo apk add coreutils; }

_info "Installing Nix..."
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

_success "Nix installed"
_info "Run: . ~/.nix-profile/etc/profile.d/nix.sh"
