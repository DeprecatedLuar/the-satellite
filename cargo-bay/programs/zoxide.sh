#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing zoxide..."

case "$DISTRO" in
    termux)
        pkg install -y zoxide
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y zoxide ;;
            alpine) sudo apk add zoxide ;;
            arch)   sudo pacman -S --noconfirm zoxide ;;
            rhel)   sudo dnf install -y zoxide ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "zoxide installed"
