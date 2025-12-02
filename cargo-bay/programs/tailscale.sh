#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../internal/messages.sh"
source "$SCRIPT_DIR/../../internal/os_detection.sh"

OS=$(detect_os)
DISTRO=$(detect_distro "$OS")
FAMILY=$(detect_distro_family "$DISTRO")

action "Installing tailscale..."

case "$DISTRO" in
    termux)
        pkg install -y tailscale
        ;;
    *)
        case "$FAMILY" in
            debian)
                curl -fsSL https://tailscale.com/install.sh | sh
                ;;
            alpine)
                action "Downloading Tailscale static binary..."

                ARCH=$(uname -m)
                case "$ARCH" in
                    x86_64)         ARCH_NAME="amd64" ;;
                    aarch64|arm64)  ARCH_NAME="arm64" ;;
                    armv7*|armhf)   ARCH_NAME="arm" ;;
                    *)              error "Unsupported architecture: $ARCH" ;;
                esac

                # Get latest version
                VERSION=$(curl -sSL "https://pkgs.tailscale.com/stable/" \
                    | grep -oP "tailscale_\K[0-9]+\.[0-9]+\.[0-9]+(?=_${ARCH_NAME}\.tgz)" \
                    | head -1)

                curl -fsSL -o /tmp/tailscale.tgz \
                    "https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH_NAME}.tgz"

                tar -xzf /tmp/tailscale.tgz -C /tmp
                rm /tmp/tailscale.tgz

                sudo mv /tmp/tailscale_${VERSION}_${ARCH_NAME}/tailscale /usr/local/bin/
                sudo mv /tmp/tailscale_${VERSION}_${ARCH_NAME}/tailscaled /usr/local/bin/
                rm -rf /tmp/tailscale_${VERSION}_${ARCH_NAME}

                # TUN module
                sudo modprobe tun 2>/dev/null || true
                grep -q "^tun$" /etc/modules 2>/dev/null || echo "tun" | sudo tee -a /etc/modules >/dev/null

                # systemd service
                sudo tee /etc/systemd/system/tailscaled.service >/dev/null <<'EOF'
[Unit]
Description=Tailscale node agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
                sudo mkdir -p /var/lib/tailscale
                sudo systemctl daemon-reload
                sudo systemctl enable tailscaled
                sudo systemctl start tailscaled
                ;;
            arch)   sudo pacman -S --noconfirm tailscale ;;
            rhel)   sudo dnf install -y tailscale ;;
            *)      error "Unsupported system: $DISTRO ($FAMILY)" ;;
        esac
        ;;
esac

success "tailscale installed"
info "Run: sudo tailscale up"
