#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing ranger..."

case "$DISTRO" in
    termux)
        pkg install -y ranger
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y ranger ;;
            alpine) sudo apk add ranger ;;
            arch)   sudo pacman -S --noconfirm ranger ;;
            rhel)   sudo dnf install -y ranger ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "ranger installed"
