#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing openssh..."

case "$DISTRO" in
    termux)
        pkg install -y openssh
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y openssh-client openssh-server ;;
            alpine) sudo apk add openssh openssh-client ;;
            arch)   sudo pacman -S --noconfirm openssh ;;
            rhel)   sudo dnf install -y openssh openssh-clients openssh-server ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "openssh installed"
