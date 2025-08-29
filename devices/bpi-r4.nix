# BananaPi BPI-R4 specific configuration
{
  pkgs,
  common,
}: rec {
  # Device identification
  name = "bpi-r4";
  description = "BananaPi BPI-R4-8G - MediaTek Filogic MT7988A (8GB RAM, WiFi 7 BPI-R4-NIC-BE14)";

  # Hardware profile for OpenWRT ImageBuilder
  profile = "bananapi_bpi-r4";

  # Note: This is specifically for BPI-R4-8G (8GB RAM variant)
  # The 8GB version requires different firmware than the 4GB version
  # Original listing: BPI-R4-8G-BE1350-WIFILMP4_1-SDK-20240318
  # MT7988A SoC supports WiFi 7, 4G/5G, high-performance networking
  #
  # CRITICAL: BL2 (Boot Loader 2) must be updated for 8GB RAM recognition
  # Without BL2 update, only 4GB will be recognized by OpenWRT
  # See: https://forum.banana-pi.org/t/bpi-r4-successfully-upgraded-8gb-ram-on-bpi-r4/17882/78
  #
  # WiFi Module: BPI-R4-NIC-BE14 (WiFi 7 accessory module)
  # Hardware specs: 4x 1GbE + 2x 10GbE SFP+ ports
  # SFP+ requirement: Fixed 10Gbps serdes, PIN6 must be GND for 3.3V power

  # Device-specific packages (in addition to common ones)
  extraPackages = [
    # BPI-R4 specific networking
    "kmod-mt7988-eth" # Ethernet driver
    "kmod-phylink" # PHY link support for 1GbE and SFP+

    # 10GbE SFP+ support (2x ports, fixed 10Gbps serdes)
    "ethtool"
    "kmod-sfp" # SFP+ module support
    "sfputil" # SFP+ diagnostic utilities

    # Advanced routing for high-end router
    "bird2" # BGP/OSPF routing
    "babeld" # Babel routing protocol

    # Performance monitoring
    "collectd"
    "luci-app-statistics"
    "rrdtool1"

    # VPN support
    "wireguard-tools"
    "kmod-wireguard"
    "openvpn-openssl"

    # QoS and traffic shaping
    "tc"
    "kmod-sched"
    "kmod-ifb"
    "sqm-scripts"
    "luci-app-sqm"

    # High-performance packages for 8GB RAM
    "irqbalance" # Distribute IRQs across CPU cores
    "kmod-nf-conntrack-netlink" # Advanced connection tracking
    "netperf" # Network performance testing
    "bmon" # Bandwidth monitoring
  ];

  # Device-specific UCI configuration
  deviceConfig = ''
    # Set hostname
    uci set system.@system[0].hostname='bpi-r4'

    # Configure LAN interface (adjust as needed)
    uci set network.lan.proto='static'
    uci set network.lan.ipaddr='192.168.1.1'
    uci set network.lan.netmask='255.255.255.0'

    # Configure DHCP
    uci set dhcp.lan.start='100'
    uci set dhcp.lan.limit='150'
    uci set dhcp.lan.leasetime='12h'

    # WiFi 7 configuration (BPI-R4-NIC-BE14 module, tri-band)
    # 2.4GHz WiFi 7 (802.11be)
    # uci set wireless.radio0.country='US'
    # uci set wireless.radio0.channel='auto'
    # uci set wireless.radio0.htmode='EHT20'  # WiFi 7 mode
    # uci set wireless.default_radio0.ssid='BPI-R4-2G'
    # uci set wireless.default_radio0.encryption='sae'
    # uci set wireless.default_radio0.key='your-wifi-password'
    # uci set wireless.radio0.disabled='0'

    # 5GHz WiFi 7 (802.11be)
    # uci set wireless.radio1.country='US'
    # uci set wireless.radio1.channel='auto'
    # uci set wireless.radio1.htmode='EHT160'  # WiFi 7 high bandwidth
    # uci set wireless.default_radio1.ssid='BPI-R4-5G'
    # uci set wireless.default_radio1.encryption='sae'
    # uci set wireless.default_radio1.key='your-wifi-password'
    # uci set wireless.radio1.disabled='0'

    # 6GHz WiFi 7 (802.11be)
    # uci set wireless.radio2.country='US'
    # uci set wireless.radio2.channel='auto'
    # uci set wireless.radio2.htmode='EHT320'  # WiFi 7 maximum bandwidth
    # uci set wireless.default_radio2.ssid='BPI-R4-6G'
    # uci set wireless.default_radio2.encryption='sae'
    # uci set wireless.default_radio2.key='your-wifi-password'
    # uci set wireless.radio2.disabled='0'

    # Configure SQM for high-speed connections
    uci set sqm.eth1=queue
    uci set sqm.eth1.enabled='1'
    uci set sqm.eth1.interface='eth1'
    uci set sqm.eth1.download='1000000'  # 1Gbps download
    uci set sqm.eth1.upload='1000000'    # 1Gbps upload
    uci set sqm.eth1.script='piece_of_cake.qos'

    # Enable 10GbE optimizations
    uci set network.wan.mtu='9000'       # Enable jumbo frames if supported

    # SFP+ port configuration (2x 10GbE ports)
    # Note: SFP serdes speed fixed at 10Gbps, PIN6 must be GND
    # Compatible with 10G SFP+ modules only
    # uci set network.sfp1=interface
    # uci set network.sfp1.proto='static'
    # uci set network.sfp1.device='sfp-eth0'
    # uci set network.sfp2=interface
    # uci set network.sfp2.proto='static'
    # uci set network.sfp2.device='sfp-eth1'

    # Configure firewall for VPN
    uci add firewall rule
    uci set firewall.@rule[-1].name='Allow-WireGuard'
    uci set firewall.@rule[-1].src='wan'
    uci set firewall.@rule[-1].dest_port='51820'
    uci set firewall.@rule[-1].proto='udp'
    uci set firewall.@rule[-1].target='ACCEPT'

    # Performance optimizations for 8GB RAM
    # Increase connection tracking table size
    echo 'net.netfilter.nf_conntrack_max = 262144' >> /etc/sysctl.conf
    echo 'net.netfilter.nf_conntrack_buckets = 65536' >> /etc/sysctl.conf

    # Optimize network buffers for high throughput
    echo 'net.core.rmem_max = 134217728' >> /etc/sysctl.conf
    echo 'net.core.wmem_max = 134217728' >> /etc/sysctl.conf
    echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf

    # Enable BBR congestion control for better performance
    echo 'net.core.default_qdisc = fq' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf
  '';

  # Device-specific files
  extraFiles = pkgs.runCommand "bpi-r4-files" {} ''
    mkdir -p $out/etc/uci-defaults
    mkdir -p $out/etc/config

    # Device-specific configuration
    cat > $out/etc/uci-defaults/95-bpi-r4-config <<'EOF'
    #!/bin/sh

    ${deviceConfig}

    # Commit device-specific changes
    uci commit
    EOF

    chmod +x $out/etc/uci-defaults/95-bpi-r4-config
  '';
}
