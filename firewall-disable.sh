#!/bin/bash

set -e

echo "Removing HTTP (port 80) rule..."
sudo ufw delete allow 80/tcp

echo "Reloading firewall..."
sudo ufw reload

echo "Firewall status:"
sudo ufw status

