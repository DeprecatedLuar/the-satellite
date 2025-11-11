#!/usr/bin/env bash

# Requires: messages.sh (warn, info, success), os_detection.sh (is_nixos)

ensure_in_path() {
    local install_dir="$1"

    # Check if already in PATH
    if [[ ":$PATH:" == *":$install_dir:"* ]]; then
        return 0
    fi

    echo ""
    warn "$install_dir is not in your PATH"
    echo ""

    # Detect distro for NixOS handling
    local distro=""
    if is_nixos; then
        distro="nixos"
    fi

    # NixOS special handling
    if [[ "$distro" == "nixos" ]]; then
        handle_nixos_path "$install_dir"
        return 0
    fi

    # Detect shell
    local user_shell=$(basename "$SHELL")
    local rc_file=""

    case "$user_shell" in
        bash)
            rc_file="$HOME/.bashrc"
            ;;
        zsh)
            rc_file="$HOME/.zshrc"
            ;;
        fish)
            rc_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            warn "Unknown shell: $user_shell"
            info "Add this to your shell config manually:"
            echo "  export PATH=\"$install_dir:\$PATH\""
            return 1
            ;;
    esac

    # Create rc file if it doesn't exist
    if [[ ! -f "$rc_file" ]]; then
        touch "$rc_file"
    fi

    # Check if PATH export already exists
    if grep -q "$install_dir" "$rc_file" 2>/dev/null; then
        info "PATH export already in $rc_file"
        info "Reload your shell: source $rc_file"
        return 0
    fi

    # Add to rc file
    echo "" >> "$rc_file"
    echo "# Added by installer" >> "$rc_file"
    echo "export PATH=\"$install_dir:\$PATH\"" >> "$rc_file"

    success "Added $install_dir to PATH in $rc_file"
    info "Reload your shell: source $rc_file"
}

handle_nixos_path() {
    local install_dir="$1"

    echo "NixOS detected. Choose installation method:"
    echo ""
    echo "  1) Quick way - Add to .bashrc (works immediately)"
    echo "  2) NixOS way - Use declarative configuration (proper NixOS style)"
    echo ""
    read -p "Choice [1/2]: " choice

    case "$choice" in
        1)
            # Add to .bashrc even on NixOS
            local rc_file="$HOME/.bashrc"
            if [[ ! -f "$rc_file" ]]; then
                touch "$rc_file"
            fi

            if grep -q "$install_dir" "$rc_file" 2>/dev/null; then
                info "PATH export already in $rc_file"
            else
                echo "" >> "$rc_file"
                echo "# Added by installer" >> "$rc_file"
                echo "export PATH=\"$install_dir:\$PATH\"" >> "$rc_file"
                success "Added $install_dir to PATH in $rc_file"
            fi
            info "Reload your shell: source $rc_file"
            ;;
        2)
            # Show declarative instructions
            echo ""
            info "For declarative configuration, add to your home-manager config:"
            echo ""
            echo "  home.sessionPath = [ \"$install_dir\" ];"
            echo ""
            info "Or in configuration.nix (system-wide):"
            echo ""
            echo "  environment.sessionVariables = {"
            echo "    PATH = [ \"$install_dir\" ];"
            echo "  };"
            echo ""
            info "Then run: nixos-rebuild switch"
            echo ""
            ;;
        *)
            error "Invalid choice. Exiting."
            ;;
    esac
}
