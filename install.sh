#!/bin/sh

# OpenWrt Travel Router Setup Script
# One-line install: wget -O- https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/install.sh | sh

set -e

REPO_URL="https://raw.githubusercontent.com/dzianisv/openwrt-travel/main"
BIN_DIR="/usr/bin"
DOC_PATH="/etc/wifi-usage.txt"

echo "🚀 OpenWrt Travel Router Setup"
echo "==============================="

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    "armv7l") TAILSCALE_ARCH="armv7" ;;
    "aarch64") TAILSCALE_ARCH="arm64" ;;
    "mips") TAILSCALE_ARCH="mips" ;;
    "mipsel") TAILSCALE_ARCH="mipsle" ;;
    *) 
        echo "⚠️  Unknown architecture: $ARCH"
        echo "Supported: armv7l, aarch64, mips, mipsel"
        exit 1
        ;;
esac

echo "📱 Detected architecture: $ARCH -> $TAILSCALE_ARCH"

# Download and install WiFi management scripts
echo "📡 Installing WiFi management tools..."

wget -q "$REPO_URL/bin/wifi-add" -O "$BIN_DIR/wifi-add"
wget -q "$REPO_URL/bin/wifi-list" -O "$BIN_DIR/wifi-list"  
wget -q "$REPO_URL/bin/wifi-remove" -O "$BIN_DIR/wifi-remove"
wget -q "$REPO_URL/bin/wifi-simple" -O "$BIN_DIR/wifi-simple"

chmod +x "$BIN_DIR/wifi-add" "$BIN_DIR/wifi-list" "$BIN_DIR/wifi-remove" "$BIN_DIR/wifi-simple"

# Set up intelligent WiFi monitoring
echo "⚡ Setting up intelligent WiFi management..."
echo "  - Auto-connects to available networks"
echo "  - Auto-disconnects from unavailable networks"  
echo "  - Runs every 3 minutes"
crontab -l 2>/dev/null | grep -v wifi-simple; echo "*/3 * * * * /usr/bin/wifi-simple" | crontab -
/etc/init.d/cron restart

# Download Tailscale binary
echo "🔗 Installing Tailscale ($TAILSCALE_ARCH)..."
TAILSCALE_URL="https://github.com/dzianisv/openwrt-travel/releases/latest/download/tailscale-$TAILSCALE_ARCH"

if wget -q "$TAILSCALE_URL" -O "$BIN_DIR/tailscale"; then
    chmod +x "$BIN_DIR/tailscale"
    ln -sf "$BIN_DIR/tailscale" "$BIN_DIR/tailscaled"
    echo "✅ Tailscale installed successfully"
else
    echo "⚠️  Failed to download Tailscale binary"
    echo "📦 You can manually download from:"
    echo "    https://github.com/dzianisv/openwrt-travel/releases"
fi

# Create documentation
echo "📚 Creating documentation..."
cat > "$DOC_PATH" << 'EOF'
OpenWrt Travel Router - WiFi Management
======================================

SIMPLE COMMANDS:
---------------

Add WiFi Network:
  wifi-add "Network_Name" "password"
  wifi-add "Hotel_WiFi" "welcome123"
  wifi-add "Starbucks" "coffee2024"

Add Open Network:
  wifi-add "Free_WiFi" "" none

List Networks:
  wifi-list

Remove Network:
  wifi-remove "Network_Name"

EXAMPLES:
--------

# Add your home WiFi
wifi-add "Home_WiFi" "mypassword123"

# Add hotel WiFi  
wifi-add "Marriott_Guest" "hotel2024"

# Add open network
wifi-add "Airport_Free" "" none

# See all networks
wifi-list

# Remove old network
wifi-remove "Old_Hotel"

HOW IT WORKS:
------------

1. Your AP is ALWAYS active
2. Router automatically connects to available networks
3. No manual management needed
4. Add networks once, they auto-connect when available

TAILSCALE SETUP:
---------------

1. Get auth key from: https://login.tailscale.com/admin/settings/keys
2. Connect: tailscale up --authkey=YOUR_KEY
3. Check status: tailscale status

ENCRYPTION TYPES:
----------------
- psk2 (default, most common)
- psk (older WPA)
- wpa2 (enterprise)
- none (open networks)

ACCESS THIS HELP:
----------------
cat /etc/wifi-usage.txt
EOF

echo ""
echo "✅ Installation Complete!"
echo ""
echo "🎯 Quick Start:"
echo "   wifi-add \"YourWiFi\" \"password\""
echo "   wifi-list"
echo ""
echo "📖 Full documentation: cat /etc/wifi-usage.txt"
echo ""
echo "🔗 Tailscale setup:"
echo "   tailscale up --authkey=YOUR_AUTH_KEY"
echo ""
echo "🚀 Your travel router is ready!"