#!/bin/bash

# Exit immediately if any command fails
set -e

echo "Updating package list..."
sudo apt update -y

echo "Installing Apache (apache2)..."
sudo apt install -y apache2

echo "Starting Apache service..."
sudo systemctl start apache2

echo "Enabling Apache to start on boot..."
sudo systemctl enable apache2

echo "Checking Apache status..."
sudo systemctl status apache2 --no-pager

echo "Allowing HTTP traffic through firewall..."
sudo ufw allow http

echo "Reloading UFW firewall..."
sudo ufw reload || true

echo "Apache installation completed successfully!"
echo ""
echo "Important paths:"
echo "Web root       : /var/www/html/index.html"
echo "Config file    : /etc/apache2/apache2.conf"

