#!/usr/bin/env bash
# Essentials: core tools for a productive shell environment
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

# Single source of truth
ESSENTIALS=(curl wget git openssh sensors zoxide ranger micro btop ncdu exa starship)

# Map generic names to distro-specific packages
pkg_name() {
    local pkg="$1"
    case "$FAMILY:$pkg" in
        debian:openssh)  echo "openssh-client openssh-server" ;;
        debian:sensors)  echo "lm-sensors" ;;
        alpine:sensors)  echo "lm-sensors" ;;
        alpine:exa)      echo "eza" ;;
        arch:sensors)    echo "lm_sensors" ;;
        arch:exa)        echo "eza" ;;
        rhel:sensors)    echo "lm_sensors" ;;
        *)               echo "$pkg" ;;
    esac
}

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

# Build package list
PKGS=""
for p in "${ESSENTIALS[@]}"; do
    PKGS="$PKGS $(pkg_name "$p")"
done

action "Installing essentials..."

case "$FAMILY" in
    debian) sudo apt install -y $PKGS ;;
    alpine) sudo apk add $PKGS ;;
    arch)   sudo pacman -S --noconfirm $PKGS ;;
    rhel)   sudo dnf install -y $PKGS ;;
    *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
esac

success "essentials installed"
