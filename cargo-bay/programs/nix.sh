#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")

# Check if already installed
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
        # Use official installer - handles channels and setup properly
        # Check for actual systemd init (not just any systemd process)
        if [[ -d /run/systemd/system ]]; then
            info "Multi-user install (systemd)"
            curl -L https://nixos.org/nix/install | sh -s -- --daemon
        else
            info "Single-user install (no systemd)"
            curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
        fi
        ;;
esac

success "Nix installed"
info "Start a new shell or run: . ~/.nix-profile/etc/profile.d/nix.sh"
