# 🛡️ OSINT SOC Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![GitHub release](https://img.shields.io/github/release/YOUR_USERNAME/osint-soc-platform.svg)](https://github.com/YOUR_USERNAME/osint-soc-platform/releases)

> A complete, production-ready Security Operations Center (SOC) platform powered by Open Source Intelligence (OSINT)

![SOC Architecture](docs/images/soc-architecture.png)

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/F4BIO-M4G4LH43S/osint-soc-platform.git
cd osint-soc-platform

# 2. Run the installer
sudo ./install.sh

# 3. Start the platform
cd /opt/osint-soc
./scripts/start.sh

# 4. Verify installation
./scripts/verify-setup.sh
```

**That's it!** Your SOC platform will be running at:
- **Wazuh Dashboard**: http://localhost:5601
- **TheHive**: http://localhost:9000  
- **MISP**: https://localhost:8443
- **OpenCTI**: http://localhost:8080
- **Shuffle**: http://localhost:3001

## 📋 What's Included

This platform integrates industry-leading open-source security tools:

| Component | Purpose | Access URL |
|-----------|---------|------------|
| **Wazuh** | SIEM, XDR, Log Management | http://localhost:5601 |
| **TheHive** | Incident Response Platform | http://localhost:9000 |
| **Cortex** | IOC Analysis Engine | http://localhost:9001 |
| **MISP** | Threat Intelligence Platform | https://localhost:8443 |
| **OpenCTI** | Cyber Threat Intelligence | http://localhost:8080 |
| **Shuffle** | Security Automation (SOAR) | http://localhost:3001 |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        OSINT SOC PLATFORM                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Wazuh      │  │    MISP      │  │   OpenCTI    │           │
│  │   (SIEM)     │  │  (Intel Hub) │  │  (Knowledge) │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                   │
│         └─────────────────┼─────────────────┘                   │
│                           │                                     │
│                    ┌──────▼────────┐                            │
│                    │     Shuffle   │                            │
│                    │     (SOAR)    │                            │
│                    └────────┬──────┘                            │
│                             │                                   │
│         ┌───────────────────┼───────────────────┐               │
│         ▼                   ▼                   ▼               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │    Cortex    │  │   TheHive    │  │  External    │           │
│  │ (Analyzers)  │  │  (Cases/IR)  │  │   APIs       │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **CPU** | 8 cores | 16 cores |
| **RAM** | 16 GB | 32 GB |
| **Disk** | 100 GB SSD | 500 GB NVMe |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| **Network** | 100 Mbps | 1 Gbps |

## 📖 Documentation

- **[Quick Start Guide](QUICKSTART.md)** - Get running in 5 minutes
- **[Installation Guide](docs/INSTALLATION.md)** - Detailed installation steps
- **[OSINT Feeds Setup](docs/OSINT-FEEDS.md)** - Configure threat intelligence
- **[Automation Guide](docs/AUTOMATION.md)** - Set up SOAR workflows
- **[Contributing](CONTRIBUTING.md)** - How to contribute

## 🔧 Installation Methods

### Method 1: Automated Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/F4BIO-M4G4LH43S/osint-soc-platform/main/install.sh | sudo bash
```

### Method 2: Manual Installation

```bash
git clone https://github.com/F4BIO-M4G4LH43S/osint-soc-platform.git
cd osint-soc-platform
sudo ./install.sh
```

### Method 3: Ansible Deployment

```bash
ansible-playbook -i ansible/inventory/production.ini ansible/playbooks/deploy-soc.yml
```

## 🎯 Key Features

### 🔍 Threat Intelligence
- **MISP Integration**: Automatic feed updates from 50+ OSINT sources
- **OpenCTI**: Structured threat intelligence with MITRE ATT&CK mapping
- **IOC Matching**: Real-time detection using Wazuh CDB lists

### 🚨 Security Monitoring
- **Wazuh SIEM**: Log analysis, file integrity monitoring, vulnerability detection
- **Real-time Alerts**: Correlation of security events with threat intel
- **Compliance**: PCI DSS, GDPR, HIPAA, NIST 800-53 support

### 🎫 Incident Response
- **TheHive**: Case management with customizable workflows
- **Cortex**: Automated IOC analysis (VirusTotal, AbuseIPDB, etc.)
- **Collaboration**: Multi-tenant with role-based access control

### 🤖 Automation
- **Shuffle SOAR**: Visual workflow builder
- **Pre-built Workflows**: Phishing response, IOC enrichment, threat hunting
- **API Integration**: Connect with 100+ security tools

## 🌐 Default Credentials

**⚠️ IMPORTANT: Change these immediately after first login!**

| Service | Username | Password |
|---------|----------|----------|
| Wazuh Dashboard | `admin` | `SecretPassword` |
| TheHive | `admin@thehive.local` | `secret` |
| MISP | `admin@admin.test` | `admin` |
| OpenCTI | `admin@opencti.local` | `changeme` |

## 🛠️ Management Commands

```bash
# Start all services
cd /opt/osint-soc && ./scripts/start.sh

# Stop all services
./scripts/stop.sh

# Check health
./scripts/health-check.sh

# Verify setup
./scripts/verify-setup.sh

# Backup data
./scripts/backup.sh

# Update OSINT feeds
./scripts/update-osint-feeds.sh
```

## 🐛 Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose -f docker/docker-compose.infra.yml logs
docker-compose -f docker/docker-compose.security.yml logs

# Reset everything (WARNING: deletes all data)
./scripts/stop.sh
docker volume prune -f
./scripts/start.sh
```

### Out of memory
```bash
# Add swap
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Port conflicts
Edit `docker/docker-compose.*.yml` and change port mappings:
```yaml
ports:
  - "5602:5601"  # Use 5602 instead of 5601
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- [Wazuh](https://wazuh.com/) - Security monitoring
- [MISP Project](https://www.misp-project.org/) - Threat intelligence
- [TheHive Project](https://thehive-project.org/) - Incident response
- [OpenCTI](https://www.opencti.io/) - Cyber threat intelligence
- [Shuffle](https://shuffler.io/) - Security automation

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/F4BIO-M4G4LH43S/osint-soc-platform/issues)
- **Discussions**: [Ask questions or share ideas](https://github.com/F4BIO-M4G4LH43S/osint-soc-platform/discussions)
- **Documentation**: [Full documentation](https://github.com/F4BIO-M4G4LH43S/osint-soc-platform/wiki)
---

**⚠️ Security Notice**: This platform handles sensitive security data. Ensure proper network isolation, access controls, and encryption before production deployment.
