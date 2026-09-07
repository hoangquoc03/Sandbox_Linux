#!/bin/bash

set -e

echo "======================================"
echo " QuickBite Initial Setup"
echo "======================================"

echo "[1/4] Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

echo "[2/4] Installing required packages..."
sudo apt-get install -y openjdk-17-jdk git curl

echo "[3/4] Checking quickbite group..."
if getent group quickbite > /dev/null; then
    echo "Group 'quickbite' already exists."
else
    echo "Creating group 'quickbite'..."
    sudo groupadd quickbite
fi

echo "[4/4] Checking quickbite user..."
if id quickbite > /dev/null 2>&1; then
    echo "User 'quickbite' already exists."
else
    echo "Creating system user 'quickbite'..."
    sudo useradd -r -g quickbite -s /bin/false quickbite
fi

echo ""
echo "======================================"
echo " QuickBite setup completed!"
echo "======================================"

echo "User information:"
id quickbite

echo ""
echo "Password/login configuration:"
getent passwd quickbite
