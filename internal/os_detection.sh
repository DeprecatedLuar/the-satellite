#!/usr/bin/env bash

detect_os() {
    local os_type
    os_type=$(uname -s | tr '[:upper:]' '[:lower:]')

    case "$os_type" in
        linux*)
            echo "linux"
            ;;
        darwin*)
            echo "darwin"
            ;;
        mingw* | msys* | cygwin*)
            echo "windows"
            ;;
        freebsd*)
            echo "freebsd"
            ;;
        openbsd*)
            echo "openbsd"
            ;;
        netbsd*)
            echo "netbsd"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_arch() {
    local arch
    arch=$(uname -m)

    case "$arch" in
        x86_64 | x86-64 | x64 | amd64)
            echo "amd64"
            ;;
        aarch64 | arm64)
            echo "arm64"
            ;;
        armv7* | armv8l)
            echo "arm"
            ;;
        armv6*)
            echo "armv6"
            ;;
        i386 | i686)
            echo "386"
            ;;
        *)
            echo "$arch"
            ;;
    esac
}

is_nixos() {
    [[ -f /etc/NIXOS ]]
}

parse_os_release() {
    local key="$1"
    local value=""

    if [[ -f /etc/os-release ]]; then
        value=$(grep -E "^${key}=" /etc/os-release | cut -d= -f2- | tr -d '"')
    fi

    echo "$value"
}

detect_distro() {
    local os="$1"

    if [[ "$os" != "linux" ]]; then
        echo "none"
        return
    fi

    # Check for Termux (Android environment)
    if [[ -n "$TERMUX_VERSION" ]] || [[ -d "/data/data/com.termux" ]]; then
        echo "termux"
        return
    fi

    if is_nixos; then
        echo "nixos"
        return
    fi

    local distro_id
    distro_id=$(parse_os_release "ID")

    if [[ -n "$distro_id" ]]; then
        echo "$distro_id"
    else
        echo "unknown"
    fi
}

detect_distro_family() {
    local distro="$1"

    case "$distro" in
        nixos)
            echo "nixos"
            ;;
        ubuntu | debian | pop | linuxmint | raspbian)
            echo "debian"
            ;;
        arch | manjaro | endeavouros)
            echo "arch"
            ;;
        fedora | rhel | centos | rocky | alma)
            echo "rhel"
            ;;
        alpine)
            echo "alpine"
            ;;
        gentoo)
            echo "gentoo"
            ;;
        opensuse* | sles)
            echo "suse"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

detect_distro_version() {
    local os="$1"

    if [[ "$os" != "linux" ]]; then
        echo ""
        return
    fi

    parse_os_release "VERSION_ID"
}

detect_kernel() {
    uname -r
}

get_system_info() {
    local os arch distro distro_family distro_version kernel

    os=$(detect_os)
    arch=$(detect_arch)
    distro=$(detect_distro "$os")
    distro_family=$(detect_distro_family "$distro")
    distro_version=$(detect_distro_version "$os")
    kernel=$(detect_kernel)

    cat <<EOF
{
  "os": "$os",
  "arch": "$arch",
  "distro": "$distro",
  "distro_family": "$distro_family",
  "distro_version": "$distro_version",
  "kernel": "$kernel"
}
EOF
}
