{
  description = "Multi-device OpenWRT configuration for BananaPi BPI-R4 and Xiaomi routers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openwrt-imagebuilder.url = "github:astro/nix-openwrt-imagebuilder";
  };

  outputs = {
    self,
    nixpkgs,
    openwrt-imagebuilder,
  }: let
    # OpenWRT ImageBuilder only works on x86_64-linux
    buildSystem = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${buildSystem};

    # Support for development on other systems (like aarch64-darwin)
    supportedSystems = ["x86_64-linux" "aarch64-darwin" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Import our modular builder
    buildDevice = import ./lib/builder.nix {
      inherit pkgs openwrt-imagebuilder;
    };
  in {
    # OpenWRT images can only be built on x86_64-linux
    packages.${buildSystem} = {
      # BananaPi BPI-R4 configuration
      bpi-r4 = buildDevice {
        deviceConfig = ./devices/bpi-r4.nix;
      };

      # Xiaomi Mi WiFi R3G v1 configuration
      xiaomi-r3g = buildDevice {
        deviceConfig = ./devices/xiaomi-r3g.nix;
      };

      # Default to BPI-R4 for convenience
      default = self.packages.${buildSystem}.bpi-r4;
    };

    # Development shells for all supported systems
    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixVersions.stable
          git
          just # For using the Justfile
          jq # For JSON processing
        ];

        shellHook = ''
          echo "🏠 Multi-Device OpenWRT Build Environment"
          echo "System: ${system}"
          echo ""
          echo "📱 Available devices:"
          echo "  • BananaPi BPI-R4 (MediaTek Filogic)"
          echo "  • Xiaomi Mi WiFi R3G v1 (MediaTek MT7621)"
          echo ""
          ${
            if system == "x86_64-linux"
            then ''
              echo "✅ This system can build OpenWRT images"
              echo "Available commands:"
              echo "  nix build .#bpi-r4        - Build BPI-R4 image"
              echo "  nix build .#xiaomi-r3g    - Build Xiaomi image"
              echo "  just build-all            - Build all devices"
              echo "  just info                 - Show build artifacts"
            ''
            else ''
              echo "⚠️  OpenWRT builds require x86_64-linux"
              echo "💡 Use GitHub Actions or a Linux machine to build"
              echo "Available commands:"
              echo "  just check          - Validate configuration"
              echo "  just update         - Update dependencies"
              echo "  git push            - Trigger GitHub Actions build"
            ''
          }
          echo ""
          echo "📚 Documentation:"
          echo "  just help           - Show all commands"
          echo "  cat README.md       - Read full documentation"
        '';
      };
    });

    # Expose device configurations for inspection
    lib = {
      devices = {
        bpi-r4 = import ./devices/bpi-r4.nix {
          inherit pkgs;
          common = import ./lib/common.nix {inherit pkgs;};
        };
        xiaomi-r3g = import ./devices/xiaomi-r3g.nix {
          inherit pkgs;
          common = import ./lib/common.nix {inherit pkgs;};
        };
      };
      common = import ./lib/common.nix {inherit pkgs;};
    };
  };
}
