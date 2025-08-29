# Xiaomi Mi WiFi R3G v1 specific configuration
{
  pkgs,
  common,
}: rec {
  # Device identification
  name = "xiaomi-r3g";
  description = "Xiaomi Mi WiFi R3G v1 - MediaTek MT7621";

  # Hardware target for Xiaomi Mi WiFi R3G v1
  target = "ramips";
  variant = "mt7621";

  # For other Xiaomi models, use one of these targets:
  # R3G v1: target = "ramips"; variant = "mt7621";
  # AX1800: target = "mediatek"; variant = "mt7622";
  # AX3600: target = "ipq807x"; variant = "generic";
  # AX6000: target = "mediatek"; variant = "mt7622";
  # AX9000: target = "ipq807x"; variant = "generic";

  # Device-specific packages (in addition to common ones)
  extraPackages = [
    # MT7621 specific drivers
    "kmod-mt76x2" # WiFi driver for MT7612E
    "mt7621-firmware" # Firmware for MT7621

    # WiFi optimization
    "wireless-regdb"
    "wifi-scripts"

    # LED control
    "kmod-leds-gpio"
    "kmod-ledtrig-default-on"
    "kmod-ledtrig-timer"
    "kmod-ledtrig-netdev"

    # USB support (R3G v1 has USB ports)
    "kmod-usb2"
    "kmod-usb-ohci"
    "kmod-usb-uhci"
    "kmod-usb-storage"

    # Network acceleration for MT7621
    "kmod-mt7621-eth" # Ethernet driver

    # Additional utilities
    "usbutils" # USB device utilities
    "pciutils" # PCI device utilities
  ];

  # Device-specific UCI configuration
  deviceConfig = ''
    # Set hostname
    uci set system.@system[0].hostname='xiaomi-r3g'

    # Configure LAN interface
    uci set network.lan.proto='static'
    uci set network.lan.ipaddr='192.168.2.1'    # Different IP from BPI-R4
    uci set network.lan.netmask='255.255.255.0'

    # Configure DHCP
    uci set dhcp.lan.start='100'
    uci set dhcp.lan.limit='150'
    uci set dhcp.lan.leasetime='12h'

    # WiFi configuration for Xiaomi R3G v1 (dual-band AC1200)
    # 2.4GHz WiFi (MT7603E)
    # uci set wireless.radio0.country='US'
    # uci set wireless.radio0.channel='6'
    # uci set wireless.radio0.htmode='HT20'
    # uci set wireless.default_radio0.ssid='Xiaomi-R3G-2G'
    # uci set wireless.default_radio0.encryption='psk2'
    # uci set wireless.default_radio0.key='your-wifi-password'
    # uci set wireless.radio0.disabled='0'

    # 5GHz WiFi (MT7612E)
    # uci set wireless.radio1.country='US'
    # uci set wireless.radio1.channel='36'
    # uci set wireless.radio1.htmode='VHT80'
    # uci set wireless.default_radio1.ssid='Xiaomi-R3G-5G'
    # uci set wireless.default_radio1.encryption='psk2'
    # uci set wireless.default_radio1.key='your-wifi-password'
    # uci set wireless.radio1.disabled='0'

    # Configure SQM for typical home connection
    uci set sqm.eth0=queue
    uci set sqm.eth0.enabled='1'
    uci set sqm.eth0.interface='eth0'
    uci set sqm.eth0.download='100000'   # 100Mbps download (adjust to your speed)
    uci set sqm.eth0.upload='50000'     # 50Mbps upload (adjust to your speed)
    uci set sqm.eth0.script='piece_of_cake.qos'

    # LED configuration
    uci set system.led_status=led
    uci set system.led_status.name='status'
    uci set system.led_status.sysfs='blue:status'
    uci set system.led_status.trigger='heartbeat'

    # Configure WiFi LEDs
    uci set system.led_wifi2g=led
    uci set system.led_wifi2g.name='wifi2g'
    uci set system.led_wifi2g.sysfs='green:wifi2g'
    uci set system.led_wifi2g.trigger='phy0tpt'

    uci set system.led_wifi5g=led
    uci set system.led_wifi5g.name='wifi5g'
    uci set system.led_wifi5g.sysfs='green:wifi5g'
    uci set system.led_wifi5g.trigger='phy1tpt'

    # Enable fast path acceleration if available
    echo 1 > /proc/sys/net/netfilter/nf_conntrack_tcp_no_window_check
    echo 1 > /proc/fast_classifier/skip_to_bridge_ingress
  '';

  # Device-specific files
  extraFiles = pkgs.runCommand "xiaomi-r3g-files" {} ''
    mkdir -p $out/etc/uci-defaults
    mkdir -p $out/etc/config
    mkdir -p $out/etc/hotplug.d/ieee80211

    # Device-specific configuration
    cat > $out/etc/uci-defaults/95-xiaomi-r3g-config <<'EOF'
    #!/bin/sh

    ${deviceConfig}

    # Commit device-specific changes
    uci commit
    EOF

    # WiFi regulatory domain script
    cat > $out/etc/hotplug.d/ieee80211/00-wifi-country <<'EOF'
    #!/bin/sh

    [ "$ACTION" = add ] && {
        # Set regulatory domain for WiFi
        iw reg set US  # Change to your country code
    }
    EOF

    chmod +x $out/etc/uci-defaults/95-xiaomi-r3g-config
    chmod +x $out/etc/hotplug.d/ieee80211/00-wifi-country
  '';
}
