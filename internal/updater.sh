#!/usr/bin/env bash

# Semantic version comparison (returns 0 if v1 < v2, 1 if v1 >= v2)
version_lt() {
    local v1="$1" v2="$2"

    # Split versions into major.minor.patch
    IFS='.' read -r -a ver1 <<< "$v1"
    IFS='.' read -r -a ver2 <<< "$v2"

    # Compare major
    [[ ${ver1[0]:-0} -lt ${ver2[0]:-0} ]] && return 0
    [[ ${ver1[0]:-0} -gt ${ver2[0]:-0} ]] && return 1

    # Compare minor
    [[ ${ver1[1]:-0} -lt ${ver2[1]:-0} ]] && return 0
    [[ ${ver1[1]:-0} -gt ${ver2[1]:-0} ]] && return 1

    # Compare patch
    [[ ${ver1[2]:-0} -lt ${ver2[2]:-0} ]] && return 0

    return 1
}

run_update_check() {
    local current_version="$1"
    local repo_user="$2"
    local repo_name="$3"

    # Get latest release/tag from GitHub API
    local latest_version=$(curl -sSL --connect-timeout 2 --max-time 5 \
        "https://api.github.com/repos/$repo_user/$repo_name/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/' || echo "")

    # If no release, try tags
    if [ -z "$latest_version" ]; then
        latest_version=$(curl -sSL --connect-timeout 2 --max-time 5 \
            "https://api.github.com/repos/$repo_user/$repo_name/tags" 2>/dev/null | \
            grep '"name":' | \
            head -1 | \
            sed -E 's/.*"([^"]+)".*/\1/' || echo "")
    fi

    # If still nothing, exit silently
    if [ -z "$latest_version" ]; then
        exit 0
    fi

    # Compare versions (strip 'v' prefix if present)
    local current_clean="${current_version#v}"
    local latest_clean="${latest_version#v}"

    # If newer version is found, print it and exit
    if version_lt "$current_clean" "$latest_clean"; then
        echo "$latest_version"
        exit 0
    fi

    # Otherwise, exit silently
    exit 0
}
