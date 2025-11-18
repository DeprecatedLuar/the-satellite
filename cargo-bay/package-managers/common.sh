#!/bin/bash
# Common package manager interface and dispatcher

# Source all package manager modules
PKGMGR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PKGMGR_DIR/apt.sh"
source "$PKGMGR_DIR/apk.sh"
source "$PKGMGR_DIR/pkg.sh"

# Get packages for a specific category and package manager
get_packages() {
    local category="$1"
    local pkg_mgr="$2"

    case "$pkg_mgr" in
        apt)
            get_apt_packages "$category"
            ;;
        apk)
            get_apk_packages "$category"
            ;;
        pkg)
            get_pkg_packages "$category"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Install packages using the appropriate package manager
install_packages() {
    local pkg_mgr="$1"
    shift
    local packages="$@"

    case "$pkg_mgr" in
        apt)
            install_apt_packages $packages
            ;;
        apk)
            install_apk_packages $packages
            ;;
        pkg)
            install_pkg_packages $packages
            ;;
        *)
            echo "Error: Unsupported package manager: $pkg_mgr"
            return 1
            ;;
    esac
}

# Install Homebrew (macOS/Linux package manager)
install_homebrew() {
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
