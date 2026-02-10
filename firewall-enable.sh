#!/bin/bash

set -e

echo "Enabling UFW (if not already enabled)..."
sudo ufw --force enable

echo "Allowing HTTP (port 80)..."
sudo ufw allow 80/tcp

echo "Reloading firewall..."
sudo ufw reload

echo "Firewall status:"
sudo ufw status

