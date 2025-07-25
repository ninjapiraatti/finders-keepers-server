#!/bin/bash
#
# Setup script to install git hooks
#

set -e

echo "⚙️  Setting up git hooks..."

# Create .git/hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy pre-commit hook
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

echo "✅ Git hooks installed successfully!"
echo ""
echo "📋 Installed hooks:"
echo "  - pre-commit: Security audit with cargo-audit"
echo ""
echo "💡 The security audit will now run automatically before each commit."
echo "   If you need to skip it temporarily, use: git commit --no-verify"
