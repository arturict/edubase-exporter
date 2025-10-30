#!/bin/bash
# WSL2 Environment Check for Playwright/Chromium GUI Apps
# This script verifies that WSL2 + WSLg is properly configured

set -e

echo "=================================================="
echo "WSL2 + WSLg Environment Check for Playwright"
echo "=================================================="
echo

# Check if running in WSL2
if grep -qi microsoft /proc/version; then
    echo "✓ Running in WSL2"
    uname -r
else
    echo "✗ Not running in WSL2"
    exit 0
fi

echo

# Check WSLg display configuration
echo "Display Configuration:"
echo "---------------------"
if [ -n "$DISPLAY" ]; then
    echo "✓ DISPLAY is set: $DISPLAY"
else
    echo "✗ DISPLAY not set"
fi

if [ -n "$WAYLAND_DISPLAY" ]; then
    echo "✓ WAYLAND_DISPLAY is set: $WAYLAND_DISPLAY"
else
    echo "⚠ WAYLAND_DISPLAY not set (optional)"
fi

if [ -d "$XDG_RUNTIME_DIR" ]; then
    echo "✓ XDG_RUNTIME_DIR exists: $XDG_RUNTIME_DIR"
else
    echo "✗ XDG_RUNTIME_DIR not set or missing"
fi

echo

# Check graphics libraries
echo "Graphics Libraries:"
echo "-------------------"
libs_ok=true

for lib in libgbm1 libdrm2 mesa-vulkan-drivers; do
    if dpkg -l | grep -q "^ii.*$lib"; then
        echo "✓ $lib installed"
    else
        echo "✗ $lib NOT installed"
        libs_ok=false
    fi
done

echo

# Check Playwright browser dependencies
echo "Playwright Dependencies:"
echo "------------------------"
if command -v playwright &> /dev/null; then
    echo "✓ Playwright CLI found"
    echo "  Run: playwright install-deps chromium"
    echo "  (requires sudo password)"
else
    echo "✗ Playwright CLI not found"
    echo "  Make sure virtual environment is activated"
fi

echo

# Test display with xeyes (if available)
echo "Display Test:"
echo "-------------"
if command -v xeyes &> /dev/null; then
    echo "✓ xeyes available for testing"
    echo "  Run: xeyes (should show a window)"
else
    echo "⚠ x11-apps not installed"
    echo "  Install with: sudo apt install x11-apps"
fi

echo

# Summary and recommendations
echo "=================================================="
echo "Recommendations:"
echo "=================================================="
echo

if [ "$libs_ok" = false ]; then
    echo "📦 Install missing graphics libraries:"
    echo "   sudo apt update"
    echo "   sudo apt install -y libgbm1 libdrm2 mesa-vulkan-drivers"
    echo
fi

echo "🔧 Install Playwright system dependencies:"
echo "   source .venv/bin/activate"
echo "   playwright install-deps chromium"
echo

echo "🧪 Test the environment:"
echo "   python edubase_cli.py capture --book-url \"URL\" --pages 1"
echo

echo "📚 WSL2 + WSLg documentation:"
echo "   https://learn.microsoft.com/windows/wsl/tutorials/gui-apps"
echo

echo "=================================================="
echo "Environment check complete!"
echo "=================================================="
