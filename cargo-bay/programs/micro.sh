#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing micro..."

case "$DISTRO" in
    termux)
        pkg install -y micro
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y micro ;;
            alpine) sudo apk add micro ;;
            arch)   sudo pacman -S --noconfirm micro ;;
            rhel)   sudo dnf install -y micro ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "micro installed"
