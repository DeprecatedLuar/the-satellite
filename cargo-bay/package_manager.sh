#!/bin/bash
# Package management for different systems

# Package definitions per manager
get_packages() {
    local category="$1"
    local pkg_mgr="$2"

    case "$pkg_mgr" in
        apt)
            case "$category" in
                universal)
                    echo "curl wget git zoxide ranger micro visidata starship ncdu btop"
                    ;;
                dev-tools)
                    echo "golang-go nodejs"
                    ;;
            esac
            ;;
        apk)
            case "$category" in
                universal)
                    echo "curl wget git zoxide ranger micro visidata starship ncdu btop"
                    ;;
                dev-tools)
                    echo "go nodejs"
                    ;;
            esac
            ;;
        pkg)
            case "$category" in
                universal)
                    echo "termux-tools git curl wget openssh zoxide ranger micro visidata starship ncdu btop"
                    ;;
                dev-tools)
                    echo "nodejs-lts python golang"
                    ;;
            esac
            ;;
    esac
}

# Install packages using appropriate package manager
install_packages() {
    local pkg_mgr="$1"
    shift
    local packages="$@"

    case "$pkg_mgr" in
        apt)
            for package in $packages; do
                echo "Installing $package..."
                sudo apt install -y "$package" || echo "Failed - skipping"
            done
            ;;
        apk)
            for package in $packages; do
                echo "Installing $package..."
                sudo apk add --no-interactive "$package" || echo "Failed - skipping"
            done
            ;;
        pkg)
            for package in $packages; do
                echo "Installing $package..."
                pkg install -y "$package" || echo "Failed - skipping"
            done
            ;;
        *)
            echo "Error: Unsupported package manager: $pkg_mgr"
            return 1
            ;;
    esac
}
