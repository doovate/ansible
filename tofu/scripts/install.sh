#!/bin/bash
export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive
journalctl --vacuum-size=500M

# Update, upgrade and install necessary packages
apt-get update -y && apt-get upgrade -y
apt-get install ca-certificates software-properties-common lsb-release apt-transport-https curl wget neovim htop zip gzip git -y

# Configure DNS with systemd-resolved
echo "Configuring DNS with systemd-resolved"
mkdir -p /etc/systemd/resolved.conf.d
tee /etc/systemd/resolved.conf.d/dns.conf > /dev/null <<EOF
[Resolve]
DNS=192.168.24.60 1.1.1.1
FallbackDNS=1.1.1.1
Domains=doovate.com
EOF

# Enable and configure systemd-resolved
systemctl enable systemd-resolved
systemctl start systemd-resolved
rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved

# Allow 53 & 8081 traffic
ufw allow 53 && ufw allow 53/tcp && ufw allow 8081/tcp
ufw reload

echo "Installation complete"

