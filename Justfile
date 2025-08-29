# Build specific device (default: bpi-r4)
build DEVICE="bpi-r4":
    #!/usr/bin/env bash
    if [[ "$(uname -m)" == "x86_64" && "$(uname -s)" == "Linux" ]]; then
        echo "🔨 Building OpenWRT image for {{DEVICE}}"
        nix build .#{{DEVICE}} --print-build-logs
    else
        echo "⚠️  OpenWRT builds require x86_64-linux system"
        echo "💡 Current system: $(uname -s) $(uname -m)"
        echo "💡 Use GitHub Actions or run on a Linux x86_64 machine"
        echo "💡 Alternatively, use: nix build .#{{DEVICE}} --system x86_64-linux"
        exit 1
    fi

# Build all devices
build-all:
    #!/usr/bin/env bash
    if [[ "$(uname -m)" == "x86_64" && "$(uname -s)" == "Linux" ]]; then
        echo "🏭 Building all devices..."
        echo "Building BPI-R4..."
        nix build .#bpi-r4 --print-build-logs -o result-bpi-r4
        echo "Building Xiaomi R3G..."
        nix build .#xiaomi-r3g --print-build-logs -o result-xiaomi-r3g
        echo "✅ All builds complete!"
    else
        echo "⚠️  OpenWRT builds require x86_64-linux system"
        echo "💡 Use GitHub Actions or run on a Linux x86_64 machine"
        exit 1
    fi

# Build with verbose output and rebuild cache
rebuild DEVICE="bpi-r4":
    #!/usr/bin/env bash
    if [[ "$(uname -m)" == "x86_64" && "$(uname -s)" == "Linux" ]]; then
        nix build .#{{DEVICE}} --rebuild --print-build-logs --verbose
    else
        echo "⚠️  OpenWRT builds require x86_64-linux system"
        echo "💡 Use GitHub Actions or run on a Linux x86_64 machine"
        exit 1
    fi

# Force build on x86_64-linux (may require emulation or remote builder)
build-force DEVICE="bpi-r4":
    nix build .#{{DEVICE}} --system x86_64-linux --print-build-logs

# Update flake inputs
up:
    nix flake update

# Check flake syntax and configuration
check:
    nix flake check

# Enter development shell
shell:
    nix develop

# Clean build artifacts
clean:
    rm -rf result result-*

# Show available OpenWRT profiles (requires network access)
profiles:
    nix run github:astro/nix-openwrt-imagebuilder#profiles-list

# Search for OpenWRT packages
search PACKAGE:
    nix run github:astro/nix-openwrt-imagebuilder#search -- {{PACKAGE}}

# Show build output info for all devices
info:
    @echo "📱 Multi-Device Build Artifacts:"
    @echo ""
    @for result_dir in result result-* ; do \
        if [ -d "$$result_dir" ]; then \
            device_name=$$(echo $$result_dir | sed 's/result-//; s/result/default/'); \
            echo "🔹 $$device_name ($$result_dir):"; \
            find "$$result_dir" -type f -name "*.bin" -o -name "*.img" -o -name "*sysupgrade*" -o -name "*factory*" | head -5; \
            echo "   📊 Size: $$(du -sh $$result_dir | cut -f1)"; \
            echo ""; \
        fi \
    done
    @if ! ls result* >/dev/null 2>&1; then \
        echo "❌ No build artifacts found. Run 'just build' or 'just build-all' first."; \
    fi

# Show info for specific device
info-device DEVICE:
    @if [ -d "result-{{DEVICE}}" ] || ([ "{{DEVICE}}" = "default" ] && [ -d "result" ]); then \
        result_dir=$$([ "{{DEVICE}}" = "default" ] && echo "result" || echo "result-{{DEVICE}}"); \
        echo "🔹 {{DEVICE}} artifacts in $$result_dir:"; \
        echo ""; \
        find "$$result_dir" -type f -name "*.bin" -o -name "*.img" -o -name "*sysupgrade*" -o -name "*factory*"; \
        echo ""; \
        echo "📊 File sizes:"; \
        du -h "$$result_dir"/* | head -10; \
        echo ""; \
        echo "📁 All files:"; \
        ls -la "$$result_dir"/; \
    else \
        echo "❌ No build artifacts found for {{DEVICE}}. Run 'just build {{DEVICE}}' first."; \
    fi

# Show flake metadata
metadata:
    nix flake metadata

# Format Nix files
fmt:
    nix fmt

# Show system information
sysinfo:
    @echo "🖥️  System Information:"
    @echo "Nix version: $(nix --version)"
    @echo "System: $(uname -a)"
    @echo "Available disk space:"
    @df -h . | tail -1
    @echo "Available memory:"
    @free -h | head -2

# Test the configuration without building
test:
    nix eval .#bpi-r4 --json | jq 'keys[]'

# Show the generated UCI configuration
show-uci:
    @echo "🔧 Generated UCI Configuration:"
    @echo "This shows what will be applied on first boot:"
    @nix build .#bpi-r4 --no-link --print-out-paths | xargs -I {} find {} -name "*uci*" -type f -exec echo "=== {} ===" \; -exec cat {} \;

# Validate the flake
validate:
    @echo "✅ Validating flake configuration..."
    nix flake check --verbose
    @echo "✅ Configuration validated for development on this platform"

# Quick development cycle: clean, update, build
dev: clean up build info

# Show help
help:
    @echo "🏠 Multi-Device OpenWRT Build Commands:"
    @echo ""
    @echo "📱 Supported Devices:"
    @echo "  • bpi-r4     - BananaPi BPI-R4 (MediaTek Filogic)"
    @echo "  • xiaomi-r3g - Xiaomi Mi WiFi R3G v1 (MediaTek MT7621)"
    @echo ""
    @echo "📦 Building:"
    @echo "  build [DEVICE]        - Build specific device (default: bpi-r4)"
    @echo "  build-all             - Build all devices"
    @echo "  rebuild [DEVICE]      - Force rebuild with verbose output"
    @echo "  build-force [DEVICE]  - Force build on x86_64-linux"
    @echo "  clean                 - Remove build artifacts"
    @echo ""
    @echo "🔍 Information:"
    @echo "  info                  - Show artifacts for all devices"
    @echo "  info-device DEVICE    - Show artifacts for specific device"
    @echo "  show-uci              - Show generated UCI configuration"
    @echo "  sysinfo               - Show system information"
    @echo "  metadata              - Show flake metadata"
    @echo ""
    @echo "🛠️  Development:"
    @echo "  shell                 - Enter development shell"
    @echo "  check                 - Check flake syntax"
    @echo "  validate              - Full validation suite"
    @echo "  test                  - Test configuration without building"
    @echo "  fmt                   - Format Nix files"
    @echo ""
    @echo "🔄 Maintenance:"
    @echo "  up                    - Update flake inputs"
    @echo "  dev                   - Quick dev cycle (clean + update + build + info)"
    @echo ""
    @echo "🔍 OpenWRT:"
    @echo "  profiles              - List available OpenWRT device profiles"
    @echo "  search PACKAGE        - Search for OpenWRT packages"
    @echo ""
    @echo "📚 Examples:"
    @echo "  just build bpi-r4           - Build BPI-R4 image"
    @echo "  just build xiaomi-r3g       - Build Xiaomi image"
    @echo "  just build-all              - Build all devices"
    @echo "  just info-device bpi-r4     - Show BPI-R4 artifacts"
    @echo "  just search wireless        - Find wireless packages"
