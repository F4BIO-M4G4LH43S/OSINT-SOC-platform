#!/bin/bash
# Docker and Docker Compose Installation Script for OSINT SOC Platform
# Supports Ubuntu 20.04/22.04 LTS

set -e

echo "=========================================="
echo "Docker Installation for OSINT SOC Platform"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Detect Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
echo "Detected Ubuntu version: $UBUNTU_VERSION"

echo "[1/6] Updating system packages..."
apt-get update && apt-get upgrade -y

echo "[2/6] Installing prerequisites..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    wget \
    jq \
    openssl

echo "[3/6] Adding Docker's official GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[4/6] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[5/6] Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[6/6] Configuring Docker..."
systemctl enable docker
systemctl start docker

# Add current user to docker group if not root
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    echo "Added $SUDO_USER to docker group"
fi

# Verify installation
echo ""
echo "Verifying Docker installation..."
docker --version
docker compose version

# System tuning for Elasticsearch/OpenSearch
echo ""
echo "Applying system tuning for search engines..."
sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf

# Disable swap for OpenSearch/Elasticsearch
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo ""
echo "=========================================="
echo "Docker installation completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Log out and back in for docker group changes to take effect"
echo "2. Run: bash scripts/generate-secrets.sh"
echo "3. Run: sudo docker compose up -d"
echo ""
