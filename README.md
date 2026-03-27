# 🛡️ OSINT SOC Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![GitHub release](https://img.shields.io/github/release/YOUR_USERNAME/osint-soc-platform.svg)](https://github.com/YOUR_USERNAME/osint-soc-platform/releases)

> A complete, production-ready Security Operations Center (SOC) platform powered by Open Source Intelligence (OSINT)

![SOC Architecture](docs/images/soc-architecture.png)

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/osint-soc-platform.git
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
│                        OSINT SOC PLATFORM                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Wazuh      │  │    MISP      │  │   OpenCTI    │           │
│  │   (SIEM)     │  │  (Intel Hub) │  │  (Knowledge) │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                  │
│         └─────────────────┼─────────────────┘                  │
│                           │                                      │
│                    ┌────────▼────────┐                           │
│                    │     Shuffle     │                           │
│                    │     (SOAR)      │                           │
│                    └────────┬────────┘                           │
│                             │                                    │
│         ┌───────────────────┼───────────────────┐                │
│         ▼                   ▼                   ▼                │
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
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/osint-soc-platform/main/install.sh | sudo bash
```

### Method 2: Manual Installation

```bash
git clone https://github.com/YOUR_USERNAME/osint-soc-platform.git
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

- **GitHub Issues**: [Report bugs or request features](https://github.com/YOUR_USERNAME/osint-soc-platform/issues)
- **Discussions**: [Ask questions or share ideas](https://github.com/YOUR_USERNAME/osint-soc-platform/discussions)
- **Documentation**: [Full documentation](https://github.com/YOUR_USERNAME/osint-soc-platform/wiki)


# Create a final summary and checklist
final_summary = """
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║           🛡️  OSINT SOC PLATFORM - COMPLETE GITHUB REPOSITORY             ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

📦 REPOSITORY LOCATION: /mnt/kimi/output/osint-soc-platform

═══════════════════════════════════════════════════════════════════════════
✅ FILES CREATED (Ready for GitHub)
═══════════════════════════════════════════════════════════════════════════

📄 CORE FILES:
   ✓ README.md              - Main documentation with badges and quick start
   ✓ QUICKSTART.md          - 5-minute deployment guide
   ✓ DEPLOYMENT.md          - Complete GitHub + server deployment guide
   ✓ CONTRIBUTING.md        - Contribution guidelines
   ✓ LICENSE                - MIT License
   ✓ .gitignore            - Git ignore patterns
   ✓ .env.example          - Environment configuration template

🔧 INSTALLATION:
   ✓ install.sh            - Automated installation script (executable)
   ✓ scripts/start.sh      - Start all services
   ✓ scripts/stop.sh       - Stop all services
   ✓ scripts/health-check.sh    - Check service health
   ✓ scripts/verify-setup.sh    - Verify complete setup
   ✓ scripts/backup.sh          - Backup all data
   ✓ scripts/update-osint-feeds.sh  - Update MISP feeds
   ✓ scripts/update-wazuh-cdb.sh    - Update Wazuh CDB lists

🐳 DOCKER COMPOSE:
   ✓ docker/docker-compose.infra.yml      - Databases & message queues
   ✓ docker/docker-compose.security.yml   - Wazuh, TheHive, Cortex
   ✓ docker/docker-compose.osint.yml      - MISP, OpenCTI, Shuffle
   ✓ docker/docker-compose.override.yml   - Development overrides

⚙️ CONFIGURATIONS:
   ✓ configs/wazuh/ossec.conf            - Wazuh manager config
   ✓ configs/wazuh/local_rules.xml       - Custom detection rules
   ✓ configs/thehive/application.conf    - TheHive configuration
   ✓ configs/cortex/application.conf     - Cortex configuration
   ✓ configs/misp/config.php             - MISP configuration
   ✓ configs/mysql/misp.cnf              - MySQL optimization
   ✓ configs/nginx/nginx.conf            - Nginx main config
   ✓ configs/nginx/sites/*.conf          - Site configurations

📚 DOCUMENTATION:
   ✓ docs/INSTALLATION.md    - Detailed installation steps
   ✓ docs/OSINT-FEEDS.md     - Threat intelligence configuration
   ✓ docs/AUTOMATION.md      - SOAR workflow automation

🔧 ANSIBLE:
   ✓ ansible/playbooks/deploy-soc.yml    - Deployment playbook
   ✓ ansible/inventory/example.ini       - Inventory example

⚙️ GITHUB:
   ✓ .github/workflows/ci.yml            - CI/CD pipeline
   ✓ .github/ISSUE_TEMPLATE/bug_report.md
   ✓ .github/ISSUE_TEMPLATE/feature_request.md

═══════════════════════════════════════════════════════════════════════════
🚀 DEPLOYMENT STEPS (Copy & Paste Ready)
═══════════════════════════════════════════════════════════════════════════

STEP 1: CREATE GITHUB REPO
───────────────────────────
cd /mnt/kimi/output/osint-soc-platform
git init
git add .
git commit -m "Initial commit: OSINT SOC Platform v1.0"

# Go to https://github.com/new and create repository
# Then:
git remote add origin https://github.com/YOUR_USERNAME/osint-soc-platform.git
git branch -M main
git push -u origin main

STEP 2: DEPLOY ON SERVER
───────────────────────────
# Option A: One-line install (fastest)
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/osint-soc-platform/main/install.sh | sudo bash

# Option B: Clone and install
git clone https://github.com/YOUR_USERNAME/osint-soc-platform.git
cd osint-soc-platform
sudo ./install.sh

STEP 3: CONFIGURE & START
───────────────────────────
# Edit environment
sudo nano /opt/osint-soc/.env

# Start services
sudo /opt/osint-soc/scripts/start.sh

# Verify
sudo /opt/osint-soc/scripts/verify-setup.sh

═══════════════════════════════════════════════════════════════════════════
🔗 ACCESS URLs (After Deployment)
═══════════════════════════════════════════════════════════════════════════

Service            URL                           Default Credentials
───────────────────────────────────────────────────────────────────────────
Wazuh Dashboard    http://localhost:5601         admin / SecretPassword
TheHive            http://localhost:9000         admin@thehive.local / secret
Cortex             http://localhost:9001         Create on first login
MISP               https://localhost:8443        admin@admin.test / admin
OpenCTI            http://localhost:8080         admin@opencti.local / changeme
Shuffle            http://localhost:3001         Create on first login

═══════════════════════════════════════════════════════════════════════════
⚠️  IMPORTANT SECURITY NOTES
═══════════════════════════════════════════════════════════════════════════

1. CHANGE ALL DEFAULT PASSWORDS IMMEDIATELY
2. Configure firewall rules (ports listed in DEPLOYMENT.md)
3. Set up SSL/TLS for production (Let's Encrypt recommended)
4. Regular backups: sudo /opt/osint-soc/scripts/backup.sh
5. Keep system updated: sudo apt update && sudo apt upgrade

═══════════════════════════════════════════════════════════════════════════
📞 SUPPORT & DOCUMENTATION
═══════════════════════════════════════════════════════════════════════════

📖 Full Documentation: See docs/ directory
🐛 Issues: Create GitHub issue
💬 Discussions: Use GitHub Discussions
🤝 Contributing: See CONTRIBUTING.md

═══════════════════════════════════════════════════════════════════════════

🎉 YOUR OSINT SOC PLATFORM IS READY TO DEPLOY!

Next steps:
1. Upload to GitHub (see STEP 1 above)
2. Deploy on your server (see STEP 2 above)
3. Configure OSINT feeds (see docs/OSINT-FEEDS.md)
4. Set up automation (see docs/AUTOMATION.md)

═══════════════════════════════════════════════════════════════════════════
"""
---

**⚠️ Security Notice**: This platform handles sensitive security data. Ensure proper network isolation, access controls, and encryption before production deployment.

**🚀 Ready to deploy?** Start with the [Quick Start Guide](QUICKSTART.md)!
'''

with open(f"{base_dir}/README.md", "w") as f:
    f.write(readme_update)

print("✅ README.md updated with comprehensive instructions")
