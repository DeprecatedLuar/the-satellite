#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing git..."

case "$DISTRO" in
    termux)
        pkg install -y git
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y git ;;
            alpine) sudo apk add git ;;
            arch)   sudo pacman -S --noconfirm git ;;
            rhel)   sudo dnf install -y git ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "git installed"
