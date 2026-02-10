#!/bin/bash

set -e

echo "Disabling DNS firewall rules (port 53)..."

sudo ufw delete allow 53/tcp
sudo ufw delete allow 53/udp

sudo ufw reload

echo "Firewall rules for DNS removed."
sudo ufw status

