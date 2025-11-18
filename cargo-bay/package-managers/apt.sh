#!/bin/bash
# APT package manager (Debian/Ubuntu/derivatives)

setup_apt_repos() {
    echo "Setting up APT repositories..."

    # Enable universe and multiverse on Ubuntu (if not already enabled)
    if command -v add-apt-repository &>/dev/null; then
        if ! grep -q "^deb.*universe" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            echo "Enabling universe repository..."
            sudo add-apt-repository -y universe
        fi

        if ! grep -q "^deb.*multiverse" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
            echo "Enabling multiverse repository..."
            sudo add-apt-repository -y multiverse
        fi
    fi

    # Update package lists
    sudo apt update -qq
}

get_apt_packages() {
    local category="$1"

    case "$category" in
        universal)
            echo "curl wget git zoxide ranger micro visidata starship ncdu btop zerotier-one exa"
            ;;
        dev-tools)
            echo "golang-go nodejs"
            ;;
    esac
}

install_apt_packages() {
    local packages="$@"

    setup_apt_repos

    for package in $packages; do
        echo "Installing $package..."
        sudo apt install -y "$package" || echo "Failed - skipping"
    done
}
