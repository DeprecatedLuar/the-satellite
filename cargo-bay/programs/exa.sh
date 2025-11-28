#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing exa..."

case "$DISTRO" in
    termux)
        pkg install -y exa
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y exa ;;
            alpine) sudo apk add exa ;;
            arch)   sudo pacman -S --noconfirm exa ;;
            rhel)   sudo dnf install -y exa ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "exa installed"
