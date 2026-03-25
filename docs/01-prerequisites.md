# Prerequisites & System Requirements

## Hardware Requirements

| Component | Minimum | Recommended | Production |
|-----------|---------|-------------|------------|
| **CPU** | 4 cores | 8 cores | 16+ cores |
| **RAM** | 16 GB | 32 GB | 64+ GB |
| **Storage** | 100 GB HDD | 200 GB SSD | 500 GB+ NVMe |
| **Network** | 100 Mbps | 1 Gbps | 10 Gbps |

## Software Requirements

- **Operating System**: Ubuntu 22.04 LTS (recommended) or 20.04 LTS
- **Kernel**: Linux 5.15 or newer
- **Docker**: 24.0.0 or newer
- **Docker Compose**: 2.20.0 or newer (plugin)

## Pre-Installation Steps

### 1. System Update

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget jq openssl
