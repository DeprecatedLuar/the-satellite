#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing visidata..."

case "$DISTRO" in
    termux)
        pkg install -y visidata
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y visidata ;;
            alpine) sudo apk add visidata ;;
            arch)   sudo pacman -S --noconfirm visidata ;;
            rhel)   sudo dnf install -y visidata ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "visidata installed"
