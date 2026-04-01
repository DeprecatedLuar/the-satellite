#!/usr/bin/env bash
# Install GitHub CLI (gh)
set -e

source <(curl -sSL "${SAT_BASE}/packages/sources/common.sh" | tr -d '\r')

command -v gh &>/dev/null && { _info "gh already installed"; exit 0; }

_info "Installing GitHub CLI..."

case "$(uname -s)" in
    Linux)  OS="linux" ;;
    Darwin) OS="macOS" ;;
    *)      _error "Unsupported OS" ;;
esac

case "$(uname -m)" in
    x86_64)        ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)             _error "Unsupported arch" ;;
esac

VERSION=$(curl -sSL "https://api.github.com/repos/cli/cli/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
[[ -z "$VERSION" ]] && _error "Failed to fetch latest gh version"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

if [[ "$OS" == "linux" ]]; then
    curl -sSL "https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_linux_${ARCH}.tar.gz" \
        | tar xz -C "$TMPDIR" --strip-components=1
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$TMPDIR/bin/gh" "$HOME/.local/bin/gh"
else
    curl -sSL "https://github.com/cli/cli/releases/download/v${VERSION}/gh_${VERSION}_macOS_${ARCH}.zip" \
        -o "$TMPDIR/gh.zip"
    unzip -q "$TMPDIR/gh.zip" -d "$TMPDIR"
    mkdir -p "$HOME/.local/bin"
    install -m 0755 "$TMPDIR/gh_${VERSION}_macOS_${ARCH}/bin/gh" "$HOME/.local/bin/gh"
fi

_success "gh installed"
_info "Run: gh auth login"
