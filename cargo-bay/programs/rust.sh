#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing rust/cargo..."

case "$DISTRO" in
    termux)
        pkg install -y rust
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y cargo ;;
            alpine) sudo apk add cargo rust ;;
            arch)   sudo pacman -S --noconfirm rust ;;
            rhel)   sudo dnf install -y cargo rust ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "rust/cargo installed"
