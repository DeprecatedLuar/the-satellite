#!/usr/bin/env bash

set -e

# Bootstrap: If piped via curl, download full satellite and re-exec
if [[ -z "${BASH_SOURCE[0]}" ]] || [[ "${BASH_SOURCE[0]}" == "bash" ]] || [[ "${BASH_SOURCE[0]}" == "/dev/fd/"* ]]; then
    TEMP_DIR=$(mktemp -d)

    # Download the-satellite repository as tarball
    curl -sSL https://github.com/DeprecatedLuar/the-satellite/archive/refs/heads/main.tar.gz | \
        tar -xz -C "$TEMP_DIR" --strip-components=1

    # Re-execute from extracted location with all original arguments
    exec bash "$TEMP_DIR/satellite.sh" "$@"
fi

# Now running from extracted location, can source internal modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/internal/messages.sh"
source "$SCRIPT_DIR/internal/os_detection.sh"
source "$SCRIPT_DIR/internal/path_utils.sh"
source "$SCRIPT_DIR/internal/updater.sh"
source "$SCRIPT_DIR/internal/install_logic.sh"
source "$SCRIPT_DIR/cargo-bay/package_manager.sh"

# Command dispatcher
case "$1" in
    check-update)
        # Usage: satellite.sh check-update <current_version> <repo_user> <repo_name>
        run_update_check "$2" "$3" "$4"
        ;;
    install)
        # Usage: satellite.sh install <project_name> <binary_name> <repo_user> <repo_name> <install_dir> <build_cmd> [ascii_art] [msg_final] [next_steps]
        PROJECT_NAME="$2"
        BINARY_NAME="$3"
        REPO_USER="$4"
        REPO_NAME="$5"
        INSTALL_DIR="$6"
        BUILD_CMD="$7"

        # Optional branding
        ASCII_ART="${8:-}"
        MSG_FINAL="${9:-}"
        NEXT_STEPS_STR="${10:-}"

        # Detect OS and architecture
        SYSTEM_INFO=$(get_system_info)
        OS=$(echo "$SYSTEM_INFO" | grep -o '"os": "[^"]*"' | cut -d'"' -f4)
        ARCH=$(echo "$SYSTEM_INFO" | grep -o '"arch": "[^"]*"' | cut -d'"' -f4)

        # Try download, fall back to build
        BINARY_INSTALLED=false
        if try_download_binary "$REPO_USER" "$REPO_NAME" "$BINARY_NAME" "$OS" "$ARCH"; then
            BINARY_INSTALLED=true
        fi

        if [ "$BINARY_INSTALLED" = false ]; then
            build_from_source "$REPO_USER" "$REPO_NAME" "$BINARY_NAME" "$BUILD_CMD"
        fi

        # Stop running instance
        stop_running_instance "$BINARY_NAME"

        # Install binary
        install_binary "$BINARY_NAME" "$INSTALL_DIR"

        # Ensure install directory is in PATH
        ensure_in_path "$INSTALL_DIR"

        success "Installed to $INSTALL_DIR/$BINARY_NAME"

        # Show ASCII art if configured
        if [ -n "$ASCII_ART" ]; then
            echo ""
            echo "$ASCII_ART"
        fi

        # Show next steps if provided (pipe-separated)
        if [ -n "$NEXT_STEPS_STR" ]; then
            echo ""
            IFS='|' read -ra NEXT_STEPS <<< "$NEXT_STEPS_STR"
            for step in "${NEXT_STEPS[@]}"; do
                echo "$step"
            done
        fi

        # Final message
        if [ -n "$MSG_FINAL" ]; then
            echo ""
            info "$MSG_FINAL"
        fi
        ;;
    install-packages)
        # Usage: satellite.sh install-packages <category>
        # Categories: universal, dev-tools, all
        CATEGORY="$2"

        # Detect package manager
        SYSTEM_INFO=$(get_system_info)
        OS=$(echo "$SYSTEM_INFO" | grep -o '"os": "[^"]*"' | cut -d'"' -f4)

        # Determine package manager based on OS
        case "$OS" in
            ubuntu|debian)
                PKG_MGR="apt"
                ;;
            alpine)
                PKG_MGR="apk"
                ;;
            termux)
                PKG_MGR="pkg"
                ;;
            *)
                # Try to detect by command availability
                if command -v apk &> /dev/null; then
                    PKG_MGR="apk"
                elif command -v apt &> /dev/null; then
                    PKG_MGR="apt"
                elif command -v pkg &> /dev/null; then
                    PKG_MGR="pkg"
                else
                    error "Unsupported package manager"
                    exit 1
                fi
                ;;
        esac

        # Get and install packages
        case "$CATEGORY" in
            universal)
                PACKAGES=$(get_packages "universal" "$PKG_MGR")
                install_packages "$PKG_MGR" $PACKAGES
                ;;
            dev-tools)
                PACKAGES=$(get_packages "dev-tools" "$PKG_MGR")
                install_packages "$PKG_MGR" $PACKAGES
                ;;
            all)
                UNIVERSAL_PKGS=$(get_packages "universal" "$PKG_MGR")
                DEV_PKGS=$(get_packages "dev-tools" "$PKG_MGR")
                install_packages "$PKG_MGR" $UNIVERSAL_PKGS $DEV_PKGS
                ;;
            *)
                error "Unknown category: $CATEGORY"
                error "Usage: satellite.sh install-packages [universal|dev-tools|all]"
                exit 1
                ;;
        esac
        ;;
    *)
        error "Unknown command: $1"
        ;;
esac
