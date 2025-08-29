# Helper function to build OpenWRT images with common + device-specific config
{
  pkgs,
  openwrt-imagebuilder,
}: let
  profiles = openwrt-imagebuilder.lib.profiles {inherit pkgs;};
  common = import ./common.nix {inherit pkgs;};
in
  # Function to build a device configuration
  {deviceConfig}: let
    device = import deviceConfig {inherit pkgs common;};

    # Combine common and device-specific packages
    allPackages = common.packages ++ device.extraPackages;

    # Combine common and device-specific files
    combinedFiles = pkgs.runCommand "${device.name}-combined-files" {} ''
      mkdir -p $out

      # Copy common files first
      if [ -d "${common.commonFiles}" ]; then
        cp -r ${common.commonFiles}/* $out/ 2>/dev/null || true
      fi

      # Copy device-specific files (will override common files if they conflict)
      if [ -d "${device.extraFiles}" ]; then
        cp -r ${device.extraFiles}/* $out/ 2>/dev/null || true
      fi

      # Set proper permissions
      find $out -type f -name "*.sh" -exec chmod +x {} \;
      find $out -type f -path "*/uci-defaults/*" -exec chmod +x {} \;
    '';

    # Build configuration object using the correct API
    config = profiles.identifyProfile device.profile // {
      packages = allPackages;
      disabledServices = common.disabledServices;
      files = combinedFiles;
    };
  in
    openwrt-imagebuilder.lib.build config
