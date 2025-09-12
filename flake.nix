{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    openwrt-imagebuilder.url = "github:astro/nix-openwrt-imagebuilder";
  };

  outputs = {
    nixpkgs,
    openwrt-imagebuilder,
    ...
  }: {
    packages.x86_64-linux.bpi-r4 = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      profiles = openwrt-imagebuilder.lib.profiles {inherit pkgs;};

      config =
        profiles.identifyProfile "bananapi_bpi-r4"
        // {
          # Minimal package set for testing
          packages = ["luci"];

          # Hostname, network, and LED configuration
          files = pkgs.runCommand "image-files" {} ''
            mkdir -p $out/etc/uci-defaults
            cat > $out/etc/uci-defaults/99-custom <<EOF
            uci -q batch << EOI
            set system.@system[0].hostname='bpi-r4'
            set network.lan.ipaddr='10.11.0.1'
            set network.lan.netmask='255.255.255.0'

            # Disable constant flashing on RJ45 LEDs - set to link/activity mode
            set system.led_lan1=led
            set system.led_lan1.name='LAN1'
            set system.led_lan1.sysfs='green:lan1'
            set system.led_lan1.trigger='netdev'
            set system.led_lan1.dev='lan1'
            set system.led_lan1.mode='link'

            set system.led_lan2=led
            set system.led_lan2.name='LAN2'
            set system.led_lan2.sysfs='green:lan2'
            set system.led_lan2.trigger='netdev'
            set system.led_lan2.dev='lan2'
            set system.led_lan2.mode='link'

            set system.led_lan3=led
            set system.led_lan3.name='LAN3'
            set system.led_lan3.sysfs='green:lan3'
            set system.led_lan3.trigger='netdev'
            set system.led_lan3.dev='lan3'
            set system.led_lan3.mode='link'

            set system.led_lan4=led
            set system.led_lan4.name='LAN4'
            set system.led_lan4.sysfs='green:lan4'
            set system.led_lan4.trigger='netdev'
            set system.led_lan4.dev='lan4'
            set system.led_lan4.mode='link'

            # WAN LED
            set system.led_wan=led
            set system.led_wan.name='WAN'
            set system.led_wan.sysfs='green:wan'
            set system.led_wan.trigger='netdev'
            set system.led_wan.dev='wan'
            set system.led_wan.mode='link'

            commit
            EOI
            EOF
          '';
        };
    in
      openwrt-imagebuilder.lib.build config;
  };
}
