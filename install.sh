#!/usr/bin/env bash
set -euo pipefail

echo "==> Recipes — Setup"
echo ""

# Verify toolchain is available
command -v crystal >/dev/null 2>&1 || { echo "ERROR: crystal not found on PATH"; exit 1; }
command -v shards  >/dev/null 2>&1 || { echo "ERROR: shards not found on PATH"; exit 1; }

echo "    Crystal: $(crystal --version | head -1)"
echo "    Shards:  $(shards --version)"
echo ""

# Install dependencies
echo "==> Installing dependencies (shards install)..."
shards install

# Compile the application
echo ""
echo "==> Building application (shards build)..."
shards build

echo ""
echo "==> Setup complete."
echo "    Run ./bin/app to start the server on 0.0.0.0:3000"
echo "    Then open http://localhost:3000 in your browser."
