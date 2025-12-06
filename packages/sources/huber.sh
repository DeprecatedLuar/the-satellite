#!/usr/bin/env bash
# Install huber (GitHub release manager)
set -e

source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"

command -v huber &>/dev/null && { _info "huber already installed"; exit 0; }

_info "Installing huber..."

case "$(uname -s)" in
    Linux)  OS="unknown-linux" ;;
    Darwin) OS="apple-darwin" ;;
    *)      _error "Unsupported OS" ;;
esac

case "$(uname -m)" in
    x86_64)        ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    armv7l)        ARCH="arm" ;;
    *)             _error "Unsupported arch" ;;
esac

# Prefer musl on Linux (static binary)
if [[ "$OS" == "unknown-linux" ]]; then
    case "$ARCH" in
        x86_64|aarch64) TARGET="${ARCH}-${OS}-musl" ;;
        arm)            TARGET="${ARCH}-${OS}-musleabihf" ;;
    esac
else
    TARGET="${ARCH}-${OS}"
fi

DEST="${HOME}/.local/bin/huber"
mkdir -p "$(dirname "$DEST")"
curl -sSL "https://github.com/innobead/huber/releases/latest/download/huber-${TARGET}" -o "$DEST"
chmod +x "$DEST"

_success "huber installed"
