#!/bin/bash

set -e

SERVICE_NAME="bind9"

echo "========== DNS (BIND9) Setup Script =========="

# -----------------------------
# 1. Check if BIND9 is installed
# -----------------------------
if dpkg -l | grep -q bind9; then
    echo "BIND9 is already installed. Skipping installation."
else
    echo "BIND9 not found. Installing DNS server..."
    sudo apt update
    sudo apt install -y bind9 bind9utils bind9-doc
fi

# -----------------------------
# 2. Check if bind9 service exists
# -----------------------------
if systemctl list-unit-files | grep -q "${SERVICE_NAME}.service"; then
    echo "DNS service (${SERVICE_NAME}) exists."
else
    echo "ERROR: ${SERVICE_NAME}.service not found after installation."
    exit 1
fi

# -----------------------------
# 3. Start DNS service only if NOT running
# -----------------------------
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "DNS service is already running."
else
    echo "DNS service is not running. Starting it..."
    sudo systemctl start "$SERVICE_NAME"
fi

# -----------------------------
# 4. Enable DNS service on boot only if not enabled
# -----------------------------
if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    echo "DNS service already enabled on boot."
else
    echo "Enabling DNS service on boot..."
    sudo systemctl enable "$SERVICE_NAME"
fi

# -----------------------------
# 5. Firewall handling (DNS ports)
# -----------------------------
if command -v ufw >/dev/null 2>&1; then
    echo "Configuring firewall for DNS (port 53)..."

    # Enable UFW if not active
    if sudo ufw status | grep -q "Status: inactive"; then
        sudo ufw --force enable
    fi

    # Allow DNS ports only if not already allowed
    if sudo ufw status | grep -q "53/tcp"; then
        echo "TCP port 53 already allowed."
    else
        sudo ufw allow 53/tcp
    fi

    if sudo ufw status | grep -q "53/udp"; then
        echo "UDP port 53 already allowed."
    else
        sudo ufw allow 53/udp
    fi

    sudo ufw reload
else
    echo "UFW not found. Skipping firewall configuration."
fi

# -----------------------------
# 6. Verify DNS is listening
# -----------------------------
echo ""
echo "Checking DNS listening ports..."
sudo ss -tulnp | grep :53 || echo "WARNING: DNS not listening on port 53"

# -----------------------------
# 7. Final service status
# -----------------------------
echo ""
echo "========== DNS Service Status =========="
sudo systemctl status "$SERVICE_NAME" --no-pager

echo ""
echo "DNS setup completed safely."

