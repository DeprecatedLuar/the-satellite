#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing zerotier-one..."

case "$DISTRO" in
    termux)
        pkg install -y zerotier-one
        ;;
    *)
        case "$FAMILY" in
            debian) sudo apt install -y zerotier-one ;;
            alpine)
                action "Downloading static ZeroTier binary..."

                ARCH=$(uname -m)
                case "$ARCH" in
                    x86_64)         ARCH_NAME="x86_64" ;;
                    aarch64|arm64)  ARCH_NAME="aarch64" ;;
                    *)              error "Unsupported architecture: $ARCH" ;;
                esac

                # Get latest version from CrystalIDEA releases
                VERSION=$(curl -sSL "https://api.github.com/repos/crystalidea/zerotier-linux-binaries/releases/latest" \
                    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

                curl -fsSL -o /tmp/zerotier.tar.gz \
                    "https://github.com/crystalidea/zerotier-linux-binaries/releases/download/${VERSION}/zerotier_${ARCH_NAME}_${VERSION}.tar.gz"

                tar -xzf /tmp/zerotier.tar.gz -C /tmp
                rm /tmp/zerotier.tar.gz

                sudo mv /tmp/zerotier-one /usr/local/bin/
                sudo ln -sf /usr/local/bin/zerotier-one /usr/local/bin/zerotier-cli

                # TUN module
                sudo modprobe tun 2>/dev/null || true
                grep -q "^tun$" /etc/modules 2>/dev/null || echo "tun" | sudo tee -a /etc/modules >/dev/null

                # systemd service
                sudo tee /etc/systemd/system/zerotier-one.service >/dev/null <<'EOF'
[Unit]
Description=ZeroTier One
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/zerotier-one
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
                sudo systemctl daemon-reload
                sudo systemctl enable zerotier-one
                sudo systemctl start zerotier-one
                ;;
            arch)   sudo pacman -S --noconfirm zerotier-one ;;
            rhel)   sudo dnf install -y zerotier-one ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "zerotier-one installed"
