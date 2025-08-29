# Multi-Device OpenWRT Configuration

🏠 Declarative OpenWRT configuration for multiple devices using Nix and the [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder).

![Build Status](https://github.com/your-username/openwrt-config/workflows/Build%20OpenWRT%20Images%20for%20Multiple%20Devices/badge.svg)

## Features

- 🔧 **Declarative Configuration**: All settings in version-controlled Nix files
- 🚀 **Automated Builds**: GitHub Actions build images for all devices
- 🏠 **Multi-Device Support**: Common settings + device-specific configurations
- 🔐 **Secure by Default**: SSH key authentication, no password login
- 📦 **Modular Design**: Easy to add new devices and share configurations
- 🔄 **Reproducible**: Same configuration always produces identical images

## Supported Devices

| Device | Target | IP Address | Notes |
|--------|--------|------------|-------|
| **BananaPi BPI-R4-8G** | MediaTek Filogic MT7988A | 192.168.1.1 | 8GB RAM, WiFi 7 BPI-R4-NIC-BE14, 2x 10GbE SFP+ |
| **Xiaomi R3G v1** | MediaTek MT7621 | 192.168.2.1 | AC1200, Dual-band |

### BananaPi BPI-R4-8G Specifications

- **Model**: BPI-R4-8G (8GB RAM variant)
- **SoC**: MediaTek MT7988A (Quad-core ARM Cortex-A73, 1.8GHz)
- **RAM**: 8GB DDR4 (upgraded variant)
- **WiFi**: WiFi 7 BPI-R4-NIC-BE14 Module (802.11be, 2.4GHz/5GHz/6GHz)
- **Ethernet**: 4x 1GbE + 2x 10GbE SFP+ (fixed 10Gbps serdes)
- **Storage**: 8GB eMMC, microSD slot, SPI-NAND
- **USB**: 1x USB 3.0
- **Connectivity**: WiFi 7, 4G/5G support
- **Special**: Requires BPI-R4-8G specific firmware + BL2 update for 8GB RAM recognition

### Xiaomi AX3000 Specifications

- **SoC**: MediaTek MT7622 (Dual-core ARM Cortex-A53)
- **WiFi**: MediaTek MT7915 (WiFi 6, 2.4GHz/5GHz)
- **Ethernet**: 4x 1GbE ports
- **RAM**: 256MB DDR3
- **Flash**: 128MB NAND

## Quick Start

### Prerequisites

- Nix with flakes enabled
- **x86_64-Linux system** (required for OpenWRT ImageBuilder)
  - If you're on macOS/Windows: Use GitHub Actions or a Linux VM/container
  - The repository works on all systems for development, but builds require x86_64-Linux

### ⚠️ Important for BPI-R4-8G Users

**Critical**: If you have the 8GB RAM version of BPI-R4, you **must** update the BL2 bootloader before flashing OpenWRT, otherwise only 4GB RAM will be recognized.

- **Forum Guide**: [BPI-R4 8GB RAM Upgrade](https://forum.banana-pi.org/t/bpi-r4-successfully-upgraded-8gb-ram-on-bpi-r4/17882/78)
- **Verification**: After installation, run `free -m` to confirm 8GB is detected
- **Firmware**: Use BPI-R4-8G specific firmware (not compatible with 4GB version)

### Setup

```bash
# Clone the repository
git clone https://github.com/your-username/openwrt-config.git
cd openwrt-config

# Add your SSH public key to lib/common.nix (around line 76)
# Replace the placeholder with your actual public key

# Enter development shell
nix develop
```

### Building Locally (Linux x86_64 only)

```bash
# Build specific device
just build bpi-r4
just build xiaomi-ax3000

# Build all devices
just build-all

# Show build results
just info
just info-device bpi-r4
```

### Using Justfile Commands

The Justfile provides convenient commands for all operations:

```bash
# Development commands (work on any system)
just help                     # Show all commands
just validate                 # Check configuration
just up                       # Update dependencies
just check                    # Syntax validation

# Building commands (require Linux x86_64)
just build [device]           # Build specific device
just build-all                # Build all devices
just rebuild [device]         # Force rebuild
just clean                    # Clean artifacts

# Information commands
just info                     # Show all build artifacts
just info-device xiaomi-ax3000 # Show specific device artifacts
just search wireless          # Search OpenWRT packages
```

## Configuration Structure

The configuration is organized in a modular way:

```
openwrt-config/
├── lib/
│   ├── common.nix              # Shared settings for all devices
│   └── builder.nix             # Build helper functions
├── devices/
│   ├── bpi-r4.nix             # BPI-R4 specific configuration
│   └── xiaomi-r3g.nix         # Xiaomi R3G V1 specific configuration
├── flake.nix                   # Main Nix flake definition
└── .github/workflows/          # CI/CD automation
```

### Common Configuration (`lib/common.nix`)

Shared across all devices:
- SSH configuration and public keys
- Common packages (LuCI, tools, utilities)
- Basic firewall and network settings
- NTP and timezone configuration

### Device-Specific Configuration

Each device has its own configuration file with:
- Hardware target and variant
- Device-specific packages
- Network settings (IP addresses, WiFi)
- Hardware-specific optimizations

## GitHub Actions

Images are automatically built on:
- ✅ Push to main/develop branches
- ✅ Pull requests to main
- ✅ Manual workflow dispatch (with device selection)
- ✅ Weekly scheduled builds (Mondays)
- ✅ Tagged releases

### Manual Builds

You can trigger builds for specific devices:

1. Go to **Actions** → **Build OpenWRT Images for Multiple Devices**
2. Click **Run workflow**
3. Choose devices: `all`, `bpi-r4`, `xiaomi-r3g`, or `bpi-r4,xiaomi-r3g`

Built images are available as:
- **Artifacts**: 30-day retention for all builds (per device)
- **Releases**: Permanent storage for tagged versions

## Installation

### Flashing Images

1. **Download** the built image from GitHub Actions artifacts or releases
2. **Identify the correct file**:
   - `*-factory.bin`: For first-time installation
   - `*-sysupgrade.bin`: For upgrading existing OpenWRT

3. **Flash methods**:
   - **Web Interface**: Use existing OpenWRT web interface
   - **Command Line**: `sysupgrade -v <image-file>`
   - **Bootloader**: TFTP or USB boot methods

### First Boot

Each device has different default settings:

#### BananaPi BPI-R4
- **IP**: 192.168.1.1/24
- **DHCP**: 192.168.1.100-250
- **Web Interface**: https://192.168.1.1
- **SSH**: `ssh root@192.168.1.1`

#### Xiaomi AX3000
- **IP**: 192.168.2.1/24
- **DHCP**: 192.168.2.100-250
- **Web Interface**: https://192.168.2.1
- **SSH**: `ssh root@192.168.2.1`

## Customization

### Adding Your SSH Key

Edit `lib/common.nix` around line 76:

```nix
sshPublicKey = ''
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... your-email@domain.com
  # Add additional keys on new lines if needed
'';
```

### WiFi Configuration

Uncomment and edit the WiFi sections in device configuration files:

**BPI-R4** (`devices/bpi-r4.nix`):
```bash
# 2.4GHz WiFi
uci set wireless.radio0.country='US'
uci set wireless.default_radio0.ssid='YourNetwork-2G'
uci set wireless.default_radio0.key='YourPassword'
uci set wireless.radio0.disabled='0'

# 5GHz WiFi  
uci set wireless.radio1.country='US'
uci set wireless.default_radio1.ssid='YourNetwork-5G'
uci set wireless.default_radio1.key='YourPassword'
uci set wireless.radio1.disabled='0'

# 6GHz WiFi (WiFi 6E)
uci set wireless.radio2.country='US'
uci set wireless.default_radio2.ssid='YourNetwork-6G'
uci set wireless.default_radio2.key='YourPassword'
uci set wireless.radio2.disabled='0'
```

**Xiaomi AX3000** (`devices/xiaomi-ax3000.nix`):
```bash
# 2.4GHz WiFi
uci set wireless.radio0.country='US'
uci set wireless.default_radio0.ssid='YourNetwork-2G'
uci set wireless.default_radio0.key='YourPassword'
uci set wireless.radio0.disabled='0'

# 5GHz WiFi
uci set wireless.radio1.country='US'
uci set wireless.default_radio1.ssid='YourNetwork-5G'
uci set wireless.default_radio1.key='YourPassword'
uci set wireless.radio1.disabled='0'
```

### Adding Packages

Add packages to common configuration (`lib/common.nix`) or device-specific files:

```nix
# In common.nix for all devices
packages = [
  "luci"
  "your-package-name"
  # ... existing packages
];

# In device-specific files for one device
extraPackages = [
  "device-specific-package"
  # ... existing packages
];
```

### Network Settings

Modify IP addresses and network configuration in device files:

```bash
# Change IP address
uci set network.lan.ipaddr='192.168.3.1'

# Change DHCP range
uci set dhcp.lan.start='50'
uci set dhcp.lan.limit='200'
```

## Adding New Devices

1. **Create device configuration** in `devices/your-device.nix`:

```nix
{
  pkgs,
  common,
}: {
  name = "your-device";
  description = "Your Device Description";
  
  target = "your-target";
  variant = "your-variant";
  
  extraPackages = [
    # Device-specific packages
  ];
  
  deviceConfig = ''
    # Device-specific UCI configuration
  '';
  
  extraFiles = pkgs.runCommand "your-device-files" {} ''
    # Device-specific files
  '';
}
```

2. **Add to flake.nix**:

```nix
packages.${buildSystem} = {
  # ... existing devices
  your-device = buildDevice {
    deviceConfig = ./devices/your-device.nix;
  };
};
```

3. **Update GitHub Actions** to include your device in the build matrix

4. **Update documentation** and Justfile help

## Finding Device Information

### OpenWRT Device Database

1. Visit [OpenWRT Firmware Selector](https://firmware-selector.openwrt.org/)
2. Search for your device model
3. Note the **target** and **subtarget** values
4. Check supported packages and features

### Using Nix Commands

```bash
# List all available device profiles
just profiles

# Search for specific devices
nix run github:astro/nix-openwrt-imagebuilder#profiles-list | grep -i xiaomi

# Search for packages
just search wireless
just search vpn
```

## Development

### Local Development Environment

```bash
# Enter development shell
nix develop

# Available in all shells:
just validate    # Validate configuration
just check       # Check syntax
just update      # Update dependencies
just metadata    # Show flake metadata
```

### Testing Configuration Changes

```bash
# Quick validation
just validate

# Test device configurations
nix eval .#lib.devices.bpi-r4.name
nix eval .#lib.devices.xiaomi-ax3000.target

# Check all packages resolve
nix eval .#lib.devices.bpi-r4.extraPackages
```

### Cross-Platform Development

The repository supports development on:
- ✅ **macOS** (aarch64-darwin, x86_64-darwin)
- ✅ **Linux** (x86_64-linux, aarch64-linux)
- ✅ **Windows** (via WSL)

Only **building images** requires x86_64-Linux (use GitHub Actions if needed).

## Advanced Configuration

### VPN Setup (WireGuard)

Both devices include WireGuard support. Add configuration:

```bash
# Generate keys
wg genkey | tee private.key | wg pubkey > public.key

# Add to device configuration
uci set network.wg0=interface
uci set network.wg0.proto='wireguard'
uci set network.wg0.private_key='<private-key>'
uci set network.wg0.listen_port='51820'
```

### Performance Optimization

**BPI-R4** (High-performance router):
```bash
# Enable hardware NAT
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'

# 10GbE optimizations
uci set network.wan.mtu='9000'  # Jumbo frames
```

**Xiaomi AX3000** (Home router):
```bash
# Fast path acceleration
echo 1 > /proc/fast_classifier/skip_to_bridge_ingress
```

### Quality of Service (QoS)

Configure SQM for your internet speed:

```bash
# Set your actual speeds (in kbps)
uci set sqm.eth0.download='200000'  # 200 Mbps
uci set sqm.eth0.upload='50000'     # 50 Mbps
```

## Troubleshooting

### Build Issues

```bash
# Check configuration
just validate

# Clear cache and rebuild
nix store gc
just clean
just update
just build

# Force rebuild specific device
just rebuild xiaomi-ax3000
```

### Network Issues

```bash
# Check device status after flashing
ping 192.168.1.1  # BPI-R4
ping 192.168.2.1  # Xiaomi AX3000

# SSH access
ssh root@192.168.1.1

# Check OpenWRT logs
logread
dmesg
```

### GitHub Actions Failures

1. **Check build logs** in Actions tab
2. **Download failed build logs** from artifacts
3. **Test locally** if you have x86_64-Linux
4. **Check OpenWRT upstream** for package changes

## Updating

### Regular Updates

```bash
# Update Nix flake inputs
just update

# Rebuild with latest packages
just build-all

# Check for new OpenWRT releases
nix run github:astro/nix-openwrt-imagebuilder#latest-release
```

### OpenWRT Version Updates

The nix-openwrt-imagebuilder automatically tracks OpenWRT releases. Your images will use the latest stable version available.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Resources

- 📚 [OpenWRT Documentation](https://openwrt.org/docs/start)
- 🍌 [BananaPi BPI-R4 Wiki](https://wiki.banana-pi.org/Banana_Pi_BPI-R4)
- 📱 [Xiaomi Router OpenWRT Support](https://openwrt.org/toh/xiaomi/start)
- 🏗️ [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder)
- 💬 [OpenWRT Forum](https://forum.openwrt.org/)
- 🔧 [UCI Configuration Guide](https://openwrt.org/docs/guide-user/base-system/uci)

---

**⚠️ Important**: Always backup your current firmware before flashing new images!