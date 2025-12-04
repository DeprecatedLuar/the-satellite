#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

DISTRO=$(detect_distro "$(detect_os)")

if command -v nix &>/dev/null; then
    info "Nix is already installed: $(nix --version)"
    exit 0
fi

action "Installing Nix..."

case "$DISTRO" in
    termux)
        error "Nix is not supported on Termux"
        ;;
    *)
        curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
        ;;
esac

success "Nix installed"
info "Run: . ~/.nix-profile/etc/profile.d/nix.sh"
