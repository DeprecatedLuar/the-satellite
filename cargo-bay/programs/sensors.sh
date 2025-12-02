#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing lm-sensors..."

case "$DISTRO" in
    termux)
        warn "lm-sensors not available on Termux"
        exit 0
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y lm-sensors ;;
            alpine) sudo apk add lm-sensors ;;
            arch)   sudo pacman -S --noconfirm lm_sensors ;;
            rhel)   sudo dnf install -y lm_sensors ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "lm-sensors installed"
info "Run: sudo sensors-detect"
