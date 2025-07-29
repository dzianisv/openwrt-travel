# OpenWrt Travel Router

OpenWrt travel router with Tailscale VPN and automatic WiFi management.

## 🚀 Install

```bash
wget -O- https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/install.sh | sh
```

## 📱 Usage

```bash
# Add WiFi networks
wifi-add "Hotel_WiFi" "password123"
wifi-add "Starbucks" "coffee2024"
wifi-add "Airport_Free" "" none

# List networks
wifi-list

# Remove network
wifi-remove "Old_Network"

# Setup Tailscale VPN
tailscale up --authkey=YOUR_AUTH_KEY
```

## ✨ Features

- **Always-On AP** - Your hotspot never goes down
- **Auto-Connect** - Switches to available networks automatically  
- **Simple Commands** - `wifi-add "SSID" "password"`
- **Tailscale VPN** - Secure mesh networking
- **Travel Ready** - Perfect for hotels, cafes, airports

## 🔧 How It Works

1. Your AP stays active (devices always connected)
2. Router auto-connects to configured WiFi when available
3. All traffic secured through Tailscale VPN
4. Zero manual management needed

**Supported:** armv7, arm64, mips, mipsle

---

⭐ Star if useful • 🛣️ Happy travels!