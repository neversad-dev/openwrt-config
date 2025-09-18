# Copilot Instructions for openwrt-config

## Repository Overview

This repository builds **custom OpenWrt firmware** for multiple router targets using Nix and the nix-openwrt-imagebuilder. It creates personalized router firmware with device-specific network configurations, LED behavior, and package sets organized in a modular structure.

### Key Facts
- **Type**: Multi-target OpenWrt firmware builder using Nix flakes
- **Target Hardware**: Multiple devices (BPI-R4, future routers)
- **Architecture**: Modular configuration system with device-specific modules
- **Languages**: Nix (primary), shell scripts in workflows
- **Build Platform**: **x86_64-linux ONLY** (ImageBuilder limitation)
- **Output**: Custom firmware images (.itb, .img.gz, bootloader files)
- **License**: MIT
- **Status**: Early stage project with growing device support

## Build System & Commands

### Prerequisites
- **Platform requirement**: **MUST run on x86_64-linux** (Ubuntu/NixOS)
- **Nix version**: 2.28.3+ with experimental features (`nix-command flakes`)
- **Build dependency**: nix-openwrt-imagebuilder from astro/nix-openwrt-imagebuilder
- **Target profiles**: Device-specific profiles (e.g., `bananapi_bpi-r4`)

### Essential Commands

**CRITICAL**: All build commands only work on x86_64-linux systems.

```bash
# Validation (works on all systems)
nix flake check --accept-flake-config
nix fmt . --accept-flake-config -- --check

# Build commands (x86_64-linux only)
nix build .#<device>                    # Build firmware for specific device
nix build .#bpi-r4                     # Build BPI-R4 firmware
nix build .#<device> --print-build-logs # Build with detailed logs
nix build .#<device> --dry-run          # Test build without execution
```

### Build Process & Outputs

The build process:
1. **Downloads**: OpenWrt ImageBuilder for target platform
2. **Configures**: Device-specific network settings, LED behavior, packages
3. **Generates**: Multiple firmware files for different use cases

**Expected build outputs** (in `result/` directory):
- `*-sysupgrade.itb` - Upgrade image for existing OpenWrt installations
- `*-sdcard.img.gz` - SD card image for fresh installations
- `*-preloader.bin` - Bootloader preloader
- `*-bl31-uboot.fip` - U-Boot firmware
- `sha256sums` - Checksums for verification
- `*.manifest` - Package manifest

## Project Architecture

### File Structure
```
├── flake.nix                 # Main flake entry point
├── flake.lock               # Dependency lock file (auto-managed)
├── devices/                 # Device-specific configurations
│   ├── bpi-r4/             # Banana Pi R4 configurations
│   │   ├── default.nix     # Main device configuration
│   │   ├── network.nix     # Network-specific settings
│   │   ├── hardware.nix    # Hardware-specific settings (LEDs, etc.)
│   │   └── packages.nix    # Device-specific package lists
│   └── <device>/           # Future device configurations
├── common/                  # Shared configuration modules
│   ├── base.nix            # Base OpenWrt configuration
│   ├── network-common.nix  # Common network utilities
│   └── packages-common.nix # Common package sets
└── hosts/                   # Host-specific configurations
    ├── home-router/        # Home router configuration
    ├── office-router/      # Office router configuration
    └── <hostname>/         # Additional host configurations
```

**Note**: This is an **early-stage project**. The current implementation may not yet have all directories, but new configurations should follow this modular structure.

### Configuration Organization

**Device-specific configurations** go in `devices/<device>/`:
- **`default.nix`**: Main device configuration and profile selection
- **`network.nix`**: Basic network settings (interface definitions, etc.)
- **`hardware.nix`**: Hardware-specific settings (LEDs, GPIO, etc.)
- **`packages.nix`**: Device-specific package lists

**Host-specific configurations** go in `hosts/<hostname>/`:
- **`default.nix`**: Host-specific overrides and customizations
- **`network.nix`**: Host-specific network settings (IP addresses, VLANs, etc.)
- Device + host combination creates final firmware configuration

