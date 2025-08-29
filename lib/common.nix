# Common OpenWRT configuration shared across all devices
{pkgs}: rec {
  # Common packages for all devices
  packages = [
    # Essential packages
    "luci" # Web interface
    "luci-ssl" # HTTPS support
    "luci-theme-bootstrap" # Clean theme

    # Network utilities
    "tcpdump"
    "iperf3"
    "curl"
    "wget-ssl"
    "openssh-sftp-server"

    # System tools
    "htop"
    "nano"
    "vim"
    "lsof"

    # WiFi and networking
    "wpad-wolfssl" # WiFi with WPA3
    "hostapd-common"
    "iw"
    "iwinfo"

    # USB and storage support
    "kmod-usb-storage"
    "kmod-fs-ext4"
    "kmod-fs-ntfs"
    "block-mount"

    # Additional utilities
    "rsync"
    "screen"
    "bind-dig"
  ];

  # Services to disable by default
  disabledServices = [
    # Add services you want to disable across all devices
    # "dnsmasq"  # if you want to use different DNS
  ];

  # Common UCI configuration that applies to all devices
  uciConfig = ''
    # Set timezone (adjust as needed)
    uci set system.@system[0].timezone='UTC'
    uci set system.@system[0].zonename='UTC'

    # Configure NTP
    uci set system.ntp.enabled='1'
    uci add_list system.ntp.server='pool.ntp.org'
    uci add_list system.ntp.server='time.cloudflare.com'

    # SSH configuration - disable password auth
    uci set dropbear.@dropbear[0].PasswordAuth='0'
    uci set dropbear.@dropbear[0].RootPasswordAuth='0'
    uci set dropbear.@dropbear[0].Port='22'

    # Basic firewall configuration
    uci set firewall.@defaults[0].syn_flood='1'
    uci set firewall.@defaults[0].input='ACCEPT'
    uci set firewall.@defaults[0].output='ACCEPT'
    uci set firewall.@defaults[0].forward='REJECT'

    # Enable hardware flow offloading if available
    uci set firewall.@defaults[0].flow_offloading='1'
    uci set firewall.@defaults[0].flow_offloading_hw='1'
  '';

  # Common SSH public key (replace with your actual key)
  sshPublicKey = ''
    # Replace this with your actual SSH public key
    # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... your-email@domain.com
    # or ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your-email@domain.com
  '';

  # Common files that all devices should have
  commonFiles = pkgs.runCommand "common-openwrt-files" {} ''
    mkdir -p $out/etc/uci-defaults
    mkdir -p $out/root/.ssh
    mkdir -p $out/etc/config

    # Common UCI configuration script
    cat > $out/etc/uci-defaults/90-common-config <<'EOF'
    #!/bin/sh

    ${uciConfig}

    # Commit all changes
    uci commit
    EOF

    # SSH public key
    cat > $out/root/.ssh/authorized_keys <<'EOF'
    ${sshPublicKey}
    EOF

    chmod 600 $out/root/.ssh/authorized_keys
    chmod +x $out/etc/uci-defaults/90-common-config
  '';
}
