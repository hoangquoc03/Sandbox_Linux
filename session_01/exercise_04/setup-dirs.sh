#!/bin/bash

set -e

echo "Creating QuickBite application directories..."

sudo mkdir -p /opt/quickbite/user-service

echo "Setting ownership..."
sudo chown -R quickbite:quickbite /opt/quickbite

echo "Setting permissions..."
sudo chmod 750 /opt/quickbite

echo "Setup completed."

echo "Checking /opt/quickbite:"
ls -ld /opt/quickbite

echo "Checking /opt/quickbite/user-service:"
ls -ld /opt/quickbite/user-service
