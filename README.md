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


| Service   |    URL     | Default Credentials |
|-----------|------------|---------------------|
| **Wazuh** | https://localhost | admin / (generated) |
| **MISP** | https://localhost | admin@admin.test / admin | 
| **TheHive** | http://localhost:9000 | admin@thehive.local / secret | 
| **Cortex** | http://localhost:9001 | admin / (set on first login) | 
| **Shuffle** | http://localhost:3001 | (create on first login) | 
| **OpenCTI** | http://localhost:8080 | admin@opencti.io / (from .env) | 

# 1. Clone the repository
```bash
git clone https://github.com/yourusername/osint-soc-platform.git
cd osint-soc-platform
```
# 2. Install Docker and dependencies
```bash
sudo bash scripts/install-docker.sh
```
# 3. Generate secure secrets
```bash
bash scripts/generate-secrets.sh
```
# 4. Deploy the entire stack
```bash
sudo docker compose up -d
```
# 5. Check health status
```bash
bash scripts/health-check.sh

```bash
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Wazuh  │───▶│  MISP   │───▶│ Shuffle │───▶│TheHive  │───▶│  Cortex │
│  (SIEM) │    │ (Intel) │    │ (SOAR)  │    │ (Cases) │    │(Analysis)│
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │              ▲              ▲              │
     │              │              │              │              │
     └──────────────┴──────────────┴──────────────┴──────────────┘
                                 │
                          ┌─────────────┐
                          │   OpenCTI   │
                          │  (MITRE ATT&CK) │
                          └─────────────┘

```
### Automated Installation

🛠️ Post-Installation Configuration
After installation, configure these essential integrations:

    Enable OSINT Feeds in MISP (CIRCL, Abuse.ch, Botvrij)
    Connect TheHive to Cortex for automated analysis
    Link TheHive to MISP for threat intelligence lookup
    Configure Shuffle workflows for Wazuh → TheHive automation
    Import MITRE ATT&CK into OpenCTI

See Integration Guide for detailed steps.
🔄 Maintenance

# Update all containers 
```bash 
sudo docker compose pull
sudo docker compose up -d
```
# Backup data
```bash
sudo bash scripts/backup.sh
```
# View logs
```bash
sudo docker compose logs -f [service-name]
```
# Stop all services
```bash
sudo docker compose down
```
🤝 Contributing
Contributions are welcome! Please read our Contributing Guide first.
📄 License
This project is licensed under the GPL-3.0 License - see the LICENSE file.
🙏 Acknowledgments

    Wazuh - Security monitoring
    MISP Project - Threat intelligence
    StrangeBee - TheHive & Cortex
    Shuffle - SOAR platform
    OpenCTI - Cyber threat intelligence
    Filigran - OpenCTI development

⚠️ Security Notice
This platform handles sensitive security data. Before production deployment:

    Change all default passwords
    Enable HTTPS/TLS for all services
    Configure proper firewall rules
    Set up regular backups
    Review Security Hardening Guide
