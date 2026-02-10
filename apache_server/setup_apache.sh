#!/bin/bash

set -e

echo "========== Apache Setup Script =========="

# -----------------------------
# 1. Check if Apache is installed
# -----------------------------
if dpkg -l | grep -q apache2; then
    echo "Apache is already installed. Skipping installation."
else
    echo "Apache not found. Installing Apache..."
    sudo apt update
    sudo apt install -y apache2
fi

# -----------------------------
# 2. Check if Apache service exists
# -----------------------------
if systemctl list-unit-files | grep -q apache2.service; then
    echo "Apache service exists."
else
    echo "Apache service not found. Exiting."
    exit 1
fi

# -----------------------------
# 3. Start Apache only if NOT running
# -----------------------------
if systemctl is-active --quiet apache2; then
    echo "Apache is already running. No action needed."
else
    echo "Apache is not running. Starting Apache..."
    sudo systemctl start apache2
fi

# -----------------------------
# 4. Enable Apache on boot only if not enabled
# -----------------------------
if systemctl is-enabled --quiet apache2; then
    echo "Apache is already enabled on boot."
else
    echo "Enabling Apache to start on boot..."
    sudo systemctl enable apache2
fi

# -----------------------------
# 5. Create index.html ONLY if it does not exist
# -----------------------------
INDEX_FILE="/var/www/html/index.html"

if [ -f "$INDEX_FILE" ]; then
    echo "index.html already exists. Skipping creation."
else
    echo "Creating default index.html..."
    sudo tee "$INDEX_FILE" > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Apache Running</title>
</head>
<body>
    <h1>Apache is running successfully 🚀</h1>
    <p>Server setup completed.</p>
</body>
</html>
EOF
fi

# -----------------------------
# 6. Firewall note (NO auto-open)
# -----------------------------
echo "Firewall NOT modified by this script."
echo "Use firewall-enable.sh if you want to open port 80."

# -----------------------------
# 7. Final status
# -----------------------------
echo ""
echo "========== Apache Status =========="
sudo systemctl status apache2 --no-pager

echo ""
echo "Setup completed safely."

