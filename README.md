# 🛡️ OSINT SOC Platform
### Open Source Intelligence Security Operations Center

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://docker.com)
[![Wazuh](https://img.shields.io/badge/Wazuh-4.7-blue)](https://wazuh.com)
[![MISP](https://img.shields.io/badge/MISP-Latest-red)](https://www.misp-project.org)

A fully integrated, open-source SOC platform leveraging OSINT for threat detection, incident response, and security automation.

## 🏗️ Architecture Overview

| Component | Purpose | Port | Documentation |
|-----------|---------|------|---------------|
| **Wazuh** | SIEM/XDR/Endpoint Detection | 443 | [Install Guide](docs/02-wazuh-installation.md) |
| **MISP** | Threat Intelligence Platform | 443 | [Install Guide](docs/03-misp-installation.md) |
| **TheHive** | Case Management | 9000 | [Install Guide](docs/04-thehive-cortex-installation.md) |
| **Cortex** | Observable Analysis | 9001 | [Install Guide](docs/04-thehive-cortex-installation.md) |
| **Shuffle** | SOAR Automation | 3001 | [Install Guide](docs/05-shuffle-installation.md) |
| **OpenCTI** | Cyber Threat Intelligence | 8080 | [Install Guide](docs/06-opencti-installation.md) |

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Ubuntu 22.04 LTS (recommended) or 20.04 LTS
- 16GB RAM minimum (32GB recommended)
- 4 CPU cores minimum
- 100GB free disk space (SSD recommended)
- Internet connection

### Automated Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/osint-soc-platform.git
cd osint-soc-platform

# 2. Install Docker and dependencies
sudo bash scripts/install-docker.sh

# 3. Generate secure secrets
bash scripts/generate-secrets.sh

# 4. Deploy the entire stack
sudo docker compose up -d

# 5. Check health status
bash scripts/health-check.sh
