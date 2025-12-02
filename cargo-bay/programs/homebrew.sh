#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")

action "Installing Homebrew..."

case "$DISTRO" in
    termux)
        error "Homebrew is not supported on Termux"
        ;;
    *)
        case "$OS" in
            darwin|linux)
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                ;;
            *)
                error "Homebrew is only supported on macOS and Linux"
                ;;
        esac
        ;;
esac

success "Homebrew installed"
