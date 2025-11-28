#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing zerotier-one..."

case "$DISTRO" in
    termux)
        pkg install -y zerotier-one
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y zerotier-one ;;
            alpine)
                warn "zerotier-one not available in Alpine repos"
                info "Must compile from source: https://github.com/zerotier/ZeroTierOne"
                exit 1
                ;;
            arch)   sudo pacman -S --noconfirm zerotier-one ;;
            rhel)   sudo dnf install -y zerotier-one ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "zerotier-one installed"
