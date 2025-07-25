#!/bin/bash

# Test script for the Docker deployment
# This script can be run in a test environment to validate the deployment

set -e

echo "🧪 Testing Docker deployment script..."

# Create a temporary directory for testing
TEST_DIR="/tmp/finders-keepers-test"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Download the deployment script
echo "📥 Downloading deployment script..."
curl -fsSL https://raw.githubusercontent.com/ninjapiraatti/finders-keepers-server/main/deployment/deploy-docker.sh -o deploy-docker.sh
chmod +x deploy-docker.sh

echo "✅ Deployment script downloaded successfully"

# Note: In a real test environment, you would run the script here
# For safety, we just validate it exists and is executable
if [[ -x "deploy-docker.sh" ]]; then
    echo "✅ Script is executable"
else
    echo "❌ Script is not executable"
    exit 1
fi

# Check script syntax
if bash -n deploy-docker.sh; then
    echo "✅ Script syntax is valid"
else
    echo "❌ Script has syntax errors"
    exit 1
fi

echo "✅ Basic validation passed!"
echo ""
echo "To run the full deployment test, execute:"
echo "  ./deploy-docker.sh"
echo ""
echo "⚠️  Note: This will install Docker and start the server!"

# Cleanup
cd /
rm -rf "$TEST_DIR"
