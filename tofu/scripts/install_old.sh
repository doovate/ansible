#!/bin/bash
export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive
journalctl --vacuum-size=500M

echo "=== Instalacion de la ostia del docker ==="
# Official docker installation
# Add Docker's official GPG key:
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker $USER || true

############################
#  Setup Loki for logging  #
############################

# Install loki plugin for docker
docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions

# Set up daemon.json file
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "loki",
  "log-opts": {
    "loki-url": "http://192.168.24.50:3100/loki/api/v1/push",
    "loki-batch-size": "400"
  }
}
EOF

# Restart docker daemon
systemctl restart docker

############################


#Updating OS and Installing dependencies
apt-get update -y && apt-get upgrade -y
apt-get install ca-certificates software-properties-common lsb-release apt-transport-https curl wget vim htop zip gzip git -y

# Configurar DNS con systemd-resolved
echo "Configurando DNS con systemd-resolved..."
mkdir -p /etc/systemd/resolved.conf.d
tee /etc/systemd/resolved.conf.d/dns.conf > /dev/null <<EOF
[Resolve]
DNS=192.168.24.60 1.1.1.1
FallbackDNS=1.1.1.1
Domains=doovate.com
EOF

# Habilitar y configurar systemd-resolved
systemctl enable systemd-resolved
systemctl start systemd-resolved
rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl restart systemd-resolved

#Allow 53 & 8081 traffic
ufw allow 53 && ufw allow 53/tcp && ufw allow 8081/tcp
ufw reload

echo "Instalación completada."

