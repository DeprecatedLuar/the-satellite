#!/usr/bin/env bash
# Dev-tools: programming languages and build tools
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

DEV_TOOLS=(go nodejs rust)

# Map generic names to distro-specific packages
pkg_name() {
    local pkg="$1"
    # Normalize cargo -> rust
    [[ "$pkg" == "cargo" ]] && pkg="rust"

    case "$DISTRO:$pkg" in
        termux:go)      echo "golang" ;;
        termux:nodejs)  echo "nodejs-lts" ;;
        termux:rust)    echo "rust" ;;
        *)
            case "$FAMILY:$pkg" in
                debian:go)      echo "golang-go" ;;
                debian:nodejs)  echo "nodejs npm" ;;
                debian:rust)    echo "cargo rust" ;;
                alpine:go)      echo "go" ;;
                alpine:nodejs)  echo "nodejs npm" ;;
                alpine:rust)    echo "cargo rust" ;;
                arch:go)        echo "go" ;;
                arch:nodejs)    echo "nodejs npm" ;;
                arch:rust)      echo "rust cargo" ;;
                rhel:go)        echo "golang" ;;
                rhel:nodejs)    echo "nodejs" ;;
                rhel:rust)      echo "cargo rust" ;;
                *)              echo "$pkg" ;;
            esac
            ;;
    esac
}

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

# Build package list
PKGS=""
for p in "${DEV_TOOLS[@]}"; do
    PKGS="$PKGS $(pkg_name "$p")"
done

action "Installing dev-tools..."

case "$DISTRO" in
    termux) pkg install -y $PKGS ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y $PKGS ;;
            alpine) sudo apk add $PKGS ;;
            arch)   sudo pacman -S --noconfirm $PKGS ;;
            rhel)   sudo dnf install -y $PKGS ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "dev-tools installed"
