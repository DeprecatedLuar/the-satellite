#!/bin/bash
# APK package manager (Alpine Linux)

setup_apk_repos() {
    echo "Setting up APK repositories..."

    local alpine_version
    alpine_version=$(cat /etc/alpine-release | cut -d'.' -f1,2)

    # Enable community repository (essential for many packages)
    if ! grep -q "community" /etc/apk/repositories 2>/dev/null; then
        echo "Enabling community repository..."
        echo "http://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/community" | sudo tee -a /etc/apk/repositories >/dev/null
    fi

    # Enable edge repository (optional - latest packages, potentially unstable)
    if ! grep -q "edge/main" /etc/apk/repositories 2>/dev/null; then
        echo "Enabling edge/main repository..."
        echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" | sudo tee -a /etc/apk/repositories >/dev/null
    fi

    if ! grep -q "edge/community" /etc/apk/repositories 2>/dev/null; then
        echo "Enabling edge/community repository..."
        echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | sudo tee -a /etc/apk/repositories >/dev/null
    fi

    # Enable testing repository (optional - pre-release packages)
    if ! grep -q "edge/testing" /etc/apk/repositories 2>/dev/null; then
        echo "Enabling edge/testing repository..."
        echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" | sudo tee -a /etc/apk/repositories >/dev/null
    fi

    # Update package index
    sudo apk update
}

get_apk_packages() {
    local category="$1"

    case "$category" in
        universal)
            # Note: zerotier-one not available in Alpine repos (must compile from source)
            echo "curl wget git zoxide ranger micro visidata starship ncdu btop exa"
            ;;
        dev-tools)
            echo "go nodejs"
            ;;
    esac
}

install_apk_packages() {
    local packages="$@"

    setup_apk_repos

    for package in $packages; do
        echo "Installing $package..."
        sudo apk add --no-interactive "$package" || echo "Failed - skipping"
    done
}