**Common modules** in `common/`:
- **`base.nix`**: Base OpenWrt configuration shared across devices
- **`network-common.nix`**: Common network utilities and functions
- **`packages-common.nix`**: Common package sets

**Example configuration structure**:
```nix
# devices/bpi-r4/hardware.nix
{
  # LED behavior (link status only, no constant flashing)
  system.led_lan1.mode = "link";
  system.led_lan2.mode = "link";
}

# hosts/home-router/network.nix
{
  network.lan.ipaddr = "10.11.0.1";
  network.lan.netmask = "255.255.255.0";
}

# hosts/home-router/default.nix
{
  system.hostname = "home-router";
  # Host-specific customizations
}
```

## Common Issues & Workarounds

### Platform Limitations
- **macOS/ARM builds**: Will fail with "incompatible system" errors
- **Solution**: Use GitHub Actions or x86_64-linux machine
- **Local testing**: Only possible on x86_64-linux systems

### Build Failures
- **Missing firmware files**: Check `result/` directory contents
- **ImageBuilder errors**: Usually indicate upstream OpenWrt issues
- **Network timeouts**: Retry build, downloads can be flaky

### Known Warnings (Safe to Ignore)
- `The check omitted these incompatible systems` - Expected behavior
- ImageBuilder warnings about missing packages - Usually cosmetic

### Dependency Issues
- **Outdated flake.lock**: Run `nix flake update` to refresh
- **Upstream changes**: Monitor nix-openwrt-imagebuilder for breaking changes
- **OpenWrt versions**: Version extracted automatically from build outputs

## Development Guidelines

### Making Configuration Changes

1. **Choose appropriate location**:
   - Device-specific: Edit files in `devices/<device>/`
   - Host-specific: Edit files in `hosts/<hostname>/`
   - Shared functionality: Edit files in `common/`
   - Main flake: Only edit `flake.nix` for new device/host definitions

2. **Create modular structure**:
   - Separate network, hardware, and package configurations
   - Use device + host combination for final configuration
   - Import common modules where applicable

3. **Test locally** (x86_64-linux only): `nix build .#<device>`
4. **Validate formatting**: `nix fmt . --accept-flake-config -- --check`
5. **Commit changes**: Standard git workflow
6. **CI validation**: GitHub Actions will test the build

### Common Customizations

**Host Network Settings** (`hosts/<hostname>/network.nix`):
```nix
{
  network.lan.ipaddr = "192.168.1.1";    # Change LAN IP for this host
  network.lan.netmask = "255.255.255.0"; # Change subnet
  # VLANs and other host-specific network config
}
```

**Device Package Management** (`devices/<device>/packages.nix`):
```nix
{
  packages = ["luci" "nano" "htop"];     # Device-specific packages
}
```

**Device LED Behavior** (`devices/<device>/hardware.nix`):
```nix
{
  system.led_lan1.mode = "link tx rx";   # Show activity + link
  system.led_lan1.mode = "none";         # Disable LED
}
```

### Version Management

The repository uses semantic versioning: `vOPENWRT_VERSION-CUSTOM_VERSION`
- **OpenWrt version**: Extracted automatically from build outputs
- **Custom version**: Use Git tags for releases
- **Example**: `v24.10.2-1.0.0` = OpenWrt 24.10.2 with custom config v1.0.0

## Validation Pipeline

The CI pipeline validates:
1. **Code formatting**: Alejandra formatter compliance
2. **Build success**: Full firmware generation
3. **Output verification**: Required firmware files present
4. **Version extraction**: OpenWrt version detection
5. **Artifact upload**: Proper file packaging

### Manual Validation (x86_64-linux only)
```bash
# Full validation sequence
nix flake check --accept-flake-config
nix fmt . --accept-flake-config -- --check
nix build .#<device> --print-build-logs  # Build specific device
ls result/  # Verify outputs
```

