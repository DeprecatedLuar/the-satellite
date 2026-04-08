#!/usr/bin/env bash

# Requires: messages.sh (action, success, warn, error), os_detection.sh (get_system_info)

# Check for dependencies function
require_command() {
    local cmd="$1"

    if ! command -v "$cmd" &> /dev/null; then
        error "$cmd not found. Please install $cmd and try again."
    fi
}

# Try to download pre-built binary from GitHub releases
try_download_binary() {
    local repo_user="$1"
    local repo_name="$2"
    local binary_name="$3"
    local os="$4"
    local arch="$5"

    # Try GitHub releases first
    local latest_release=$(curl -s "https://api.github.com/repos/$repo_user/$repo_name/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "")

    # If no stable release, try first release (including prereleases)
    if [ -z "$latest_release" ]; then
        latest_release=$(curl -s "https://api.github.com/repos/$repo_user/$repo_name/releases" | grep '"tag_name":' | head -1 | sed -E 's/.*"([^"]+)".*/\1/' || echo "")
    fi

    if [ -z "$latest_release" ]; then
        return 1
    fi

    # Try common binary naming patterns
    local binary_patterns=(
        "${binary_name}-${os}-${arch}"
        "${binary_name}_${os}_${arch}"
        "${binary_name}-${latest_release}-${os}-${arch}"
        "${binary_name}"
    )

    # Also try with .tar.gz and .zip extensions
    local archive_patterns=(
        "${binary_name}-${os}-${arch}.tar.gz"
        "${binary_name}-${os}-${arch}.zip"
        "${binary_name}_${os}_${arch}.tar.gz"
        "${binary_name}_${os}_${arch}.zip"
    )

    # Try direct binary download
    for pattern in "${binary_patterns[@]}"; do
        local download_url="https://github.com/$repo_user/$repo_name/releases/download/$latest_release/$pattern"

        if curl -fsSL -o "$binary_name" "$download_url" 2>/dev/null; then
            chmod +x "$binary_name"
            return 0
        fi
    done

    # Try archive download and extraction
    for pattern in "${archive_patterns[@]}"; do
        local download_url="https://github.com/$repo_user/$repo_name/releases/download/$latest_release/$pattern"

        if curl -fsSL -o "/tmp/archive-$$" "$download_url" 2>/dev/null; then
            if [[ "$pattern" == *.tar.gz ]]; then
                tar -xzf "/tmp/archive-$$" -C /tmp
            elif [[ "$pattern" == *.zip ]]; then
                unzip -q "/tmp/archive-$$" -d /tmp
            fi

            # Try to find binary in extracted files
            if [ -f "/tmp/$binary_name" ]; then
                mv "/tmp/$binary_name" "./$binary_name"
                chmod +x "$binary_name"
                rm -f "/tmp/archive-$$"
                return 0
            fi
            rm -f "/tmp/archive-$$"
        fi
    done

    # Fallback: scan actual release assets for OS/arch match
    local asset_urls
    asset_urls=$(curl -s "https://api.github.com/repos/$repo_user/$repo_name/releases/latest" \
        | grep '"browser_download_url":' \
        | sed -E 's/.*"([^"]+)".*/\1/')

    for asset_url in $asset_urls; do
        local asset_filename
        asset_filename=$(basename "$asset_url")

        # Skip checksums, signatures, etc.
        [[ "$asset_filename" == *.sha256 ]] && continue
        [[ "$asset_filename" == *.sig ]]    && continue
        [[ "$asset_filename" == *.asc ]]    && continue

        if [[ "$asset_filename" == *"$os"* ]] && [[ "$asset_filename" == *"$arch"* ]]; then
            local tmp_archive="/tmp/satellite-asset-$$"
            if curl -fsSL -o "$tmp_archive" "$asset_url" 2>/dev/null; then
                if [[ "$asset_filename" == *.tar.gz ]]; then
                    local extract_dir="/tmp/satellite-extract-$$"
                    mkdir -p "$extract_dir"
                    tar -xzf "$tmp_archive" -C "$extract_dir"
                    local found_bin
                    found_bin=$(find "$extract_dir" -type f -executable | head -1)
                    if [ -n "$found_bin" ]; then
                        mv "$found_bin" "./$binary_name"
                        chmod +x "./$binary_name"
                        rm -rf "$extract_dir" "$tmp_archive"
                        return 0
                    fi
                    rm -rf "$extract_dir" "$tmp_archive"
                elif [[ "$asset_filename" == *.zip ]]; then
                    local extract_dir="/tmp/satellite-extract-$$"
                    mkdir -p "$extract_dir"
                    unzip -q "$tmp_archive" -d "$extract_dir"
                    local found_bin
                    found_bin=$(find "$extract_dir" -type f -executable | head -1)
                    if [ -n "$found_bin" ]; then
                        mv "$found_bin" "./$binary_name"
                        chmod +x "./$binary_name"
                        rm -rf "$extract_dir" "$tmp_archive"
                        return 0
                    fi
                    rm -rf "$extract_dir" "$tmp_archive"
                else
                    mv "$tmp_archive" "./$binary_name"
                    chmod +x "./$binary_name"
                    return 0
                fi
            fi
        fi
    done

    warn "No release binary found, building from source..."
    return 1
}

# Build from source
build_from_source() {
    local repo_user="$1"
    local repo_name="$2"
    local binary_name="$3"
    local build_cmd="$4"

    require_command git

    # Check if we're in the repo directory (local usage)
    if [ -d ".git" ] && ([ -f "go.mod" ] || [ -f "Cargo.toml" ] || [ -f "Makefile" ]); then
        eval "$build_cmd"

        if [ $? -ne 0 ]; then
            error "Build failed"
        fi
    else
        # Remote usage - clone and build
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"

        if ! git clone -q "https://github.com/$repo_user/$repo_name.git" . 2>/dev/null; then
            error "Failed to clone repository"
        fi

        # If repo has install.sh, use it instead of build cmd
        if [ -f "install.sh" ]; then
            bash install.sh
            cd "$OLDPWD"
            rm -rf "$temp_dir"
            return 0
        fi

        eval "$build_cmd"

        if [ $? -ne 0 ]; then
            rm -rf "$temp_dir"
            error "Build failed"
        fi

        # Move binary to original directory
        mv "$binary_name" "$OLDPWD/"
        cd "$OLDPWD"
        rm -rf "$temp_dir"
    fi
}

# Stop running instance of binary
stop_running_instance() {
    local binary_name="$1"

    # Find all processes with exact binary name match
    local all_pids=$(pgrep -x "$binary_name" 2>/dev/null || true)

    if [ -z "$all_pids" ]; then
        return 0
    fi

    # Separate zombies from running processes
    local running_pids=""
    local zombie_pids=""

    for pid in $all_pids; do
        local state=$(ps -o stat= -p "$pid" 2>/dev/null | sed 's/[^A-Z]//g')
        if [[ "$state" == *"Z"* ]]; then
            zombie_pids="$zombie_pids $pid"
        else
            running_pids="$running_pids $pid"
        fi
    done

    # Kill running processes
    if [ -n "$running_pids" ]; then
        action "Stopping running instance..."

        for pid in $running_pids; do
            kill -TERM "$pid" 2>/dev/null || true
        done

        # Wait for clean exit (timeout: 5 seconds)
        for i in {1..10}; do
            sleep 0.5
            local still_running=""
            for pid in $running_pids; do
                if ps -p "$pid" > /dev/null 2>&1; then
                    local state=$(ps -o stat= -p "$pid" 2>/dev/null | sed 's/[^A-Z]//g')
                    if [[ "$state" != *"Z"* ]]; then
                        still_running="$still_running $pid"
                    fi
                fi
            done

            if [ -z "$still_running" ]; then
                success "Process stopped"
                return 0
            fi
            running_pids="$still_running"
        done

        # If still running after timeout, error
        if [ -n "$running_pids" ]; then
            echo ""
            error "Failed to stop running $binary_name (PIDs:$running_pids). Please stop it manually and try again."
        fi
    fi

    # Zombies can't be killed, they'll be reaped by parent eventually
    if [ -n "$zombie_pids" ]; then
        warn "You got some zombie processes (PIDs:$zombie_pids). Nothing to worry though."
    fi
}

# Install binary to target directory
install_binary() {
    local binary_name="$1"
    local install_dir="$2"

    # Check if sudo is needed
    if [[ "$install_dir" == /usr/* ]] || [[ "$install_dir" == /opt/* ]]; then
        sudo cp "$binary_name" "$install_dir/"
        sudo chmod +x "$install_dir/$binary_name"
    else
        mkdir -p "$install_dir"
        cp "$binary_name" "$install_dir/"
        chmod +x "$install_dir/$binary_name"
    fi

    # Clean up
    rm -f "$binary_name"
}
