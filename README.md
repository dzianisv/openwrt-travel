# Tailscale OpenWrt Builds

[![Build Tailscale OpenWrt Binaries](https://github.com/dzianisv/tailscale-openwrt-builds/actions/workflows/build-release.yml/badge.svg)](https://github.com/dzianisv/tailscale-openwrt-builds/actions/workflows/build-release.yml)

Automated builds of minimized Tailscale binaries optimized for OpenWrt devices across multiple architectures.

## 🚀 Quick Start

1. **Download** the appropriate binary for your device architecture from the [latest release](https://github.com/dzianisv/tailscale-openwrt-builds/releases/latest)
2. **Extract** the archive to your OpenWrt device
3. **Install** using the included installation script:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
4. **Connect** to your Tailscale network:
   ```bash
   tailscale up --authkey=YOUR_AUTH_KEY
   ```

## 📋 Supported Architectures

| Architecture | Description | Typical Devices |
|-------------|-------------|-----------------|
| **armv7** | 32-bit ARM with hardware floating point | Most modern ARM-based routers (Raspberry Pi, newer Linksys, ASUS, etc.) |
| **arm64** | 64-bit ARM | High-end ARM routers, newer Raspberry Pi models |
| **mips** | 32-bit MIPS big-endian, software floating point | Older routers (some TP-Link, D-Link models) |
| **mipsle** | 32-bit MIPS little-endian, software floating point | Some older routers, embedded devices |

## 📦 What's Included

Each release contains:

- **Optimized binaries**: Symbol-stripped, UPX-compressed for minimal size
- **Installation script**: Automated setup for OpenWrt
- **Documentation**: Architecture-specific README with usage instructions
- **Combined functionality**: Single binary handles both `tailscale` and `tailscaled`

## 🔧 Build Features

- ✅ **Minimized size**: ~6MB per binary (down from ~40MB)
- ✅ **Static linking**: No external dependencies required
- ✅ **OpenWrt optimized**: Built specifically for embedded Linux
- ✅ **Multi-architecture**: Supports ARM and MIPS variants
- ✅ **Automated builds**: GitHub Actions with automatic releases
- ✅ **UPX compression**: Additional size reduction with runtime decompression

## 🏗️ Building Locally

### Prerequisites

- Go 1.13 or newer
- git
- upx (optional, for compression)

### Build Script

```bash
# Clone this repository
git clone https://github.com/dzianisv/tailscale-openwrt-builds.git
cd tailscale-openwrt-builds

# Run the build script
./build-tailscale-openwrt.sh

# Binaries will be in the 'binaries' directory
```

### Build Script Options

```bash
./build-tailscale-openwrt.sh --help    # Show help
./build-tailscale-openwrt.sh --clean   # Clean build directories
```

## 📱 Installation on OpenWrt

### Method 1: Using Release Archives (Recommended)

1. Download the appropriate `.tar.gz` file for your architecture
2. Transfer to your OpenWrt device:
   ```bash
   scp tailscale-openwrt-armv7.tar.gz root@192.168.1.1:/tmp/
   ```
3. Extract and install:
   ```bash
   cd /tmp
   tar -xzf tailscale-openwrt-armv7.tar.gz
   cd tailscale-openwrt-armv7
   ./install.sh
   ```

### Method 2: Manual Installation

1. Download the standalone binary for your architecture
2. Transfer to your device and make executable:
   ```bash
   scp tailscale-armv7 root@192.168.1.1:/usr/bin/tailscale
   ssh root@192.168.1.1 "chmod +x /usr/bin/tailscale"
   ssh root@192.168.1.1 "ln -sf /usr/bin/tailscale /usr/bin/tailscaled"
   ```

## 🔍 Determining Your Architecture

If you're unsure of your device's architecture:

```bash
# On your OpenWrt device, run:
uname -m

# Common outputs:
# armv7l     -> use armv7
# aarch64    -> use arm64  
# mips       -> use mips
# mipsel     -> use mipsle
```

Or check `/proc/cpuinfo`:
```bash
cat /proc/cpuinfo | grep -E "(processor|model|architecture)"
```

## ⚙️ Usage

### Basic Commands

```bash
# Start Tailscale (requires auth key from https://login.tailscale.com/admin/settings/keys)
tailscale up --authkey=tskey-abcdef...

# Check status
tailscale status

# Show IP addresses
tailscale ip

# Exit/disconnect
tailscale down

# Show help
tailscale --help
```

### Service Management

The installation creates symbolic links so the binary can be used as both client and daemon:

```bash
# Client commands
tailscale status
tailscale up
tailscale down

# Daemon (runs automatically)
tailscaled --help
```

## 🤖 Automated Releases

This repository uses GitHub Actions to:

1. **Build** binaries for all supported architectures
2. **Package** them with installation scripts and documentation  
3. **Create releases** with versioned artifacts
4. **Upload** to GitHub Releases for easy download

### Triggering Builds

- **Automatic**: Push a git tag (e.g., `git tag v1.0.0 && git push origin v1.0.0`)
- **Manual**: Use the "Actions" tab to manually trigger a build

## 📄 Binary Information

| Architecture | Typical Size | Compression Ratio | Static Linked |
|-------------|-------------|-------------------|---------------|
| armv7 | ~5.9MB | 84% reduction | ✅ Yes |
| arm64 | ~6.4MB | 83% reduction | ✅ Yes |
| mips | ~5.8MB | 85% reduction | ✅ Yes |
| mipsle | ~5.9MB | 84% reduction | ✅ Yes |

*Sizes may vary based on Tailscale version and build optimizations*

## 🔒 Security Notes

- Binaries are built from the official [Tailscale repository](https://github.com/tailscale/tailscale)
- All builds are reproducible and use official Go toolchain
- No modifications to Tailscale source code
- Static linking ensures no dependency vulnerabilities

## 🐛 Troubleshooting

### Common Issues

**"Permission denied" when running binary:**
```bash
chmod +x tailscale
```

**"No such file or directory" on execution:**
- Verify you downloaded the correct architecture
- Check with `file tailscale` command

**Network connectivity issues:**
- Ensure your OpenWrt firewall allows Tailscale traffic
- Check if your router supports the required network features

### Getting Help

1. Check the [Tailscale OpenWrt documentation](https://tailscale.com/kb/1188/openwrt)
2. Visit [Tailscale Community](https://github.com/tailscale/tailscale/discussions)
3. Open an issue in this repository for build-specific problems

## 📝 License

This build system is provided under the same license as Tailscale. The Tailscale binary itself is proprietary software from Tailscale Inc.

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 🔗 Related Projects

- [Official Tailscale](https://github.com/tailscale/tailscale) - The main Tailscale repository
- [OpenWrt](https://openwrt.org/) - The OpenWrt project
- [Tailscale OpenWrt Package](https://github.com/openwrt/packages/tree/master/net/tailscale) - Official OpenWrt package

---

⭐ **Star this repository** if you find it useful!

**Disclaimer**: This is an unofficial build system. For official support, please contact Tailscale Inc.