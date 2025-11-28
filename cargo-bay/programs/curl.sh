#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing curl..."

case "$DISTRO" in
    termux)
        pkg install -y curl
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y curl ;;
            alpine) sudo apk add curl ;;
            arch)   sudo pacman -S --noconfirm curl ;;
            rhel)   sudo dnf install -y curl ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "curl installed"
