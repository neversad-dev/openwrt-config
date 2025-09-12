# OpenWrt BPI-R4 Custom Image

Custom OpenWrt firmware build for Banana Pi R4 router with personalized configuration built in.

## What This Repository Does

This repository builds a custom OpenWrt image with:
- **Custom IP configuration**: LAN network set to `10.11.0.1/24`
- **Controlled LED behavior**: RJ45 port LEDs show link status only (no constant flashing)
- **Minimal package set**: LuCI web interface for basic management
- **Automated builds**: GitHub Actions workflow for CI/CD

## Quick Start

### Local Build

> **Requirements**: x86_64 Linux system with Nix installed

```bash
# Clone and build
git clone git@github.com:neversad-dev/openwrt-config.git
cd openwrt-config
nix build .#bpi-r4

# Find firmware files
ls result/
# Look for: openwrt-*-factory.bin or openwrt-*-sysupgrade.bin
```

### GitHub Actions Build

1. Push changes to `main` branch
2. Download artifacts from Actions tab
3. Flash the `.bin` file to your BPI-R4

## Customization

To modify the configuration, edit `flake.nix` and adjust:
- **IP address**: Change `network.lan.ipaddr`
- **Packages**: Add to `packages = [ ... ]` list
- **LED behavior**: Modify `system.led_*` settings

## Files

- `flake.nix` - Main build configuration
- `.github/workflows/build.yml` - Automated build workflow

## Hardware

**Target Device**: Banana Pi R4  
**Profile**: `bananapi_bpi-r4`  
**Architecture**: MediaTek MT7988A (ARM64)

## Versioning

This project uses the versioning scheme: `vOPENWRT_VERSION-CUSTOM_VERSION`

- **OpenWrt Version**: Base OpenWrt release (e.g., `24.10.2`)
- **Custom Version**: Our configuration version (e.g., `1.0.0`)

Example: `v24.10.2-1.0.0` = OpenWrt 24.10.2 with our custom config v1.0.0

## Links

- [Banana Pi R4 Wiki](https://openwrt.org/toh/sinovoip/bananapi_bpi-r4)
- [nix-openwrt-imagebuilder](https://github.com/astro/nix-openwrt-imagebuilder)
- [OpenWrt Documentation](https://openwrt.org/docs/start)