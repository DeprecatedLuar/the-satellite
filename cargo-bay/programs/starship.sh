#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing starship..."

case "$DISTRO" in
    termux)
        pkg install -y starship
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y starship ;;
            alpine) sudo apk add starship ;;
            arch)   sudo pacman -S --noconfirm starship ;;
            rhel)   sudo dnf install -y starship ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "starship installed"
