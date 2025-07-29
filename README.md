# OpenWrt Travel Router

[![Build Tailscale OpenWrt Binaries](https://github.com/dzianisv/openwrt-travel/actions/workflows/build-release.yml/badge.svg)](https://github.com/dzianisv/openwrt-travel/actions/workflows/build-release.yml)

Complete OpenWrt travel router solution with Tailscale VPN and intelligent WiFi management for seamless connectivity on the go.

## 🚀 One-Line Install

```bash
wget -O- https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/install.sh | sh
```

This installs:
- ✅ **Tailscale VPN** - Secure mesh networking
- ✅ **WiFi Management Tools** - Simple network configuration  
- ✅ **Automatic WiFi Switching** - Connects to available networks
- ✅ **Fault-Tolerant AP** - Your hotspot always works

## 📱 WiFi Management

### Simple Commands

```bash
# Add any WiFi network
wifi-add "Hotel_WiFi" "password123"

# Add open network
wifi-add "Airport_Free" "" none

# List all networks  
wifi-list

# Remove network
wifi-remove "Old_Network"
```

### How It Works

1. **AP Always Active** - Your router's hotspot never goes down
2. **Auto-Connect** - Automatically connects to configured networks when available
3. **Zero Management** - No manual switching or monitoring needed
4. **Travel Ready** - Add networks once, connect everywhere

### Example Travel Setup

```bash
# Add home WiFi
wifi-add "Home_WiFi" "mypassword"

# Add hotel chains
wifi-add "Marriott_Guest" "welcome"
wifi-add "Hilton_Honors" "guest123"

# Add common networks
wifi-add "Starbucks" "coffee"
wifi-add "Airport_Free" "" none

# Your router will auto-connect to whichever is available!
```

## 🔗 Tailscale VPN Setup

```bash
# Get auth key from: https://login.tailscale.com/admin/settings/keys
tailscale up --authkey=YOUR_AUTH_KEY

# Check connection
tailscale status

# Access your devices from anywhere!
```

## 📋 Supported Architectures

| Architecture | Description | Typical Devices |
|-------------|-------------|-----------------|
| **armv7** | 32-bit ARM with hardware FP | Most ARM routers, Raspberry Pi |
| **arm64** | 64-bit ARM | High-end ARM routers, newer Pi models |
| **mips** | 32-bit MIPS big-endian | Older TP-Link, D-Link routers |
| **mipsle** | 32-bit MIPS little-endian | Some embedded devices |

## 🛠️ Manual Installation

If you prefer manual setup:

```bash
# Download scripts
wget https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/bin/wifi-add -O /usr/bin/wifi-add
wget https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/bin/wifi-list -O /usr/bin/wifi-list
wget https://raw.githubusercontent.com/dzianisv/openwrt-travel/main/bin/wifi-remove -O /usr/bin/wifi-remove
chmod +x /usr/bin/wifi-*

# Set up auto-switching
echo "*/3 * * * * /usr/bin/wifi-simple" | crontab -

# Download Tailscale (replace 'armv7' with your architecture)
wget https://github.com/dzianisv/openwrt-travel/releases/latest/download/tailscale-armv7 -O /usr/bin/tailscale
chmod +x /usr/bin/tailscale
ln -sf /usr/bin/tailscale /usr/bin/tailscaled
```

## 🔍 Find Your Architecture

```bash
# Check architecture
uname -m

# Common outputs:
# armv7l  -> use armv7
# aarch64 -> use arm64
# mips    -> use mips  
# mipsel  -> use mipsle
```

## ✨ Features

### Travel Router Benefits
- **Always-On Hotspot** - Your devices stay connected
- **Automatic WiFi** - Connects to hotel/cafe networks automatically  
- **VPN Protection** - All traffic secured through Tailscale
- **Simple Management** - Add networks with one command
- **Fault Tolerant** - AP works even when no client networks available

### WiFi Management Features
- **Smart Auto-Connect** - Automatically switches to available networks
- **Open Network Support** - Handles both secured and open networks
- **Simple Commands** - Easy-to-remember wifi-add/list/remove
- **Status Monitoring** - See which networks are active/ready
- **Error Recovery** - AP automatically recovers if issues occur

### Tailscale Integration
- **Optimized Binaries** - 6MB compressed (down from 40MB)
- **Static Linking** - No external dependencies
- **Auto-Detection** - Installs correct architecture automatically
- **Combined Binary** - Single file handles client and daemon

## 🎯 Use Cases

### Business Travel
```bash
wifi-add "Hotel_Chain_Guest" "welcome123"
wifi-add "Airport_WiFi" "" none
wifi-add "Conference_Center" "event2024"
```

### Digital Nomad
```bash
wifi-add "Coworking_Space" "productivity"
wifi-add "Cafe_WiFi" "coffee123"  
wifi-add "Airbnb_Guest" "vacation"
```

### Home/Backup
```bash
wifi-add "Home_Primary" "homepassword"
wifi-add "Neighbor_Guest" "shared123"
wifi-add "Mobile_Hotspot" "phonedata"
```

## 🔧 Advanced Configuration

### Custom WiFi Monitoring Frequency
The auto-switcher runs every 3 minutes by default. To change:

```bash
# Edit cron for different intervals
crontab -e

# Examples:
# */1 * * * * /usr/bin/wifi-simple    # Every minute
# */5 * * * * /usr/bin/wifi-simple    # Every 5 minutes
```

### Manual WiFi Control
```bash
# Force manual connection attempt
/usr/bin/wifi-simple

# Check what networks are visible
iw dev phy0-ap0 scan | grep SSID

# View current wireless config
uci show wireless
```

## 🏗️ Building from Source

```bash
git clone https://github.com/dzianisv/openwrt-travel.git
cd openwrt-travel
./build-tailscale-openwrt.sh
```

## 🐛 Troubleshooting

### WiFi Issues
```bash
# Check AP status
wifi-list

# Restart WiFi
wifi reload

# Check logs
logread | grep -i wifi
```

### Tailscale Issues
```bash
# Check status
tailscale status

# Restart daemon
killall tailscaled
tailscaled &
```

### Common Problems

**AP not broadcasting:**
- Check: `uci get wireless.default_radio0.disabled` should be `0`
- Fix: `uci set wireless.default_radio0.disabled='0' && uci commit && wifi reload`

**Not connecting to networks:**
- Check: Networks are added with `wifi-list`
- Check: Networks are in range with `iw dev phy0-ap0 scan | grep YourSSID`

## 📝 Documentation

Full documentation available on device:
```bash
cat /etc/wifi-usage.txt
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch  
3. Test on real OpenWrt hardware
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

The Tailscale binary is proprietary software from Tailscale Inc.

---

⭐ **Star this repository** if it makes your travels easier!

🛣️ **Happy traveling with your OpenWrt router!**