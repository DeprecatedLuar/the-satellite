#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

# Setup service based on init system
setup_service() {
    if [ -d /run/systemd/system ]; then
        sudo tee /etc/systemd/system/zerotier-one.service > /dev/null << 'EOF'
[Unit]
Description=ZeroTier One
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/sbin/zerotier-one
Restart=always
RestartSec=5
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
        sudo systemctl daemon-reload
        sudo systemctl enable zerotier-one
        sudo systemctl start zerotier-one

    elif [ -f /sbin/openrc ]; then
        sudo rc-update add zerotier-one default 2>/dev/null || true
        sudo rc-service zerotier-one start

    else
        sudo zerotier-one -d
    fi
}

action "Installing zerotier-one..."

case "$DISTRO" in
    termux)
        pkg install -y zerotier-one
        ;;
    *)
        case "$FAMILY" in
            debian)
                curl -fsSL https://install.zerotier.com | sudo bash
                ;;
            alpine)
                (
                    cd /tmp
                    mkdir -p zerotier-build && cd zerotier-build

                    sudo apk add --no-cache git make gcc g++ linux-headers openssl-dev curl

                    # Install Rust if not present
                    if ! command -v cargo &>/dev/null; then
                        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                        source "$HOME/.cargo/env"
                    fi

                    # TUN module
                    sudo modprobe tun 2>/dev/null || true
                    grep -q "^tun$" /etc/modules 2>/dev/null || echo "tun" | sudo tee -a /etc/modules >/dev/null

                    # Build
                    git clone --depth 1 https://github.com/zerotier/ZeroTierOne.git
                    cd ZeroTierOne
                    make -j$(nproc) ZT_SSO_SUPPORTED=0
                    sudo make install ZT_SSO_SUPPORTED=0

                    # Cleanup
                    cd /
                    rm -rf /tmp/zerotier-build
                )

                setup_service
                ;;
            arch)
                sudo pacman -S --noconfirm zerotier-one
                sudo systemctl enable --now zerotier-one
                ;;
            rhel)
                sudo dnf install -y zerotier-one
                sudo systemctl enable --now zerotier-one
                ;;
            *)
                error "Unsupported system: $DISTRO ($FAMILY)"
                ;;
        esac
        ;;
esac

success "zerotier-one installed"
