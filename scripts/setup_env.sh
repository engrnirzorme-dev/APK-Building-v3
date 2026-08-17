#!/bin/bash
set -e

echo "=========================================="
echo "🤖 Anti-Gravity CLI & Environment Setup"
echo "=========================================="

echo "1. Checking Java & Android SDK..."
java -version

echo "2. Setting up executable permissions..."
chmod +x ./scripts/*.sh 2>/dev/null || true

echo "3. Environment provisioning complete."
