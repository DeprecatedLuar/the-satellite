#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing btop..."

case "$DISTRO" in
    termux)
        pkg install -y btop
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y btop ;;
            alpine) sudo apk add btop ;;
            arch)   sudo pacman -S --noconfirm btop ;;
            rhel)   sudo dnf install -y btop ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "btop installed"
