#!/bin/bash
# PKG package manager (Termux)

setup_pkg_repos() {
    echo "Setting up Termux repositories..."

    # Enable TUR (Termux User Repository) - essential for many community packages
    if ! pkg list-installed 2>/dev/null | grep -q "tur-repo"; then
        echo "Enabling TUR (Termux User Repository)..."
        pkg install -y tur-repo || echo "Warning: Failed to setup TUR"
    fi

    # Enable X11 repository - for GUI applications
    if ! pkg list-installed 2>/dev/null | grep -q "x11-repo"; then
        echo "Enabling X11 repository..."
        pkg install -y x11-repo || echo "Warning: Failed to setup X11 repo"
    fi

    # Enable Root repository - for root-specific tools (if device is rooted)
    if ! pkg list-installed 2>/dev/null | grep -q "root-repo"; then
        echo "Enabling Root repository..."
        pkg install -y root-repo || echo "Warning: Failed to setup Root repo (device may not be rooted)"
    fi

    # Update package lists
    pkg update -y 2>/dev/null || true
}

get_pkg_packages() {
    local category="$1"

    case "$category" in
        universal)
            echo "termux-tools git curl wget openssh zoxide ranger micro visidata starship ncdu btop zerotier-one exa"
            ;;
        dev-tools)
            echo "nodejs-lts python golang rust"
            ;;
    esac
}

install_pkg_packages() {
    local packages="$@"

    setup_pkg_repos

    for package in $packages; do
        echo "Installing $package..."
        pkg install -y "$package" || echo "Failed - skipping"
    done
}
