#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

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
        case "$FAMILY" in
            alpine)
                # Alpine has nix in community repo - simplest path
                info "Using Alpine package (musl-native)"
                sudo apk add nix

                # Enable and start the daemon
                sudo rc-update add nix-daemon default 2>/dev/null || true
                sudo rc-service nix-daemon start 2>/dev/null || true

                # Add user to nix group
                sudo addgroup "$USER" nix 2>/dev/null || true
                ;;
            *)
                # Use official installer for glibc systems
                # Check for systemd to decide daemon mode
                if pidof systemd &>/dev/null; then
                    info "Using multi-user install (systemd detected)"
                    curl -L https://nixos.org/nix/install | sh -s -- --daemon
                else
                    info "Using single-user install (no systemd)"
                    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
                fi
                ;;
        esac
        ;;
esac

success "Nix installed"
info "Start a new shell or run: . ~/.nix-profile/etc/profile.d/nix.sh"
